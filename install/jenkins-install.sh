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
    openjdk-17-jre
msg_ok "Зависимости(необходимое ПО) установлены."

msg_info "Setup Jenkins"
wget -qO /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" https://pkg.jenkins.io/debian binary/ >/etc/apt/sources.list.d/jenkins.list
$STD apt-get update
$STD apt-get install -y jenkins
msg_ok "Setup Jenkins"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Временные файлы установки - удалены!"