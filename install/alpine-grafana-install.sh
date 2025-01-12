#!/usr/bin/env bash

# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT
# https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"

color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Устанавливаю зависимости(необходимое ПО).."
$STD apk add newt
$STD apk add curl
$STD apk add openssh
$STD apk add nano
$STD apk add mc
msg_ok "Зависимости(необходимое ПО) установлены."

msg_info "Устанавливаю Grafana"
$STD apk add grafana
$STD sed -i '/http_addr/s/127.0.0.1/0.0.0.0/g' /etc/conf.d/grafana
$STD rc-service grafana start
$STD rc-update add grafana default
msg_ok "Installed Grafana"

motd_ssh
customize