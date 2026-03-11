# 🚀 Avalon Nano 3 Overclock - Полная Инструкция

## 📋 Что было сделано:

1. **Распакована оригинальная прошивка** heater_nano3_master_image.img
2. **Изучены файлы** btcminer, systemcfg.ini, cgminercfg.html
3. **Найдены параметры разгона:**
   - `--avalon10-freq [25-800]` - частота в MHz
   - `--avalon10-voltage [1150-1450]` - напряжение в mV
   - `--avalon10-freq-sel [0-4]` - уровень частоты
   - `work_level [0-2]` - режим работы (Low/Medium/High)

4. **Модифицированы файлы:**
   - `cgminercfg.html` - разблокированы Medium/High, добавлена страница разгона
   - `systemcfg.ini` - work_level = 2 по умолчанию
   - `overclock.cgi` - CGI скрипт для обработки запросов

---

## ⚡ Быстрая установка (через SSH):

```bash
cd /home/smile/avalon_patch
./install_overclock_ssh.sh YOUR_MINER_IP
```

**Что сделает скрипт:**
- Скопирует модифицированный HTML на майнер
- Изменит work_level на 2 (High)
- Добавит параметры `--avalon10-freq 700 --avalon10-voltage 1300`
- Перезагрузит майнер

---

## 🔧 Ручная установка (по шагам):

### Шаг 1: Подключение по SSH
```bash
ssh admin@YOUR_MINER_IP
# пароль: admin

sudo -i
# пароль: admin
```

### Шаг 2: Изменение work_level
```bash
sed -i 's/work_level *= *.*/work_level = 2/' /data/usrcon/systemcfg.ini
cat /data/usrcon/systemcfg.ini | grep work_level
# Должно показать: work_level = 2
```

### Шаг 3: Добавление параметров разгона
```bash
# Резервная копия
cp /etc/init.d/rcS /etc/init.d/rcS.bak

# Изменение строки запуска
sed -i 's|./btcminer \&|./btcminer --avalon10-freq 700 --avalon10-voltage 1300 \&|' /etc/init.d/rcS

# Проверка
grep btcminer /etc/init.d/rcS
```

### Шаг 4: Обновление веб-интерфейса (опционально)
```bash
# Копирование модифицированного HTML
cp /home/smile/avalon_patch/heater/www/html/cgminercfg.html /mnt/heater/www/html/
```

### Шаг 5: Установка CGI скрипта (опционально)
```bash
# Копирование overclock.cgi
cp /home/smile/avalon_patch/overclock.cgi /mnt/heater/www/cgi-bin/
chmod +x /mnt/heater/www/cgi-bin/overclock.cgi
```

### Шаг 6: Перезагрузка
```bash
reboot
```

---

## 📊 Проверка после разгона:

### Через API cgminer:
```bash
echo '{"command": "devs"}' | nc YOUR_MINER_IP 4028 | strings
```

**Ожидаемый результат:**
- `MHS 5s`: ~7000000-8000000 (7-8 TH/s)
- `Freq`: 700.00

### Через SSH:
```bash
ssh admin@YOUR_MINER_IP
ps aux | grep btcminer
# Должно показать: ./btcminer --avalon10-freq 700 --avalon10-voltage 1300
```

---

## 🎯 Рекомендуемые профили разгона:

| Профиль | Частота | Напряжение | Хешрейт | Температура | Риск |
|---------|---------|------------|---------|-------------|------|
| **Стоковый** | 500 MHz | 1200 mV | ~4 TH/s | 50-60°C | Минимальный |
| **Лёгкий** | 550 MHz | 1225 mV | ~4.5 TH/s | 55-65°C | Низкий |
| **Средний** | 600 MHz | 1250 mV | ~5.5 TH/s | 60-70°C | Средний |
| **Высокий** | 650 MHz | 1275 mV | ~6.5 TH/s | 65-75°C | Высокий |
| **Экстрим** | 700 MHz | 1300 mV | ~7.5 TH/s | 70-80°C | Очень высокий |
| **Битакс стиль** | 712 MHz | 1300 mV | ~7.8 TH/s | 75-85°C | Экстремальный |

**Для изменения профиля** отредактируйте строку в `/etc/init.d/rcS`:
```bash
# Пример для 600 MHz / 1250 mV
sed -i 's|./btcminer.*|./btcminer --avalon10-freq 600 --avalon10-voltage 1250 \&|' /etc/init.d/rcS
```

---

## ⚠️ Предупреждения:

1. **Перегрев** - следите за температурой!
2. **Износ** - высокий вольтаж сокращает срок службы
3. **Гарантия** - разгон аннулирует гарантию
4. **Нестабильность** - при слишком высоком разгоне возможны ошибки

**Рекомендуется:**
- Начинать с 550 MHz / 1225 mV
- Постепенно повышать частоту
- Следить за Hardware Errors в API
- Обеспечить хорошее охлаждение

---

## 🔙 Восстановление (если что-то пошло не так):

### Сброс настроек:
```bash
ssh admin@YOUR_MINER_IP
sudo -i

# Сброс work_level
sed -i 's/work_level *= *.*/work_level = 0/' /data/usrcon/systemcfg.ini

# Сброс параметров btcminer
sed -i 's|./btcminer --avalon10.*|./btcminer \&|' /etc/init.d/rcS

reboot
```

### Полная перепрошивка:
Используйте оригинальный образ и KendryteBurningTool.

---

## 📁 Файлы в пакете:

```
/home/smile/avalon_patch/
├── README.md                      # Документация
├── install_overclock_ssh.sh       # Скрипт быстрой установки
├── build_patched_firmware.sh      # Скрипт сборки прошивки
├── overclock.cgi                  # CGI скрипт для веб-интерфейса
└── heater/
    ├── www/html/cgminercfg.html   # Модифицированный веб-интерфейс
    └── confiles/usrcon/systemcfg.ini  # Конфиг с work_level=2
```

---

## 📞 Источники:

- Документация: https://orca.pet/nanojb/
- cgminer: https://github.com/ckolivas/cgminer
- Официальная прошивка: heater_nano3_master_image.img

---

**Удачи в разгоне! 🚀**
