# 🔬 Avalon Nano 3 - ПОЛНЫЙ АНАЛИЗ И СКРЫТЫЕ ВОЗМОЖНОСТИ

> **Дата:** 2026-03-11
> **Прошивка:** 2025061101
> **API:** cgminer 4.11.1
> **Приложение:** Canaan Avalon 0.38.0

---

## 📊 ЧТО НАЙДЕНО

### 1. Privileged API Команды ✅

**Порт:** 4028
**Статус:** РАБОТАЮТ!

```bash
echo '{"command":"privileged","arg":"ascset=0,800,1450"}' | nc -w 3 192.168.31.133 4028
# Возвращает: {"STATUS":[{"Code":46,"Msg":"Privileged access OK"}]}
```

**Доступные команды:**
- `ascset=<id>,<freq>,<volt>` - Установка частоты/напряжения
- `setconfig=<params>` - Установка конфигурации
- `set_test_mode=1` - Включить тестовый режим
- `debug=1` - Включить отладку
- `dorestart=<id>` - Перезапуск ASIC
- `ascenable=<id>` - Включение/выключение ASIC

---

### 2. SUPER Режим 🔥

**Найдено в btcminer:**
- `g_dev_super` - глобальная переменная SUPER режима
- `dev_super_get` - функция получения SUPER статуса
- `exec_cmd` - функция выполнения команд

**Что это даёт:**
- Доступ к **инженерным функциям**
- **Преодоление лимитов** разгона
- **Скрытые настройки** оборудования

---

### 3. Factory Команды 🔧

**Найдено:**
- `factory set %s` - Установка factory параметра
- `factory set level error` - Ошибка уровня factory
- `factory_reset_sys` - Системный сброс
- `button_detect:long=%d, factory reset` - Сброс кнопкой

**Значение:**
- Factory режим имеет **больше прав** чем обычный
- Позволяет менять **защищённые параметры**

---

### 4. Test Режим 🧪

**Функции:**
- `syscfg_is_test_mode()` - Проверка режима
- `set_test_mode()` - Установка режима

**Команда:**
```bash
echo '{"command":"privileged","arg":"set_test_mode=1"}' | nc -w 3 IP 4028
```

---

### 5. Скрытые Параметры Разгона

**Найдено в btcminer:**

| Параметр | Диапазон | Описание |
|----------|----------|----------|
| `--avalon10-freq` | 25-800 MHz | Частота ASIC |
| `--avalon10-voltage` | 1150-1450 mV | Напряжение |
| `--avalon10-freq-sel` | 0-4 | Уровень частоты |
| `--avalon10-voltage-level` | 0-75 | Уровень напряжения |
| `--avalon10-core-clk-sel` | 0-1 | Выбор ядра |

**work_level:**
- `0` = Low (Обогреватель)
- `1` = Medium
- `2` = High (Майнинг)
- `3+` = **INVALID** (может блокировать!)

---

### 6. Bluetooth (BLE) Подключение 📱

**Приложение Canaan Avalon использует:**

**Файл:** `bledata.proto`

**Команды BLE:**
- `WriteCharacteristicRequest` - Запись команды
- `ReadCharacteristicRequest` - Чтение ответа
- `NotifyCharacteristicRequest` - Подписка на уведомления

**Что это значит:**
- Приложение отправляет **Privileged команды** через Bluetooth
- WiFi API тоже доступно для прямого доступа

---

### 7. exec_cmd Функция ⚡

**Найдено в btcminer:**
- `exec_cmd` - Выполнение системных команд

**Возможное использование:**
```bash
# Через API (если доступно)
echo '{"command":"exec_cmd","arg":"ls -la"}' | nc -w 3 IP 4028
```

---

## 🚀 КАК АКТИВИРОВАТЬ

### 1. Privileged Доступ (WiFi)

```bash
# Проверка доступа
echo '{"command":"privileged","arg":"test"}' | nc -w 3 192.168.31.133 4028

# Применение разгона
echo '{"command":"privileged","arg":"ascset=0,800,1450"}' | nc -w 3 192.168.31.133 4028

# Включение test режима
echo '{"command":"privileged","arg":"set_test_mode=1"}' | nc -w 3 192.168.31.133 4028
```

