#!/bin/bash
# ============================================================================
# Avalon Nano 3 - Анализ температурного контроля
# ============================================================================

MINER_IP="${1:-192.168.31.133}"

echo "============================================================"
echo "  Avalon Nano 3 - Анализ температурных параметров"
echo "============================================================"
echo "IP: $MINER_IP"
echo ""

# Проверка подключения
echo "[1/4] Проверка подключения..."
ping -c 1 -W 2 "$MINER_IP" > /dev/null 2>&1 && echo "  ✓ Майнер доступен" || { echo "  ✗ Майнер не отвечает!"; exit 1; }

# Получение статуса через API
echo "[2/4] Получение статуса через API (порт 4028)..."
echo '{"command":"devs"}' | nc -w 3 "$MINER_IP" 4028 2>/dev/null | strings | grep -iE "temp|freq|fan" | head -20

# Получение конфига
echo ""
echo "[3/4] Получение конфигурации..."
echo '{"command":"config"}' | nc -w 3 "$MINER_IP" 4028 2>/dev/null | strings | head -30

# Проверка work_level
echo ""
echo "[4/4] Проверка work_level через SSH..."
ssh admin@"$MINER_IP" "echo 'admin' | sudo -S cat /data/usrcon/systemcfg.ini 2>/dev/null" | grep work_level || echo "  Не удалось получить (нужен SSH)"

echo ""
echo "============================================================"
echo "  Анализ завершён"
echo "============================================================"
echo ""
echo "Для разгона:"
echo "  1. work_level = 2 (High)"
echo "  2. freq = 700-800 MHz"
echo "  3. voltage = 1300-1400 mV"
echo ""
echo "Команды для применения:"
echo "  ssh admin@$MINER_IP"
echo "  echo 'admin' | sudo -S sed -i 's/work_level *= *.*/work_level = 2/' /data/usrcon/systemcfg.ini"
echo "  echo 'admin' | sudo -S sed -i 's|^\\./btcminer .*|./btcminer --avalon10-freq 750 --avalon10-voltage 1350 --listen-api \\&|' /etc/init.d/rcS"
echo "  echo 'admin' | sudo -S reboot"
echo ""
