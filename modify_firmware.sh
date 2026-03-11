#!/bin/bash
# ============================================================================
# Avalon Nano 3 - Модификация прошивки для режима МАЙНИНГА
# ============================================================================
# Скрипт изменяет work_level с 0 (обогреватель) на 2 (майнинг)
# ============================================================================

FW_PATH="/media/smile/76C963B16CEB900F/avalonnano3/full_extracted"

echo "============================================================"
echo "  Avalon Nano 3 - Модификация прошивки"
echo "============================================================"
echo ""

# Находим файлы systemcfg.ini
echo "[1/3] Поиск файлов systemcfg.ini..."
SYS_CFG_A="$FW_PATH/24342067/ubi_app_part_a/heater/confiles/usrcon/systemcfg_bak.ini"
SYS_CFG_B="$FW_PATH/707453085/ubi_app_part_b/heater/confiles/usrcon/systemcfg_bak.ini"
SYS_CFG_DATA="$FW_PATH/1695388264/ubi_data_part/usrcon/systemcfg.ini"

echo "  Part A: $SYS_CFG_A"
echo "  Part B: $SYS_CFG_B"
echo "  Data:   $SYS_CFG_DATA"

# Модификация
echo ""
echo "[2/3] Изменение work_level с 0 на 2..."

for cfg in "$SYS_CFG_A" "$SYS_CFG_B" "$SYS_CFG_DATA"; do
    if [ -f "$cfg" ]; then
        echo "  Модификация: $cfg"
        # Делаем бэкап
        cp "$cfg" "$cfg.bak"
        # Меняем work_level = 0 на work_level = 2
        sed -i 's/work_level *= *0/work_level = 2/' "$cfg"
        # Проверяем
        if grep -q "work_level = 2" "$cfg"; then
            echo "    ✓ work_level изменён на 2"
        else
            echo "    ✗ Ошибка изменения!"
        fi
    else
        echo "  ✗ Файл не найден: $cfg"
    fi
done

# Показываем результат
echo ""
echo "[3/3] Результат:"
echo ""
for cfg in "$SYS_CFG_A" "$SYS_CFG_B" "$SYS_CFG_DATA"; do
    if [ -f "$cfg" ]; then
        echo "  $cfg:"
        grep "work_level" "$cfg" | sed 's/^/    /'
        echo ""
    fi
done

echo "============================================================"
echo "  ✓ Модификация завершена!"
echo "============================================================"
echo ""
echo "⚠️ ВАЖНО: Теперь нужно собрать прошивку обратно и прошить!"
echo ""
echo "Для применения изменений на майнере:"
echo "  1. Подключись по SSH: ssh admin@192.168.31.133"
echo "  2. Введи: echo 'admin' | sudo -S sed -i 's/work_level *= *0/work_level = 2/' /data/usrcon/systemcfg.ini"
echo "  3. Перезагрузи: echo 'admin' | sudo -S reboot"
echo ""
echo "ИЛИ создай патченную прошивку .swu и обнови через веб-интерфейс."
echo ""
