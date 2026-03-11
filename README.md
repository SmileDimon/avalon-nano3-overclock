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

---

## 🌐 Веб-интерфейс

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

