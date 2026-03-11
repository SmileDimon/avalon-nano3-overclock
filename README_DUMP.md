<<<<<<< HEAD
# 🔧 Avalon Nano 3 — Полный дамп и документация BTCMiner

**Версия прошивки:** 2025061101  
**Дата анализа:** 11 марта 2026  
**Автор:** Дмитрий (Алекс-бот)

---

## 📋 Содержание

1. [Обзор](#обзор)
2. [Аппаратная часть](#аппаратная-часть)
3. [BTCMiner — анализ бинарника](#btcminer-анализ-бинарника)
4. [CGMiner API — команды](#cgminer-api-команды)
5. [Параметры разгона](#параметры-разгона)
6. [Веб-интерфейс](#веб-интерфейс)
7. [Мониторинг и управление](#мониторинг-и-управление)
8. [Файлы проекта](#файлы-проекта)

---

## 📖 Обзор

Avalon Nano 3 — ASIC майнер на базе 10 чипов A3198, работающий под управлением модифицированной версии CGMiner 4.11.1.

**Основные характеристики:**
- **Хешрейт:** 4 TH/s (сток)
- **Чипы:** 10x A3198
- **SoC:** Kendryte K230 (1.6GHz RISC-V)
- **RAM:** 128MB
- **Flash:** 128MB NAND
- **API порт:** 4028 (CGMiner protocol)
- **Веб-порт:** 80 (HTTP)

---

## 🖥️ Аппаратная часть

### SoC Kendryte K230
```
Архитектура: RISC-V (64-bit)
Частота: 1.6 GHz
RAM: 128MB
Flash: 128MB NAND
Интерфейсы: Ethernet, UART, SPI
```

### ASIC чипы A3198
```
Количество: 10 штук
Частота (сток): 500-700 MHz
Напряжение (сток): 1200-1300 mV
Макс. частота: 800 MHz
Макс. напряжение: 1450 mV
```

---

## 🔍 BTCMiner — анализ бинарника

### Информация о бинарнике

**Файл:** `btcminer_original`  
**Тип:** ELF 64-bit LSB executable  
**Архитектура:** UCB RISC-V, RVC, double-float ABI  
**Интерпретатор:** `/lib/ld-linux-riscv64xthead-lp64d.so.1`  
**Версия CGMiner:** 4.11.1  
**Сборка:** Не стрипнут (с debug_info)

### Путь сборки
```
/home/wangjunshuai/workspace/heater/k230_sdk/app_heater/cgminer/cgminer.c
/home/wangjunshuai/workspace/heater/k230_sdk/app_heater/web/cgi/cgi_cgminer.c
```

### Ключевые компоненты бинарника

#### 1. Драйверы
- `driver-avalon12.c` — драйвер для Avalon контроллера
- `avalonnano_drv` — специфичный драйвер для Nano
- `avalon_set_voltage` — управление напряжением
- `avalon_set_heater_level` — управление обогревателем

#### 2. API функции
- `api_add_freq` — добавление данных о частоте
- `api_add_volts` — добавление данных о напряжении
- `api_add_temp` — добавление данных о температуре
- `api_add_mhs` — добавление данных о хешрейте

#### 3. CGI обработчики
- `/cgi/cgconf.cgi` — конфигурация CGMiner
- `/cgi/cglog.cgi` — логи CGMiner
- `/cgi/network.cgi` — сетевые настройки
- `/cgi/apssidconf.cgi` — настройки Wi-Fi
- `/get_minerinfo.cgi` — информация о майнере

---

## 🎛️ CGMiner API — команды

### Протокол

**Порт:** 4028  
**Формат:** JSON  
**Пример запроса:**
```json
{"command":"summary"}
```

**Пример ответа:**
```json
{
  "STATUS": "S",
  "When": 1234567890,
  "Code": "SUMMARY",
  "Msg": "Summary data",
  "Elapsed": 3600,
  "MHS av": 4000000,
  "Accepted": 1000,
  "Rejected": 10,
  "Hardware Errors": 5
}
```

### Команды мониторинга (Read-only)

| Команда | Описание | Пример |
|---------|----------|--------|
| `version` | Версия CGMiner | `{"command":"version"}` |
| `summary` | Общая сводка | `{"command":"summary"}` |
| `devs` | Статус всех ASIC | `{"command":"devs"}` |
| `devdetails` | Детали устройств | `{"command":"devdetails"}` |
| `pools` | Статус пулов | `{"command":"pools"}` |
| `stats` | Расширенная статистика | `{"command":"stats"}` |
| `config` | Текущая конфигурация | `{"command":"config"}` |

### Привилегированные команды (Privileged)

**Требуют авторизации через cookie!**

| Команда | Описание | Пример аргумента |
|---------|----------|------------------|
| `ascset` | Установка параметров ASIC | `0,750,1350` (miner_id,freq,volt) |
| `setconfig` | Установка конфигурации | `work_level,2` |
| `addpool` | Добавить пул | `url,user,password` |
| `switchpool` | Переключить пул | `0` (pool_id) |
| `restart` | Перезапуск cgminer | - |
| `save` | Сохранить конфигурацию | `config.conf` |

### Примеры команд

#### Получить сводку
```bash
echo '{"command":"summary"}' | nc -w 3 192.168.31.133 4028 | strings
```

#### Установить разгон (Privileged)
```bash
echo '{"command":"privileged","arg":"ascset=0,750,1350"}' | nc -w 3 192.168.31.133 4028 | strings
```

#### Установить Work Level
```bash
echo '{"command":"privileged","arg":"setconfig=work_level,2"}' | nc -w 3 192.168.31.133 4028 | strings
```

---

## ⚡ Параметры разгона

### Командная строка BTCMiner

```bash
# Частота
--avalon10-freq [25-800]           # Частота в MHz
--avalon10-freq-sel [0-4]          # Селектор частоты
--avalon10-core-clk-sel [0-1]      # Селектор ядра

# Напряжение
--avalon10-voltage [1150-1450]     # Напряжение в mV
--avalon10-voltage-level [0-75]    # Уровень напряжения

# Работа
work_level [0-2]                   # Уровень работы
  0 = Low (Обогреватель)
  1 = Medium
  2 = High (Майнинг)

# Отладка
--avalon10-polling-delay           # Задержка опроса
--avalon10-nonce-check             # Проверка nonce
--avalon10-nonce-mask              # Маска nonce
--avalon10-roll-enable             # Включить roll
```

### Диапазоны параметров

| Параметр | Минимум | Максимум | Единицы | Описание |
|----------|---------|----------|---------|----------|
| Частота | 25 | 800 | MHz | Частота ASIC чипа |
| Напряжение | 1150 | 1450 | mV | Напряжение ASIC чипа |
| work_level | 0 | 2 | - | Уровень работы |
| freq-sel | 0 | 4 | - | Селектор частоты |
| voltage-level | 0 | 75 | - | Уровень напряжения |
| core-clk-sel | 0 | 1 | - | Селектор ядра |

### Пресеты разгона

| Название | Частота | Напряжение | Описание |
|----------|---------|------------|----------|
| 🐢 Сток | 500 MHz | 1200 mV | Заводские настройки |
| ⚡ Средний | 650 MHz | 1300 mV | Баланс производительности |
| 🚀 Быстрый | 750 MHz | 1350 mV | Высокая производительность |
| 🔥 МАКС | 800 MHz | 1450 mV | Максимальный разгон |
=======
# 📚 Avalon Nano 3 - Полная документация

> **Версия:** 1.0.0
> **Дата:** 2026-03-11
> **Прошивка:** 2025061101
> **API:** cgminer 4.11.1

---

## 📖 Оглавление

### 📘 Основная документация

| Документ | Описание |
|----------|----------|
| **[API_DOCUMENTATION.md](API_DOCUMENTATION.md)** | 📡 **Полная документация API команд** (25+ команд) |
| **[MODES_DOCUMENTATION.md](MODES_DOCUMENTATION.md)** | 🎛️ **Режимы работы** и переключение |
| **[PRIVILEGED_API.md](PRIVILEGED_API.md)** | 🔐 **Privileged команды** API |
| **[SUPER_MODE.md](SUPER_MODE.md)** | ⚡ **СУПЕР РЕЖИМ** и скрытые параметры |

### 🛠️ Скрипты

| Скрипт | Описание |
|--------|----------|
| **privileged_api.sh** | Интерактивный скрипт для отправки API команд |
| **super_mode.sh** | Применение СУПЕР разгона (800 MHz / 1450 mV) |
| **overclock_miner.sh** | Применение разгона (750 MHz / 1350 mV) |
| **modify_firmware.sh** | Модификация прошивки (work_level = 2) |
| **analyze_temp.sh** | Анализ температуры и статуса |

---

## 🚀 Быстрый старт

### 1. Проверка статуса майнера

```bash
echo '{"command":"devs"}' | nc -w 3 192.168.31.133 4028 | strings
```

### 2. Применение разгона через API

```bash
# Запустить интерактивный скрипт
./privileged_api.sh 192.168.31.133

# Или напрямую
echo '{"command":"privileged","arg":"ascset=0,800,1450"}' | nc -w 3 192.168.31.133 4028
```

### 3. Постоянный разгон (через SSH)

```bash
# Запустить скрипт
./super_mode.sh 192.168.31.133

# Или вручную
ssh admin@192.168.31.133
echo 'admin' | sudo -S sed -i 's/work_level *= *.*/work_level = 2/' /data/usrcon/systemcfg.ini
echo 'admin' | sudo -S sed -i 's|^\./btcminer .*|./btcminer --avalon10-freq 800 --avalon10-voltage 1450 --listen-api \&|' /etc/init.d/rcS
echo 'admin' | sudo -S reboot
```

---

## 📊 Найденные API команды

### Основные (25+ команд)

| Команда | Описание |
|---------|----------|
| `version` | Версия API |
| `help` | Список команд |
| `summary` | Общая статистика |
| `devs` | Статистика устройств |
| `edevs` | Расширенная статистика |
| `pools` | Информация о пулах |
| `config` | Конфигурация |

### Управление ASIC

| Команда | Описание |
|---------|----------|
| `ascset` | Установка параметров ASIC |
| `ascenable` | Включение/выключение ASIC |
| `ascstatus` | Статус ASIC |
| `asccount` | Количество ASIC |
| `ascdev` | Информация об ASIC |
| `dorestart` | Перезапуск ASIC |

### Privileged команды

| Команда | Описание |
|---------|----------|
| `set_test_mode=1` | Включить тестовый режим |
| `setconfig=...` | Установить конфигурацию |
| `debug=1` | Включить отладку |
| `ascset=0,freq,volt` | Установка частоты/напряжения |

### Управление пулами

| Команда | Описание |
|---------|----------|
| `addpool` | Добавить пул |
| `enablepool` | Включить пул |
| `disablepool` | Выключить пул |
| `removepool` | Удалить пул |
| `switchpool` | Переключиться на пул |

---

## 🔍 Ключевые открытия

### 1. work_level режимы

```ini
work_level = 0  ; Обогреватель (низкая мощность)
work_level = 1  ; Medium (средняя мощность)
work_level = 2  ; High (майнинг, максимальная мощность)
```

### 2. Скрытые параметры разгона

```bash
--avalon10-freq <25-800>              # Частота MHz
--avalon10-voltage <1150-1450>        # Напряжение mV
--avalon10-freq-sel <0-4>             # Уровень частоты
--avalon10-voltage-level <0-75>       # Уровень напряжения
--avalon10-core-clk-sel <0-1>         # Выбор ядра
```

### 3. Privileged API доступ

**Порт:** 4028
**Формат:** `{"command":"privileged","arg":"<cmd>=<arg>"}`

**Возвращает:** `{"STATUS":[{"Code":46,"Msg":"Privileged access OK"}]}`

### 4. Тестовый режим

```bash
echo '{"command":"privileged","arg":"set_test_mode=1"}' | nc -w 3 IP 4028
```

---

## 📁 Структура репозитория

```
avalon_patch/
├── README.md                        # Этот файл
├── API_DOCUMENTATION.md             # Полная документация API
├── MODES_DOCUMENTATION.md           # Режимы работы
├── PRIVILEGED_API.md                # Privileged команды
├── SUPER_MODE.md                    # СУПЕР РЕЖИМ
├── privileged_api.sh                # Скрипт API команд
├── super_mode.sh                    # Скрипт СУПЕР разгона
├── overclock_miner.sh               # Скрипт разгона
├── modify_firmware.sh               # Скрипт модификации прошивки
└── analyze_temp.sh                  # Скрипт анализа температуры
```

---

## ⚠️ Предупреждения

1. **Разгон** может привести к перегреву и повреждению оборудования
2. **Режим 3+** может блокировать загрузку майнера
3. **Высокое напряжение** ускоряет деградацию чипов
4. **Следи за температурой** — не выше 85°C
5. Все действия выполняются на свой страх и риск

---

## 🔗 Ссылки

- **GitHub:** https://github.com/SmileDimon/avalon-nano3-overclock
- **Документация orca.pet:** https://orca.pet/nanojb/
- **Canaan:** https://canaan.io/product/avalon-nano3
- **Bitcointalk:** https://bitcointalk.org/

---

## 📝 Changelog

### 2026-03-11 - Версия 1.0.0

- ✅ Найдено 25+ API команд
- ✅ Обнаружен Privileged доступ
- ✅ Найдены скрытые параметры разгона
- ✅ Найдены work_level режимы
- ✅ Найдены test_mode команды
- ✅ Создана полная документация
- ✅ Созданы рабочие скрипты
- ✅ Загружено на GitHub

---

## 👤 Автор

**Дмитрий (SmileDimon)**

- GitHub: https://github.com/SmileDimon
- Telegram: @clawadict_bot (Клавик)

---

## 💰 Поддержать проект

Если документация помогла, рассмотрите пожертвование:

```
BEP-20: 0xDdCE054935efbfdf53177d59f2771dfDc2baAb9D
BTC: bc1q0qfecejvx4k23huthjxzmchqdlvl2asfy6ejeg
ETH: 0xDdCE054935efbfdf53177d59f2771dfDc2baAb9D
TON: UQCl2z15wB8oZEEs2LCvZQgJX4iuK7lxneHEF7bTyzvM3hDc
```

---

*Документ создан на основе анализа прошивки 2025061101*
*Последнее обновление: 2026-03-11*
>>>>>>> 27a9486a57533d13b3e500a16858898ce7732efc

---

## 🌐 Веб-интерфейс

<<<<<<< HEAD
### CGI страницы

| URL | Описание |
|-----|----------|
| `/` | Главная страница (dashboard) |
| `/cgconf.cgi` | Конфигурация CGMiner |
| `/cglog.cgi` | Логи майнера |
| `/network.cgi` | Сетевые настройки |
| `/apssidconf.cgi` | Настройки Wi-Fi |
| `/get_minerinfo.cgi` | Информация о майнере |
| `/get_wifi_stats.cgi` | Статистика Wi-Fi |
| `/admin.cgi` | Админ-панель |

### HTTP API

**Порт:** 80  
**Методы:** GET, POST

**Пример запроса:**
```bash
curl http://192.168.31.133/get_minerinfo.cgi
```

### Авторизация

**Cookie для привилегированного доступа:**
```
ff0000ff4813494d137e1631bba301d5
```

**Уязвимость:** timezoneconf.cgi позволяет получить SSH доступ

---

## 📊 Мониторинг и управление

### Python скрипт

**Файл:** `avalon_monitor.py`

**Функции:**
- ✅ Мониторинг в реальном времени (опрос каждые 5 сек)
- ✅ Веб-интерфейс с автообновлением
- ✅ Управление разгоном (частота + напряжение)
- ✅ Привилегированные команды API
- ✅ Пресеты разгона
- ✅ Лог событий

**Запуск:**
```bash
python3 avalon_monitor.py
```

**Веб-интерфейс:** `http://localhost:8080`

### Команды для ручного мониторинга

```bash
# Получить версию
echo '{"command":"version"}' | nc -w 3 192.168.31.133 4028 | strings

# Получить сводку
echo '{"command":"summary"}' | nc -w 3 192.168.31.133 4028 | strings

# Получить статус устройств
echo '{"command":"devs"}' | nc -w 3 192.168.31.133 4028 | strings

# Получить пулы
echo '{"command":"pools"}' | nc -w 3 192.168.31.133 4028 | strings

# Получить конфигурацию
echo '{"command":"config"}' | nc -w 3 192.168.31.133 4028 | strings
```

---

## 📁 Файлы проекта

### Структура

```
avalon-nano3-dump/
├── README.md                 # Этот файл
├── docs/
│   ├── api_commands.md       # Полные API команды
│   ├── overclock_guide.md    # Гид по разгону
│   └── troubleshooting.md    # Решение проблем
├── scripts/
│   ├── avalon_monitor.py     # Мониторинг и управление
│   ├── test_api.sh           # Тест API команд
│   └── extract_strings.sh    # Скрипт извлечения строк
├── configs/
│   ├── cgminer.conf          # Пример конфигурации
│   └── overclock_presets.json # Пресеты разгона
└── firmware_info/
    ├── version.txt           # Информация о прошивке
    └── build_info.txt        # Информация о сборке
```

### Связанные файлы

- `btcminer_original` — оригинальный бинарник CGMiner
- `avalon_monitor.py` — скрипт мониторинга
- `AVALON_MONITOR_README.md` — документация мониторинга
- `avalon-nano3-overclock.zip` — патч для разгона

---

## 🔗 Ресурсы

### Официальные ресурсы
- [Avalon Official](https://www.canaan.io/)
- [CGMiner Repository](https://github.com/ckolivas/cgminer)

### Документы
- [Полный анализ бинарника](docs/btcminer_analysis.md)
- [Список всех строк бинарника](scripts/btcminer_strings.txt)

---

**Дата создания:** 11 марта 2026  
**Автор:** Дмитрий (Алекс-бот)  
**Лицензия:** MIT
=======
### Advanced Settings Page

**Файл:** `advanced_full.html`

**Установка:**

```bash
# Через SSH
ssh admin@192.168.31.133
echo 'admin' | sudo -S cp /home/smile/avalon_patch/advanced_full.html /mnt/heater/www/html/advanced.html
```

**URL:** `http://192.168.31.133/advanced.html`

**Функции:**
- ✨ Privileged API Control - выполнение API команд
- ⚡ Quick Overclock Presets - Stock, Mild, Medium, Extreme
- 🎛️ Work Level Configuration - 0 (обогрев), 1, 2 (майнинг)
- 📊 Real-time мониторинг статуса

>>>>>>> 27a9486a57533d13b3e500a16858898ce7732efc
