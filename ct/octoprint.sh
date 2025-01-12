#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://octoprint.org/

# App Default Values
APP="OctoPrint"
var_tags="3d-printing"
var_cpu="1"
var_ram="1024"
var_disk="4"
var_os="debian"
var_version="12"
var_unprivileged="0"

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
    if [[ ! -d /opt/octoprint ]]; then
        msg_error "Отсутствует установленная версия ${APP}"
        exit
    fi
    msg_info "Stopping OctoPrint"
    systemctl stop octoprint
    msg_ok "Stopped OctoPrint"

    msg_info "Обновляю OctoPrint"
    source /opt/octoprint/bin/activate
    pip3 install octoprint --upgrade &>/dev/null
    msg_ok "Updated OctoPrint"

    msg_info "Запускаю OctoPrint"
    systemctl start octoprint
    msg_ok "Запустил OctoPrint"
    msg_ok "Приложение успешно обновлено!"
    exit
}

start
build_container
description

msg_ok "Установка успешно завершена!\n"
echo -e "${CREATING}${GN}${APP} Установка успешно завершена!${CL}"
echo -e "${INFO}${YW} Сервис доступен по ссылке:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:5000${CL}"