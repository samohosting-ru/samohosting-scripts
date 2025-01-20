#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# Modified_by: samohosting.ru
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://www.docker.com/

# App Default Values
APP="start-samohosting"
var_tags="start-samohosting"
var_cpu="4"
var_ram="8192"
var_disk="15"
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
    if [[ ! -d /var ]]; then
        msg_error "Отсутствует установленная версия ${APP}"
        exit
    fi
    msg_info "Обновляю ${APP} LXC"
    apt-get update &>/dev/null
    apt-get -y upgrade &>/dev/null
    msg_ok "Updated ${APP} LXC"
    exit
}

start
build_container
description

# msg_ok "Установка успешно завершена!\n"
# echo -e "${CREATING}${GN}${APP} Установка успешно завершена!${CL}"
