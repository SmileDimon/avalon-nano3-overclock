#!/bin/bash
# ============================================================================
# Скрипт извлечения строк из бинарника btcminer
# Версия: 1.0
# Дата: 11 марта 2026
# ============================================================================

# Пути
BINARIES_DIR="$(dirname "$0")/.."
BINARY_FILE="$BINARIES_DIR/../btcminer_original"
OUTPUT_DIR="$BINARIES_DIR/../firmware_info"

# Создание директории вывода
mkdir -p "$OUTPUT_DIR"

echo "╔══════════════════════════════════════════════════════════╗"
echo "║   BTCMiner String Extractor                              ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Проверка наличия бинарника
if [ ! -f "$BINARY_FILE" ]; then
    echo "❌ Бинарник не найден: $BINARY_FILE"
    exit 1
fi

echo "📁 Бинарник: $BINARY_FILE"
echo "📂 Вывод: $OUTPUT_DIR"
echo ""

# Извлечение всех строк
echo "⏳ Извлечение всех строк..."
strings "$BINARY_FILE" | sort | uniq > "$OUTPUT_DIR/all_strings.txt"
TOTAL=$(wc -l < "$OUTPUT_DIR/all_strings.txt")
echo "✅ Всего строк: $TOTAL"
echo ""

# Опции командной строки
echo "⏳ Извлечение опций командной строки..."
strings "$BINARY_FILE" | grep -E "^--" | sort | uniq > "$OUTPUT_DIR/cli_options.txt"
echo "✅ Опции: $(wc -l < "$OUTPUT_DIR/cli_options.txt")"
echo ""

# API команды
echo "⏳ Извлечение API команд..."
strings "$BINARY_FILE" | grep -iE "api|command|privileged|ascset|setconfig" | sort | uniq > "$OUTPUT_DIR/api_commands.txt"
echo "✅ API команды: $(wc -l < "$OUTPUT_DIR/api_commands.txt")"
echo ""

# Параметры Avalon
echo "⏳ Извлечение параметров Avalon..."
strings "$BINARY_FILE" | grep -iE "avalon|freq|volt|work_level|asic|chip" | sort | uniq > "$OUTPUT_DIR/avalon_params.txt"
echo "✅ Параметры Avalon: $(wc -l < "$OUTPUT_DIR/avalon_params.txt")"
echo ""

# CGI и веб
echo "⏳ Извлечение CGI и веб..."
strings "$BINARY_FILE" | grep -iE "cgi|web|http|html|css|js" | sort | uniq > "$OUTPUT_DIR/web_cgi.txt"
echo "✅ Веб/CGI: $(wc -l < "$OUTPUT_DIR/web_cgi.txt")"
echo ""

# Пути файлов
echo "⏳ Извлечение путей файлов..."
strings "$BINARY_FILE" | grep -E "^/|\.c$|\.h$|\.conf$|\.json$" | sort | uniq > "$OUTPUT_DIR/file_paths.txt"
echo "✅ Пути файлов: $(wc -l < "$OUTPUT_DIR/file_paths.txt")"
echo ""

# Логи и сообщения
echo "⏳ Извлечение логов и сообщений..."
strings "$BINARY_FILE" | grep -iE "error|warning|info|debug|log" | sort | uniq > "$OUTPUT_DIR/log_messages.txt"
echo "✅ Логи: $(wc -l < "$OUTPUT_DIR/log_messages.txt")"
echo ""

# Сетевые параметры
echo "⏳ Извлечение сетевых параметров..."
strings "$BINARY_FILE" | grep -iE "port|ip|url|pool|stratum" | sort | uniq > "$OUTPUT_DIR/network_params.txt"
echo "✅ Сеть: $(wc -l < "$OUTPUT_DIR/network_params.txt")"
echo ""

# Информация о сборке
echo "⏳ Извлечение информации о сборке..."
{
    echo "=== BTCMiner Build Information ==="
    echo ""
    echo "Binary: $BINARY_FILE"
    echo "Extracted: $(date)"
    echo ""
    echo "=== File Type ==="
    file "$BINARY_FILE"
    echo ""
    echo "=== Build Paths ==="
    strings "$BINARY_FILE" | grep -E "^/home/" | head -10
    echo ""
    echo "=== Version Strings ==="
    strings "$BINARY_FILE" | grep -iE "version|ver\.|build" | head -10
    echo ""
    echo "=== Statistics ==="
    echo "Total strings: $TOTAL"
    echo "CLI options: $(wc -l < "$OUTPUT_DIR/cli_options.txt")"
    echo "API commands: $(wc -l < "$OUTPUT_DIR/api_commands.txt")"
    echo "Avalon params: $(wc -l < "$OUTPUT_DIR/avalon_params.txt")"
    echo "Web/CGI: $(wc -l < "$OUTPUT_DIR/web_cgi.txt")"
    echo "File paths: $(wc -l < "$OUTPUT_DIR/file_paths.txt")"
} > "$OUTPUT_DIR/build_info.txt"
echo "✅ Информация о сборке: $OUTPUT_DIR/build_info.txt"
echo ""

# Итоговый отчёт
echo "╔══════════════════════════════════════════════════════════╗"
echo "║   Извлечение завершено!                                  ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "📁 Созданные файлы:"
echo ""
ls -lh "$OUTPUT_DIR"/*.txt | awk '{print "  " $9 " (" $5 ")"}'
echo ""
echo "✅ Готово!"
