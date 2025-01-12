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
$STD apt-get install -y git
$STD apt-get install -y gnupg
msg_ok "Зависимости(необходимое ПО) установлены."

msg_info "Настраиваю Node.js Репозиторий"
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" >/etc/apt/sources.list.d/nodesource.list
msg_ok "Репозиторий Node.js настроен"

msg_info "Устанавливаю Node.js"
$STD apt-get update
$STD apt-get install -y nodejs
$STD npm install pm2 -g
msg_ok "Node.js установлен"

msg_info "Устанавливаю Pingvin Share (Patience)"
git clone -q https://github.com/stonith404/pingvin-share /opt/pingvin-share
cd /opt/pingvin-share
$STD git fetch --tags
$STD git checkout $(git describe --tags `git rev-list --tags --max-count=1`)
cd backend
$STD npm install
$STD npm run build
$STD pm2 start --name="pingvin-share-backend" npm -- run prod
cd ../frontend
sed -i '/"admin.config.smtp.allow-unauthorized-certificates":\|admin.config.smtp.allow-unauthorized-certificates.description":/,+1d' ./src/i18n/translations/fr-FR.ts
$STD npm install
$STD npm run build
$STD pm2 start --name="pingvin-share-frontend" npm -- run start
# create and enable pm2-root systemd script
$STD pm2 startup systemd 
# save running pm2 processes so pingvin-share can survive reboots
$STD pm2 save
msg_ok "Installed Pingvin Share"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Временные файлы установки - удалены!"
