#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://jellyfin.org/

# App Default Values
APP="Jellyfin"
var_tags="media"
var_cpu="2"
var_ram="2048"
var_disk="8"
var_os="ubuntu"
var_version="22.04"
var_unprivileged="1"

# App Output & Base Settings
header_info "$APP"
base_settings

# Core
variables
color
catch_errors

function update_script() {
     header_info
     check_container_storage
     check_container_resources
     if [[ ! -d /usr/lib/jellyfin ]]; then
          msg_error "Отсутствует установленная версия ${APP}"
          exit
     fi
     msg_info "Обновляю ${APP} LXC"
     apt-get update &>/dev/null
     apt-get -y upgrade &>/dev/null
     apt-get --with-new-pkgs upgrade jellyfin jellyfin-server &>/dev/null
     msg_ok "Updated ${APP} LXC"
     exit
}

start
build_container
description

msg_ok "Установка успешно завершена!\n"
echo -e "${CREATING}${GN}${APP} Установка успешно завершена!${CL}"
echo -e "${INFO}${YW} Сервис доступен по ссылке:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8096${CL}"
