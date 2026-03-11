# ⚡ Avalon Nano 3 - СУПЕР РЕЖИМ и скрытые параметры

## 🔍 Найденные скрытые параметры

### Параметры командной строки btcminer:

```bash
# Частота и напряжение
--avalon10-freq <25-800>              # Частота MHz (сток: 500)
--avalon10-voltage <1150-1450>        # Напряжение mV (сток: 1200)
--avalon10-freq-sel <0-4>             # Уровень частоты (сток: ?)
--avalon10-voltage-level <0-75>       # Уровень напряжения (сток: ?)
--avalon10-core-clk-sel <0-1>         # Выбор ядра (0/1)

# Дополнительные
--avalon10-nonce-check                # Проверка nonce
--avalon10-nonce-mask                 # Маска nonce
--avalon10-polling-delay <ms>         # Задержка опроса
--avalon10-roll-enable                # Включить roll

# Отладка
--debug|-D                            # Режим отладки
--verbose                             # Подробный вывод
```

---

## 🎛️ work_level режимы

| work_level | Режим | Описание |
|------------|-------|----------|
| 0 | **Low** | Обогреватель (низкая мощность) |
| 1 | **Medium** | Средний режим |
| 2 | **High** | Майнинг (максимальная мощность) |
| 3+ | **INVALID** | Может блокировать загрузку! |

---

## ⚡ СУПЕР РЕЖИМ (Max Power)

### Параметры для максимального разгона:

```bash
./btcminer \
  --avalon10-freq 800 \
  --avalon10-voltage 1450 \
  --avalon10-freq-sel 4 \
  --avalon10-voltage-level 75 \
  --avalon10-core-clk-sel 1 \
  --listen-api &
```

**Ожидаемый хешрейт:** ~8000+ GH/s (8+ TH/s)

---

## 🔧 Скрипты

### 1. super_mode.sh - СУПЕР РЕЖИМ

```bash
/home/smile/avalon_patch/super_mode.sh 192.168.31.133
```

**Что делает:**
- work_level = 2
- Частота: 800 MHz
- Напряжение: 1450 mV
- Freq Sel: 4
- Voltage Level: 75
- Core Clk Sel: 1

### 2. overclock_miner.sh - Обычный разгон

```bash
/home/smile/avalon_patch/overclock_miner.sh 192.168.31.133
```

**Что делает:**
- work_level = 2
- Частота: 750 MHz
- Напряжение: 1350 mV

---

## 🌡️ Температурные пороги

### Обнаруженные функции:

```
g_target_temp           # Глобальная целевая температура
set_target_temp         # Установка целевой температуры
get_target_temp         # Получение целевой температуры
opt_cutofftemp          # Температура отключения
*Dev Thermal Cutoff     # Термоотключение устройства
```

### levelparam (управление мощностью):

```
levelparam set vf,level:%d,pout:%d,temper:%d,vf:%d-%d:%d:%d:%d
```

**Параметры:**
- `vf` — voltage/frequency
- `level` — work_level (0/1/2)
- `pout` — power output
- `temper` — target temperature

---

## 🎛️ Factory команды

```
factory set %s              # Установка factory параметра
factory set level error     # Ошибка уровня factory
factory get:                # Получение factory параметра
factory_reset_sys           # Сброс к заводским
```

---

## 🔐 Скрытые опции

```
opt_hidden                  # Таблица скрытых опций
opt_avalon12_power_level    # Уровень мощности
```

---

## 📁 Файлы конфигурации

### /data/usrcon/systemcfg.ini

```ini
[syscfg]
work_level = 2              # 0=Low, 1=Medium, 2=High
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

## 🚀 Применение СУПЕР РЕЖИМА

### Через SSH:

```bash
ssh admin@192.168.31.133
# Пароль: admin

# 1. Установить work_level = 2
echo 'admin' | sudo -S sed -i 's/work_level *= *.*/work_level = 2/' /data/usrcon/systemcfg.ini

# 2. Применить СУПЕР разгон
echo 'admin' | sudo -S cp /etc/init.d/rcS /etc/init.d/rcS.bak
echo 'admin' | sudo -S sed -i 's|^\./btcminer .*|./btcminer --avalon10-freq 800 --avalon10-voltage 1450 --avalon10-freq-sel 4 --avalon10-voltage-level 75 --avalon10-core-clk-sel 1 --listen-api \&|' /etc/init.d/rcS

# 3. Проверить
grep btcminer /etc/init.d/rcS

# 4. Перезагрузить
echo 'admin' | sudo -S reboot
```

### Через скрипт:

```bash
chmod +x /home/smile/avalon_patch/super_mode.sh
/home/smile/avalon_patch/super_mode.sh 192.168.31.133
```

---

## 📊 Диагностика

### Проверка статуса:

```bash
# Через API
echo '{"command":"devs"}' | nc -w 3 192.168.31.133 4028 | strings

# Проверка процесса
ssh admin@192.168.31.133 "ps aux | grep btcminer"

# Проверка конфига
ssh admin@192.168.31.133 "cat /data/usrcon/systemcfg.ini | grep work_level"
```

### Ожидаемые значения:

| Параметр | Сток | Разгон | СУПЕР |
|----------|------|--------|-------|
| Частота | 500 MHz | 750 MHz | 800 MHz |
| Напряжение | 1200 mV | 1350 mV | 1450 mV |
| Хешрейт | ~4 TH/s | ~6-7 TH/s | ~8+ TH/s |
| Температура | 50-60°C | 65-75°C | 75-85°C |

---

## ⚠️ Предупреждения

1. **Режим 3+** может блокировать загрузку майнера!
2. **СУПЕР РЕЖИМ** требует хорошего охлаждения
3. **Высокое напряжение** ускоряет деградацию чипов
4. **Следи за температурой** — не выше 85°C!

---

## 🔧 Откат к стоку

```bash
ssh admin@192.168.31.133

# Восстановить rcS
echo 'admin' | sudo -S cp /etc/init.d/rcS.bak /etc/init.d/rcS

# Сбросить work_level
echo 'admin' | sudo -S sed -i 's/work_level *= *.*/work_level = 0/' /data/usrcon/systemcfg.ini

# Перезагрузить
echo 'admin' | sudo -S reboot
```

---

*Документ создан: 2026-03-11*
*На основе анализа прошивки 2025061101*
