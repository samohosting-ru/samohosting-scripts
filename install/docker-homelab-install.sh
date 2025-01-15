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
PORTAINER_AGENT_LATEST_VERSION=$(get_latest_release "portainer/agent")
DOCKER_COMPOSE_LATEST_VERSION=$(get_latest_release "docker/compose")

msg_info "Устанавливаю Docker $DOCKER_LATEST_VERSION"
DOCKER_CONFIG_PATH='/etc/docker/daemon.json'
mkdir -p $(dirname $DOCKER_CONFIG_PATH)
echo -e '{\n  "log-driver": "journald"\n}' >/etc/docker/daemon.json
$STD sh <(curl -sSL https://get.docker.com)
msg_ok "Docker $DOCKER_LATEST_VERSION установлен."
msg_info "Устанавливаю Portainer $PORTAINER_LATEST_VERSION"
docker volume create portainer_data >/dev/null
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
  docker volume create dashy_data >/dev/null
  $STD docker run -d \
    -p 4000:8080 \
    -v dashy_data/conf.yml:/app/user-data/conf.yml \
    --name samohosting-dashboard \
    --restart=always \
    lissy93/dashy:latest 
  msg_ok "Dashy Dashboard установлен."
  echo -e "${TAB}${INFO}${YW} Dashy Dashboard: ${GN}${IP}${CL}:4000" >> "$MOTD_FILE"
    
motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Временные файлы установки - удалены!"
