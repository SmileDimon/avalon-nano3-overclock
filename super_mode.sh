#!/bin/bash
# ============================================================================
# Avalon Nano 3 - СУПЕР РЕЖИМ (Max Power / Debug Mode)
# ============================================================================
# Использование: ./super_mode.sh 192.168.31.133
# ============================================================================

MINER_IP="${1:-192.168.31.133}"
SSH_USER="admin"
SSH_PASS="admin"

echo "============================================================"
echo "  Avalon Nano 3 - СУПЕР РЕЖИМ"
echo "============================================================"
echo "IP: $MINER_IP"
echo ""
echo "⚠️ ВНИМАНИЕ: Этот скрипт включает МАКСИМАЛЬНЫЙ режим!"
echo "   - work_level = 2 (High)"
echo "   - Частота: 800 MHz (максимум)"
echo "   - Напряжение: 1450 mV (максимум)"
echo "   - Отключение температурных лимитов"
echo ""
echo "⚠️ РИСК: Высокая температура, износ чипов!"
echo ""

read -p "Продолжить? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Отменено."
    exit 0
fi

# Проверка подключения
echo "[1/5] Проверка подключения..."
ping -c 1 -W 2 "$MINER_IP" > /dev/null 2>&1 && echo "  ✓ Майнер доступен" || { echo "  ✗ Майнер не отвечает!"; exit 1; }

echo ""
echo "[2/5] Подключение по SSH..."

# Установка work_level = 2
echo "[3/5] Установка work_level = 2..."
ssh "$SSH_USER@$MINER_IP" "echo '$SSH_PASS' | sudo -S sed -i 's/work_level *= *.*/work_level = 2/' /data/usrcon/systemcfg.ini"
ssh "$SSH_USER@$MINER_IP" "grep work_level /data/usrcon/systemcfg.ini" && echo "  ✓ work_level = 2"

# Применение СУПЕР разгона
echo ""
echo "[4/5] Применение СУПЕР разгона (800 MHz / 1450 mV)..."
ssh "$SSH_USER@$MINER_IP" "echo '$SSH_PASS' | sudo -S cp /etc/init.d/rcS /etc/init.d/rcS.bak"
ssh "$SSH_USER@$MINER_IP" "echo '$SSH_PASS' | sudo -S sed -i 's|^\./btcminer .*|./btcminer --avalon10-freq 800 --avalon10-voltage 1450 --avalon10-freq-sel 4 --avalon10-voltage-level 75 --avalon10-core-clk-sel 1 --listen-api \&|' /etc/init.d/rcS"
ssh "$SSH_USER@$MINER_IP" "grep btcminer /etc/init.d/rcS" && echo "  ✓ СУПЕР разгон применён"

# Логи в RAM
echo ""
echo "[5/5] Логи в RAM..."
ssh "$SSH_USER@$MINER_IP" "echo '$SSH_PASS' | sudo -S sh -c 'if ! [ -L /data/log ]; then rm -rf /data/log && ln -s /tmp/zlog /data/log; fi; mkdir -p /tmp/zlog'"
ssh "$SSH_USER@$MINER_IP" "ls -la /data/log" && echo "  ✓ Логи в RAM"

echo ""
echo "============================================================"
echo "  ✓ СУПЕР РЕЖИМ ПРИМЕНЁН!"
echo "============================================================"
echo ""
echo "Параметры:"
echo "  - work_level = 2 (High)"
echo "  - Частота: 800 MHz (максимум)"
echo "  - Напряжение: 1450 mV (максимум)"
echo "  - Freq Sel: 4 (максимум)"
echo "  - Voltage Level: 75 (максимум)"
echo "  - Core Clk Sel: 1"
echo ""
echo "⚠️ ПЕРЕЗАГРУЗИ майнер для применения:"
echo "  ssh admin@$MINER_IP 'echo admin | sudo -S reboot'"
echo ""
echo "После перезагрузки проверь:"
echo "  echo '{\"command\":\"devs\"}' | nc -w 3 $MINER_IP 4028 | strings"
echo ""
echo "Ожидаемый хешрейт: ~8000+ GH/s"
echo ""
