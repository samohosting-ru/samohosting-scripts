#!/usr/bin/env bash

# Copyright (c) 2021-2025 community-scripts ORG
# Author: tlissak
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://typesense.org/

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Устанавливаю зависимости(необходимое ПО).."
$STD apt-get install -y \
    curl \
    mc \
    sudo 
msg_ok "Зависимости(необходимое ПО) установлены."

msg_info "Устанавливаю TypeSense"
RELEASE=$(curl -s https://api.github.com/repos/typesense/typesense/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4) }')
cd /opt
wget -q https://dl.typesense.org/releases/${RELEASE}/typesense-server-${RELEASE}-amd64.deb
$STD apt install -y /opt/typesense-server-${RELEASE}-amd64.deb
echo 'enable-cors = true' >> /etc/typesense/typesense-server.ini
echo "${RELEASE}" >"/opt/${APPLICATION}_version.txt"
msg_ok "Installed TypeSense"

motd_ssh
customize

msg_info "Cleaning up"
rm -rf /opt/typesense-server-${RELEASE}-amd64.deb
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Временные файлы установки - удалены!"
