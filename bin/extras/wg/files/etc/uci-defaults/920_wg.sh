#!/bin/bash
wlan_name="OpenWRT.enc"
wlan_password="ChangeMe123456"
wlan_encryption="psk2"

uci set network.wg0='interface'
uci set network.wg0.proto='wireguard'

uci set network.wg_network='interface'
uci set network.wg_network.proto='none'
uci set network.wg_network.ifname='wg0'

uci add firewall zone
uci set firewall.@zone[-1]='zone'
uci set firewall.@zone[-1].name='wg'
uci set firewall.@zone[-1].network='wg_network'
uci set firewall.@zone[-1].input='ACCEPT'
uci set firewall.@zone[-1].output='ACCEPT'
uci set firewall.@zone[-1].forward='REJECT'

uci add firewall forwarding
uci set firewall.@forwarding[-1].src='wg'
uci set firewall.@forwarding[-1].dest='wwan'

uci commit network
uci commit firewall
