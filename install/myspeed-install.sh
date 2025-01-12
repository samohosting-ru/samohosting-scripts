#!/usr/bin/env bash

# Copyright (c) 2021-2025 tteck
# Author: tteck
# Co-Author: MickLesk (Canbiz)
# License: MIT
# https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://github.com/gnmyt/myspeed

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
  sudo \
  make \
  gpg \
  ca-certificates \
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
msg_ok "Node.js установлен"

msg_info "Устанавливаю MySpeed"
RELEASE=$(wget -q https://github.com/gnmyt/myspeed/releases/latest -O - | grep "title>Release" | cut -d " " -f 5)
cd /opt
wget -q https://github.com/gnmyt/myspeed/releases/download/v$RELEASE/MySpeed-$RELEASE.zip
unzip -q MySpeed-$RELEASE.zip -d myspeed
cd myspeed
$STD npm install
echo "${RELEASE}" >/opt/${APPLICATION}_version.txt
msg_ok "Installed MySpeed"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/myspeed.service
[Unit]
Description=MySpeed
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/node server
Restart=always
User=root
Environment=NODE_ENV=production
WorkingDirectory=/opt/myspeed 

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now myspeed.service
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
rm -rf /opt/MySpeed-$RELEASE.zip
$STD apt-get -y autoclean
msg_ok "Временные файлы установки - удалены!"