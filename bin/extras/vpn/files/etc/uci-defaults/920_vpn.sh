# Configure vpnclient network
uci -q delete network.vpnclient
uci add network.vpnclient
uci set network.vpnclient=interface
uci set network.vpnclient.ifname="tun0"
uci set network.vpnclient.proto="none"
