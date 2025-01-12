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
$STD apt-get install -y curl sudo git mc
$STD apt-get install -y make zip net-tools
$STD apt-get install -y gcc g++ cmake
$STD apt-get install -y ca-certificates
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
msg_ok "Node.js установлен"

msg_info "Устанавливаю FFMPEG"
$STD apt-get install -y ffmpeg
msg_ok "Installed FFMPEG"

msg_info "Cloning Shinobi"
cd /opt
$STD git clone https://gitlab.com/Shinobi-Systems/Shinobi.git -b master Shinobi
cd Shinobi
gitVersionNumber=$(git rev-parse HEAD)
theDateRightNow=$(date)
touch version.json
chmod 777 version.json
echo '{"Product" : "'"Shinobi"'" , "Branch" : "'"master"'" , "Version" : "'"$gitVersionNumber"'" , "Date" : "'"$theDateRightNow"'" , "Repository" : "'"https://gitlab.com/Shinobi-Systems/Shinobi.git"'"}' > version.json
msg_ok "Cloned Shinobi"

msg_info "Устанавливаю Database"
sqluser="root"
sqlpass="root"
echo "mariadb-server mariadb-server/root_password password $sqlpass" | debconf-set-selections
echo "mariadb-server mariadb-server/root_password_again password $sqlpass" | debconf-set-selections
$STD apt-get install -y mariadb-server
service mysql start
mysql -u "$sqluser" -p"$sqlpass" -e "source sql/user.sql" || true
msg_ok "Installed Database"

msg_info "Устанавливаю Shinobi"
cp conf.sample.json conf.json
cronKey=$(head -c 1024 < /dev/urandom | sha256sum | awk '{print substr($1,1,29)}')
sed -i -e 's/Shinobi/'"$cronKey"'/g' conf.json
cp super.sample.json super.json
$STD npm i npm -g
$STD npm install --unsafe-perm
$STD npm install pm2@latest -g
chmod -R 755 .
touch INSTALL/installed.txt
ln -s /opt/Shinobi/INSTALL/shinobi /usr/bin/shinobi
node /opt/Shinobi/tools/modifyConfiguration.js addToConfig="{\"cron\":{\"key\":\"$(head -c 64 < /dev/urandom | sha256sum | awk '{print substr($1,1,60)}')\"}}" &>/dev/null
$STD pm2 start camera.js
$STD pm2 start cron.js
$STD pm2 startup
$STD pm2 save
$STD pm2 list
msg_ok "Installed Shinobi"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Временные файлы установки - удалены!"
