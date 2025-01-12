#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck | Co-Author: MickLesk (Canbiz)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://www.mysql.com/

# App Default Values
APP="MySQL"
var_tags="database"
var_cpu="1"
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
    if [[ ! -f /usr/share/keyrings/mysql.gpg ]]; then
        msg_error "Отсутствует установленная версия ${APP}"
        exit
    fi
    msg_info "Обновляю ${APP} LXC"
    apt-get update &>/dev/null
    apt-get -y upgrade &>/dev/null
    msg_ok "Приложение успешно обновлено!"
    exit
}

start
build_container
description

msg_ok "Установка успешно завершена!\n"
echo -e "${CREATING}${GN}${APP} Установка успешно завершена!${CL}"
echo -e "${INFO}${YW} Access it using the following IP:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}${IP}:3306${CL}"
