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
    mc \
    sudo \
    default-jdk \
    git \
    git-lfs
msg_ok "Зависимости(необходимое ПО) установлены."


msg_info "Устанавливаю OneDev"
cd /opt
wget -q https://code.onedev.io/onedev/server/~site/onedev-latest.tar.gz
tar -xzf onedev-latest.tar.gz
mv /opt/onedev-latest /opt/onedev
$STD /opt/onedev/bin/server.sh install
systemctl start onedev
RELEASE=$(cat /opt/onedev/release.properties | grep "version" | cut -d'=' -f2)
echo "${RELEASE}" >"/opt/${APPLICATION}_version.txt"
msg_ok "Installed OneDev"

motd_ssh
customize

msg_info "Cleaning up"
rm -rf /opt/onedev-latest.tar.gz
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Временные файлы установки - удалены!"
