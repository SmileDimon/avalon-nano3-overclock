# 📋 CGMiner API — Полный список команд

**Версия:** 4.11.1 (Avalon Nano 3)  
**Порт:** 4028  
**Протокол:** JSON

---

## 📡 Формат команд

### Базовый формат
```json
{"command":"<cmd>","arg":"<arg>"}
```

### Привилегированный доступ
```json
{"command":"privileged","arg":"<cmd>=<arg>"}
```

### Пример отправки (bash)
```bash
echo '{"command":"summary"}' | nc -w 3 192.168.31.133 4028 | strings
```

### Пример отправки (Python)
```python
import socket
import json

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect(('192.168.31.133', 4028))
sock.sendall(json.dumps({"command":"summary"}).encode() + b"\n")
response = sock.recv(4096)
sock.close()
```

---

## 🔍 Команды мониторинга (Read-only)

### version
**Описание:** Версия CGMiner  
**Пример:**
```json
{"command":"version"}
```
**Ответ:**
```json
{
  "STATUS": "S",
  "When": 1234567890,
  "Code": "VERSION",
  "Msg": "CGMiner 4.11.1",
  "VERSION": "4.11.1",
  "API": "4.11"
}
```

---

### summary
**Описание:** Общая сводка работы майнера  
**Пример:**
```json
{"command":"summary"}
```
**Ответ:**
```json
{
  "STATUS": "S",
  "When": 1234567890,
  "Code": "SUMMARY",
  "Msg": "Summary data",
  "Elapsed": 3600,
  "MHS av": 4000000,
  "MHS 5m": 3950000,
  "Accepted": 1000,
  "Rejected": 10,
  "Hardware Errors": 5,
  "Utility": 0.28,
  "Discarded": 0,
  "Stale": 0,
  "Get Failures": 0,
  "Local Work": 0,
  "Total MH": 14400000000,
  "Work Utility": 1008.0
}
```

**Поля:**
| Поле | Описание |
|------|----------|
| Elapsed | Время работы (сек) |
| MHS av | Средний хешрейт (H/s) |
| MHS 5m | Хешрейт за 5 мин |
| Accepted | Принятые шары |
| Rejected | Отклонённые шары |
| Hardware Errors | Аппаратные ошибки |
| Utility | Полезность |
| Total MH | Всего хешей |

---

### devs
**Описание:** Статус всех ASIC устройств  
**Пример:**
```json
{"command":"devs"}
```
**Ответ:**
```json
{
  "STATUS": "S",
  "When": 1234567890,
  "Code": "DEVS",
  "Msg": "Device status",
  "DEVS": [
    {
      "DEV": 0,
      "Status": "Alive",
      "Temperature": 65,
      "MHS av": 400000,
      "MHS 5m": 395000,
      "Accepted": 100,
      "Rejected": 1,
      "Hardware Errors": 0,
      "Last Share Time": 1234567890,
      "Last Valid Work": 1234567890
    },
    ...
  ]
}
```

**Поля устройства:**
| Поле | Описание |
|------|----------|
| DEV | ID устройства (0-9) |
| Status | Статус (Alive/Dead/Sick) |
| Temperature | Температура (°C) |
| MHS av | Средний хешрейт |
| MHS 5m | Хешрейт за 5 мин |
| Accepted | Принятые шары |
| Rejected | Отклонённые шары |
| Hardware Errors | Ошибки HW |
| Last Share Time | Время последней шары |
| Last Valid Work | Последняя валидная работа |

---

### devdetails
**Описание:** Детальная информация об устройствах  
**Пример:**
```json
{"command":"devdetails"}
```

---

### pools
**Описание:** Статус пулов  
**Пример:**
```json
{"command":"pools"}
```
**Ответ:**
```json
{
  "STATUS": "S",
  "When": 1234567890,
  "Code": "POOLS",
  "Msg": "Pool status",
  "POOLS": [
    {
      "POOL": 0,
      "URL": "stratum+tcp://pool.example.com:3333",
      "Status": "Alive",
      "Priority": 0,
      "Quota": 1,
      "Long Poll": "Y",
      "Getworks": 100,
      "Accepted": 1000,
      "Rejected": 10,
      "Works": 100,
      "Discarded": 0,
      "Stale": 0,
      "Get Failures": 0,
      "Remote Failures": 0,
      "User": "worker1",
      "Last Share Time": 1234567890,
      "Diff1 Work": 1500,
      "Difficulty Accepted": 1500,
      "Difficulty Rejected": 15,
      "Difficulty Stale": 0
    }
  ]
}
```

---

### stats
**Описание:** Расширенная статистика  
**Пример:**
```json
{"command":"stats"}
```

---

### config
**Описание:** Текущая конфигурация  
**Пример:**
```json
{"command":"config"}
```
**Ответ:**
```json
{
  "STATUS": "S",
  "When": 1234567890,
  "Code": "CONFIG",
  "Msg": "Configuration data",
  "Config": {
    "work_level": "2",
    "freq": "700",
    "voltage": "1300",
    "pool_count": "1"
  }
}
```

---

## 🔐 Привилегированные команды

**ВАЖНО:** Для выполнения требуется привилегированный доступ!

### ascset
**Описание:** Установка параметров ASIC чипа  
**Формат:** `ascset=<miner_id>,<freq>,<voltage>`

**Пример:**
```json
{"command":"privileged","arg":"ascset=0,750,1350"}
```

