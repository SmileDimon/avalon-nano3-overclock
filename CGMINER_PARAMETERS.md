# 🔧 Avalon Nano 3 - CGMiner Parameters Reference

## Полные параметры для btcminer (cgminer 4.11.1)

---

## ✅ Сейчас используется:

```bash
./btcminer --avalon10-freq 700 --avalon10-voltage 1300
```

---

## 🎯 Рекомендуемые дополнительные параметры:

### Для повышения стабильности:

```bash
# Добавить в /etc/init.d/rcS
./btcminer \
  --avalon10-freq 700 \
  --avalon10-voltage 1300 \
  --avalon10-freq-sel 4 \
  --temp-target 75 \
  --fan-min 60 \
  --log-level 3 \
  --api-listen \
  --api-network \
  &
```

---

## 📊 Все доступные параметры Avalon10:

| Параметр | Диапазон | По умолчанию | Описание |
|----------|----------|--------------|----------|
| `--avalon10-freq` | 25-800 MHz | 500 | Частота ASIC |
| `--avalon10-voltage` | 1150-1450 mV | 1200 | Напряжение |
| `--avalon10-freq-sel` | 0-4 | 0 | Уровень PLL |
| `--temp-target` | 50-85 °C | 80 | Целевая температура |
| `--fan-min` | 0-100 % | 40 | Мин. скорость вентилятора |
| `--fan-max` | 0-100 % | 100 | Макс. скорость вентилятора |
| `--log-level` | 0-10 | 5 | Уровень логирования |
| `--api-listen` | - | - | Включить API |
| `--api-network` | - | - | Сетевой API (0.0.0.0:4028) |
| `--no-submit-stale` | - | - | Не отправлять stale шары |
| `--queue N` | 1-10 | 1 | Размер очереди задач |
| `--scan-time N` | 1-60 | 7 | Время сканирования |
| `--expiry N` | 1-999 | 0 | Время экспирации |

---

## 🔥 Продвинутые настройки:

### Вариант 1: Максимальная производительность

```bash
./btcminer \
  --avalon10-freq 712 \
  --avalon10-voltage 1325 \
  --avalon10-freq-sel 4 \
  --temp-target 80 \
  --fan-min 70 \
  --fan-max 100 \
  --queue 3 \
  --scan-time 5 \
  --api-listen \
  &
```

**Ожидаемый хешрейт:** ~7.8-8.2 TH/s  
**Температура:** 75-85°C  
**Риск:** Высокий ⚠️

---

### Вариант 2: Баланс производительность/стабильность

```bash
./btcminer \
  --avalon10-freq 650 \
  --avalon10-voltage 1275 \
  --avalon10-freq-sel 3 \
  --temp-target 70 \
  --fan-min 50 \
  --queue 2 \
  --scan-time 6 \
  --api-listen \
  &
```

**Ожидаемый хешрейт:** ~6.5 TH/s  
**Температура:** 60-70°C  
**Риск:** Средний

---

### Вариант 3: Энергоэффективность

```bash
./btcminer \
  --avalon10-freq 550 \
  --avalon10-voltage 1225 \
  --avalon10-freq-sel 2 \
  --temp-target 65 \
  --fan-min 40 \
  --queue 1 \
  --scan-time 7 \
  --api-listen \
  &
```

**Ожидаемый хешрейт:** ~4.5 TH/s  
**Температура:** 50-60°C  
**Потребление:** ~650W  
**Риск:** Низкий

---

## 🎛️ Настройки пула (Strategy):

### Failover (по умолчанию)
```bash
--failover-only
```
Переключается на следующий пул при ошибке

### Round Robin
```bash
--round-robin
```
Равномерное распределение между пулами

### Load Balance
```bash
--load-balance
```
Балансировка по производительности

---

## ⚙️ CGMiner API команды:

### Через nc (netcat):

```bash
# Информация об устройствах
echo '{"command":"devs"}' | nc -w 3 192.168.31.133 4028 | strings

# Сводка
echo '{"command":"summary"}' | nc -w 3 192.168.31.133 4028 | strings

# Пулы
echo '{"command":"pools"}' | nc -w 3 192.168.31.133 4028 | strings

# Перезапуск
echo '{"command":"restart"}' | nc -w 3 192.168.31.133 4028

# Изменить частоту на лету
echo '{"command":"avalon10freq","freq":650}' | nc -w 3 192.168.31.133 4028

# Изменить напряжение
echo '{"command":"avalon10volt","voltage":1275}' | nc -w 3 192.168.31.133 4028
```

---

## 📈 Мониторинг в реальном времени:

### Скрипт для мониторинга:

```bash
#!/bin/bash
# monitor.sh

MINER_IP="192.168.31.133"

while true; do
    clear
    echo "=== Avalon Nano 3 Monitor ==="
    echo "Time: $(date)"
    echo ""
    
    echo '{"command":"devs"}' | nc -w 2 $MINER_IP 4028 | strings | \
        grep -oE '"Temperature":[0-9.]+|"MHS 5s":[0-9.]+|"Freq":[0-9.]+|"Hardware Errors":[0-9]+'
    
    echo ""
    echo "Press Ctrl+C to stop"
    sleep 5
done
```

---

## 🎯 Применение настроек:

### Через SSH:

```bash
ssh admin@192.168.31.133

sudo -i

# Резервная копия
cp /etc/init.d/rcS /etc/init.d/rcS.bak

# Редактирование
nano /etc/init.d/rcS

# Найти строку:
./btcminer --avalon10-freq 700 --avalon10-voltage 1300 &

# Заменить на нужные параметры

# Сохранить (Ctrl+O, Enter, Ctrl+X)
# Перезагрузиться
reboot
```

---

## ⚠️ Важные замечания:

1. **Температура:** Не превышайте 80°C для длительной работы
2. **Напряжение:** Выше 1350 mV — риск деградации чипов
3. **Частота:** Выше 750 MHz — нестабильность возможна
4. **Вентиляторы:** Минимум 40% для охлаждения радиаторов

---

## 🔬 Экспериментальные параметры:

> ⚠️ Только для тестирования!

```bash
# Разгон с динамической частотой
--avalon10-dynamic-freq 1

# Автоматическая регулировка напряжения
--avalon10-auto-volt 1

# Приоритет производительности
--performance 1

# Отключение температурного троттлинга (ОПАСНО!)
--no-temp-limit 1
```

---

## 📊 Сравнение профилей:

| Профиль | Частота | Напряжение | Хешрейт | Потребление | Temp |
|---------|---------|------------|---------|-------------|------|
| Stock | 500 MHz | 1200 mV | 4.0 TH/s | ~600W | 55°C |
| Light OC | 550 MHz | 1225 mV | 4.5 TH/s | ~650W | 60°C |
| Medium OC | 600 MHz | 1250 mV | 5.5 TH/s | ~720W | 65°C |
| High OC | 650 MHz | 1275 mV | 6.5 TH/s | ~800W | 70°C |
| Extreme | 700 MHz | 1300 mV | 7.5 TH/s | ~900W | 75°C |
| Max Risk | 750 MHz | 1350 mV | 8.5 TH/s | ~1000W | 85°C |

---

**Удачи в настройке! 🚀**
