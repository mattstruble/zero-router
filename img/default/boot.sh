wlan_name="OpenWRT"
wlan_password="ChangeMe123456"

lan_ip_address="192.168.1.1"

# log potential errors
exec >/tmp/setup.log 2>&1

# Configure LAN
# More options: https://openwrt.org/docs/guide-user/base-system/basic-networking
if [ "$lan_ip_address" != "" ]; then
    uci set network.lan.ipaddr="$lan_ip_address"
    uci commit network
fi

# Configure WLAN
# More options: https://openwrt.org/docs/guide-user/network/wifi/basic#wi-fi_interfaces
if [ "$wlan_name" != "" -a -n "$wlan_password" -a ${#wlan_password} -ge 8 ]; then
    uci set wireless.@wifi-device[0].disabled='0'
    uci set wireless.@wifi-iface[0].disabled='0'
    uci set wireless.@wifi-iface[0].encryption='sae-mixed'
    uci set wireless.@wifi-iface[0].ssid="$wlan_name"
    uci set wireless.@wifi-iface[0].key="$wlan_password"
    uci commit wireless
fi
