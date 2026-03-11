#!/bin/bash
# ============================================================================
# Avalon Nano 3 - Тест API команд
# Версия: 1.0
# Дата: 11 марта 2026
# ============================================================================

MINER_IP="192.168.31.133"
API_PORT="4028"

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция отправки команды
send_cmd() {
    local cmd="$1"
    echo "{\"command\":\"$cmd\"}" | nc -w 3 $MINER_IP $API_PORT 2>/dev/null | strings
}

# Функция отправки привилегированной команды
send_privileged() {
    local cmd="$1"
    local arg="$2"
    echo "{\"command\":\"privileged\",\"arg\":\"$cmd=$arg\"}" | nc -w 3 $MINER_IP $API_PORT 2>/dev/null | strings
}

# Очистка JSON ответа
clean_json() {
    local response="$1"
    echo "$response" | sed 's/[^[:print:]\t]//g' | grep -o '{.*}'
}

# Показать использование
show_usage() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Avalon Nano 3 - CGMiner API Test Script                ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Использование:${NC} $0 <команда> [параметры]"
    echo ""
    echo -e "${GREEN}Команды мониторинга:${NC}"
    echo "  version          - Версия CGMiner"
    echo "  summary          - Общая сводка"
    echo "  devs             - Статус устройств (ASIC)"
    echo "  devdetails       - Детали устройств"
    echo "  pools            - Статус пулов"
    echo "  stats            - Расширенная статистика"
    echo "  config           - Текущая конфигурация"
    echo ""
    echo -e "${GREEN}Привилегированные команды:${NC}"
    echo "  ascset <id> <freq> <volt> - Установка параметров ASIC"
    echo "  setconfig <name> <value>  - Установка конфигурации"
    echo "  restart                   - Перезапуск CGMiner"
    echo "  save                      - Сохранить конфигурацию"
    echo ""
    echo -e "${GREEN}Пресеты:${NC}"
    echo "  stock            - Сток настройки (500MHz/1200mV)"
    echo "  medium           - Средний (650MHz/1300mV)"
    echo "  fast             - Быстрый (750MHz/1350mV)"
    echo "  max              - МАКС (800MHz/1450mV)"
    echo ""
    echo -e "${GREEN}Мониторинг:${NC}"
    echo "  monitor          - Непрерывный мониторинг"
    echo "  temp             - Только температура"
    echo ""
    echo -e "${YELLOW}Примеры:${NC}"
    echo "  $0 summary"
    echo "  $0 ascset 0 750 1350"
    echo "  $0 setconfig work_level 2"
    echo "  $0 fast"
    echo ""
}

# Версия
cmd_version() {
    echo -e "${BLUE}=== Версия CGMiner ===${NC}"
    local response=$(send_cmd "version")
    echo "$response" | strings
}

# Summary
cmd_summary() {
    echo -e "${BLUE}=== Общая сводка ===${NC}"
    local response=$(send_cmd "summary")
    
    # Парсинг полей
    local elapsed=$(echo "$response" | grep -o 'Elapsed=[^,|]*' | cut -d= -f2)
    local mhs_av=$(echo "$response" | grep -o 'MHS av=[^,|]*' | cut -d= -f2)
    local accepted=$(echo "$response" | grep -o 'Accepted=[^,|]*' | cut -d= -f2)
    local rejected=$(echo "$response" | grep -o 'Rejected=[^,|]*' | cut -d= -f2)
    local hw_errors=$(echo "$response" | grep -o 'Hardware Errors=[^,|]*' | cut -d= -f2)
    
    echo -e "Время работы: ${GREEN}${elapsed:-N/A} сек${NC}"
    echo -e "Хешрейт (AVG): ${GREEN}${mhs_av:-N/A} GH/s${NC}"
    echo -e "Принято: ${GREEN}${accepted:-N/A}${NC}"
    echo -e "Отклонено: ${YELLOW}${rejected:-N/A}${NC}"
    echo -e "Ошибки HW: ${RED}${hw_errors:-N/A}${NC}"
    
    # Эффективность
    if [ -n "$accepted" ] && [ -n "$rejected" ]; then
        local total=$((accepted + rejected))
        if [ $total -gt 0 ]; then
            local efficiency=$(echo "scale=2; $accepted * 100 / $total" | bc 2>/dev/null)
            echo -e "Эффективность: ${GREEN}${efficiency:-N/A}%${NC}"
        fi
    fi
}

