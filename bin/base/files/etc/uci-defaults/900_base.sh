#!/bin/bash
wlan_name="OpenWRT"
wlan_password="ChangeMe123456"
wlan_encryption="psk2"
lan_ip_address="10.71.71.1"

# log potential errors
exec >/tmp/setup.log 2>&1

# Configure LAN
# More options: https://openwrt.org/docs/guide-user/base-system/basic-networking
uci -q delete network.lan
uci set network.lan=interface
uci set network.lan.ipaddr="$lan_ip_address"
uci set network.lan.proto="static"
uci set network.lan.netmask="255.255.255.0"
uci set network.lan.device="br-lan"
uci set network.lan.ip6assign="60"
uci set network.lan.force_link="1"
uci commit network

# Configure WWAN
uci -q delete network.wwan
uci set network.wwan=interface
uci set network.wwan.proto="dhcp"
uci set network.wwan.peerdns="1"
uci set network.wwan.force_link="1"
# Set DNS to Quad9 and Cloudflare Secure
# uci set network.wwan.dns="9.9.9.9 149.112.112.112 1.1.1.2 1.0.0.2"
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
uci set firewall.@zone[-1].input='ACCEPT'
uci set firewall.@zone[-1].output='ACCEPT'
uci set firewall.@zone[-1].forward='REJECT'
uci set firewall.@zone[-1].masq='1'
uci set firewall.@zone[-1].mtu_fix='1'
uci commit firewall

#### Configure Travelmate ####
# More options: https://github.com/openwrt/packages/blob/master/net/travelmate/files/README.md
####
# uci set travelmate.global="travelmate"
# uci set travelmate.global.trm_enabled="0"
# uci set travelmate.global.trm_iface="wwan"
# uci set travelmate.global.trm_captive="1"
# uci set travelmate.global.trm_netcheck="1"
# uci set travelmate.global.trm_proactive="1"
# uci set travelmate.global.trm_autoadd="1"
# uci set travelmate.global.trm_randomize="1"
# uci commit travelmate

#### Configure WLAN ####
# More options: https://openwrt.org/docs/guide-user/network/wifi/basic#wi-fi_interfaces
####

# Hardcode the built-in raspberry pi device to radio0
# https://forum.openwrt.org/t/list-option-paths-usb-radio-firstboot/96436
pi_path=$(find /sys/devices/platform/soc/*mmc*/ -name "net" -print0 | xargs dirname)

uci set wireless.radio0='wifi-device'
uci set wireless.radio0.disabled='0'
uci set wireless.radio0.path="${pi_path##/sys/devices/}"
uci set wireless.radio0.channel='auto'
uci set wireless.radio0.band='2g'
uci set wireless.radio0.htmode='HT20'

uci set wireless.default_radio0.disabled='1'

#### Configure wireless interfaces
###

# Set up clear access point
uci set wireless.clear_ap='wifi-iface'
uci set wireless.clear_ap.disabled='0'
uci set wireless.clear_ap.device="radio0"
uci set wireless.clear_ap.encryption="$wlan_encryption"
uci set wireless.clear_ap.ssid="$wlan_name"
uci set wireless.clear_ap.key="$wlan_password"
uci set wireless.clear_ap.mode="ap"
uci set wireless.clear_ap.network="lan"
uci commit wireless

# Set up WWAN wireless
uci set wireless.wwan_radio='wifi-iface'
uci set wireless.wwan_radio.disabled='1'
uci set wireless.wwan_radio.network="wwan"
uci set wireless.wwan_radio.mode="sta"
uci commit wireless
