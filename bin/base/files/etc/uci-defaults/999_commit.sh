#!/bin/bash

uci commit network
uci commit firewall
uci commit wireless

# Restart wifi devices
wifi