### 2. SUPER Режим

**Через SSH:**
```bash
ssh admin@192.168.31.133

# Попытка активации (требует исследования)
echo 'admin' | sudo -S sh -c 'echo 1 > /sys/class/dev_super/enable'
```

**Через API (гипотеза):**
```bash
echo '{"command":"privileged","arg":"dev_super=1"}' | nc -w 3 IP 4028
```

### 3. Factory Режим

**Активация:**
```bash
# Через SSH
echo 'admin' | sudo -S sh -c 'echo 1 > /data/factory_mode'

# Или кнопкой (долгое нажатие)
button_detect:long=3000  # 3 секунды
```

### 4. Test Режим

```bash
# Через API
echo '{"command":"privileged","arg":"set_test_mode=1"}' | nc -w 3 IP 4028

# Через SSH
echo 'admin' | sudo -S sh -c 'set_test_mode 1'
```

### 5. Постоянный Разгон

**Модификация rcS:**
```bash
ssh admin@IP

# Бэкап
echo 'admin' | sudo -S cp /etc/init.d/rcS /etc/init.d/rcS.bak

# Применение разгона
echo 'admin' | sudo -S sed -i 's|^\./btcminer .*|./btcminer --avalon10-freq 800 --avalon10-voltage 1450 --avalon10-freq-sel 4 --avalon10-voltage-level 75 --avalon10-core-clk-sel 1 --listen-api \&|' /etc/init.d/rcS

# Установка work_level
echo 'admin' | sudo -S sed -i 's/work_level *= *.*/work_level = 2/' /data/usrcon/systemcfg.ini

# Перезагрузка
echo 'admin' | sudo -S reboot
```

---

## 📁 ФАЙЛЫ КОНФИГУРАЦИИ

### /data/usrcon/systemcfg.ini

```ini
[syscfg]
work_level = 2              ; 0=Low, 1=Medium, 2=High, 3=INVALID!
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

## 🎯 СКРЫТЫЕ ВОЗМОЖНОСТИ

### 1. Максимальный Разгон

**Параметры:**
- Частота: **800 MHz** (сток: 500)
- Напряжение: **1450 mV** (сток: 1200)
- Freq Sel: **4** (максимум)
- Voltage Level: **75** (максимум)
- Core Clk Sel: **1**

**Ожидаемый хешрейт:** ~8+ TH/s (сток: 4 TH/s)

### 2. Отключение Температурных Лимитов

**Гипотеза:**
```bash
# Через privileged API
echo '{"command":"privileged","arg":"setconfig=--no-thermal-throttle"}' | nc -w 3 IP 4028
```

### 3. Инженерный Режим

**Активация:**
```bash
# Через factory режим
echo '{"command":"privileged","arg":"factory set dev_mode=1"}' | nc -w 3 IP 4028
```

### 4. Прямой Доступ к GPIO

**Для электриков:**
```bash
# Через exec_cmd (если работает)
echo '{"command":"exec_cmd","arg":"gpio read P1.0"}' | nc -w 3 IP 4028
```

---

## ⚠️ ПРЕДУПРЕЖДЕНИЯ

### Критические Риски

1. **Режим 3+** - может блокировать загрузку!
2. **Напряжение >1450 mV** - риск повреждения чипов
3. **Температура >85°C** - риск перегрева
4. **Factory режим** - может сбросить гарантию

### Безопасные Параметры

| Параметр | Безопасно | Экстрим | Риск |
|----------|-----------|---------|------|
| Частота | ≤700 MHz | 800 MHz | >800 MHz |
| Напряжение | ≤1350 mV | 1450 mV | >1450 mV |
| Температура | ≤75°C | ≤85°C | >85°C |

---

## 📊 ТАБЛИЦА ВСЕХ КОМАНД

### API Команды (порт 4028)

| Команда | Аргумент | Описание | Доступ |
|---------|----------|----------|--------|
| `version` | Нет | Версия API | Публичный |
| `summary` | Нет | Общая статистика | Публичный |
| `devs` | Нет | Статистика устройств | Публичный |
| `edevs` | Нет | Расширенная статистика | Публичный |
| `pools` | Нет | Информация о пулах | Публичный |
| `config` | Нет | Конфигурация | Публичный |
| `privileged` | `<cmd>=<arg>` | Privileged команды | **Требуется доступ** |
| `ascset` | `id,freq,volt` | Установка ASIC | Privileged |
| `ascenable` | `id` | Включение ASIC | Privileged |
| `dorestart` | `id` | Перезапуск ASIC | Privileged |
| `setconfig` | `params` | Конфигурация | Privileged |
| `set_test_mode` | `0/1` | Тест режим | Privileged |
| `debug` | `0/1` | Отладка | Privileged |
| `dosave` | Нет | Сохранить | Privileged |

### Factory Команды

| Команда | Описание |
|---------|----------|
| `factory set <param>=<value>` | Установка factory параметра |
| `factory get <param>` | Получение factory параметра |
| `factory_reset_sys` | Системный сброс |

### SUPER Режим

| Функция | Описание |
|---------|----------|
| `g_dev_super` | Глобальная переменная SUPER |
| `dev_super_get` | Получение статуса SUPER |
| `dev_super_set` | Установка SUPER режима |

---

## 🔗 ИНСТРУМЕНТЫ

### Для работы с API

```bash
# privileged_api.sh - Интерактивный скрипт
./privileged_api.sh 192.168.31.133

