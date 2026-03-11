#!/bin/bash
# ============================================================================
# Avalon Nano 3 - Privileged API Commands
# ============================================================================
# Использование: ./privileged_api.sh 192.168.31.133 "command" "arg"
# ============================================================================

MINER_IP="${1:-192.168.31.133}"
PORT=4028

echo "============================================================"
echo "  Avalon Nano 3 - Privileged API"
echo "============================================================"
echo "IP: $MINER_IP"
echo "Port: $PORT"
echo ""

# Список доступных privileged команд
echo "Доступные команды:"
echo "  1. set_test_mode=1          - Включить тестовый режим"
echo "  2. setconfig=...            - Установить конфиг"
echo "  3. ascset=0,freq,volt       - Установить частоту/напряжение"
echo "  4. debug=1                  - Включить отладку"
echo "  5. dorestart=0              - Перезапустить ASIC 0"
echo "  6. ascenable=0              - Включить ASIC 0"
echo "  7. edevstatus               - Расширенный статус устройств"
echo ""

# Проверка подключения
echo "Проверка подключения..."
echo '{"command":"version"}' | nc -w 2 "$MINER_IP" "$PORT" > /dev/null 2>&1 && echo "  ✓ Майнер доступен" || { echo "  ✗ Майнер не отвечает!"; exit 1; }

echo ""
echo "Тест privileged доступа..."
RESP=$(echo '{"command":"privileged","arg":"test"}' | nc -w 2 "$MINER_IP" "$PORT" 2>/dev/null | strings)
echo "$RESP" | grep -q "Privileged access OK" && echo "  ✓ Privileged доступ разрешён!" || { echo "  ✗ Privileged доступ запрещён!"; exit 1; }

echo ""
echo "============================================================"
echo "  Выбор команды:"
echo "============================================================"
echo ""
echo "1) Включить TEST режим"
echo "2) Установить разгон (800 MHz / 1450 mV)"
echo "3) Установить супер-разгон (800 MHz / 1450 mV + все уровни)"
echo "4) Включить debug режим"
echo "5) Перезапустить ASIC"
echo "6) Проверить статус (edevs)"
echo "7) Своя команда"
echo ""
read -p "Выбор: " -n 1 -r
echo ""

case $REPLY in
    1)
        echo "Включение TEST режима..."
        echo '{"command":"privileged","arg":"set_test_mode=1"}' | nc -w 3 "$MINER_IP" "$PORT" | strings
        ;;
    2)
        echo "Установка разгона (800 MHz / 1450 mV)..."
        echo '{"command":"privileged","arg":"setconfig=--avalon10-freq 800 --avalon10-voltage 1450"}' | nc -w 3 "$MINER_IP" "$PORT" | strings
        ;;
    3)
        echo "Установка СУПЕР разгона..."
        echo '{"command":"privileged","arg":"ascset=0,800,1450"}' | nc -w 3 "$MINER_IP" "$PORT" | strings
        echo '{"command":"privileged","arg":"setconfig=--avalon10-freq 800 --avalon10-voltage 1450 --avalon10-freq-sel 4 --avalon10-voltage-level 75 --avalon10-core-clk-sel 1"}' | nc -w 3 "$MINER_IP" "$PORT" | strings
        ;;
    4)
        echo "Включение debug режима..."
        echo '{"command":"privileged","arg":"debug=1"}' | nc -w 3 "$MINER_IP" "$PORT" | strings
        ;;
    5)
        echo "Перезапуск ASIC..."
        echo '{"command":"privileged","arg":"dorestart=0"}' | nc -w 3 "$MINER_IP" "$PORT" | strings
        ;;
    6)
        echo "Проверка статуса (edevs)..."
        echo '{"command":"edevs"}' | nc -w 3 "$MINER_IP" "$PORT" | strings
        ;;
    7)
        read -p "Введите команду: " CMD
        read -p "Введите аргумент: " ARG
        echo "{\"command\":\"privileged\",\"arg\":\"$CMD=$ARG\"}" | nc -w 3 "$MINER_IP" "$PORT" | strings
        ;;
    *)
        echo "Отменено."
        exit 0
        ;;
esac

echo ""
echo "============================================================"
echo "  Готово!"
echo "============================================================"
echo ""
echo "Проверь статус:"
echo "  echo '{\"command\":\"devs\"}' | nc -w 3 $MINER_IP $PORT | strings"
echo ""
