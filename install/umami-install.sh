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
$STD apt-get install -y gpg
$STD apt-get install -y postgresql
msg_ok "Зависимости(необходимое ПО) установлены."

msg_info "Настраиваю Node.js Репозиторий"
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" >/etc/apt/sources.list.d/nodesource.list
msg_ok "Репозиторий Node.js настроен"

msg_info "Устанавливаю Node.js"
$STD apt-get update
$STD apt-get install -y nodejs
$STD npm install -g yarn
msg_ok "Node.js установлен"

msg_info "Setting up postgresql"
DB_NAME=umamidb
DB_USER=umami
DB_PASS=$(openssl rand -base64 18 | tr -dc 'a-zA-Z0-9' | head -c13)
SECRET_KEY="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)"
$STD sudo -u postgres psql -c "CREATE ROLE $DB_USER WITH LOGIN PASSWORD '$DB_PASS';"
$STD sudo -u postgres psql -c "CREATE DATABASE $DB_NAME WITH OWNER $DB_USER ENCODING 'UTF8' TEMPLATE template0;"
$STD sudo -u postgres psql -c "ALTER ROLE $DB_USER SET client_encoding TO 'utf8';"
$STD sudo -u postgres psql -c "ALTER ROLE $DB_USER SET default_transaction_isolation TO 'read committed';"
$STD sudo -u postgres psql -c "ALTER ROLE $DB_USER SET timezone TO 'UTC'"
echo "" >~/umami.creds
echo "Umami Database Credentials" >>~/umami.creds
echo "" >>~/umami.creds
echo -e "umami Database User: \e[32m$DB_USER\e[0m" >>~/umami.creds
echo -e "umami Database Password: \e[32m$DB_PASS\e[0m" >>~/umami.creds
echo -e "umami Database Name: \e[32m$DB_NAME\e[0m" >>~/umami.creds
msg_ok "Set up postgresql"

msg_info "Устанавливаю Umami (Patience)"
git clone -q https://github.com/umami-software/umami.git /opt/umami
cd /opt/umami
$STD yarn install
echo -e "DATABASE_URL=postgresql://$DB_USER:$DB_PASS@localhost:5432/$DB_NAME" >>/opt/umami/.env
$STD yarn run build
msg_ok "Installed Umami"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/umami.service
echo "[Unit]
Description=umami

[Service]
Type=simple
Restart=always
User=root
WorkingDirectory=/opt/umami
ExecStart=/usr/bin/yarn run start

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now umami.service
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Временные файлы установки - удалены!"
