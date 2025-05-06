#!/bin/bash
wg_lan_ip_address="10.72.72.1"

uci set network.wg0='interface'
uci set network.wg0.proto='wireguard'

uci set network.wg_lan="interface"
uci set network.wg_lan.ipaddr="$wg_lan_ip_address"
uci set network.wg_lan.proto="static"
uci set network.wg_lan.netmask="255.255.255.0"
uci set network.wg_lan.device="br-lan"
uci set network.wg_lan.delegate='0'
uci set network.wg_lan.defaultroute='0'
uci commit network

uci add firewall zone
uci set firewall.@zone[-1].name='wg_lan_zone'
uci set firewall.@zone[-1].network='wg_lan'
uci set firewall.@zone[-1].input='DROP'
uci set firewall.@zone[-1].output='ACCEPT'
uci set firewall.@zone[-1].forward='DROP'
uci commit firewall

uci add firewall zone
uci set firewall.@zone[-1]='zone'
uci set firewall.@zone[-1].name='wg0_zone'
uci set firewall.@zone[-1].network='wg0'
uci set firewall.@zone[-1].input='DROP'
uci set firewall.@zone[-1].output='ACCEPT'
uci set firewall.@zone[-1].forward='DROP'
uci set firewall.@zone[-1].masq='1'
uci commit firewall

uci add firewall forwarding
uci set firewall.@forwarding[-1].src='wg_lan_zone'
uci set firewall.@forwarding[-1].dest='wg0_zone'

uci add firewall forwarding
uci set firewall.@forwarding[-1].src='wg0_zone'
uci set firewall.@forwarding[-1].dest='wg_lan_zone'

uci add firewall rule
uci set firewall.@rule[-1].src='wg_lan_zone'
uci set firewall.@rule[-1].dest='wg0_zone'
uci set firewall.@rule[-1].proto='all'
uci set firewall.@rule[-1].target='ACCEPT'
uci set firewall.@rule[-1].family='ipv4'
uci set firewall.@rule[-1].state='RELATED,ESTABLISHED'

uci commit network
uci commit firewall
