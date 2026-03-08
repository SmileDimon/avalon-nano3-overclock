#!/bin/bash -e
# Скрипт для сборки модифицированной прошивки Avalon Nano 3
# Автор: Custom build with overclock support

set -euo pipefail
cd $(dirname "$0")

PATCHED_FOLDER="heater"
OUTPUT_FOLDER="patched_output"
ORIGINAL_IMG="/media/smile/76C963B16CEB900F/avalonnano3/heater_nano3_master_image.img"

echo "=== Avalon Nano 3 Patched Firmware Builder ==="
echo ""

# Проверка наличия оригинального образа
if [ ! -f "$ORIGINAL_IMG" ]; then
    echo "ERROR: Original image not found: $ORIGINAL_IMG"
    exit 1
fi

# Создание выходной папки
rm -rf "$OUTPUT_FOLDER"
mkdir -p "$OUTPUT_FOLDER"

echo "[1/5] Копирование модифицированных файлов..."
cp -r "$PATCHED_FOLDER" "$OUTPUT_FOLDER/"

echo "[2/5] Создание UBIFS образа для app раздела..."
# Используем ubinize для создания UBI образа
# Сначала создадим конфигурационный файл ubinize.cfg

cat > "$OUTPUT_FOLDER/ubinize.cfg" <<EOF
[ubi_app_part_a]
mode=ubi
image=$OUTPUT_FOLDER/heater/ubi_app.img
vol_id=0
vol_type=dynamic
vol_name=app_a
vol_flags=autoresize
vol_alignment=1

[ubi_data_part]
mode=ubi
image=$OUTPUT_FOLDER/data/ubi_data.img
vol_id=1
vol_type=dynamic
vol_name=data
vol_flags=autoresize
vol_alignment=1
EOF

echo "[3/5] Упаковка app раздела в UBIFS..."
# Создаём временную папку для содержимого app
mkdir -p "$OUTPUT_FOLDER/app_content/heater"
cp -r "$OUTPUT_FOLDER/heater/"* "$OUTPUT_FOLDER/app_content/heater/"

# Создаём UBIFS образ
mkfs.ubifs -r "$OUTPUT_FOLDER/app_content" -o "$OUTPUT_FOLDER/app_a.ubi" \
    -m 2048 -e 126976 -c 2048

echo "[4/5] Создание UBI образа..."
ubinize -o "$OUTPUT_FOLDER/app_ubifs.ubi" -m 2048 -p 128KiB -s 512 "$OUTPUT_FOLDER/ubinize.cfg"

echo "[5/5] Вставка нового образа в оригинальную прошивку..."
# Копируем оригинальный образ
cp "$ORIGINAL_IMG" "$OUTPUT_FOLDER/heater_nano3_master_image_PATCHED.img"

# Вычисляем смещение для app раздела (нужно определить из оригинального образа)
# Для Avalon Nano 3 app раздел начинается по адресу 0x1400000 (20MB)
APP_OFFSET=$((0x1400000))

# Вставляем новый UBI образ
dd if="$OUTPUT_FOLDER/app_ubifs.ubi" of="$OUTPUT_FOLDER/heater_nano3_master_image_PATCHED.img" \
    bs=1 seek=$APP_OFFSET conv=notrunc

echo ""
echo "=== Сборка завершена! ==="
echo "Патченная прошивка: $OUTPUT_FOLDER/heater_nano3_master_image_PATCHED.img"
echo ""
echo "Изменения:"
echo "  - Разблокированы режимы Medium и High в веб-интерфейсе"
echo "  - Добавлена страница Overclock Settings"
echo "  - work_level по умолчанию = 2 (High)"
echo ""
echo "Для прошивки используйте KendryteBurningTool или SWUpdate"
