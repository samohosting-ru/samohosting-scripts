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

#set colors
GN=$(echo "\033[1;92m")
BL=$(echo "\033[36m")
BGN=$(echo "\033[4;92m")
CL=$(echo "\033[m")
YW=$(echo "\033[33m")
# Get the current private IP address
IP=$(hostname -I | awk '{print $1}')  # Private IP
# --------------------------------------------------------------------------------------------------------------------
msg_info "Устанавливаю зависимости(необходимое ПО).."
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
msg_ok "Зависимости(необходимое ПО) установлены."
msg_ok "--------------------------------------------------------------------------------------"
msg_ok "${BOLD}${YW}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!ВНИМАНИЕ!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${CL}"
msg_ok "${BOLD}${YW}Начинаю устанавливать набор приложений для домашенго сервера от samohosting.ru${CL}"
msg_ok "${BOLD}${YW}Это может занять какое-то время(не переживайте)${CL}"
msg_ok "${BOLD}${YW}Налейте чашечку чая.. почитайте книгу.. я все сделаю за Вас.. Приятного отдыха..${CL}"
msg_ok "--------------------------------------------------------------------------------------"
# --------------------------------------------------------------------------------------------------------------------
motd_ssh
customize
# --------------------------------------------------------------------------------------------------------------------
# _____НЕ ЗАБУДЬ МЕНЯ УДАЛИТЬ__СТАРТ__________________________________________________________
# get_latest_release() {
#   curl -sL https://api.github.com/repos/$1/releases/latest | grep '"tag_name":' | cut -d'"' -f4
# }
# PORTAINER_LATEST_VERSION=$(get_latest_release "portainer/portainer")
# DOCKER_COMPOSE_LATEST_VERSION=$(get_latest_release "docker/compose")
# DOCKER_LATEST_VERSION=$(get_latest_release "moby/moby")
# msg_info "Устанавливаю Docker $DOCKER_LATEST_VERSION"
# DOCKER_CONFIG_PATH='/etc/docker/daemon.json'
# mkdir -p $(dirname $DOCKER_CONFIG_PATH)
# echo -e '{\n  "log-driver": "journald"\n}' >/etc/docker/daemon.json
# $STD sh <(curl -sSL https://get.docker.com)
# msg_ok "Docker $DOCKER_LATEST_VERSION установлен."
# _____НЕ ЗАБУДЬ МЕНЯ УДАЛИТЬ__КОНЕЦ__________________________________________________________

# --------------------------------------------------------------------------------------------------------------------
msg_info "Устанавливаю приложение Runtipi"
cd /opt
wget -q https://raw.githubusercontent.com/runtipi/runtipi/master/scripts/install.sh
chmod +x install.sh
$STD ./install.sh
chmod 666 /opt/runtipi/state/settings.json
chmod -R 777 /opt/runtipi/
msg_ok "Установлено приложение Runtipi"
# --------------------------------------------------------------------------------------------------------------------
msg_info "Устанавливаю Dashy Dashboard.."
mkdir -p /opt/dashy/user-data/
wget -qO/opt/dashy/user-data/conf.yml https://raw.githubusercontent.com/LiaGen/samohosting/refs/heads/main/files_from_videos/conf.yml
wget -qO/opt/dashy/user-data/conf2.yml https://raw.githubusercontent.com/LiaGen/samohosting/refs/heads/main/files_from_videos/conf2.yml
sed -i -e "s|localhost|$IP|g" /opt/dashy/user-data/conf.yml
sed -i -e "s|localhost|$IP|g" /opt/dashy/user-data/conf2.yml
msg_info "Устанавливаю Dashy Dashboard.."
      # $STD docker run -d \
      #   -p 1000:8080 \
      #   --name samohosting-dashboard \
      #   --restart=always \
      #   -v /opt/dashy/user-data/conf.yml:/app/user-data/conf.yml \
      #   -v /opt/dashy/user-data/conf2.yml:/app/user-data/conf2.yml \
      #   lissy93/dashy:latest 
mkdir -p /opt/dockge/stacks/samohosting-dashboard
cd /opt/dockge/stacks/samohosting-dashboard
cat <<EOF >/opt/dockge/stacks/samohosting-dashboard/compose.yaml
services:
  dashy:
    ports:
      - 1000:8080
    container_name: samohosting-dashboard
    restart: always
    volumes:
      - /opt/dashy/user-data/conf.yml:/app/user-data/conf.yml
      - /opt/dashy/user-data/conf2.yml:/app/user-data/conf2.yml
    image: lissy93/dashy:latest
