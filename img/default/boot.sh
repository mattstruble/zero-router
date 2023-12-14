wlan_name="OpenWRT"
wlan_password="ChangeMe123456"

lan_ip_address="192.168.1.1"

# TODO: Find more reliable way to list wifi devices
wifi_count=$(lsusb | wc -l)
#eth_count=$(nmcli device | grep eth  | wc -l)

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
uci set wireless.@wifi-device[0].disabled='0'
uci set wireless.@wifi-iface[0].disabled='0'
uci set wireless.@wifi-iface[0].encryption='psk2'
uci set wireless.@wifi-iface[0].ssid="$wlan_name"
uci set wireless.@wifi-iface[0].key="$wlan_password"
uci set wireless.@wifi-iface[0].mode="ap"
uci set wireless.@wifi-iface[0].network="lan"
uci commit wireless

# Configure secondary wifi-iface as the client to connect to the external Wifi AP
# This is based on the assumption that the usb device will have longer range than the built in rpi
if [ "$wifi_count" -gt 1 ]; then
    uci set wireless.radio1='wifi-device'
    uci set wireless.radio1.channel='36'
    uci set wireless.radio1.disabled='0'

    uci set wireless.@wifi-iface[1].disabled='0'
    uci set wireless.@wifi-iface[1].device='radio1'
    uci set wireless.@wifi-iface[1].mode="client"
    uci set wireless.@wifi-iface[1].network="wwan"
    uci commit wireless

    wifi
    ifconfig wlan1 up
fi
