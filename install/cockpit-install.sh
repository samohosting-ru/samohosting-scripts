#!/usr/bin/env bash

# Copyright (c) 2021-2025 tteck
# Author: tteck
# Co-Author: havardthom
# License: MIT
# https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://github.com/cockpit-project/cockpit

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

msg_info "Устанавливаю Cockpit"
source /etc/os-release
echo "deb http://deb.debian.org/debian ${VERSION_CODENAME}-backports main" >/etc/apt/sources.list.d/backports.list
$STD apt-get update
$STD apt-get install -t ${VERSION_CODENAME}-backports cockpit --no-install-recommends -y
sed -i "s/root//g" /etc/cockpit/disallowed-users
msg_ok "Installed Cockpit"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Временные файлы установки - удалены!"
