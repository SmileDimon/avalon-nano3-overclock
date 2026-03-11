# 🌐 Установка Advanced Settings в веб-интерфейс

## 📋 Быстрая установка

### 1️⃣ Копирование файла

```bash
ssh admin@192.168.31.133
echo 'admin' | sudo -S cp /home/smile/avalon_patch/advanced_full.html /mnt/heater/www/html/advanced.html
echo 'admin' | sudo -S chmod 644 /mnt/heater/www/html/advanced.html
exit
```

### 2️⃣ Открыть в браузере

```
http://192.168.31.133/advanced.html
```

---

## 🎯 Что даёт Advanced страница

### Privileged API Control

Выполняй API команды прямо из браузера:

- `edevs` - Расширенный статус устройств
- `summary` - Общая статистика
- `privileged ascset=0,750,1350` - Разгон ASIC
- `privileged set_test_mode=1` - Тестовый режим
- `privileged debug=1` - Режим отладки

### Quick Overclock Presets

Одна кнопка - готовый разгон:

| Кнопка | Частота | Напряжение |
|--------|---------|------------|
| Stock | 500 MHz | 1200 mV |
| Mild OC | 650 MHz | 1275 mV |
| Medium OC | 750 MHz | 1350 mV |
| Extreme OC | 800 MHz | 1450 mV |

### Work Level Configuration

Переключение режимов:

- **0** = Обогреватель (низкая мощность)
- **1** = Medium (средняя)
- **2** = Майнинг (максимальная)

---

## ⚠️ Важно

1. **Privileged команды** работают через API на порту 4028
2. **Разгон через API** временный - до перезагрузки
3. Для **постоянного разгона** нужно модифицировать `/etc/init.d/rcS`
4. Следи за **температурой** при разгоне!

---

## 🔧 Интеграция в меню (опционально)

Чтобы добавить ссылку в основное меню:

```bash
ssh admin@192.168.31.133
echo 'admin' | sudo -S nano /mnt/heater/www/html/cgminercfg.html
```

Найти меню и добавить:

```html
<li><i>&gt;</i><strong onclick="window.open('advanced.html','_blank');">Advanced</strong></li>
```

---

## 📊 Примеры использования

### 1. Проверка статуса

1. Выбрать команду: `edevs`
2. Нажать **Execute**
3. Получить JSON со статусом устройств

### 2. Применение разгона

1. Выбрать пресет: **Medium OC (750 MHz)**
2. Нажать **Apply Medium OC**
3. Проверить статус через `edevs`

### 3. Включение тестового режима

1. Выбрать команду: `privileged_set_test_mode`
2. Нажать **Execute**
3. Режим включён до перезагрузки

---

*Инструкция: 2026-03-11*
*GitHub: https://github.com/SmileDimon/avalon-nano3-overclock*
