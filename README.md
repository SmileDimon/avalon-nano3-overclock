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

---

## 🌐 Веб-интерфейс

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
