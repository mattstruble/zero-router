wlan_name="OpenWRT"
wlan_password="ChangeMe123456"
wlan_encryption="psk2"

lan_ip_address="10.71.71.1"

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
# Set DNS to Quad9 and Cloudflare Secure
uci set network.wwan.dns="9.9.9.9 149.112.112.112 1.1.1.2 1.0.0.2"
uci commit network

#### Configure Firewall ####
while uci -q delete firewall.@zone[0]; do :; done

# LAN
uci add firewall zone
uci set firewall.@zone[-1].name='lan'
uci set firewall.@zone[-1].network='lan'
uci set firewall.@zone[-1].input='ACCEPT'
uci set firewall.@zone[-1].output='ACCEPT'
uci set firewall.@zone[-1].forward='ACCEPT'
uci commit firewall

# WAN
uci add firewall zone
uci set firewall.@zone[-1].name='wan'
uci set firewall.@zone[-1].network='wwan'
uci set firewall.@zone[-1].input='REJECT'
uci set firewall.@zone[-1].output='ACCEPT'
uci set firewall.@zone[-1].forward='REJECT'
uci set firewall.@zone[-1].masq='1'
uci set firewall.@zone[-1].mtu_fix='1'
uci commit firewall

#### Configure Travelmate ####
# More options: https://github.com/openwrt/packages/blob/master/net/travelmate/files/README.md
####
uci set travelmate.global="travelmate"
uci set travelmate.global.trm_enabled="0"
uci set travelmate.global.trm_iface="wwan"
uci set travelmate.global.trm_radio="radio0"
uci set travelmate.global.trm_captive="1"
uci set travelmate.global.trm_netcheck="1"
uci set travelmate.global.trm_proactive="1"
uci set travelmate.global.trm_autoadd="1"
uci set travelmate.global.trm_randomize="1"
uci commit travelmate

#### Configure WLAN ####
# More options: https://openwrt.org/docs/guide-user/network/wifi/basic#wi-fi_interfaces
####

# Hardcode the built-in raspberry pi device to radio0
# https://forum.openwrt.org/t/list-option-paths-usb-radio-firstboot/96436
pi_path=$(find /sys/devices/platform/soc/*mmc*/ -name "net" | xargs dirname)

uci set wireless.radio0.disabled='0'
uci set wireless.radio0.path="${pi_path##/sys/devices/}"
uci set wireless.default_radio0.disabled='0'
uci set wireless.default_radio0.device="radio0"
uci set wireless.default_radio0.encryption="$wlan_encryption"
uci set wireless.default_radio0.ssid="$wlan_name"
uci set wireless.default_radio0.key="$wlan_password"
uci set wireless.default_radio0.mode="ap"
uci set wireless.default_radio0.network="lan"
uci commit wireless

# Configure secondary wifi-iface as the client to connect to the external Wifi AP
# This is based on the assumption that the usb device will have longer range than the built in rpi
if [ "$wifi_count" -gt 1 ]; then
    # Hardcode the usb device to radio1
    # https://forum.openwrt.org/t/list-option-paths-usb-radio-firstboot/96436
    usb_path=$(find /sys/devices/platform/soc/*usb*/ -name "net" | xargs dirname)

    uci set wireless.radio1.disabled='1'
    uci set wireless.radio1.channel='auto'
    uci set wireless.radio1.path="${usb_path##/sys/devices/}"
    # uci set wireless.radio1='wifi-device'
    # uci set wireless.radio1.channel='36'
    # uci set wireless.radio1.disabled='0'

    uci set wireless.default_radio1.disabled='1'
    uci set wireless.default_radio1.device='radio1'
    uci set wireless.default_radio1.mode="sta"
    uci set wireless.default_radio1.network="wwan"
    uci set wireless.default_radio1.encryption="$wlan_encryption"
    uci set wireless.default_radio1.ssid="$wlan_name"
    uci set wireless.default_radio1.key="$wlan_password"
    uci commit wireless

    uci set travelmate.global.trm_radio="radio1"
fi

# Restart wifi devices
wifi

uci commit travelmate
