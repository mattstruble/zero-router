# zero-router

A repository to set up a headless Travel Router on a raspberry pi zero using
OpenWRT.

## Setup

1. Download OpenWRT Firmware

### Additional packages

`kmod-rt2800-lib kmod-rt2800-usb kmod-rt2x00-lib kmod-rt2x00-usb kmod-usb-core kmod-usb-ohci kmod-usb-uhci kmod-usb2 usbutils openvpn-openssl luci-app-openvpn kmod-usb-net-rtl8152 luci luci-ssl`

## Acknowledgement

- [NetworkChuck travel router](https://www.youtube.com/watch?v=jlHWnKVpygw)
- [tongpu/uci-guest-wifi](https://gist.github.com/tongpu/c54d1f45a8874d28b5d4)
- [damianperera/openwrt-rpi](https://github.com/damianperera/openwrt-rpi)
- [Turn your Raspberry Pi into a Travel Router](https://reyestechtips.com/turn-your-raspberry-pi-into-a-travel-router/)
- [OpenWRT Raspberry Pi 4b WiFi Router with adblock](https://forum.openwrt.org/t/openwrt-raspberry-pi-4b-wifi-router-with-adblock/162299)
- [Initial network configuration via firmware selector](https://forum.openwrt.org/t/initial-network-configuration-via-firmware-selector/155139/1)

## TODO

- [x] UCI configurations aren't standing up any of the wifi networks.
- [ ] Create different configs for eth0, dual wifi, and adblock
