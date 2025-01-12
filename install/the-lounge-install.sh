#!/usr/bin/env bash

# Copyright (c) 2021-2025 community-scripts ORG
# Author: kristocopani
# License: MIT
# https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Устанавливаю зависимости(необходимое ПО).."
$STD apt-get install -y \
  curl \
  gpg \
  wget \
  mc
msg_ok "Зависимости(необходимое ПО) установлены."

msg_info "Настраиваю Node.js Репозиторий"
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" >/etc/apt/sources.list.d/nodesource.list
msg_ok "Репозиторий Node.js настроен"

msg_info "Устанавливаю Node.js"
$STD apt-get update
$STD apt-get install -y nodejs
$STD npm install --global yarn
msg_ok "Node.js установлен"

msg_info "Устанавливаю The Lounge"
cd /opt
RELEASE=$(curl -s https://api.github.com/repos/thelounge/thelounge-deb/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4) }')
wget -q https://github.com/thelounge/thelounge-deb/releases/download/v${RELEASE}/thelounge_${RELEASE}_all.deb
$STD dpkg -i ./thelounge_${RELEASE}_all.deb
echo "${RELEASE}" >"/opt/${APPLICATION}_version.txt"
msg_ok "Installed The Lounge"

motd_ssh
customize

msg_info "Cleaning up"
rm -rf /opt/thelounge_${RELEASE}_all.deb
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Временные файлы установки - удалены!"
