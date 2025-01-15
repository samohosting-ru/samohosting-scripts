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
msg_ok "Installed Docker $DOCKER_LATEST_VERSION"

# read -r -p "Would you like to add Portainer? <y/N> " prompt
# if [[ ${prompt,,} =~ ^(y|yes)$ ]]; then
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
  msg_ok "Installed Portainer $PORTAINER_LATEST_VERSION"
# else
#   read -r -p "Would you like to add the Portainer Agent? <y/N> " prompt
#   if [[ ${prompt,,} =~ ^(y|yes)$ ]]; then
#     msg_info "Устанавливаю Portainer agent $PORTAINER_AGENT_LATEST_VERSION"
#     $STD docker run -d \
#       -p 4000:8080 \
#       -v /root/my-local-conf.yml:/app/user-data/conf.yml \
#       --name my-dashboard \
#       --restart=always \
#       lissy93/dashy:latest 
#     msg_ok "Installed Portainer Agent $PORTAINER_AGENT_LATEST_VERSION"
#     echo -e "${TAB}${INFO}${YW} main dashboard ip: ${GN}${IP}${CL}:4000" >> "$MOTD_FILE"
#   fi
# fi

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Временные файлы установки - удалены!"
