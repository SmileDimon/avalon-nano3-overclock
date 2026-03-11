# 📱 Android приложение Canaan/Avalon - Исследование

## 🔍 Где найти приложение

### Официальные источники:

1. **Google Play Store:**
   - Поиск: "Canaan" или "Avalon"
   - Разработчик: Canaan Creative

2. **APK Pure:**
   - https://apkpure.com/search?q=canaan%20avalon

3. **GitHub Canaan:**
   - https://github.com/Canaan-Creative

---

## 🔬 Как исследовать приложение

### Способ 1: APK анализ

**APK это ZIP архив!**

```bash
# 1. Скачать APK
# 2. Переименовать в .zip
unzip avalon-app.apk -d avalon-app-extracted/

# 3. Исследовать файлы
ls -la avalon-app-extracted/
cat avalon-app-extracted/assets/*.json 2>/dev/null
cat avalon-app-extracted/res/values/strings.xml
```

**Что искать:**
- API endpoints
- Порты подключения
- Команды к майнеру
- Зашифрованные ключи

---

### Способ 2: Перехват трафика

**Через tcpdump на майнере:**

```bash
ssh admin@192.168.31.133

# Запустить перехват
echo 'admin' | sudo -S tcpdump -i any -s 0 -w /tmp/miner_traffic.pcap port 4028

# Открыть приложение и подключить к майнеру
# Остановить tcpdump (Ctrl+C)

# Скопировать файл
scp admin@192.168.31.133:/tmp/miner_traffic.pcap /home/smile/

# Анализировать в Wireshark
wireshark miner_traffic.pcap
```

**Через proxy на компьютере:**

1. Установить **mitmproxy** или **Burp Suite**
2. Настроить телефон на использование proxy
3. Запустить приложение
4. Анализировать запросы

---

### Способ 3: Decompilation APK

**Инструменты:**
- **JADX** - декомпилятор APK в Java
- **APKTool** - распаковка ресурсов
- **Bytecode Viewer** - просмотр байт-кода

**JADX:**

```bash
# Скачать: https://github.com/skylot/jadx
jadx-gui avalon-app.apk

# Или в командной строке
jadx -d avalon-src avalon-app.apk
```

**Что искать в коде:**

```java
// Поиск API команд
"privileged"
"ascset"
"setconfig"
"set_test_mode"

// Поиск портов
4028
80
9090

// Поиск URL
"http://"
"canaan"
"avalon"
```

---

## 🎯 Что скорее всего делает приложение

### Локальное подключение:

```
Телефон (WiFi) → Майнер (порт 4028)
```

**Команды которые использует приложение:**

1. **summary** - Общая статистика
2. **devs** - Статус устройств
3. **pools** - Информация о пулах
4. **config** - Конфигурация
5. **privileged** - Изменение настроек

### Обнаруженные API endpoints:

| Endpoint | Порт | Описание |
|----------|------|----------|
| `/get_minerinfo.cgi` | 80 | Получение информации |
| API JSON | 4028 | Прямые команды cgminer |
| SWUpdate | 9090 | Обновление прошивки |

---

## 🔐 Privileged доступ в приложении

**Скорее всего приложение:**

1. Подключается к порту **4028**
2. Отправляет JSON команды:
   ```json
   {"command":"privileged","arg":"ascset=0,750,1350"}
   ```
3. Получает ответ:
   ```json
   {"STATUS":[{"Code":46,"Msg":"Privileged access OK"}]}
   ```

**Почему у приложения есть доступ:**

- Приложение использует **встроенные privileged команды**
- Команды **не задокументированы** для пользователей
- Canaan использует их для сервисных функций

---

## 📋 План исследования

### 1. Скачать приложение

```
Google Play: "Canaan" или "Avalon"
APK Pure: https://apkpure.com/
```

### 2. Декомпилировать

```bash
jadx -d canaan-app canaan-app.apk
```

### 3. Найти API команды

```bash
grep -r "privileged\|ascset\|4028" canaan-app/
```

### 4. Перехватить трафик

```bash
tcpdump -i any -s 0 -w /tmp/app_traffic.pcap host 192.168.31.133
```

### 5. Проанализировать

- Какие команды отправляет?
- Какие параметры использует?
- Есть ли скрытые функции?

---

## 🎁 Что это нам даст

### Найденные функции:

1. **Официальные privileged команды** от Canaan
2. **Скрытые настройки** которые не показаны в веб-интерфейсе
3. **Безопасные параметры** разгона от производителя
4. **Дополнительные API endpoints**

### Интеграция:

- Добавить найденные команды в `advanced.html`
- Создать пресеты на основе официальных
- Документировать все обнаруженные функции

---

## 📸 Как показать мне приложение

### Вариант 1: Скриншоты

1. Открой приложение
2. Покажи все экраны/настройки
3. Загрузи на imgur.com
4. Скинь ссылку

### Вариант 2: Экспорт настроек

1. Найди в приложении экспорт конфигурации
2. Скопируй JSON/XML файл
3. Покажи содержимое

### Вариант 3: APK файл

1. Скачай APK
2. Загрузи на файлообменник
3. Скинь ссылку
4. Я исследую

---

## 🔗 Ссылки

- **Canaan GitHub:** https://github.com/Canaan-Creative
- **Canaan Shop:** https://shop.canaan.io
- **Canaan Support:** https://canaan.io/support
- **APK Pure:** https://apkpure.com/
- **JADX:** https://github.com/skylot/jadx

---

*Инструкция создана: 2026-03-11*