# Devs
cmd_devs() {
    echo -e "${BLUE}=== Статус устройств (ASIC) ===${NC}"
    local response=$(send_cmd "devs")
    echo "$response" | strings | head -50
}

# Config
cmd_config() {
    echo -e "${BLUE}=== Текущая конфигурация ===${NC}"
    local response=$(send_cmd "config")
    echo "$response" | strings
}

# Pools
cmd_pools() {
    echo -e "${BLUE}=== Статус пулов ===${NC}"
    local response=$(send_cmd "pools")
    echo "$response" | strings
}

# ASCSet (Privileged)
cmd_ascset() {
    local chip_id="$1"
    local freq="$2"
    local voltage="$3"
    
    if [ -z "$chip_id" ] || [ -z "$freq" ] || [ -z "$voltage" ]; then
        echo -e "${RED}Ошибка: укажите chip_id, freq и voltage${NC}"
        echo "Пример: $0 ascset 0 750 1350"
        return 1
    fi
    
    echo -e "${BLUE}=== Установка параметров ASIC #$chip_id ===${NC}"
    echo -e "Частота: ${GREEN}${freq} MHz${NC}"
    echo -e "Напряжение: ${GREEN}${voltage} mV${NC}"
    
    local response=$(send_privileged "ascset" "$chip_id,$freq,$voltage")
    echo "$response" | strings
}

# SetConfig (Privileged)
cmd_setconfig() {
    local name="$1"
    local value="$2"
    
    if [ -z "$name" ] || [ -z "$value" ]; then
        echo -e "${RED}Ошибка: укажите name и value${NC}"
        echo "Пример: $0 setconfig work_level 2"
        return 1
    fi
    
    echo -e "${BLUE}=== Установка конфигурации ===${NC}"
    echo -e "Параметр: ${GREEN}${name}${NC}"
    echo -e "Значение: ${GREEN}${value}${NC}"
    
    local response=$(send_privileged "setconfig" "$name,$value")
    echo "$response" | strings
}

# Restart (Privileged)
cmd_restart() {
    echo -e "${YELLOW}=== Перезапуск CGMiner ===${NC}"
    echo -e "${RED}⚠️  Внимание: майнер будет перезапущен!${NC}"
    local response=$(send_privileged "restart" "")
    echo "$response" | strings
}

# Save (Privileged)
cmd_save() {
    echo -e "${BLUE}=== Сохранение конфигурации ===${NC}"
    local response=$(send_privileged "save" "")
    echo "$response" | strings
}

# Применить пресет
apply_preset() {
    local preset="$1"
    
    case "$preset" in
        stock)
            echo -e "${BLUE}=== Применение пресета: 🐢 СТОК ===${NC}"
            freq=500
            volt=1200
            ;;
        medium)
            echo -e "${BLUE}=== Применение пресета: ⚡ СРЕДНИЙ ===${NC}"
            freq=650
            volt=1300
            ;;
        fast)
            echo -e "${BLUE}=== Применение пресета: 🚀 БЫСТРЫЙ ===${NC}"
            freq=750
            volt=1350
            ;;
        max)
            echo -e "${BLUE}=== Применение пресета: 🔥 МАКС ===${NC}"
            echo -e "${RED}⚠️  Внимание: максимальные настройки!${NC}"
            freq=800
            volt=1450
            ;;
        *)
            echo -e "${RED}Неизвестный пресет: $preset${NC}"
            return 1
            ;;
    esac
    
    echo -e "Частота: ${GREEN}${freq} MHz${NC}"
    echo -e "Напряжение: ${GREEN}${volt} mV${NC}"
    echo ""
    
    # Применение ко всем чипам
    for i in {0..9}; do
        echo -n "Чип $i: "
        send_privileged "ascset" "$i,$freq,$volt" | strings
        sleep 0.5
    done
    
    echo ""
    echo -e "${GREEN}✅ Пресет применён!${NC}"
    echo -e "${YELLOW}💡 Не забудьте сохранить: $0 save${NC}"
}

