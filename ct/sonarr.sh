#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://sonarr.tv/

# App Default Values
APP="Sonarr"
var_tags="arr"
var_cpu="2"
var_ram="1024"
var_disk="4"
var_os="debian"
var_version="12"
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
    if [[ ! -d /var/lib/sonarr/ ]]; then
        msg_error "Отсутствует установленная версия ${APP}"
        exit
    fi
    msg_info "Обновляю $APP v4"
    systemctl stop sonarr.service
    wget -q -O SonarrV4.tar.gz 'https://services.sonarr.tv/v1/download/main/latest?version=4&os=linux&arch=x64'
    tar -xzf SonarrV4.tar.gz
    rm -rf /opt/Sonarr
    mv Sonarr /opt
    rm -rf SonarrV4.tar.gz
    systemctl start sonarr.service
    msg_ok "Updated $APP v4"
    exit
}

start
build_container
description

msg_ok "Установка успешно завершена!\n"
echo -e "${CREATING}${GN}${APP} Установка успешно завершена!${CL}"
echo -e "${INFO}${YW} Сервис доступен по ссылке:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8989${CL}"