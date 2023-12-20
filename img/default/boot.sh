wlan_name="OpenWRT"
wlan_password="ChangeMe123456"
wlan_encryption="psk2"

lan_ip_address="192.168.1.1"

# https://unix.stackexchange.com/a/552995
wifi_count=$(ls /sys/class/ieee80211/*/device/net/* -d | wc -l)

# log potential errors
exec >/tmp/setup.log 2>&1

# Configure LAN
# More options: https://openwrt.org/docs/guide-user/base-system/basic-networking
uci set network.lan.ipaddr="$lan_ip_address"
uci set network.lan.proto="static"
uci set network.lan.netmask="255.255.255.0"
uci set network.lan.device="br-lan"
uci set network.lan.ip6assign="60"
uci set network.lan.force_link="1"
uci commit network

# Configure WWAN
uci set network.wwan="interface"
uci set network.wwan.proto="dhcp"
uci set network.wwan.peerdns="0"
uci set network.wwan.dns="9.9.9.9 1.1.1.1"
uci commit network

# Configure WLAN
# More options: https://openwrt.org/docs/guide-user/network/wifi/basic#wi-fi_interfaces
uci set wireless.radio0.disabled='0'
uci set wireless.default_radio0.disabled='0'
uci set wireless.default_radio0.device="radio0"
uci set wireless.default_radio0.encryption='$wlan_encryption'
uci set wireless.default_radio0.ssid="$wlan_name"
uci set wireless.default_radio0.key="$wlan_password"
uci set wireless.default_radio0.mode="ap"
uci set wireless.default_radio0.network="lan"
uci commit wireless

# Configure secondary wifi-iface as the client to connect to the external Wifi AP
# This is based on the assumption that the usb device will have longer range than the built in rpi
if [ "$wifi_count" -gt 1 ]; then
    uci set wireless.radio1.disabled='0'
    uci set wireless.radio1.channel='auto'
    # uci set wireless.radio1='wifi-device'
    # uci set wireless.radio1.channel='36'
    # uci set wireless.radio1.disabled='0'

    uci set wireless.wifinet2='wifi-iface'
    uci set wireless.wifinet2.disabled='0'
    uci set wireless.wifinet2.device='radio1'
    uci set wireless.wifinet2.mode="sta"
    uci set wireless.wifinet2.network="wwan"
    uci set wireless.wifinet2.encryption="$wlan_encryption"
    uci set wireless.wifinet2.ssid="$wlan_name"
    uci set wireless.wifinet2.key="$wlan_password"
    uci commit wireless
fi