# Прямые команды
echo '{"command":"devs"}' | nc -w 3 192.168.31.133 4028
```

### Для разгона

```bash
# super_mode.sh - СУПЕР разгон
./super_mode.sh 192.168.31.133

# overclock_miner.sh - Обычный разгон
./overclock_miner.sh 192.168.31.133
```

### Веб-интерфейс

```bash
# advanced_full.html - Страница Advanced Settings
# URL: http://192.168.31.133/advanced.html
```

---

## 📋 ВЫВОДЫ

### ✅ Подтверждено

1. **Privileged API** работает через порт 4028
2. **get_minerinfo.cgi** существует и работает
3. **work_level** управляет режимом (0=обогрев, 2=майнинг)
4. **Bluetooth (BLE)** используется приложением
5. **factory команды** существуют
6. **test_mode** доступен

### 🔮 Гипотезы

1. **SUPER режим** (`g_dev_super`) - требует активации
2. **exec_cmd** - возможно выполнение системных команд
3. **dev_super_get/set** - управление SUPER режимом

### 🎯 Рекомендации

1. **Для разгона:** Использовать `privileged ascset`
2. **Для тестов:** Включить `set_test_mode=1`
3. **Для постоянного эффекта:** Модифицировать `/etc/init.d/rcS`
4. **Для безопасности:** Следить за температурой ≤75°C

---

## 📁 ФАЙЛЫ РЕПОЗИТОРИЯ

| Файл | Описание |
|------|----------|
| `FINAL_FINDINGS.md` | 📊 Этот файл - полные находки |
| `API_DOCUMENTATION.md` | 📡 Документация API |
| `PRIVILEGED_API.md` | 🔐 Privileged команды |
| `SUPER_MODE.md` | ⚡ SUPER режим |
| `APK_FINDINGS.md` | 📱 Анализ приложения |
| `advanced_full.html` | 🌐 Веб-интерфейс |
| `privileged_api.sh` | 🛠️ Скрипт API |
| `super_mode.sh` | 🚀 Скрипт разгона |

---

## 🔗 ССЫЛКИ

- **GitHub:** https://github.com/SmileDimon/avalon-nano3-overclock
- **Документация:** https://orca.pet/nanojb/
- **Canaan:** https://canaan.io/product/avalon-nano3

---

*Полный анализ проведён: 2026-03-11*
*Автор: Дмитрий (SmileDimon)*
*Прошивка: 2025061101*
*Приложение: Canaan Avalon 0.38.0*
