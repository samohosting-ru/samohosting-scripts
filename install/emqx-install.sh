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
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
msg_ok "Зависимости(необходимое ПО) установлены."

msg_info "Устанавливаю EMQX"
$STD bash <(curl -fsSL https://packagecloud.io/install/repositories/emqx/emqx/script.deb.sh)
$STD apt-get install -y emqx
$STD systemctl enable --now emqx
msg_ok "Installed EMQX"

motd_ssh
customize

msg_info "Cleaning up"
apt-get autoremove >/dev/null
apt-get autoclean >/dev/null
msg_ok "Временные файлы установки - удалены!"
