#!/bin/bash
# Скрипт для быстрой установки разгона на Avalon Nano 3
# Использование: ./install_overclock_ssh.sh YOUR_MINER_IP

MINER_IP="${1:-YOUR_MINER_IP}"
SSH_PASS="admin"
SSH_USER="admin"

echo "=== Avalon Nano 3 Overclock Installer ==="
echo "IP адрес майнера: $MINER_IP"
echo ""

# Проверка доступности
echo "[1/4] Проверка доступности майнера..."
if ! ping -c 1 -W 2 "$MINER_IP" > /dev/null 2>&1; then
    echo "ERROR: Майнер не отвечает на ping!"
    exit 1
fi
echo "OK: Майнер доступен"

# Установка sshpass если нет
if ! command -v sshpass &> /dev/null; then
    echo "[2/4] Установка sshpass..."
    sudo apt-get install -y sshpass > /dev/null 2>&1 || {
        echo "ERROR: Не удалось установить sshpass!"
        echo "Установите вручную: sudo apt-get install -y sshpass"
        exit 1
    }
fi

echo "[2/4] Копирование модифицированного HTML на майнер..."
sshpass -p "$SSH_PASS" scp -o StrictHostKeyChecking=no \
    heater/www/html/cgminercfg.html \
    ${SSH_USER}@${MINER_IP}:/mnt/heater/www/html/cgminercfg.html

if [ $? -eq 0 ]; then
    echo "OK: HTML файл скопирован"
else
    echo "WARNING: Не удалось скопировать HTML (возможно нужно вручную)"
fi

echo "[3/4] Настройка work_level и разгона через SSH..."
sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no \
    ${SSH_USER}@${MINER_IP} "
    sudo -i << 'ENDSSH'
    
    # Изменить work_level на 2 (High)
    sed -i 's/work_level *= *.*/work_level = 2/' /data/usrcon/systemcfg.ini
    
    # Добавить параметры разгона в btcminer если ещё не добавлено
    if ! grep -q '\-\-avalon10-freq' /etc/init.d/rcS; then
        sed -i 's|./btcminer \&|./btcminer --avalon10-freq 700 --avalon10-voltage 1300 \&|' /etc/init.d/rcS
    fi
    
    # Проверить изменения
    echo '=== Проверка настроек ==='
    echo 'work_level:'
    grep work_level /data/usrcon/systemcfg.ini
    echo ''
    echo 'btcminer параметры:'
    grep btcminer /etc/init.d/rcS
    echo ''
    
    echo '=== Перезагрузка через 5 секунд ==='
    sleep 5
    reboot
ENDSSH
"

echo "[4/4] Настройки применены!"
echo ""
echo "Майнер перезагрузится автоматически через 5 секунд."
echo "После загрузки:"
echo "  - work_level = 2 (High)"
echo "  - Частота: 700 MHz"
echo "  - Напряжение: 1300 mV"
echo "  - Ожидаемый хешрейт: ~7-8 TH/s"
echo ""
echo "Для проверки подключитесь через 1-2 минуты:"
echo "  ssh admin@$MINER_IP"
echo ""
