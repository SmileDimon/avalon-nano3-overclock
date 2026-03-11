#!/bin/bash
# ============================================================================
# Avalon Nano 3 - Разгон для режима МАЙНИНГА (не обогревателя!)
# ============================================================================
# Использование: ./overclock_miner.sh 192.168.31.133
# ВАЖНО: Скрипт требует SSH доступа (пароль: admin)
# ============================================================================

set -e

MINER_IP="${1:-192.168.31.133}"
SSH_USER="admin"
SSH_PASS="admin"

# Параметры для МАЙНИНГА (максимальный хешрейт)
FREQ=750        # Частота MHz (750 - оптимально, до 800 для экстрима)
VOLT=1350       # Напряжение mV (1350 - оптимально, до 1450 для экстрима)
WORK_LEVEL=2    # High режим

echo "============================================================"
echo "  Avalon Nano 3 - Разгон для режима МАЙНИНГА"
echo "============================================================"
echo "IP: $MINER_IP"
echo "Параметры:"
echo "  - Частота: ${FREQ} MHz"
echo "  - Напряжение: ${VOLT} mV"
echo "  - Work Level: ${WORK_LEVEL} (High)"
echo ""
echo "⚠️ ВНИМАНИЕ: Это отключит режим обогревателя!"
echo "   Майнер будет работать на максимальный хешрейт,"
echo "   а не на поддержание температуры."
echo ""

read -p "Продолжить? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Отменено."
    exit 0
fi

# Проверка подключения
echo "[1/6] Проверка подключения..."
ping -c 1 -W 2 "$MINER_IP" > /dev/null 2>&1 && echo "  ✓ Майнер доступен" || { echo "  ✗ Майнер не отвечает!"; exit 1; }

# Подключение по SSH и применение настроек
echo ""
echo "[2/6] Подключение по SSH..."

echo "[3/6] Установка work_level = $WORK_LEVEL..."
ssh "$SSH_USER@$MINER_IP" "echo '$SSH_PASS' | sudo -S sed -i 's/work_level *= *.*/work_level = $WORK_LEVEL/' /data/usrcon/systemcfg.ini"
ssh "$SSH_USER@$MINER_IP" "grep work_level /data/usrcon/systemcfg.ini" && echo "  ✓ work_level установлен"

echo ""
echo "[4/6] Применение разгона (${FREQ} MHz / ${VOLT} mV)..."
ssh "$SSH_USER@$MINER_IP" "echo '$SSH_PASS' | sudo -S cp /etc/init.d/rcS /etc/init.d/rcS.bak"
ssh "$SSH_USER@$MINER_IP" "echo '$SSH_PASS' | sudo -S sed -i 's|^\./btcminer .*|./btcminer --avalon10-freq $FREQ --avalon10-voltage $VOLT --listen-api \&|' /etc/init.d/rcS"
ssh "$SSH_USER@$MINER_IP" "grep btcminer /etc/init.d/rcS" && echo "  ✓ Разгон применён"

echo ""
echo "[5/6] Логи в RAM (для снижения износа flash)..."
ssh "$SSH_USER@$MINER_IP" "echo '$SSH_PASS' | sudo -S sh -c 'if ! [ -L /data/log ]; then rm -rf /data/log && ln -s /tmp/zlog /data/log; fi; mkdir -p /tmp/zlog'"
ssh "$SSH_USER@$MINER_IP" "ls -la /data/log" && echo "  ✓ Логи в RAM"

echo ""
echo "[6/6] Отключение истории команд..."
ssh "$SSH_USER@$MINER_IP" "echo '$SSH_PASS' | sudo -S sh -c 'echo \"export HISTFILE=\" | tee /etc/profile.d/no-history.sh'"
ssh "$SSH_USER@$MINER_IP" "cat /etc/profile.d/no-history.sh" && echo "  ✓ История отключена"

echo ""
echo "============================================================"
echo "  ✓ ПАТЧИ ПРИМЕНЕНЫ!"
echo "============================================================"
echo ""
echo "⚠️ ВАЖНО: Теперь нужно перезагрузить майнер!"
echo ""
echo "Команда для перезагрузки:"
echo "  ssh admin@$MINER_IP 'echo admin | sudo -S reboot'"
echo ""
echo "Или перезагрузи через веб-интерфейс: http://$MINER_IP:9090/"
echo ""
echo "После перезагрузки проверь хешрейт:"
echo "  echo '{\"command\":\"devs\"}' | nc -w 3 $MINER_IP 4028 | strings"
echo ""
echo "Ожидаемый хешрейт: ~7000-7500 GH/s (${FREQ} MHz)"
echo ""
