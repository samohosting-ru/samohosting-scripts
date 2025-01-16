#!/usr/bin/env bash

# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# Modified_by: samohosting.ru
# License: MIT
# https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

# Get the current private IP address
IP=$(hostname -I | awk '{print $1}')  # Private IP

msg_info "Устанавливаю зависимости(необходимое ПО).."
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
msg_ok "Зависимости(необходимое ПО) установлены."
msg_ok "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!ВНИМАНИЕ!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
msg_ok "Начинаю устанавливать набор приложений для домашенго сервера от samohosting.ru"
msg_ok "Это может занять около 30 минут.."
msg_ok "Налейте чашечку чая..почитайте книгу..я все сделаю за Вас....Приятного отдыха.."
msg_ok "--------------------------------------------------------------------------------------"
get_latest_release() {
  curl -sL https://api.github.com/repos/$1/releases/latest | grep '"tag_name":' | cut -d'"' -f4
}

DOCKER_LATEST_VERSION=$(get_latest_release "moby/moby")
PORTAINER_LATEST_VERSION=$(get_latest_release "portainer/portainer")
DOCKER_COMPOSE_LATEST_VERSION=$(get_latest_release "docker/compose")

msg_info "Устанавливаю Docker $DOCKER_LATEST_VERSION"
DOCKER_CONFIG_PATH='/etc/docker/daemon.json'
mkdir -p $(dirname $DOCKER_CONFIG_PATH)
echo -e '{\n  "log-driver": "journald"\n}' >/etc/docker/daemon.json
$STD sh <(curl -sSL https://get.docker.com)
msg_ok "Docker $DOCKER_LATEST_VERSION установлен."
msg_info "Устанавливаю Portainer $PORTAINER_LATEST_VERSION"
$STD docker run -d \
  -p 8000:8000 \
  -p 9443:9443 \
  --name=portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest
msg_ok "Portainer $PORTAINER_LATEST_VERSION установлен."
msg_info "Устанавливаю Dashy Dashboard.."
mkdir -p /opt/dashy/user-data/
wget -qO/opt/dashy/user-data/conf.yml https://raw.githubusercontent.com/LiaGen/samohosting/refs/heads/main/files_from_videos/conf.yml
sed -i -e "s|samohosting.ru|$IP|g" /opt/dashy/user-data/conf.yml
msg_info "Устанавливаю Dashy Dashboard.."
$STD docker run -d \
  -p 1000:8080 \
  --name samohosting-dashboard \
  --restart=always \
  -v /opt/dashy/user-data/conf.yml:/app/user-data/conf.yml \
  lissy93/dashy:latest 
msg_ok "Dashy Dashboard установлен."
msg_info "Настраиваю Ваш линый дашборд by samohosting.ru"
msg_ok "Ваш линчый дашборд by SAMOHOSTING.RU настроен"
msg_info "Устанавливаю приложение Runtipi"
cd /opt
wget -q https://raw.githubusercontent.com/runtipi/runtipi/master/scripts/install.sh
chmod +x install.sh
$STD ./install.sh
chmod 666 /opt/runtipi/state/settings.json
msg_ok "Установлено приложение Runtipi"

# update MOTD with application info, system details
MOTD_FILE="/etc/motd"
if [ -f "$MOTD_FILE" ]; then
  # Start MOTD with application info and link
  echo -e "Начните изучать Ваш домашний сервер by samohosting.ru ==>> http://$IP:1000" >> "$MOTD_FILE"
else
  echo "MotD file does not exist!" >&2
fi
    
motd_ssh
customize
GN=$(echo "\033[1;92m")
CL=$(echo "\033[m")
msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Временные файлы установки - удалены!"
msg_ok "Начните изучать Ваш домашний сервер by samohosting.ru ==>> http://$IP:1000 . Удачного самохостинга!"
msg_ok "Начните изучать Ваш домашний сервер by samohosting.ru ==>> http://${GN}${IP}${CL}:1000 . Удачного самохостинга!"
echo -e "Начните изучать Ваш домашний сервер by samohosting.ru ==>> ${GN}http://${IP}:1000${CL} . Удачного самохостинга!"

