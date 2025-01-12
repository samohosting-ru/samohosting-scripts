#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: Michel Roegl-Brunner (michelroegl-brunner)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://zammad.com

#App Default Values
APP="Zammad"
TAGS="webserver;ticket-system"
var_disk="8"
var_cpu="2"
var_ram="4096"
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
    if [[ ! -d /opt/zammad ]]; then
        msg_error "Отсутствует установленная версия ${APP}"
        exit
    fi
    msg_info "Stopping Service"
    systemctl stop zammad &>/dev/null
    msg_info "Обновляю ${APP}"
    apt-get update &>/dev/null
    apt-mark hold zammad &>/dev/null
    apt-get -y upgrade &>/dev/null
    apt-mark unhold zammad &>/dev/null
    apt-get -y upgrade &>/dev/null
    msg_info "Запускаю Service"
    systemctl start zammad &>/dev/null
    msg_ok "Updated ${APP} LXC"
    exit
}

start
build_container
description

msg_ok "Установка успешно завершена!\n"
echo -e "${CREATING}${GN}${APP} Установка успешно завершена!${CL}"
echo -e "${INFO}${YW} Сервис доступен по ссылке:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}${CL}"