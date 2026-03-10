# 🔐 Avalon Nano 3 - Privileged API Commands

## 📡 API Доступ

**Порт:** 4028
**Протокол:** JSON over TCP

### Формат команд:

```bash
echo '{"command":"<cmd>","arg":"<arg>"}' | nc -w 3 <IP> 4028 | strings
```

---

## 🔑 Privileged Команды

**Все privileged команды возвращают:**
```json
{"STATUS":[{"STATUS":"S","Code":46,"Msg":"Privileged access OK"}]}
```

### 1. set_test_mode

Включает **тестовый режим** (инженерный доступ):

```bash
echo '{"command":"privileged","arg":"set_test_mode=1"}' | nc -w 3 192.168.31.133 4028 | strings
```

**Функции:**
- `syscfg_is_test_mode()` — проверка режима
- `set_test_mode()` — установка режима

---

### 2. setconfig

Установка конфигурации cgminer:

```bash
# Базовый разгон
echo '{"command":"privileged","arg":"setconfig=--avalon10-freq 800 --avalon10-voltage 1450"}' | nc -w 3 IP 4028

# Полный разгон
echo '{"command":"privileged","arg":"setconfig=--avalon10-freq 800 --avalon10-voltage 1450 --avalon10-freq-sel 4 --avalon10-voltage-level 75 --avalon10-core-clk-sel 1"}' | nc -w 3 IP 4028
```

---

### 3. ascset

Установка параметров ASIC:

```bash
# Формат: ascset=<asic_id>,<freq_mhz>,<volt_mv>

# Установить ASIC 0: 750 MHz / 1350 mV
echo '{"command":"privileged","arg":"ascset=0,750,1350"}' | nc -w 3 IP 4028

# Установить ASIC 0: 800 MHz / 1450 mV (максимум)
echo '{"command":"privileged","arg":"ascset=0,800,1450"}' | nc -w 3 IP 4028
```

---

### 4. debug

Включение режима отладки:

```bash
echo '{"command":"privileged","arg":"debug=1"}' | nc -w 3 IP 4028
```

**Параметры:**
- `--debug|-D` — вывод отладочной информации
- `--verbose` — подробный вывод

---

### 5. dorestart

Перезапуск ASIC:

```bash
# Перезапустить ASIC 0
echo '{"command":"privileged","arg":"dorestart=0"}' | nc -w 3 IP 4028
```

---

### 6. ascenable

Включение/выключение ASIC:

```bash
# Включить ASIC 0
echo '{"command":"privileged","arg":"ascenable=0"}' | nc -w 3 IP 4028

# Выключить ASIC 0
echo '{"command":"privileged","arg":"ascenable=-1"}' | nc -w 3 IP 4028
```

---

### 7. edevs

**Расширенный статус устройств** (не privileged):

```bash
echo '{"command":"edevs"}' | nc -w 3 IP 4028 | strings
```

**Возвращает:**
- Temperature
- MHS av (средний хешрейт)
- MHS 5s (хешрейт за 5 секунд)
- Accepted/Rejected
- Hardware Errors
- Device Elapsed

---

## 📊 Обычные API команды

### version

```bash
echo '{"command":"version"}' | nc -w 3 IP 4028 | strings
```

### summary

```bash
echo '{"command":"summary"}' | nc -w 3 IP 4028 | strings
```

### devs

```bash
echo '{"command":"devs"}' | nc -w 3 IP 4028 | strings
```

### config

```bash
echo '{"command":"config"}' | nc -w 3 IP 4028 | strings
```

### pools

```bash
echo '{"command":"pools"}' | nc -w 3 IP 4028 | strings
```

---

## 🛠️ Скрипт для работы с API

### privileged_api.sh

```bash
/home/smile/avalon_patch/privileged_api.sh 192.168.31.133
```

**Меню:**
1. Включить TEST режим
2. Установить разгон (800 MHz / 1450 mV)
3. Установить супер-разгон
4. Включить debug режим
5. Перезапустить ASIC
6. Проверить статус (edevs)
7. Своя команда

---

## 🚀 Быстрый разгон через API

```bash
# 1. Включить test_mode
echo '{"command":"privileged","arg":"set_test_mode=1"}' | nc -w 3 192.168.31.133 4028

# 2. Установить частоту/напряжение
echo '{"command":"privileged","arg":"ascset=0,800,1450"}' | nc -w 3 192.168.31.133 4028

# 3. Применить конфиг
echo '{"command":"privileged","arg":"setconfig=--avalon10-freq 800 --avalon10-voltage 1450 --listen-api"}' | nc -w 3 192.168.31.133 4028

# 4. Проверить статус
echo '{"command":"edevs"}' | nc -w 3 192.168.31.133 4028 | strings
```

---

## ⚠️ Важные замечания

1. **Privileged команды принимаются**, но для **постоянного эффекта** нужно:
   - Изменить `/data/usrcon/systemcfg.ini` (work_level = 2)
   - Изменить `/etc/init.d/rcS` (параметры btcminer)
   - Перезагрузить майнер

2. **Температура 0.00** — датчик не подключен или майнер холодный

3. **MHS 5s** может быть высоким, но **MHS av** растёт медленно

4. **Режим 3+** может блокировать загрузку!

---

## 📁 Файлы для постоянного применения

### /data/usrcon/systemcfg.ini

```ini
[syscfg]
work_level = 2
```

### /etc/init.d/rcS

```bash
cd /mnt/heater/app
./btcminer --avalon10-freq 800 --avalon10-voltage 1450 --avalon10-freq-sel 4 --avalon10-voltage-level 75 --avalon10-core-clk-sel 1 --listen-api &
```

---

## 🔧 Полный цикл разгона

### Через API (временный эффект):

```bash
# Применить настройки
echo '{"command":"privileged","arg":"ascset=0,800,1450"}' | nc -w 3 IP 4028

# Проверить
echo '{"command":"edevs"}' | nc -w 3 IP 4028 | strings
```

### Через SSH (постоянный эффект):

```bash
ssh admin@IP

# Установить work_level
echo 'admin' | sudo -S sed -i 's/work_level *= *.*/work_level = 2/' /data/usrcon/systemcfg.ini

# Применить разгон
echo 'admin' | sudo -S sed -i 's|^\./btcminer .*|./btcminer --avalon10-freq 800 --avalon10-voltage 1450 --avalon10-freq-sel 4 --avalon10-voltage-level 75 --avalon10-core-clk-sel 1 --listen-api \&|' /etc/init.d/rcS

# Перезагрузить
echo 'admin' | sudo -S reboot
```

---

*Документ создан: 2026-03-11*
*На основе анализа прошивки и тестирования API*
