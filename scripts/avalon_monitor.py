#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🔧 Avalon Nano 3 - Мониторинг и Управление
Версия: 1.0
Дата: 11 марта 2026

Функции:
- Мониторинг статуса майнера (демоны, пулы, статистика)
- Управление разгоном (частота, вольтаж)
- Привилегированные команды API
- Веб-интерфейс с расширенными данными
"""

import socket
import json
import time
import threading
from http.server import HTTPServer, SimpleHTTPRequestHandler
from datetime import datetime
import urllib.parse
import os

# ============================================================================
# КОНФИГУРАЦИЯ
# ============================================================================
CONFIG = {
    'miner_ip': '192.168.31.133',      # IP Avalon Nano 3
    'api_port': 4028,                   # Порт cgminer API
    'web_port': 8080,                   # Порт веб-интерфейса
    'poll_interval': 5,                 # Интервал опроса (сек)
    'privileged_cookie': 'ff0000ff4813494d137e1631bba301d5',  # Cookie для привилегированного доступа
}

# ============================================================================
# CGMINER API КОМАНДЫ
# ============================================================================
class CgminerAPI:
    """Класс для работы с CGMiner API Avalon Nano 3"""
    
    def __init__(self, host, port):
        self.host = host
        self.port = port
        self.socket = None
        
    def connect(self):
        """Подключение к API"""
        try:
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.socket.settimeout(5)
            self.socket.connect((self.host, self.port))
            return True
        except Exception as e:
            print(f"❌ Ошибка подключения: {e}")
            return False
    
    def disconnect(self):
        """Отключение от API"""
        if self.socket:
            self.socket.close()
            self.socket = None
    
    def send_command(self, command, arg=None, privileged=False):
        """Отправка команды API (JSON протокол CGMiner)"""
        try:
            # Подключаемся
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(5)
            sock.connect((self.host, self.port))

            # Формируем JSON команду
            if privileged:
                cmd_data = {"command": "privileged", "arg": f"{command}={arg}" if arg else command}
            else:
                cmd_data = {"command": command}
                if arg:
                    cmd_data["arg"] = arg

            # Отправляем
            cmd_json = json.dumps(cmd_data) + "\n"
            sock.sendall(cmd_json.encode())

            # Получаем ответ
            response = b""
            sock.settimeout(3)
            while True:
                try:
                    chunk = sock.recv(4096)
                    if not chunk:
                        break
                    response += chunk
                    if len(chunk) < 4096:
                        break
                except socket.timeout:
                    break

            sock.close()

            # Очищаем от бинарного мусора (как strings в bash)
            response_str = ''.join(chr(b) for b in response if 32 <= b < 127 or b in (9, 10, 13))

            # Парсим JSON
            try:
                # Ищем JSON в ответе
                start = response_str.find('{')
                end = response_str.rfind('}') + 1
                if start >= 0 and end > start:
                    json_str = response_str[start:end]
                    return json.loads(json_str)
            except:
                pass

            return {"raw": response_str, "error": "Failed to parse JSON"}

        except Exception as e:
            print(f"❌ Ошибка команды {command}: {e}")
            return None

    def _parse_cgminer_response(self, response, command):
        """Парсинг ответа CGMiner API"""
        if not response:
            return {"error": "Empty response"}

        # Разделяем по |
        parts = response.split('|')

        result = {
            "command": command,
            "raw": response,
            "status": []
        }

        # Парсим статусы
        for part in parts:
            part = part.strip()
            if part.startswith('STATUS='):
                result["status"].append(part.replace('STATUS=', ''))
            elif part.startswith('S='):
                result["status"].append(part.replace('S=', ''))
            elif '=' in part:
                key, value = part.split('=', 1)
                result[key] = value

        # Для devs/summary/pools парсим данные
        if 'DEVS=' in response or 'DEV' in response:
            result["type"] = "devs"
        elif 'SUMMARY=' in response:
            result["type"] = "summary"
        elif 'POOLS=' in response:
            result["type"] = "pools"

        return result
    
    # ========== МОНИТОРИНГ (Read-only) ==========
    def get_version(self):
        """Версия CGMiner"""
        return self.send_command("version")
    
    def get_summary(self):
        """Общая сводка"""
        return self.send_command("summary")
    
    def get_devs(self):
        """Статус всех устройств (ASIC)"""
        return self.send_command("devs")
    
    def get_devdetails(self):
        """Детали устройств"""
        return self.send_command("devdetails")
    
    def get_pools(self):
        """Статус пулов"""
        return self.send_command("pools")
    
    def get_stats(self):
        """Расширенная статистика"""
        return self.send_command("stats")
    
    def get_config(self):
        """Текущая конфигурация"""
        return self.send_command("config")
    
    # ========== УПРАВЛЕНИЕ (Privileged) ==========
    def privileged_ascset(self, miner_id, freq, voltage):
        """
        Установка параметров ASIC
        :param miner_id: ID майнера (0-9)
        :param freq: Частота в MHz (25-800)
        :param voltage: Напряжение в mV (1150-1450)
        """
        arg = f"{miner_id},{freq},{voltage}"
        return self.send_command("ascset", arg=arg, privileged=True)
    
    def privileged_setconfig(self, name, value):
        """Установка конфигурации"""
        arg = f"{name},{value}"
        return self.send_command("setconfig", arg=arg, privileged=True)
    
    def privileged_addpool(self, url, user, password):
        """Добавить пул"""
        arg = f"{url},{user},{password}"
        return self.send_command("addpool", arg=arg, privileged=True)
    
    def privileged_switchpool(self, pool_id):
        """Переключить пул"""
        return self.send_command("switchpool", arg=str(pool_id), privileged=True)
    
    def privileged_restart(self):
        """Перезапуск cgminer"""
        return self.send_command("restart", privileged=True)
    
    def privileged_save(self, filename=None):
        """Сохранить конфигурацию"""
        return self.send_command("save", arg=filename, privileged=True)
    
    # ========== СПЕЦИАЛЬНЫЕ КОМАНДЫ AVALON ==========
    def set_work_level(self, level):
        """
        Установка уровня работы
        0 = Low (Обогреватель)
        1 = Medium
        2 = High (Майнинг)
        """
        return self.privileged_setconfig("work_level", level)
    
    def set_frequency(self, freq):
        """Установка частоты для всех чипов"""
        results = []
        for i in range(10):  # 10 чипов в Avalon Nano 3
            result = self.privileged_ascset(i, freq, 1300)  # 1300mV по умолчанию
            results.append(result)
        return results
    
    def set_voltage(self, voltage):
        """Установка напряжения для всех чипов"""
        results = []
        for i in range(10):
            result = self.privileged_ascset(i, 700, voltage)  # 700MHz по умолчанию
            results.append(result)
        return results
    
    def full_overclock(self, freq, voltage):
        """Полный разгон: частота + напряжение"""
        results = []
        for i in range(10):
            result = self.privileged_ascset(i, freq, voltage)
            results.append(result)
        return results


# ============================================================================
# МЕНЕДЖЕР МАЙНЕРА
# ============================================================================
class MinerManager:
    """Менеджер для сбора и хранения данных майнера"""
    
    def __init__(self, config):
        self.config = config
        self.api = CgminerAPI(config['miner_ip'], config['api_port'])
        self.data = {
            'summary': {},
            'devs': [],
            'pools': [],
            'stats': {},
            'last_update': None,
            'status': 'disconnected'
        }
        self.running = False
        self.thread = None
    
    def start_polling(self):
        """Запуск опроса майнера"""
        self.running = True
        self.thread = threading.Thread(target=self._poll_loop, daemon=True)
        self.thread.start()
        print(f"✅ Опрос майнера запущен ({self.config['poll_interval']}с)")
    
    def stop_polling(self):
        """Остановка опроса"""
        self.running = False
        if self.thread:
            self.thread.join()
        self.api.disconnect()
        print("⏹️ Опрос майнера остановлен")
    
    def _poll_loop(self):
        """Цикл опроса (текстовый протокол)"""
        while self.running:
            try:
                # Получаем данные (каждая команда переподключается)
                summary = self.api.get_summary()
                devs = self.api.get_devs()
                pools = self.api.get_pools()
                stats = self.api.get_stats()

                # Сохраняем в data
                self.data['summary'] = summary
                self.data['devs'] = devs
                self.data['pools'] = pools
                self.data['stats'] = stats
                self.data['last_update'] = datetime.now().isoformat()
                self.data['status'] = 'connected'

            except Exception as e:
                print(f"⚠️ Ошибка опроса: {e}")
                self.data['status'] = 'error'

            time.sleep(self.config['poll_interval'])
    
    def execute_command(self, cmd_name, **kwargs):
        """Выполнение команды управления"""
        if not self.api.socket:
            self.api.connect()

        if hasattr(self.api, cmd_name):
            method = getattr(self.api, cmd_name)
            return method(**kwargs)
        return None
    
    def get_data(self):
        """Получение текущих данных"""
        return self.data


# ============================================================================
# ВЕБ-ИНТЕРФЕЙС
# ============================================================================
class WebInterfaceHandler(SimpleHTTPRequestHandler):
    """Обработчик веб-интерфейса"""
    
    miner_manager = None
    
    def do_GET(self):
        """Обработка GET запросов"""
        parsed = urllib.parse.urlparse(self.path)
        
        if parsed.path == '/':
            self.send_html(self._generate_main_page())
        elif parsed.path == '/api/data':
            self.send_json(self.miner_manager.get_data())
        elif parsed.path == '/api/summary':
            self.send_json(self.miner_manager.get_data()['summary'])
        elif parsed.path == '/api/devs':
            self.send_json(self.miner_manager.get_data()['devs'])
        elif parsed.path == '/api/pools':
            self.send_json(self.miner_manager.get_data()['pools'])
        else:
            super().do_GET()
    
    def do_POST(self):
        """Обработка POST запросов"""
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        data = json.loads(post_data.decode('utf-8'))

        cmd_name = data.get('command')
        params = data.get('params', {})

        # Выполняем команду
        result = self.miner_manager.execute_command(cmd_name, **params)

        self.send_json({
            'command': cmd_name,
            'result': result,
            'timestamp': datetime.now().isoformat()
        })
    
    def send_json(self, data):
        """Отправка JSON ответа"""
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(json.dumps(data, indent=2).encode())
    
    def send_html(self, html):
        """Отправка HTML"""
        self.send_response(200)
        self.send_header('Content-Type', 'text/html; charset=utf-8')
        self.end_headers()
        self.wfile.write(html.encode('utf-8'))
    
    def _generate_main_page(self):
        """Генерация главной страницы"""
        return '''<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🔧 Avalon Nano 3 - Мониторинг и Управление</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
            color: #fff;
            min-height: 100vh;
            padding: 20px;
        }
        .container { max-width: 1400px; margin: 0 auto; }
        h1 {
            text-align: center;
            margin-bottom: 30px;
            font-size: 2.5em;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        .status-bar {
            background: rgba(255,255,255,0.1);
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .status-indicator {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .status-dot {
            width: 15px;
            height: 15px;
            border-radius: 50%;
            animation: pulse 2s infinite;
        }
        .status-dot.connected { background: #4CAF50; }
        .status-dot.disconnected { background: #f44336; }
        .status-dot.error { background: #ff9800; }
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }
        .card {
            background: rgba(255,255,255,0.1);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 20px;
            border: 1px solid rgba(255,255,255,0.2);
        }
        .card h2 {
            margin-bottom: 15px;
            font-size: 1.3em;
            border-bottom: 2px solid rgba(255,255,255,0.3);
            padding-bottom: 10px;
        }
        .metric {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }
        .metric:last-child { border-bottom: none; }
        .metric-label { opacity: 0.8; }
        .metric-value { font-weight: bold; color: #4FC3F7; }
        .device-card {
            background: rgba(0,0,0,0.2);
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 10px;
        }
        .device-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
        }
        .temp-good { color: #4CAF50; }
        .temp-warn { color: #ff9800; }
        .temp-bad { color: #f44336; }
        .control-panel {
            background: rgba(0,0,0,0.3);
            border-radius: 15px;
            padding: 20px;
            margin-top: 20px;
        }
        .control-group {
            margin-bottom: 20px;
        }
        .control-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
        }
        input[type="range"], input[type="number"], select {
            width: 100%;
            padding: 10px;
            border-radius: 5px;
            border: none;
            background: rgba(255,255,255,0.2);
            color: #fff;
            font-size: 1em;
        }
        input[type="range"]::-webkit-slider-thumb {
            -webkit-appearance: none;
            width: 20px;
            height: 20px;
            background: #4FC3F7;
            border-radius: 50%;
            cursor: pointer;
        }
        button {
            background: linear-gradient(135deg, #4FC3F7 0%, #2196F3 100%);
            color: #fff;
            border: none;
            padding: 12px 25px;
            border-radius: 8px;
            font-size: 1em;
            cursor: pointer;
            transition: transform 0.2s;
            margin: 5px;
        }
        button:hover {
            transform: scale(1.05);
        }
        button.danger {
            background: linear-gradient(135deg, #f44336 0%, #d32f2f 100%);
        }
        button.success {
            background: linear-gradient(135deg, #4CAF50 0%, #388E3C 100%);
        }
        .button-group {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-top: 15px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }
        th, td {
            padding: 10px;
            text-align: left;
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }
        th {
            background: rgba(0,0,0,0.3);
            font-weight: bold;
        }
        tr:hover {
            background: rgba(255,255,255,0.05);
        }
        .log-container {
            background: rgba(0,0,0,0.3);
            border-radius: 10px;
            padding: 15px;
            max-height: 300px;
            overflow-y: auto;
            font-family: 'Courier New', monospace;
            font-size: 0.9em;
        }
        .log-entry {
            padding: 5px 0;
            border-bottom: 1px solid rgba(255,255,255,0.05);
        }
        .preset-buttons {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 10px;
            margin-top: 10px;
        }
        .refresh-btn {
            background: rgba(255,255,255,0.2);
            padding: 8px 15px;
            border-radius: 5px;
            cursor: pointer;
            transition: background 0.3s;
        }
        .refresh-btn:hover {
            background: rgba(255,255,255,0.3);
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔧 Avalon Nano 3<br><small style="font-size: 0.5em">Мониторинг и Управление</small></h1>
        
        <!-- Статус бар -->
        <div class="status-bar">
            <div class="status-indicator">
                <div class="status-dot" id="statusDot"></div>
                <span id="statusText">Подключение...</span>
            </div>
            <div>
                Последнее обновление: <span id="lastUpdate">-</span>
                <span class="refresh-btn" onclick="refreshData()">🔄 Обновить</span>
            </div>
        </div>
        
        <!-- Основные метрики -->
        <div class="grid">
            <div class="card">
                <h2>📊 Общая статистика</h2>
                <div id="summaryMetrics">Загрузка...</div>
            </div>
            
            <div class="card">
                <h2>🏊 Пулы</h2>
                <div id="poolsInfo">Загрузка...</div>
            </div>
        </div>
        
        <!-- Устройства -->
        <div class="card">
            <h2>⚡ ASIC Чипы (10)</h2>
            <div id="devicesList">Загрузка...</div>
        </div>
        
        <!-- Панель управления -->
        <div class="control-panel">
            <h2>🎛️ Управление разгоном</h2>
            
            <div class="control-group">
                <label>Частота (MHz): <span id="freqValue">700</span></label>
                <input type="range" id="freqSlider" min="25" max="800" step="25" value="700"
                       oninput="document.getElementById('freqValue').textContent = this.value">
            </div>
            
            <div class="control-group">
                <label>Напряжение (mV): <span id="voltValue">1300</span></label>
                <input type="range" id="voltSlider" min="1150" max="1450" step="10" value="1300"
                       oninput="document.getElementById('voltValue').textContent = this.value">
            </div>
            
            <div class="control-group">
                <label>Work Level:</label>
                <select id="workLevel">
                    <option value="0">0 - Low (Обогреватель)</option>
                    <option value="1">1 - Medium</option>
                    <option value="2" selected>2 - High (Майнинг)</option>
                </select>
            </div>
            
            <div class="button-group">
                <button class="success" onclick="applyOverclock()">⚡ Применить разгон</button>
                <button onclick="setWorkLevel()">🔧 Установить Work Level</button>
                <button onclick="saveConfig()">💾 Сохранить конфиг</button>
                <button class="danger" onclick="restartMiner()">🔄 Перезапуск</button>
            </div>
            
            <h3 style="margin-top: 20px;">📋 Пресеты разгона:</h3>
            <div class="preset-buttons">
                <button onclick="applyPreset(500, 1200)">🐢 Сток (500MHz/1200mV)</button>
                <button onclick="applyPreset(650, 1300)">⚡ Средний (650MHz/1300mV)</button>
                <button onclick="applyPreset(750, 1350)">🚀 Быстрый (750MHz/1350mV)</button>
                <button onclick="applyPreset(800, 1450)" class="danger">🔥 МАКС (800MHz/1450mV)</button>
            </div>
        </div>
        
        <!-- Привилегированные команды -->
        <div class="control-panel">
            <h2>🔐 Привилегированные команды</h2>
            <div class="button-group">
                <button onclick="sendPrivileged('privileged')">Проверить доступ</button>
                <button onclick="sendPrivileged('devs')">Получить DEVs</button>
                <button onclick="sendPrivileged('stats')">Получить Stats</button>
                <button onclick="sendPrivileged('config')">Получить Config</button>
            </div>
        </div>
        
        <!-- Лог событий -->
        <div class="card" style="margin-top: 20px;">
            <h2>📝 Лог событий</h2>
            <div class="log-container" id="eventLog"></div>
        </div>
    </div>
    
    <script>
        let minerData = {};
        
        // Автообновление
        setInterval(refreshData, 5000);
        refreshData();
        
        async function refreshData() {
            try {
                const response = await fetch('/api/data');
                minerData = await response.json();
                updateUI(minerData);
            } catch (e) {
                logEvent('❌ Ошибка получения данных: ' + e.message);
            }
        }
        
        function updateUI(data) {
            // Статус
            const statusDot = document.getElementById('statusDot');
            const statusText = document.getElementById('statusText');
            statusDot.className = 'status-dot ' + (data.status || 'disconnected');
            statusText.textContent = data.status === 'connected' ? '✅ Подключено' : 
                                     data.status === 'error' ? '⚠️ Ошибка' : '❌ Отключено';
            
            // Последнее обновление
            document.getElementById('lastUpdate').textContent = 
                data.last_update ? new Date(data.last_update).toLocaleTimeString() : '-';
            
            // Summary метрики
            const summary = data.summary || {};
            document.getElementById('summaryMetrics').innerHTML = `
                <div class="metric"><span class="metric-label">Время работы:</span> <span class="metric-value">${formatSeconds(summary.Elapsed)}</span></div>
                <div class="metric"><span class="metric-label">Хешрейт (AVG):</span> <span class="metric-value">${summary['MHS av'] || 0} GH/s</span></div>
                <div class="metric"><span class="metric-label">Принято:</span> <span class="metric-value">${summary.Accepted || 0}</span></div>
                <div class="metric"><span class="metric-label">Отклонено:</span> <span class="metric-value">${summary.Rejected || 0}</span></div>
                <div class="metric"><span class="metric-label">Ошибки HW:</span> <span class="metric-value">${summary['Hardware Errors'] || 0}</span></div>
                <div class="metric"><span class="metric-label">Эффективность:</span> <span class="metric-value">${calcEfficiency(summary)}</span></div>
            `;
            
            // Пулы
            const pools = data.pools || [];
            if (Array.isArray(pools) && pools.length > 0) {
                document.getElementById('poolsInfo').innerHTML = pools.map((pool, i) => `
                    <div class="metric">
                        <span class="metric-label">Пул ${i}: ${pool.Status || 'N/A'}</span>
                        <span class="metric-value">${pool.URL ? pool.URL.split(':')[1] : 'N/A'}</span>
                    </div>
                `).join('');
            } else {
                document.getElementById('poolsInfo').innerHTML = '<div class="metric">Нет данных о пулах</div>';
            }
            
            // Устройства
            const devs = data.devs || [];
            if (Array.isArray(devs) && devs.length > 0) {
                document.getElementById('devicesList').innerHTML = devs.map((dev, i) => {
                    const temp = dev.Temperature || 0;
                    const tempClass = temp < 60 ? 'temp-good' : temp < 80 ? 'temp-warn' : 'temp-bad';
                    return `
                        <div class="device-card">
                            <div class="device-header">
                                <strong>Чип #${dev.DEVES || i}</strong>
                                <span class="${tempClass}">🌡️ ${temp}°C</span>
                            </div>
                            <div class="metric"><span class="metric-label">Хешрейт:</span> <span class="metric-value">${dev['MHS av'] || 0} GH/s</span></div>
                            <div class="metric"><span class="metric-label">Принято:</span> <span class="metric-value">${dev.Accepted || 0}</span></div>
                            <div class="metric"><span class="metric-label">Ошибки:</span> <span class="metric-value">${dev['Hardware Errors'] || 0}</span></div>
                        </div>
                    `;
                }).join('');
            } else {
                document.getElementById('devicesList').innerHTML = '<div class="metric">Нет данных об устройствах</div>';
            }
        }
        
        function formatSeconds(sec) {
            if (!sec) return '0с';
            const h = Math.floor(sec / 3600);
            const m = Math.floor((sec % 3600) / 60);
            const s = sec % 60;
            return `${h}ч ${m}м ${s}с`;
        }
        
        function calcEfficiency(summary) {
            const acc = summary.Accepted || 0;
            const rej = summary.Rejected || 0;
            const total = acc + rej;
            if (total === 0) return '0%';
            return ((acc / total) * 100).toFixed(2) + '%';
        }
        
        async function applyOverclock() {
            const freq = parseInt(document.getElementById('freqSlider').value);
            const volt = parseInt(document.getElementById('voltSlider').value);
            logEvent(`⚡ Применение разгона: ${freq}MHz / ${volt}mV`);
            
            const response = await fetch('/api/data', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({
                    command: 'full_overclock',
                    params: {freq: freq, voltage: volt}
                })
            });
            const result = await response.json();
            logEvent('✅ ' + JSON.stringify(result));
        }
        
        function applyPreset(freq, volt) {
            document.getElementById('freqSlider').value = freq;
            document.getElementById('voltValue').textContent = freq;
            document.getElementById('voltSlider').value = volt;
            document.getElementById('voltValue').textContent = volt;
            logEvent(`📋 Пресет применён: ${freq}MHz / ${volt}mV`);
        }
        
        async function setWorkLevel() {
            const level = document.getElementById('workLevel').value;
            logEvent(`🔧 Установка Work Level: ${level}`);
            
            const response = await fetch('/api/data', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({
                    command: 'set_work_level',
                    params: {level: level}
                })
            });
            const result = await response.json();
            logEvent('✅ ' + JSON.stringify(result));
        }
        
        async function saveConfig() {
            logEvent('💾 Сохранение конфигурации...');
            const response = await fetch('/api/data', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({command: 'privileged_save'})
            });
            const result = await response.json();
            logEvent('✅ ' + JSON.stringify(result));
        }
        
        async function restartMiner() {
            if (!confirm('⚠️ Вы уверены? Майнер будет перезапущен!')) return;
            logEvent('🔄 Перезапуск майнера...');
            const response = await fetch('/api/data', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({command: 'privileged_restart'})
            });
            const result = await response.json();
            logEvent('✅ ' + JSON.stringify(result));
        }
        
        async function sendPrivileged(cmd) {
            logEvent(`🔐 Отправка команды: ${cmd}`);
            const response = await fetch('/api/data', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({command: 'send_command', params: {command: cmd, privileged: true}})
            });
            const result = await response.json();
            logEvent('✅ ' + JSON.stringify(result));
        }
        
        function logEvent(message) {
            const log = document.getElementById('eventLog');
            const time = new Date().toLocaleTimeString();
            log.innerHTML = `<div class="log-entry">[${time}] ${message}</div>` + log.innerHTML;
        }
    </script>
</body>
</html>'''


# ============================================================================
# ЗАПУСК
# ============================================================================
def main():
    """Главная функция запуска"""
    print("=" * 60)
    print("🔧 Avalon Nano 3 - Мониторинг и Управление")
    print("=" * 60)
    print(f"📍 IP майнера: {CONFIG['miner_ip']}:{CONFIG['api_port']}")
    print(f"🌐 Веб-интерфейс: http://localhost:{CONFIG['web_port']}")
    print("=" * 60)
    
    # Создаём менеджер майнера
    miner_manager = MinerManager(CONFIG)
    
    # Передаём менеджер в веб-обработчик
    WebInterfaceHandler.miner_manager = miner_manager
    
    # Запускаем опрос
    miner_manager.start_polling()
    
    # Запускаем веб-сервер
    server = HTTPServer(('0.0.0.0', CONFIG['web_port']), WebInterfaceHandler)
    print(f"✅ Веб-сервер запущен на порту {CONFIG['web_port']}")
    print("🎯 Откройте в браузере: http://localhost:" + str(CONFIG['web_port']))
    print("📋 Для выхода нажмите Ctrl+C")
    print("=" * 60)
    
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n⏹️ Остановка...")
        miner_manager.stop_polling()
        server.shutdown()
        print("✅ Работа завершена")


if __name__ == '__main__':
    main()