EOF
docker compose up -d --quiet-pull
msg_ok "Dashy Dashboard установлен."
msg_info "Настраиваю Ваш линый дашборд by samohosting.ru"
msg_ok "Ваш личный дашборд by SAMOHOSTING.RU настроен"

# --------------------------------------------------------------------------------------------------------------------
msg_info "Устанавливаю Dockge для управления Docker контейнерами и стэками.."
mkdir -p /opt/dockge/stacks
mkdir -p /opt/dockge/data
mkdir -p /opt/dockge/stacks/dockge
cd /opt/dockge/stacks/dockge
cat <<EOF >/opt/dockge/stacks/dockge/compose.yaml
services:
  dockge:
    ports:
      - 5001:5001
    container_name: dockge
    restart: unless-stopped
    environment:
      - PUID=$(id -u)
      - PGID=$(id -g)
      - DOCKGE_STACKS_DIR=/opt/dockge/stacks
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /opt/dockge/data:/app/data
      - /opt/dockge/stacks:/opt/dockge/stacks
    image: louislam/dockge:latest
networks: {}
EOF
docker compose up -d --quiet-pull
msg_ok "Dockge установлен."

# --------------------------------------------------------------------------------------------------------------------
# msg_info "Устанавливаю веб-файл-браузер.."
mkdir -p /opt/dockge/stacks/filebrowser
cd /opt/dockge/stacks/filebrowser
cat <<EOF >/opt/dockge/stacks/filebrowser/compose.yaml
services:
  filebrowser:
    ports:
      - 1001:80
    container_name: filebrowser
    restart: unless-stopped
    environment:
      - PUID=$(id -u)
      - PGID=$(id -g)
    volumes:
      - /:/srv/ALL_FOLDERS_LXC-START-SAMOHOSTING
      - /opt:/srv/APPS_FOLDER
      - /opt/runtipi/logs:/srv/RUNTIPI_LOGS
      - /opt/filebrowser/data/db:/database
    image: filebrowser/filebrowser:s6
networks: {}
EOF
$STD docker compose up -d --quiet-pull
msg_ok "Веб-файл-браузер установлен."

# --------------------------------------------------------------------------------------------------------------------
# msg_info "Устанавливаю Dockge для управления Docker контейнерами и стэками.."
# mkdir -p /opt/dockge/stacks
# mkdir -p /opt/dockge/data
# $STD docker run -d \
#   -p 5001:5001 \
#   --name=dockge \
#   --restart=unless-stopped \
#   -e PUID=$(id -u) \
#   -e PGID=$(id -g) \
#   -v /var/run/docker.sock:/var/run/docker.sock \
#   -v /opt/dockge/data:/app/data \
#   -v /opt/dockge/stacks:/opt/dockge/stacks \
#   -e DOCKGE_STACKS_DIR=/opt/dockge/stacks \
#   louislam/dockge:latest
# msg_ok "Dockge установлен."

# --------------------------------------------------------------------------------------------------------------------
# msg_info "Устанавливаю веб-файл-браузер.."
# $STD docker run -d \
#   -p 1001:80 \
#   --name=filebrowser \
#   --restart=unless-stopped \
#   -e PUID=$(id -u) \
#   -e PGID=$(id -g) \
#   -v /:/srv/ALL_FOLDERS_LXC-START-SAMOHOSTING \
#   -v /opt:/srv/APPS_FOLDER \
#   -v /opt/runtipi/logs:/srv/RUNTIPI_LOGS \
#   -v /opt/filebrowser/data/db:/database \
#   filebrowser/filebrowser:s6
# msg_ok "Веб-файл-браузер установлен."

# --------------------------------------------------------------------------------------------------------------------
# msg_info "Устанавливаю Glances.."
# $STD docker run -d \
#   -p 1002:61208 \
#   --name=glance \
#   --restart=unless-stopped \
#   --pid=host \
#   -e GLANCES_OPT=-w \
#   -v /var/run/docker.sock:/var/run/docker.sock:ro \
#   nicolargo/glances:latest-full
# msg_ok "Glances установлен."

