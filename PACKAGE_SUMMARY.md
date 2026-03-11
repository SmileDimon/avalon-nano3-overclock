# 📦 Avalon Nano 3 Patch Package - Содержание

## Файлы в пакете

| Файл | Описание | Размер |
|------|----------|--------|
| `README.md` | Полная документация на английском | 8.8 KB |
| `README_RU.md` | Полная документация на русском | 12 KB |
| `apply_patches.sh` | Автоматический скрипт установки | 7.9 KB |
| `install_overclock_ssh.sh` | Скрипт установки через SSH | 2.9 KB |
| `INSTRUCTION.md` | Подробная инструкция | 6.1 KB |
| `QUICK_START.md` | Быстрый старт | 1.6 KB |
| `GITHUB_UPLOAD.md` | Инструкция по загрузке на GitHub | 5.2 KB |
| `overclock.cgi` | CGI скрипт для веб-интерфейса | 2.2 KB |
| `build_patched_firmware.sh` | Скрипт сборки прошивки | 3.1 KB |
| `heater/` | Папка с модифицированными файлами | - |

---

## 🚀 Быстрое применение патчей

### Автоматически (рекомендуется)

```bash
cd /home/smile/avalon_patch
./apply_patches.sh YOUR_MINER_IP
```

### Вручную

```bash
# 1. Подключиться по SSH
ssh admin@YOUR_MINER_IP
# Пароль: admin

# 2. Получить root
sudo -i
# Пароль: admin

# 3. Применить разгон
sed -i 's|^\./btcminer .*|./btcminer --avalon10-freq 700 --avalon10-voltage 1300 --listen-api \&|' /etc/init.d/rcS

# 4. Установить work_level
sed -i 's/work_level *= *.*/work_level = 2/' /data/usrcon/systemcfg.ini

# 5. Логи в RAM
if ! [ -L /data/log ]; then
  rm -rf /data/log
  ln -s /tmp/zlog /data/log
fi
mkdir -p /tmp/zlog

# 6. Отключить историю
echo "export HISTFILE=" | tee /etc/profile.d/no-history.sh

# 7. Перезагрузиться
reboot
```

---

## 📊 Профили разгона

| Профиль | Частота | Напряжение | Хешрейт | Температура |
|---------|---------|------------|---------|-------------|
| Сток | 500 MHz | 1200 mV | ~4 TH/s | 50-60°C |
| Лёгкий | 550 MHz | 1225 mV | ~4.5 TH/s | 55-65°C |
| Средний | 600 MHz | 1250 mV | ~5.5 TH/s | 60-70°C |
| Высокий | 650 MHz | 1275 mV | ~6.5 TH/s | 65-75°C |
| Экстрим | 700 MHz | 1300 mV | ~7.5 TH/s | 70-80°C |

Для изменения отредактируйте строку в `/etc/init.d/rcS`:
```bash
sed -i 's|^\./btcminer .*|./btcminer --avalon10-freq 600 --avalon10-voltage 1250 \&|' /etc/init.d/rcS
```

---

## 🔧 Проверка

```bash
# Проверка процесса
ps aux | grep btcminer

# Проверка хешрейта
echo '{"command":"devs"}' | nc -w 3 YOUR_MINER_IP 4028 | strings | grep "MHS 5s"

# Проверка температуры
echo '{"command":"devs"}' | nc -w 3 YOUR_MINER_IP 4028 | strings | grep "Temperature"

# Проверка work_level
cat /data/usrcon/systemcfg.ini | grep work_level
```

---

## 📁 Для загрузки на GitHub

1. Создайте репозиторий: `avalon-nano3-overclock`
2. Загрузите все файлы из этой папки
3. Следуйте инструкции в `GITHUB_UPLOAD.md`

**Минимальный набор файлов:**
- `README.md` или `README_RU.md`
- `apply_patches.sh`
- `install_overclock_ssh.sh`

---

## ⚠️ Предупреждения

- Разгон аннулирует гарантию
- Следите за температурой
- Начните с лёгкого профиля (550 MHz)
- Обеспечьте хорошее охлаждение

---

## 📞 Источники

- [orca.pet/nanojb/](https://orca.pet/nanojb/) - Основная документация
- [GitHub: ckolivas/cgminer](https://github.com/ckolivas/cgminer) - cgminer
- [Canaan Kendryte](https://kendryte.com/) - K230 SoC

---

**Версия:** 1.0  
**Дата:** 2026-03-08  
**Автор:** На основе исследований orca.pet
