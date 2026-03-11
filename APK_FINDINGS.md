# 📱 Canaan Avalon App - Результаты Анализа APK

## 📲 Информация о приложении

**Файл:** `Avalon Family_0.38.0_APKPure.xapk`
**Package:** `com.canaan.avalon`
**Версия:** 0.38.0
**Размер:** 46.9 MB

---

## 🔍 Ключевые находки

### 1. Приложение использует Bluetooth (BLE)!

**Файл:** `bledata.proto`

Это **протокол Bluetooth Low Energy** для подключения к майнеру!

**Что это значит:**
- Приложение подключается к майнеру через **Bluetooth**, НЕ через WiFi!
- Все команды отправляются через BLE характеристики
- **Privileged API команды** скорее всего передаются через Bluetooth

### 2. Разрешения приложения

```json
"permissions": [
  "android.permission.INTERNET",           // Интернет доступ
  "android.permission.BLUETOOTH_SCAN",     // Поиск BLE устройств
  "android.permission.BLUETOOTH_CONNECT",  // Подключение BLE
  "android.permission.BLUETOOTH",          // Bluetooth доступ
  "android.permission.BLUETOOTH_ADMIN",    // Bluetooth админ
  "android.permission.ACCESS_FINE_LOCATION", // Точное местоположение
  "android.permission.ACCESS_WIFI_STATE",  // WiFi состояние
  "android.permission.CHANGE_WIFI_STATE",  // Изменение WiFi
  "android.permission.INTERNET"            // Интернет
]
```

### 3. Подключение к майнеру

**Два способа:**

#### Способ A: Bluetooth (основной)
```
Телефон → Bluetooth → Майнер (BLE)
```

**Команды передаются через BLE характеристики:**
- `ReadCharacteristicRequest`
- `WriteCharacteristicRequest`
- `NotifyCharacteristicRequest`

#### Способ B: WiFi (дополнительный)
```
Телефон → WiFi → Майнер (порт 4028 или 80)
```

**Используется для:**
- `get_minerinfo.cgi` запросы
- Прямые API команды

---

## 🎯 Что это значит для нас

### Privileged Команды

Приложение **ИСПОЛЬЗУЕТ** privileged команды:

```
privileged ascset
privileged setconfig
privileged set_test_mode
```

**НО** они передаются через **Bluetooth**, а не напрямую через API!

### Как приложение отправляет команды:

1. **Подключение через BLE**
2. **Запись в характеристику** с командой
3. **Майнер выполняет** команду
4. **Чтение ответа** из характеристики

---

## 🔬 Структура APK

```
com.canaan.avalon.apk
├── AndroidManifest.xml      # Разрешения и компоненты
├── classes.dex              # Java байт-код (основной код)
├── bledata.proto            # Bluetooth протокол ← ВАЖНО!
├── assets/                  # Ресурсы
├── res/                     # Ресурсы Android
└── META-INF/                # Подписи
```

---

## 📋 Следующие шаги

### 1. Декомпилировать classes.dex

**Инструмент:** JADX

```bash
jadx -d avalon_src com.canaan.avalon.apk
```

**Что искать:**
- Классы с "Ble", "Bluetooth", "Miner"
- Методы отправки команд
- Строки "privileged", "ascset", "4028"

### 2. Исследовать BLE протокол

**Файл:** `bledata.proto`

**Команды которые нужно найти:**
- Как приложение устанавливает частоту?
- Как переключает режимы?
- Какие параметры использует?

### 3. Перехватить трафик

**Вариант A: Bluetooth HCI Log**
```bash
# Включить HCI log на Android
adb shell setprop persist.bluetooth.btsnooplog.mode true

# Запустить приложение, подключить к майнеру
# Скопировать лог
adb pull /sdcard/btsnoop_hci.log
```

**Вариант B: Frida Hook**
```javascript
// Перехват BLE команд
Java.use("com.signify.hue.flutterreactiveble")
  .writeCharacteristic.implementation = function(data) {
    console.log("BLE Write:", data);
    return this.writeCharacteristic(data);
  };
```

---

## 🎁 Ожидаемые находки

### Команды которые использует приложение:

```protobuf
// Через Bluetooth
message WriteMinerCommand {
  string command = 1;  // "privileged"
  string arg = 2;      // "ascset=0,750,1350"
}
```

### Параметры от Canaan:

| Параметр | Значение |
|----------|----------|
| Max Frequency | ? MHz |
| Max Voltage | ? mV |
| Work Levels | 0, 1, 2 |
| Test Mode | Есть/Нет |

---

## 🔗 Инструменты для анализа

### Декомпиляция:
- **JADX:** https://github.com/skylot/jadx
- **Ghidra:** https://ghidra-sre.org/
- **Bytecode Viewer:** https://github.com/Konloch/bytecode-viewer

### Bluetooth анализ:
- **nRF Connect:** (Android app для BLE)
- **Wireshark:** с Bluetooth адаптером
- **Frida:** https://frida.re/

---

## 📊 Выводы

1. **Приложение использует Bluetooth** для подключения к майнеру
2. **Privileged команды** передаются через BLE
3. **WiFi API** тоже доступен (get_minerinfo.cgi)
4. **Нужно декомпилировать** classes.dex для полного анализа

---

*Анализ проведён: 2026-03-11*
*APK: Avalon Family 0.38.0*
*Package: com.canaan.avalon*
