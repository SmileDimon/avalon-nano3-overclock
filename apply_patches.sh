#!/bin/bash
# ============================================================================
# Avalon Nano 3 - Автоматический скрипт разгона и оптимизации
# ============================================================================
# Версия: 1.0
# Дата: 2026-03-08
# Описание: Применяет все безопасные патчи к Avalon Nano 3
# ============================================================================

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Конфигурация
MINER_IP="${1:-YOUR_MINER_IP}"
SSH_USER="admin"
SSH_PASS="admin"

# Параметры разгона (можно изменить)
OVERCLOCK_FREQ="${OVERCLOCK_FREQ:-700}"
OVERCLOCK_VOLT="${OVERCLOCK_VOLT:-1300}"
WORK_LEVEL="${WORK_LEVEL:-2}"

# ============================================================================
# Функции
# ============================================================================

print_header() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${BLUE}  Avalon Nano 3 - Патч скрипт v1.0${NC}"
    echo -e "${BLUE}============================================================${NC}"
}

print_step() {
    echo -e "${YELLOW}[$1]${NC} $2"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

check_connection() {
    print_step "1" "Проверка подключения к майнеру..."
    if ping -c 1 -W 2 "$MINER_IP" > /dev/null 2>&1; then
        print_success "Майнер доступен по адресу $MINER_IP"
    else
        print_error "Майнер не отвечает на ping!"
        exit 1
    fi
}

check_ssh() {
    print_step "2" "Проверка SSH доступа..."
    if sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$SSH_USER@$MINER_IP" "echo 'OK'" > /dev/null 2>&1; then
        print_success "SSH доступен"
    else
        print_error "SSH недоступен!"
        echo ""
        echo "Возможные причины:"
        echo "  1. Майнер на стоковой прошивке (нужна патченная)"
        echo "  2. Неправильный IP адрес"
        echo "  3. SSH ещё не запустился после загрузки"
        echo ""
        echo "Прошейте патченную прошивку через http://$MINER_IP:9090/"
        exit 1
    fi
}

apply_work_level() {
    print_step "3" "Установка work_level = $WORK_LEVEL..."
    
    sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no "$SSH_USER@$MINER_IP" "
        echo '$SSH_PASS' | sudo -S sed -i 's/work_level *= *.*/work_level = $WORK_LEVEL/' /data/usrcon/systemcfg.ini
        echo '$SSH_PASS' | sudo -S grep work_level /data/usrcon/systemcfg.ini
    " 2>&1 | grep -q "work_level = $WORK_LEVEL" && \
        print_success "work_level установлен в $WORK_LEVEL" || \
        print_error "Не удалось установить work_level"
}

apply_overclock() {
    print_step "4" "Применение разгона (${OVERCLOCK_FREQ} MHz / ${OVERCLOCK_VOLT} mV)..."
    
    sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no "$SSH_USER@$MINER_IP" "
        echo '$SSH_PASS' | sudo -S cp /etc/init.d/rcS /etc/init.d/rcS.bak
        echo '$SSH_PASS' | sudo -S sed -i 's|^\./btcminer .*|./btcminer --avalon10-freq $OVERCLOCK_FREQ --avalon10-voltage $OVERCLOCK_VOLT --listen-api \&|' /etc/init.d/rcS
        echo '$SSH_PASS' | sudo -S grep btcminer /etc/init.d/rcS
    " 2>&1 | grep -q "avalon10-freq $OVERCLOCK_FREQ" && \
        print_success "Параметры разгона применены" || \
        print_error "Не удалось применить разгон"
}

apply_log_patch() {
    print_step "5" "Перенос логов в RAM..."
    
    sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no "$SSH_USER@$MINER_IP" "
        echo '$SSH_PASS' | sudo -S sh -c '
        if ! [ -L /data/log ]; then
            rm -rf /data/log
            ln -s /tmp/zlog /data/log
        fi
        mkdir -p /tmp/zlog
        ls -la /data/log
        '
    " 2>&1 | grep -q "tmp/zlog" && \
        print_success "Логи перенесены в RAM" || \
        print_error "Не удалось перенести логи"
}

apply_history_patch() {
    print_step "6" "Отключение истории команд..."
    
    sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no "$SSH_USER@$MINER_IP" "
        echo '$SSH_PASS' | sudo -S sh -c 'echo \"export HISTFILE=\" | tee /etc/profile.d/no-history.sh'
        echo '$SSH_PASS' | sudo -S cat /etc/profile.d/no-history.sh
    " 2>&1 | grep -q "HISTFILE=" && \
        print_success "История команд отключена" || \
        print_error "Не удалось отключить историю"
}

verify_miner() {
    print_step "7" "Проверка настроек..."
    
    echo ""
    echo "  Параметры btcminer:"
    sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no "$SSH_USER@$MINER_IP" "
        ps aux | grep btcminer | grep -v grep
    " 2>&1 | sed 's/^/    /'
    
    echo ""
    echo "  work_level:"
    sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no "$SSH_USER@$MINER_IP" "
        grep work_level /data/usrcon/systemcfg.ini
    " 2>&1 | sed 's/^/    /'
    
    echo ""
    echo "  Логи в RAM:"
    sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no "$SSH_USER@$MINER_IP" "
        ls -la /data/log
    " 2>&1 | sed 's/^/    /'
}

reboot_miner() {
    echo ""
    read -p "Перезагрузить майнер сейчас? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_step "8" "Перезагрузка майнера..."
        sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no "$SSH_USER@$MINER_IP" "
            echo '$SSH_PASS' | sudo -S reboot
        " 2>&1
        print_success "Майнер перезагружается..."
        echo ""
        echo "Подождите 1-2 минуты и проверьте:"
        echo "  ping $MINER_IP"
        echo "  echo '{\"command\":\"devs\"}' | nc -w 3 $MINER_IP 4028 | strings"
    else
        echo ""
        echo "Перезагрузите майнер вручную:"
        echo "  sshpass -p '$SSH_PASS' ssh $SSH_USER@$MINER_IP 'echo $SSH_PASS | sudo -S reboot'"
    fi
}

print_summary() {
    echo ""
    echo -e "${GREEN}============================================================${NC}"
    echo -e "${GREEN}  Патчи успешно применены!${NC}"
    echo -e "${GREEN}============================================================${NC}"
    echo ""
    echo "Применено:"
    echo "  ✓ work_level = $WORK_LEVEL"
    echo "  ✓ Разгон: ${OVERCLOCK_FREQ} MHz / ${OVERCLOCK_VOLT} mV"
    echo "  ✓ Логи в RAM"
    echo "  ✓ Отключение истории"
    echo ""
    echo "SSH доступ:"
    echo "  ssh $SSH_USER@$MINER_IP"
    echo "  Пароль: $SSH_PASS"
    echo ""
    echo "Root доступ:"
    echo "  sudo -i"
    echo "  Пароль: $SSH_PASS"
    echo ""
    echo "Проверка хешрейта после загрузки:"
    echo "  echo '{\"command\":\"devs\"}' | nc -w 3 $MINER_IP 4028 | strings"
    echo ""
}

# ============================================================================
# Основная программа
# ============================================================================

print_header
echo ""
echo "IP адрес майнера: $MINER_IP"
echo "Параметры разгона: ${OVERCLOCK_FREQ} MHz / ${OVERCLOCK_VOLT} mV"
echo "work_level: $WORK_LEVEL"
echo ""

check_connection
check_ssh
apply_work_level
apply_overclock
apply_log_patch
apply_history_patch
verify_miner
reboot_miner
print_summary
