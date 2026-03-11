# 🔬 Avalon Nano 3 - Firmware Dump & Analysis Guide

> **Версия:** 1.0  
> **Дата:** 2026-03-08  
> **Описание:** Полный процесс дампинга, анализа и модификации прошивки Avalon Nano 3

---

## 📋 Содержание

1. [Что понадобится](#что-понадобится)
2. [Извлечение прошивки](#извлечение-прошивки)
3. [Анализ структуры](#анализ-структуры)
4. [Модификация файлов](#модификация-файлов)
5. [Сборка обратно](#сборка-обратно)
6. [Инструменты](#инструменты)

---

## 🛠️ Что понадобится

### Оборудование:
- ПК с Windows (для KendryteBurningTool)
- USB кабель (для режима восстановления)
- Avalon Nano 3 майнер

### Программы:
- **KendryteBurningTool-AvalonNano3** — для прошивки
- **Zadig** — драйверы USB
- **binwalk** — анализ прошивки
- **ubireader** — работа с UBI разделами
- **Python 3** — для скриптов

### Файлы:
- Оригинальная прошивка: `heater_nano3_master_image.img` (128 MB)
- Патченная прошивка: `heater_nano3_all_2025103101_151231-patched.swu` (48 MB)

---

## 📥 Извлечение прошивки

### Шаг 1: Скачивание оригинальной прошивки

**Источник:** Android приложение Avalon (через update.json)
```
https://sinh1-aws-app01.s3.ap-southeast-1.amazonaws.com/app/update.json
```

Или найти в интернете:
- `heater_nano3_master_image.img` — полный дамп NAND (128 MB)
- `heater_nano3_all_*.swu` — SWUpdate образ (~48 MB)

---

### Шаг 2: Анализ через binwalk

```bash
binwalk -e heater_nano3_master_image.img
```

**Результат:**
```
DECIMAL    HEXADECIMAL    DESCRIPTION
0          0x0            UBI Image
20971520   0x1400000      UBI Image (app partition)
```

---

### Шаг 3: Извлечение UBI разделов

```bash
# Создаём папку для извлечения
mkdir -p extracted
cd extracted

# Извлекаем UBI
ubireader_extract_files -k -o ./ubi_extracted ../heater_nano3_master_image.img
```

**Структура после извлечения:**
```
ubi_extracted/
├── 754184207/           # App partition
│   └── ubi_app_part_a/
│       └── heater/
│           ├── app/btcminer
│           ├── www/html/
│           └── confiles/
├── 1901852473/          # RootFS partition
│   └── ubi_rootfs_part_a/
│       ├── etc/
│       ├── usr/
│       └── bin/
└── 1348322100/          # Data partition
    └── ubi_data_part/
```

---

## 🔍 Анализ структуры

### Основные разделы NAND:

| Раздел | Смещение | Размер | Описание |
|--------|----------|--------|----------|
| **U-Boot** | 0x0 | 1 MB | Загрузчик |
| **Kernel** | 0x100000 | 4 MB | Ядро Linux |
| **RootFS** | 0x500000 | ~50 MB | Корневая ФС |
| **App** | 0x1400000 | ~50 MB | Приложение (heater) |
| **Data** | 0x2800000 | ~20 MB | Данные (настройки) |

---

### Ключевые файлы для модификации:

#### 1. `/etc/init.d/rcS` — Скрипт инициализации
```bash
# Здесь запускается btcminer
./btcminer &
```

#### 2. `/data/usrcon/systemcfg.ini` — Конфигурация
```ini
[syscfg]
work_level = 2    # 0=Low, 1=Medium, 2=High
webuser = root
webpass = ff0000ff4813494d137e1631bba301d5
```

#### 3. `/mnt/heater/www/html/` — Веб-интерфейс
- `cgminercfg.html` — Настройки майнера
- `overview.html` — Главная страница
- `login.html` — Вход

#### 4. `/usr/bin/btcminer` — Бинарник майнера
```bash
# Параметры разгона:
--avalon10-freq 700        # Частота MHz
--avalon10-voltage 1300    # Напряжение mV
--listen-api               # Включить API
```

---

## ✏️ Модификация файлов

### Патч 1: Добавление SSH (dropbear)

**Файл:** `build-dropbear.sh`
```bash
#!/bin/bash
# Скачиваем и компилируем dropbear для K230
wget https://matt.ucc.asn.au/dropbear/releases/dropbear-2025.88.tar.bz2
wget https://kendryte-download.canaan-creative.com/k230/toolchain/Xuantie-900-gcc-linux-5.10.4-glibc-x86_64-V2.6.0.tar.bz2

# Компилируем
export CC=./Xuantie-900-gcc-linux-5.10.4-glibc-x86_64-V2.6.0/bin/riscv64-unknown-linux-gnu-gcc
./configure --host riscv64-unknown-linux
make -j$(nproc)
```

---

### Патч 2: Изменение work_level

**Файл:** `heater/confiles/usrcon/systemcfg.ini`
```ini
[syscfg]
work_level = 2
```

---

### Патч 3: Разгон в rcS

**Файл:** `heater/confiles/etc/init.d/rcS`
```bash
# Было:
./btcminer &

# Стало:
./btcminer --avalon10-freq 700 --avalon10-voltage 1300 --listen-api &
```

---

### Патч 4: Модификация веб-интерфейса

**Файл:** `heater/www/html/cgminercfg.html`

**Изменения:**
- Разблокировать Medium/High режимы
- Добавить страницу Overclock Settings
- Изменить частоты в dropdown

```html
<!-- Было -->
<option value="0">Low</option>

<!-- Стало -->
<option value="0">Low</option>
<option value="1">Medium</option>
<option value="2">High</option>
```

---

## 📦 Сборка обратно

### Вариант 1: Создание SWU образа

```bash
#!/bin/bash
# build-patched-firmware.sh

# 1. Создаём UBIFS образ
mkfs.ubifs -r heater/ -o app_a.ubi \
    -m 2048 -e 126976 -c 2048

# 2. Создаём UBI контейнер
ubinize -o patched.swu -m 2048 -p 128KiB -s 512 ubinize.cfg

# 3. Вставляем в оригинальный образ
dd if=patched.swu of=heater_nano3_master_image_PATCHED.img \
    bs=1 seek=0x1400000 conv=notrunc
```

---

### Вариант 2: Прямая модификация IMG

```bash
# 1. Извлекаем раздел
dd if=heater_nano3_master_image.img of=app_partition.img \
    bs=1 skip=0x1400000 count=0x1400000

# 2. Модифицируем файлы (через ubireader)
ubireader_extract_files -k app_partition.img

# 3. Вносим изменения
# ... редактируем файлы ...

# 4. Собираем обратно
ubinize -o new_app.img -m 2048 -p 128KiB ubinize.cfg

# 5. Вставляем в образ
dd if=new_app.img of=heater_nano3_master_image.img \
    bs=1 seek=0x1400000 conv=notrunc
```

---

## 🧪 Проверка

### Перед прошивкой:

```bash
# Проверить размер
ls -lh heater_nano3_master_image_PATCHED.img
# Должно быть ~128 MB

# Проверить контрольную сумму
sha256sum heater_nano3_master_image_PATCHED.img
```

### После прошивки:

```bash
# Проверить версию
cat /etc/version

# Проверить btcminer
ps aux | grep btcminer

# Проверить разгон
echo '{"command":"devs"}' | nc -w 3 192.168.31.133 4028 | strings
```

---

## 🛠️ Инструменты

### Установить в Ubuntu:

```bash
sudo apt-get install -y \
    binwalk \
    ubi-reader \
    mtd-utils \
    python3 \
    git \
    wget
```

### Python модули:

```bash
pip3 install ubi-reader
```

---

## 📁 Структура проекта

```
/home/smile/Загрузки/avalon/
├── heater_nano3_all_2025103101_151231-patched.img   # Полный дамп (128M)
├── heater_nano3_all_2025103101_151231-patched.swu   # SWUpdate (48M)
├── extracted/                                        # Извлечённые файлы
│   └── _heater_nano3_all_*.img.extracted/
│       └── 1400000.ubi
├── ubi_extracted/                                    # UBI разделы
│   ├── 754184207/ubi_app_part_a/heater/
│   └── 1901852473/ubi_rootfs_part_a/
└── swu_contents/                                     # Содержимое SWU
```

---

## ⚠️ Предупреждения

1. **Всегда делайте бэкап** оригинальной прошивки!
2. **Не прерывайте прошивку** — может превратиться в кирпич
3. **Проверяйте контрольные суммы** перед записью
4. **Используйте ИБП** — отключение питания фатально

---

## 🔗 Источники

- [orca.pet/nanojb/](https://orca.pet/nanojb/) — Оригинальное исследование
- [GitHub: Avalon Nano 3 Tools](https://github.com/)
- [Canaan Kendryte](https://kendryte.com/) — Документация K230
- [UBI Reader](https://github.com/jrspruitt/ubi_reader)

---

**Удачи во вскрытии! 🔓**