# --------------------------------------------------------------------------------------------------------------------
msg_info "Добавляю Firefox1 конфигурацию в Dockge"
mkdir -p /opt/dockge/stacks/firefox1
cat <<EOF >/opt/dockge/stacks/firefox1/compose.yaml
services:
  firefox:
    image: lscr.io/linuxserver/firefox:latest
    container_name: firefox1
    security_opt:
      - seccomp:unconfined #optional
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - FIREFOX_CLI=https://www.samohosting.ru/ #optional
    volumes:
      - /opt/firefox1/data/config:/config
    ports:
      - 3000:3000
      # - 3001:3001
    shm_size: 1gb
    restart: unless-stopped
EOF
msg_ok "Конфигурация для запуска Firefox1 в Dockge добавлена в шаблоны конфигураций"

# --------------------------------------------------------------------------------------------------------------------
msg_info "Добавляю Firefox2 конфигурацию в Dockge"
mkdir -p /opt/dockge/stacks/firefox2
cat <<EOF >/opt/dockge/stacks/firefox2/compose.yaml
services:
  firefox:
    image: lscr.io/linuxserver/firefox:latest
    container_name: firefox2
    security_opt:
      - seccomp:unconfined #optional
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - FIREFOX_CLI=https://www.samohosting.ru/ #optional
    volumes:
      - /opt/firefox2/data/config:/config
    ports:
      - 3002:3000
      # - 3001:3001
    shm_size: 1gb
    restart: unless-stopped
EOF
msg_ok "Конфигурация для запуска Firefox2 в Dockge добавлена в шаблоны конфигураций"
# --------------------------------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------------------------------
msg_info "Добавляю Firefox3 конфигурацию в Dockge"
mkdir -p /opt/dockge/stacks/firefox3
cat <<EOF >/opt/dockge/stacks/firefox3/compose.yaml
services:
  firefox:
    image: lscr.io/linuxserver/firefox:latest
    container_name: firefox3
    security_opt:
      - seccomp:unconfined #optional
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - FIREFOX_CLI=https://www.samohosting.ru/ #optional
    volumes:
      - /opt/firefox3/data/config:/config
    ports:
      - 3003:3000
      # - 3001:3001
    shm_size: 1gb
    restart: unless-stopped
EOF
msg_ok "Конфигурация для запуска Firefox3 в Dockge добавлена в шаблоны конфигураций"
# --------------------------------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------------------------------
msg_info "Добавляю Firefox4 конфигурацию в Dockge"
mkdir -p /opt/dockge/stacks/firefox4
cat <<EOF >/opt/dockge/stacks/firefox4/compose.yaml
services:
  firefox:
    image: lscr.io/linuxserver/firefox:latest
    container_name: firefox4
    security_opt:
      - seccomp:unconfined #optional
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - FIREFOX_CLI=https://www.samohosting.ru/ #optional
    volumes:
      - /opt/firefox4/data/config:/config
    ports:
      - 3004:3000
      # - 3001:3001
    shm_size: 1gb
    restart: unless-stopped
EOF
msg_ok "Конфигурация для запуска Firefox4 в Dockge добавлена в шаблоны конфигураций"
# --------------------------------------------------------------------------------------------------------------------

msg_info "Провожу уборку. Нет, не генеральную.."
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Временные файлы установки - удалены!"
msg_ok "--------------------------------------------------------------------------------------"
msg_ok "Ваш новенький домашний сервер собран и установлен!"

# echo -e "     ${YW}Важная информация:${CL}"
# echo -e "     ${YW}Пожалуйста начните с создания аккаунта Portianer. На его регистрацию у Вас 5 минут после установки.${CL}"
# echo -e "     ${YW}Если Вы не успеете - потребуется перезагрузка Docker\LXC контейнера для регистрации в сервисе.${CL}"
# echo -e "     ${YW}Для регистрации перейдите по ссылке ${CL} ==>> ${BGN}https://${IP}:9443${CL}"
echo -e "     ${BOLD}${BL}Начните изучать Ваш домашний сервер by samohosting.ru${CL} ==>> ${BGN}http://${IP}:1000${CL} Удачного самохостинга!"
echo -e "${TAB}${HOSTNAME}${BL} Начните изучать Ваш домашний сервер by samohosting.ru${CL} ==>> ${BGN}http://${IP}:1000${CL} Удачного самохостинга!" >> /etc/motd