**Параметры:**
| Параметр | Диапазон | Описание |
|----------|----------|----------|
| miner_id | 0-9 | ID чипа (0-9 для 10 чипов) |
| freq | 25-800 | Частота в MHz |
| voltage | 1150-1450 | Напряжение в mV |

**Ответ:**
```json
{
  "STATUS": "S",
  "When": 1234567890,
  "Code": "ASCSET",
  "Msg": "ASC set ok",
  "ASC": 0,
  "Frequency": 750,
  "Voltage": 1350
}
```

---

### setconfig
**Описание:** Установка конфигурации  
**Формат:** `setconfig=<name>,<value>`

**Пример (установить work_level):**
```json
{"command":"privileged","arg":"setconfig=work_level,2"}
```

**Параметры:**
| Параметр | Значения | Описание |
|----------|----------|----------|
| work_level | 0-2 | 0=Low, 1=Medium, 2=High |

**Ответ:**
```json
{
  "STATUS": "S",
  "When": 1234567890,
  "Code": "SETCONFIG",
  "Msg": "Set config ok",
  "Config": {
    "work_level": "2"
  }
}
```

---

### addpool
**Описание:** Добавить новый пул  
**Формат:** `addpool=<url>,<user>,<password>`

**Пример:**
```json
{"command":"privileged","arg":"addpool=stratum+tcp://pool.com:3333,worker1,pass123"}
```

---

### switchpool
**Описание:** Переключиться на другой пул  
**Формат:** `switchpool=<pool_id>`

**Пример:**
```json
{"command":"privileged","arg":"switchpool=1"}
```

---

### restart
**Описание:** Перезапуск CGMiner  
**Пример:**
```json
{"command":"privileged","arg":"restart"}
```

---

### save
**Описание:** Сохранить конфигурацию  
**Формат:** `save=<filename>` (опционально)

**Пример:**
```json
{"command":"privileged","arg":"save"}
```

---

## 🧪 Специальные команды

### mining.authorize (Stratum)
**Описание:** Авторизация на пуле  
**Пример:**
```json
{"id": 1, "method": "mining.authorize", "params": ["worker1", "password"]}
```

---

### mining.subscribe (Stratum)
**Описание:** Подписка на стратум  
**Пример:**
```json
{"id": 1, "method": "mining.subscribe", "params": []}
```

---

### mining.suggest_difficulty (Stratum)
**Описание:** Предложить сложность  
**Пример:**
```json
{"id": 1, "method": "mining.suggest_difficulty", "params": [16]}
```

---

### mining.configure (Stratum)
**Описание:** Конфигурация version-rolling  
**Пример:**
```json
{"id": 1, "method": "mining.configure", "params": [["version-rolling"], {"version-rolling.mask": "1fffe000"}]}
```

---

## 📊 Кódы ответов

### STATUS
| Код | Описание |
|-----|----------|
| S | Success (успех) |
| W | Warning (предупреждение) |
| E | Error (ошибка) |
| F | Fatal (фатальная ошибка) |

### Msg
| Сообщение | Описание |
|-----------|----------|
| Privileged access OK | Привилегированный доступ разрешён |
| Access denied | Доступ запрещён |
| Invalid command | Неверная команда |
| ASC set ok | Параметры ASIC установлены |
| Set config ok | Конфигурация установлена |

---

## 🔧 Утилиты для работы с API

### Bash скрипт (test_api.sh)
```bash
#!/bin/bash
MINER_IP="192.168.31.133"
API_PORT="4028"

send_cmd() {
    echo "{\"command\":\"$1\"}" | nc -w 3 $MINER_IP $API_PORT | strings
}

send_privileged() {
    echo "{\"command\":\"privileged\",\"arg\":\"$1\"}" | nc -w 3 $MINER_IP $API_PORT | strings
}

case "$1" in
    version) send_cmd "version" ;;
    summary) send_cmd "summary" ;;
    devs) send_cmd "devs" ;;
    pools) send_cmd "pools" ;;
    config) send_cmd "config" ;;
    ascset) send_privileged "ascset=$2,$3,$4" ;;
    setconfig) send_privileged "setconfig=$2,$3" ;;
    *) echo "Usage: $0 {version|summary|devs|pools|config|ascset|setconfig}" ;;
esac
```

### Python функция
```python
import socket
import json

def send_api_command(host, port, command, arg=None, privileged=False):
    """Отправка команды CGMiner API"""
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(5)
    sock.connect((host, port))
    
    if privileged:
        cmd_data = {"command": "privileged", "arg": f"{command}={arg}"}
    else:
        cmd_data = {"command": command}
        if arg:
            cmd_data["arg"] = arg
    
    sock.sendall(json.dumps(cmd_data).encode() + b"\n")
    
    response = b""
    while True:
        chunk = sock.recv(4096)
        if not chunk:
            break
        response += chunk
        if len(chunk) < 4096:
            break
    
    sock.close()
    
    # Очистка от бинарного мусора
    response_str = ''.join(chr(b) for b in response if 32 <= b < 127 or b in (9, 10, 13))
    
    # Парсинг JSON
    start = response_str.find('{')
    end = response_str.rfind('}') + 1
    if start >= 0 and end > start:
        json_str = response_str[start:end]
        return json.loads(json_str)
    
    return {"raw": response_str, "error": "Failed to parse JSON"}
```

---

**Дата:** 11 марта 2026  
**Автор:** Дмитрий (Алекс-бот)
