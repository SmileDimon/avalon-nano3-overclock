# 📘 Avalon Nano 3 - Полная документация API команд

> **Версия:** 1.0.0
> **Дата:** 2026-03-11
> **Прошивка:** 2025061101
> **API:** cgminer 4.11.1

---

## 📡 Подключение к API

**Порт:** `4028`
**Протокол:** JSON over TCP
**Формат:** `{"command":"<cmd>","arg":"<arg>"}`

### Пример подключения:

```bash
echo '{"command":"version"}' | nc -w 3 192.168.31.133 4028 | strings
```

### Python пример:

```python
import socket

def send_command(ip, port, command, arg=""):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((ip, port))
    msg = f'{{"command":"{command}","arg":"{arg}"}}\x00'
    sock.send(msg.encode())
    response = sock.recv(4096).decode()
    sock.close()
    return response

# Использование
response = send_command("192.168.31.133", 4028, "version")
print(response)
```

---

## 📋 Все API команды

### Основные команды

| Команда | Описание | Аргументы | Пример |
|---------|----------|-----------|--------|
| `version` | Версия API | Нет | `{"command":"version"}` |
| `help` | Список команд | Нет | `{"command":"help"}` |
| `summary` | Общая статистика | Нет | `{"command":"summary"}` |
| `devs` | Статистика устройств | Нет | `{"command":"devs"}` |
| `edevs` | Расширенная статистика | Нет | `{"command":"edevs"}` |
| `pools` | Информация о пулах | Нет | `{"command":"pools"}` |
| `config` | Конфигурация | Нет | `{"command":"config"}` |

---

### Команды управления ASIC

| Команда | Описание | Аргументы | Пример |
|---------|----------|-----------|--------|
| `ascset` | Установка параметров ASIC | `<asic_id>,<freq_mhz>,<volt_mv>` | `{"command":"ascset","arg":"0,750,1350"}` |
| `ascenable` | Включение/выключение ASIC | `<asic_id>` (0=вкл, -1=выкл) | `{"command":"ascenable","arg":"0"}` |
| `ascstatus` | Статус ASIC | `<asic_id>` | `{"command":"ascstatus","arg":"0"}` |
| `asccount` | Количество ASIC | Нет | `{"command":"asccount"}` |
| `ascdev` | Информация об ASIC | `<asic_id>` | `{"command":"ascdev","arg":"0"}` |
| `ascdevice` | Детали устройства ASIC | `<asic_id>` | `{"command":"ascdevice","arg":"0"}` |
| `dorestart` | Перезапуск ASIC | `<asic_id>` | `{"command":"dorestart","arg":"0"}` |

---

### Команды управления пулами

| Команда | Описание | Аргументы | Пример |
|---------|----------|-----------|--------|
| `addpool` | Добавить пул | `<url>,<user>,<pass>` | `{"command":"addpool","arg":"stratum+tcp://pool.com:3333,user,pass"}` |
| `enablepool` | Включить пул | `<pool_id>` | `{"command":"enablepool","arg":"0"}` |
| `disablepool` | Выключить пул | `<pool_id>` | `{"command":"disablepool","arg":"0"}` |
| `removepool` | Удалить пул | `<pool_id>` | `{"command":"removepool","arg":"0"}` |
| `setpool` | Установить параметры пула | `<pool_id>,<param>,<value>` | `{"command":"setpool","arg":"0,priority,1"}` |
| `switchpool` | Переключиться на пул | `<pool_id>` | `{"command":"switchpool","arg":"1"}` |
| `currentpool` | Текущий пул | Нет | `{"command":"currentpool"}` |

---

### Privileged команды (требуют прав)

| Команда | Описание | Аргументы | Пример |
|---------|----------|-----------|--------|
| `privileged` | Выполнить привилегированную команду | `<cmd>=<arg>` | `{"command":"privileged","arg":"set_test_mode=1"}` |

**Доступные privileged команды:**

| Команда | Описание |
|---------|----------|
| `set_test_mode=1` | Включить тестовый режим |
| `set_test_mode=0` | Выключить тестовый режим |
| `setconfig=<params>` | Установить конфигурацию cgminer |
| `debug=1` | Включить режим отладки |
| `debug=0` | Выключить режим отладки |
| `ascset=<id>,<freq>,<volt>` | Установка частоты/напряжения ASIC |

**Примеры:**

```bash
# Включить тестовый режим
echo '{"command":"privileged","arg":"set_test_mode=1"}' | nc -w 3 IP 4028

# Установить разгон
echo '{"command":"privileged","arg":"setconfig=--avalon10-freq 800 --avalon10-voltage 1450"}' | nc -w 3 IP 4028

# Установить частоту ASIC
echo '{"command":"privileged","arg":"ascset=0,800,1450"}' | nc -w 3 IP 4028

# Включить отладку
echo '{"command":"privileged","arg":"debug=1"}' | nc -w 3 IP 4028
```

