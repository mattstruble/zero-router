#!/bin/bash

radio_num=1
# Iterate over all radios and set them up
# https://stackoverflow.com/a/9612232
while IFS= read -r -d '' line; do
    device_dir=$(dirname "$line")

    uci set wireless.radio"$radio_num".disabled='1'
    uci set wireless.radio"$radio_num".channel='auto'
    uci set wireless.radio"$radio_num.path=${device_dir##/sys/devices/}"

    uci set wireless.default_radio"$radio_num".disabled='1'
    uci set wireless.default_radio"$radio_num".mode='sta'
    uci set wireless.default_radio"$radio_num".network="wan"

    uci commit wireless

    radio_num=$(expr "$radio_num" + 1)

done < <(find /sys/devices/platform/soc/*usb*/ -name "net" -print0)
