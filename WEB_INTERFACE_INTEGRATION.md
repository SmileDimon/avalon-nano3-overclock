# 🌐 Интеграция Advanced Settings в веб-интерфейс Avalon Nano 3

## 📁 Файлы для интеграции

### 1. advanced.html

**Путь:** `/mnt/heater/www/html/advanced.html`

**Что делает:** Страница расширенных настроек с доступом к Privileged API

**Функции:**
- Выполнение Privileged API команд
- Быстрые пресеты разгона (Stock, Mild, Medium, Extreme)
- Управление work_level
- Мониторинг статуса в реальном времени

---

## 🔧 Установка

### Шаг 1: Копирование файла

```bash
# Через SSH
ssh admin@192.168.31.133

# Копирование файла
echo 'admin' | sudo -S cp /home/smile/avalon_patch/advanced_full.html /mnt/heater/www/html/advanced.html
echo 'admin' | sudo -S chmod 644 /mnt/heater/www/html/advanced.html
```

### Шаг 2: Добавление в меню

Нужно модифицировать **cgminercfg.html** или **index.html** чтобы добавить ссылку на Advanced:

```bash
# Через SSH
echo 'admin' | sudo -S nano /mnt/heater/www/html/cgminercfg.html
```

Найти меню навигации и добавить:

```html
<li><i>&gt;</i><strong pageid="advanced" onclick="tabChange(this);">Advanced</strong></li>
```

Или создать отдельную ссылку:

```html
<a href="advanced.html" target="_blank">Advanced Settings</a>
```

### Шаг 3: Проверка CGI обработчика

**get_minerinfo.cgi** уже существует в прошивке!

Проверь что он работает:

```bash
curl 'http://192.168.31.133/get_minerinfo.cgi?cmd=version'
```

---

## 🎛️ Функции Advanced страницы

### 1. Privileged API Control

**Выполнение команд:**

| Команда | Описание | Аргумент |
|---------|----------|----------|
| `edevs` | Расширенный статус устройств | Нет |
| `summary` | Общая статистика майнера | Нет |
| `devs` | Статистика устройств | Нет |
| `config` | Текущая конфигурация | Нет |
| `set_test_mode=1` | Включить тестовый режим | Нет |
| `debug=1` | Включить отладку | Нет |
| `ascset` | Установка частоты/напряжения ASIC | `0,750,1350` |
| `setconfig` | Установка конфигурации | `--avalon10-freq 800` |
| `dorestart` | Перезапуск ASIC | `0` |
| `dosave` | Сохранить конфигурацию | Нет |

### 2. Quick Overclock Presets

**Предустановки:**

| Пресет | Частота | Напряжение | Описание |
|--------|---------|------------|----------|
| Stock | 500 MHz | 1200 mV | Стоковые настройки |
| Mild OC | 650 MHz | 1275 mV | Лёгкий разгон |
| Medium OC | 750 MHz | 1350 mV | Средний разгон |
| Extreme OC | 800 MHz | 1450 mV | Максимальный разгон |

### 3. Work Level Configuration

**Режимы:**

| Work Level | Режим | Описание |
|------------|-------|----------|
| 0 | Low | Обогреватель (низкая мощность) |
| 1 | Medium | Средний режим |
| 2 | High | Майнинг (максимальная мощность) |

---

## 🔌 Альтернативный доступ

### Через браузер (прямой доступ к API)

Открыть консоль браузера (F12) и выполнить:

```javascript
// Проверка статуса
fetch('/get_minerinfo.cgi?cmd=edevs')
  .then(r => r.json())
  .then(d => console.log(d));

// Применение разгона
fetch('/get_minerinfo.cgi?cmd=privileged&arg=ascset=0,800,1450')
  .then(r => r.json())
  .then(d => console.log(d));
```

### Через curl

```bash
# Проверка статуса
curl 'http://192.168.31.133/get_minerinfo.cgi?cmd=devs'

# Применение разгона
curl 'http://192.168.31.133/get_minerinfo.cgi?cmd=privileged&arg=ascset=0,800,1450'

# Включение тестового режима
curl 'http://192.168.31.133/get_minerinfo.cgi?cmd=privileged&arg=set_test_mode=1'
```

---

## 📝 Модификация меню (детали)

### Вариант 1: Добавление в основное меню

Открыть `/mnt/heater/www/html/cgminercfg.html`:

```html
<!-- Найти блок меню -->
<ul class="menu" id="">
  <li><i>&gt;</i><strong pageid="dashboard" onclick="tabChange(this);">Overview</strong></li>
  <li><i>&gt;</i><strong pageid="cgconf" onclick="tabChange(this);">Configuration</strong></li>
  <li><i>&gt;</i><strong pageid="network" onclick="tabChange(this);">Network</strong></li>
  <li><i>&gt;</i><strong pageid="cglog" onclick="tabChange(this);">Log</strong></li>
  <!-- ДОБАВИТЬ: -->
  <li><i>&gt;</i><strong pageid="advanced" onclick="window.open('advanced.html','_blank');">Advanced</strong></li>
</ul>
```

### Вариант 2: Отдельная ссылка в System

```html
<ul class="menu-ch">
  <li><i>&gt;&gt;</i><strong pageid="admin" onclick="tabChange(this);">Password</strong></li>
  <li><i>&gt;&gt;</i><strong pageid="upgrade" onclick="tabChange(this);">Upgrade</strong></li>
  <li><i>&gt;&gt;</i><strong onclick="window.open('advanced.html','_blank');">Advanced</strong></li>
  <li><i>&gt;&gt;</i><strong pageid="reboot1" onclick="reboot(this);">Reboot</strong></li>
</ul>
```

---

## ⚠️ Важные замечания

1. **CGI обработчик** `get_minerinfo.cgi` уже существует в прошивке
2. **Privileged команды** требуют прав администратора
3. **Изменения через API** временные — для постоянных нужна модификация конфигов
4. **Температура** — следи за перегревом при разгоне!

---

## 🔄 Обновление страницы

Если нужно обновить advanced.html:

```bash
ssh admin@192.168.31.133
echo 'admin' | sudo -S cp /tmp/advanced_full.html /mnt/heater/www/html/advanced.html
# Перезагрузить веб-сервер или майнер
echo 'admin' | sudo -S reboot
```

---

## 🎯 Быстрый доступ после установки

**URL:** `http://192.168.31.133/advanced.html`

Или через меню **Advanced** в веб-интерфейсе!

---

*Инструкция создана: 2026-03-11*
*Для прошивки 2025061101*
