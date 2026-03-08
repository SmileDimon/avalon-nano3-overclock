wpa_supplicant -D nl80211 -i wlan0 -c /mnt/heater/confiles/wpa_supplicant.conf -B
wpa_cli -i wlan0 scan
wpa_cli -i wlan0 scan_result
wpa_cli -i wlan0 add_network
wpa_cli -i wlan0 set_network 1 ssid '"lab"'
wpa_cli -i wlan0 set_network 1 psk '"canaanlab"'
wpa_cli -i wlan0 list_network
wpa_cli -i wlan0 select_network 1
udhcpc -i wlan0 -q

