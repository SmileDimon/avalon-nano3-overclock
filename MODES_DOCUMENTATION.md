# 🎛️ Avalon Nano 3 - Режимы работы и переключение

## 📋 Обнаруженные режимы

### 1. work_level (из systemcfg.ini)

```ini
[syscfg]
work_level = 0  ; 0=Low, 1=Medium, 2=High
```

**Значения:**
- `0` = **Low** — Режим обогревателя (низкая температура/мощность)
- `1` = **Medium** — Средний режим
- `2` = **High** — Режим майнинга (максимальная температура/мощность)

---

### 2. mode (Air Speed — скорость вентилятора)

Из веб-интерфейса (`cgminercfg.html`):

```html
<select name="mode" id="mode">
  <option value="0">Low</option>
  <option value="1">Medium</option>
  <option value="2">High</option>
</select>
```

**mode_count = 3** — количество доступных режимов

---

## 🔄 Переключение режимов

### Кнопка на устройстве

**Двойное нажатие кнопки** переключает **workmode**:

```
button_detect:double_click=%d, switch workmode
```

**Другие нажатия:**
- **Короткое** — переключение страницы LCD
- **Среднее+длинное** — режим точки доступа (AP mode)
- **Длинное** — сброс к заводским настройкам
- **Короткое питание** — переключение LED

---

### Логика переключения

При двойном нажатии:
1. Читается текущий `work_level` из `systemcfg.ini`
2. Увеличивается на 1: `work_level = (work_level + 1) % 3`
3. Сохраняется через `syscfg_set_work_level()`
4. Майнер перезапускается с новыми параметрами

**Цикл:** `0 → 1 → 2 → 0 → ...`

---

## 🌡️ Температурный контроль

### levelparam

```
levelparam set vf,level:%d,pout:%d,temper:%d,vf:%d-%d:%d:%d:%d
```

**Параметры:**
- `vf` — voltage/frequency
- `level` — work_level (0/1/2)
- `pout` — power output
- `temper` — target temperature

### g_target_temp

Глобальная переменная **целевой температуры**.

**Функции:**
- `get_target_temp()` — получить целевую температуру
- `set_target_temp()` — установить целевую температуру

---

## 🔧 Температурные пороги

### Thermal Cutoff

```
*Dev Thermal Cutoff
Device reached thermal cutoff
opt_cutofftemp
```

При достижении **критической температуры** майнер отключается!

---

## 📊 LED индикация режимов

```
led mode:%d, bright:%d, temper:%d, rgb:0x%06X
led_mode_switch
led swmode ok
led setmode ok
```

**LED показывает:**
- `mode` — текущий режим
- `bright` — яркость
- `temper` — температура
- `rgb` — цвет (0xRRGGBB)

---

## 🛠️ Как переключить режим

### Способ 1: Через SSH (быстро)

```bash
ssh admin@192.168.31.133
# Пароль: admin

# Проверить текущий режим
cat /data/usrcon/systemcfg.ini | grep work_level

# Установить режим майнинга (High)
echo 'admin' | sudo -S sed -i 's/work_level *= *0/work_level = 2/' /data/usrcon/systemcfg.ini

# Перезагрузить
echo 'admin' | sudo -S reboot
```

### Способ 2: Кнопкой на устройстве

**Двойное нажатие** кнопки переключает режим по кругу:
- Обогреватель → Medium → Майнинг → Обогреватель → ...

### Способ 3: Через веб-интерфейс

1. Открыть `http://192.168.31.133:9090/`
2. Перейти в **Configuration**
3. Изменить **Air Speed** (mode)
4. Нажать **Confirm**

---

## ⚡ Разгон для режима майнинга

Для максимального хешрейта:

```bash
# 1. Установить work_level = 2
echo 'admin' | sudo -S sed -i 's/work_level *= *0/work_level = 2/' /data/usrcon/systemcfg.ini

# 2. Добавить параметры разгона в rcS
echo 'admin' | sudo -S sed -i 's|^\./btcminer .*|./btcminer --avalon10-freq 750 --avalon10-voltage 1350 --listen-api \&|' /etc/init.d/rcS

# 3. Перезагрузить
echo 'admin' | sudo -S reboot
```

**Параметры:**
- `--avalon10-freq 750` — частота 750 MHz (сток: 500)
- `--avalon10-voltage 1350` — напряжение 1350 mV (сток: 1200)
- `--listen-api` — включить API на порту 4028

---

## 📁 Файлы конфигурации

| Файл | Описание |
|------|----------|
| `/data/usrcon/systemcfg.ini` | Основная конфигурация (work_level) |
| `/etc/init.d/rcS` | Скрипт запуска btcminer |
| `/mnt/heater/app/btcminer` | Бинарник майнера |

---

## 🔍 Диагностика

### Проверка режима

```bash
# Через SSH
cat /data/usrcon/systemcfg.ini | grep work_level

# Через API
echo '{"command":"config"}' | nc -w 3 192.168.31.133 4028 | strings
```

### Проверка температуры

```bash
echo '{"command":"devs"}' | nc -w 3 192.168.31.133 4028 | strings | grep -i temp
```

### Проверка процесса

```bash
ps aux | grep btcminer
# Должно вывести: ./btcminer --avalon10-freq 750 --avalon10-voltage 1350
```

---

## 📝 Выводы

1. **work_level = 0** — это режим **обогревателя** (низкая мощность)
2. **work_level = 2** — это режим **майнинга** (максимальная мощность)
3. **Двойное нажатие кнопки** переключает режимы по кругу
4. Для разгона нужно изменить **work_level** и добавить параметры в **rcS**

---

*Документ создан на основе анализа прошивки 2026-03-11*