---

### Отладочные команды

| Команда | Описание | Аргументы | Пример |
|---------|----------|-----------|--------|
| `debug` | Режим отладки | `0` или `1` | `{"command":"debug","arg":"1"}` |
| `dbgstats` | Отладочная статистика | Нет | `{"command":"dbgstats"}` |
| `devdetails` | Детали устройств | Нет | `{"command":"devdetails"}` |
| `estats` | Расширенная статистика | Нет | `{"command":"estats"}` |

---

### Системные команды

| Команда | Описание | Аргументы | Пример |
|---------|----------|-----------|--------|
| `dosave` | Сохранить конфигурацию | Нет | `{"command":"dosave"}` |
| `doquit` | Выход | Нет | `{"command":"doquit"}` |
| `restart` | Перезапуск | Нет | `{"command":"restart"}` |
| `addtime` | Добавить время | Нет | `{"command":"addtime"}` |
| `cgtime` | Время cgminer | Нет | `{"command":"cgtime"}` |

---

### Команды веб-интерфейса

| Команда | Описание | Аргументы | Пример |
|---------|----------|-----------|--------|
| `cgconf` | Конфигурация cgminer | Нет | `{"command":"cgconf"}` |
| `cglog` | Логи cgminer | Нет | `{"command":"cglog"}` |
| `dashboard` | Панель управления | Нет | `{"command":"dashboard"}` |
| `admin` | Администрирование | Нет | `{"command":"admin"}` |
| `auth` | Аутентификация | `<user>,<pass>` | `{"command":"auth","arg":"admin,admin"}` |

---

## 📊 Примеры ответов API

### version

```json
{
  "STATUS": [
    {
      "STATUS": "S",
      "When": 1773186227,
      "Code": 1,
      "Msg": "API Version",
      "Description": "cgminer 4.11.1"
    }
  ],
  "VERSION": {
    "API": "2.1",
    "cgminer": "4.11.1",
    "cgmineroptions": "--lowmem --real-quiet"
  },
  "id": 1
}
```

### summary

```json
{
  "STATUS": [
    {
      "STATUS": "S",
      "When": 1773186227,
      "Code": 11,
      "Msg": "Summary",
      "Description": "cgminer 4.11.1"
    }
  ],
  "SUMMARY": [
    {
      "Elapsed": 8,
      "MHS av": 1255381.63,
      "MHS 5s": 4078850.45,
      "Found Blocks": 0,
      "Getworks": 6,
      "Accepted": 0,
      "Rejected": 0,
      "Hardware Errors": 0,
      "Utility": 0.00,
      "Total MH": 0.0000,
      "Network Blocks": 1
    }
  ],
  "id": 1
}
```

### devs

```json
{
  "STATUS": [
    {
      "STATUS": "S",
      "When": 1773186227,
      "Code": 9,
      "Msg": "1 ASC(s)",
      "Description": "cgminer 4.11.1"
    }
  ],
  "DEVS": [
    {
      "ASC": 0,
      "Name": "AVANANO",
      "ID": 0,
      "Enabled": "Y",
      "Status": "Alive",
      "Temperature": 0.00,
      "MHS av": 1255381.63,
      "MHS 5s": 4078850.45,
      "Accepted": 9,
      "Rejected": 0,
      "Hardware Errors": 0,
      "Utility": 0.71,
      "Last Share Pool": 0,
      "Last Share Time": 1773186218,
      "Total MH": 949978044.0000,
      "Device Hardware%": 0.0000,
      "Device Rejected%": 0.0000,
      "Device Elapsed": 757
    }
  ],
  "id": 1
}
```

### privileged (успех)

```json
{
  "STATUS": [
    {
      "STATUS": "S",
      "When": 1773186227,
      "Code": 46,
      "Msg": "Privileged access OK",
      "Description": "cgminer 4.11.1"
    }
  ],
  "id": 1
}
```

### privileged (ошибка)

```json
{
  "STATUS": [
    {
      "STATUS": "E",
      "When": 1773186227,
      "Code": 14,
      "Msg": "Invalid command",
      "Description": "cgminer 4.11.1"
    }
  ],
  "id": 1
}
```

---

## 🚀 Практические примеры

### 1. Проверка статуса майнера

```bash
# Общая информация
echo '{"command":"summary"}' | nc -w 3 192.168.31.133 4028 | strings

# Детальная информация об устройствах
echo '{"command":"devs"}' | nc -w 3 192.168.31.133 4028 | strings

# Расширенная информация
echo '{"command":"edevs"}' | nc -w 3 192.168.31.133 4028 | strings
```