# Непрерывный мониторинг
cmd_monitor() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Avalon Nano 3 - Мониторинг (Ctrl+C для выхода)         ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    while true; do
        clear
        echo -e "${BLUE}══════════════════════════════════════════════════════════${NC}"
        echo -e "  Avalon Nano 3 - Мониторинг ($(date '+%H:%M:%S'))"
        echo -e "${BLUE}══════════════════════════════════════════════════════════${NC}"
        echo ""
        
        # Summary
        echo -e "${GREEN}┌─── Общая сводка ───┐${NC}"
        local response=$(send_cmd "summary")
        local elapsed=$(echo "$response" | grep -o 'Elapsed=[^,|]*' | cut -d= -f2)
        local mhs_av=$(echo "$response" | grep -o 'MHS av=[^,|]*' | cut -d= -f2)
        local accepted=$(echo "$response" | grep -o 'Accepted=[^,|]*' | cut -d= -f2)
        local hw_errors=$(echo "$response" | grep -o 'Hardware Errors=[^,|]*' | cut -d= -f2)
        
        echo -e "  Время работы: ${YELLOW}${elapsed:-N/A} сек${NC}"
        echo -e "  Хешрейт: ${GREEN}${mhs_av:-N/A} GH/s${NC}"
        echo -e "  Принято: ${GREEN}${accepted:-N/A}${NC}"
        echo -e "  Ошибки HW: ${RED}${hw_errors:-N/A}${NC}"
        echo ""
        
        # Температура
        echo -e "${GREEN}┌─── Температура ───┐${NC}"
        local devs=$(send_cmd "devs")
        echo "$devs" | grep -o 'Temperature=[0-9]*' | head -10 | while read temp; do
            local t=$(echo "$temp" | cut -d= -f2)
            if [ -n "$t" ]; then
                if [ "$t" -lt 70 ]; then
                    echo -e "  ${GREEN}●${NC} $t°C"
                elif [ "$t" -lt 80 ]; then
                    echo -e "  ${YELLOW}●${NC} $t°C"
                else
                    echo -e "  ${RED}●${NC} $t°C"
                fi
            fi
        done
        echo ""
        
        echo -e "${BLUE}══════════════════════════════════════════════════════════${NC}"
        echo -e "Обновление через 5 секунд... (Ctrl+C для выхода)"
        echo ""
        
        sleep 5
    done
}

# Только температура
cmd_temp() {
    echo -e "${BLUE}=== Температура ASIC ===${NC}"
    local response=$(send_cmd "devs")
    
    echo "$response" | grep -o 'DEV=[0-9]*\|Temperature=[0-9]*' | \
    paste - - | while read dev temp; do
        local d=$(echo "$dev" | cut -d= -f2)
        local t=$(echo "$temp" | cut -d= -f2)
        
        if [ -n "$t" ]; then
            if [ "$t" -lt 70 ]; then
                echo -e "  ASIC #$d: ${GREEN}$t°C${NC}"
            elif [ "$t" -lt 80 ]; then
                echo -e "  ASIC #$d: ${YELLOW}$t°C${NC}"
            else
                echo -e "  ASIC #$d: ${RED}$t°C${NC}"
            fi
        fi
    done
}

# Главная логика
case "$1" in
    version)
        cmd_version
        ;;
    summary)
        cmd_summary
        ;;
    devs)
        cmd_devs
        ;;
    devdetails)
        send_cmd "devdetails" | strings
        ;;
    pools)
        cmd_pools
        ;;
    stats)
        send_cmd "stats" | strings
        ;;
    config)
        cmd_config
        ;;
    ascset)
        cmd_ascset "$2" "$3" "$4"
        ;;
    setconfig)
        cmd_setconfig "$2" "$3"
        ;;
    restart)
        cmd_restart
        ;;
    save)
        cmd_save
        ;;
    stock|medium|fast|max)
        apply_preset "$1"
        ;;
    monitor)
        cmd_monitor
        ;;
    temp)
        cmd_temp
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        show_usage
        exit 1
        ;;
esac

exit 0
