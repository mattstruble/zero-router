#!/bin/bash

radio_num=0
# Iterate over all radios and set them up
# https://stackoverflow.com/a/9612232
while IFS= read -r -d '' line; do
    device_dir=$(dirname "$line")
    ((radio_num = radio_num + 1))

    uci set wireless.radio"$radio_num"='wifi-device'
    uci set wireless.radio"$radio_num".disabled='1'
    uci set wireless.radio"$radio_num".channel='auto'
    uci set wireless.radio"$radio_num.path=${device_dir##/sys/devices/}"
    uci set wireless.radio"$radio_num".band='2g'
    uci set wireless.radio"$radio_num".htmode='HT20'

    uci set wireless.default_radio"$radio_num".disabled='1'

    uci commit wireless

done < <(find /sys/devices/platform/soc/*usb*/ -name "net" -print0)

# If there is more than two USB devices disable the built in rpi wifi
# then enable radio1 as its replacement
if [ "$radio_num" -gt 2 ]; then
    uci set wireless.radio0.disabled='1'
    uci set wireless.radio1.disabled='0'

    uci set wireless.clear_ap.device="radio1"
    uci set wireless.wwan_radio.device="radio2"

elif [ "$radio_num" -gt 0 ]; then
    uci set wireless.radio1.disabled='0'
    uci set wireless.wwan_radio.device="radio1"
    uci set wireless.wwan_radio.disabled='0'
fi

uci commit wireless