### 2. Применение разгона

```bash
# Временный разгон (до перезагрузки)
echo '{"command":"privileged","arg":"ascset=0,800,1450"}' | nc -w 3 192.168.31.133 4028

# Проверка
echo '{"command":"devs"}' | nc -w 3 192.168.31.133 4028 | strings | grep -i "MHS 5s"
```

### 3. Включение тестового режима

```bash
echo '{"command":"privileged","arg":"set_test_mode=1"}' | nc -w 3 192.168.31.133 4028
```

### 4. Управление пулами

```bash
# Добавить пул
echo '{"command":"addpool","arg":"stratum+tcp://pool.com:3333,user,pass"}' | nc -w 3 IP 4028

# Переключиться на пул 1
echo '{"command":"switchpool","arg":"1"}' | nc -w 3 IP 4028

# Выключить пул 0
echo '{"command":"disablepool","arg":"0"}' | nc -w 3 IP 4028
```

### 5. Сохранение конфигурации

```bash
echo '{"command":"dosave"}' | nc -w 3 192.168.31.133 4028
```

---

## 🔧 Скрипты для работы с API

### Bash скрипт (privileged_api.sh)

```bash
#!/bin/bash
IP="192.168.31.133"
PORT=4028

send_cmd() {
    echo "{\"command\":\"$1\",\"arg\":\"$2\"}" | nc -w 3 "$IP" "$PORT" | strings
}

# Примеры использования
send_cmd "version" ""
send_cmd "summary" ""
send_cmd "privileged" "ascset=0,800,1450"
send_cmd "edevs" ""
```

### Python скрипт

```python
#!/usr/bin/env python3
import socket
import json

class AvalonAPI:
    def __init__(self, ip="192.168.31.133", port=4028):
        self.ip = ip
        self.port = port
    
    def send(self, command, arg=""):
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(5)
        sock.connect((self.ip, self.port))
        msg = f'{{"command":"{command}","arg":"{arg}"}}\x00'
        sock.send(msg.encode())
        response = sock.recv(8192).decode()
        sock.close()
        return json.loads(response.strip('\x00'))
    
    def version(self):
        return self.send("version")
    
    def summary(self):
        return self.send("summary")
    
    def devs(self):
        return self.send("devs")
    
    def edevs(self):
        return self.send("edevs")
    
    def privileged(self, arg):
        return self.send("privileged", arg)
    
    def ascset(self, asic_id, freq, volt):
        return self.privileged(f"ascset={asic_id},{freq},{volt}")

# Использование
api = AvalonAPI()
print("Version:", api.version())
print("Summary:", api.summary())
print("Apply overclock:", api.ascset(0, 800, 1450))
print("Status:", api.edevs())
```

---

## ⚠️ Важные замечания

### Коды ответов API

| Код | Описание |
|-----|----------|
| 1 | API Version |
| 9 | Статистика устройств |
| 11 | Общая статистика |
| 14 | Ошибка команды |
| 33 | Конфигурация |
| 46 | Privileged access OK |
| 47 | Privileged access denied |

### Статусы

| Статус | Описание |
|--------|----------|
| `S` | Success (успех) |
| `E` | Error (ошибка) |
| `W` | Warning (предупреждение) |

### Ограничения

1. **Privileged команды** требуют прав администратора
2. **Тестовый режим** может быть сброшен после перезагрузки
3. **Разгон через API** временный — для постоянного эффекта нужно изменить конфиги
4. **Максимальные значения:**
   - Частота: 800 MHz
   - Напряжение: 1450 mV
   - Freq Sel: 4
   - Voltage Level: 75

---

## 📁 Файлы конфигурации

### /data/usrcon/systemcfg.ini

```ini
[syscfg]
work_level = 2              ; 0=Low, 1=Medium, 2=High
ledmode = 1
ledrgb = 255
ledbright = 100
ledtemper = 100
webuser = root
webpass = ff0000ff4813494d137e1631bba301d5
```

### /etc/init.d/rcS

```bash
cd /mnt/heater/app
./btcminer --avalon10-freq 800 --avalon10-voltage 1450 --listen-api &
```

---

## 🔗 Ссылки

- **GitHub:** https://github.com/SmileDimon/avalon-nano3-api
- **Документация:** https://orca.pet/nanojb/
- **Canaan:** https://canaan.io/product/avalon-nano3

---

*Документ создан: 2026-03-11*
*Автор: Дмитрий (SmileDimon)*
*На основе анализа прошивки 2025061101*
