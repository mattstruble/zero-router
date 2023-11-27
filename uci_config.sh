#!/bin/sh

uci set network.wwan='interface'
uci set network.wwan.proto='dhcp'
uci set network.wwan.peerdins='0'
uci set network.wwan.dns='9.9.9.9 1.1.1.1'

uci set network.vpn='interface'
uci set network.vpn.ifname='tun0'
uci set network.vpn.proto='none'

uci set firewall.wan.input='ACCEPT'

uci set wireless.radio0.channel='7'
uci set wireless.radio0.hwmode='11g'
uci set wireless.radio0.htmode='HT20'
uci set wireless.radio0.short_gi_40='0'
uci set wireless.radio0.disabled='0'

ifconfig wlan1 up

uci set wireless.radio1.ssid='Zero Travel'
uci set wireless.radio1.key='ChangeMe'
uci set wireless.radio1.disabled='0'
uci set wireless.radio1.encryption='psk2+ccmp'

uci commit
wifi
