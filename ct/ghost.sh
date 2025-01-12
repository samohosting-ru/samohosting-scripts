#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func) 
# Copyright (c) 2021-2025 community-scripts ORG
# Author: fabrice1236
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://ghost.org/

# App Default Values
APP="Ghost"
var_tags="cms;blog"
var_cpu="2"
var_ram="1024"
var_disk="5"
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
    msg_info "Обновляю ${APP} LXC"

    if command -v ghost &> /dev/null; then
        current_version=$(ghost version | grep 'Ghost-CLI version' | awk '{print $3}')
        latest_version=$(npm show ghost-cli version)
        if [ "$current_version" != "$latest_version" ]; then
            msg_info "Обновляю ${APP} from version v${current_version} to v${latest_version}"
            npm install -g ghost-cli@latest &> /dev/null
            msg_ok "Приложение успешно обновлено!"
        else
            msg_ok "${APP} is already at v${current_version}"
        fi
    else
        msg_error "Отсутствует установленная версия ${APP}"
        exit
    fi
    exit
}

start
build_container
description

msg_ok "Установка успешно завершена!\n"
echo -e "${CREATING}${GN}${APP} Установка успешно завершена!${CL}"
echo -e "${INFO}${YW} Сервис доступен по ссылке:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:2368${CL}"