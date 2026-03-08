#!/bin/sh
# overclock.cgi - Обработчик запросов разгона для Avalon Nano 3
# Устанавливается в /www/cgi-bin/overclock.cgi

# Получить параметры из query string
freq=$(echo "$QUERY_STRING" | sed -n 's/.*freq=\([0-9]*\).*/\1/p')
voltage=$(echo "$QUERY_STRING" | sed -n 's/.*voltage=\([0-9]*\).*/\1/p')
freq_sel=$(echo "$QUERY_STRING" | sed -n 's/.*freq_sel=\([0-9]*\).*/\1/p')

# Проверка параметров
if [ -z "$freq" ] || [ -z "$voltage" ]; then
    echo "Content-Type: text/html"
    echo ""
    echo "<html><body>Invalid parameters</body></html>"
    exit 1
fi

# Проверка диапазонов
if [ "$freq" -lt 25 ] || [ "$freq" -gt 800 ]; then
    echo "Content-Type: text/html"
    echo ""
    echo "<html><body>Frequency out of range (25-800)</body></html>"
    exit 1
fi

if [ "$voltage" -lt 1150 ] || [ "$voltage" -gt 1450 ]; then
    echo "Content-Type: text/html"
    echo ""
    echo "<html><body>Voltage out of range (1150-1450)</body></html>"
    exit 1
fi

# Сохранение настроек в systemcfg.ini
if [ -f /data/usrcon/systemcfg.ini ]; then
    # Установить work_level в 2 при разгоне
    sed -i 's/work_level *= *.*/work_level = 2/' /data/usrcon/systemcfg.ini
fi

# Перезапуск майнера с новыми параметрами
# Убиваем текущий процесс
killall btcminer 2>/dev/null

# Запускаем с новыми параметрами
cd /mnt/heater/app
./btcminer --avalon10-freq "$freq" --avalon10-voltage "$voltage" --avalon10-freq-sel "$freq_sel" &

# Вывод успешного ответа
echo "Content-Type: text/html"
echo ""
cat <<EOF
<html>
<head>
    <meta http-equiv="refresh" content="3;url=/index.html">
    <title>Overclock Applied</title>
</head>
<body>
    <h1>Overclock settings applied!</h1>
    <p>Frequency: ${freq} MHz</p>
    <p>Voltage: ${voltage} mV</p>
    <p>Frequency Select: ${freq_sel}</p>
    <p>Miner is restarting... Redirecting to home page.</p>
</body>
</html>
EOF

# Логирование
echo "$(date): Overclock applied - freq=${freq}MHz, voltage=${voltage}mV, freq_sel=${freq_sel}" >> /tmp/overclock.log
