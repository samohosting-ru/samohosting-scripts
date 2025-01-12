#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://umami.is/

# App Default Values
APP="Umami"
var_tags="analytics"
var_cpu="2"
var_ram="2048"
var_disk="12"
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
    if [[ ! -d /opt/umami ]]; then
        msg_error "Отсутствует установленная версия ${APP}"
        exit
    fi

    msg_info "Останавливаю работу приложения ${APP}"
    systemctl stop umami
    msg_ok "Stopped $APP"

    msg_info "Обновляю ${APP}"
    cd /opt/umami
    git pull
    yarn install
    yarn build
    msg_ok "Updated ${APP}"

    msg_info "Запускаю ${APP}"
    systemctl start umami
    msg_ok "Запустил ${APP}"

    msg_ok "Приложение успешно обновлено!"
    exit
}

start
build_container
description

msg_ok "Установка успешно завершена!\n"
echo -e "${CREATING}${GN}${APP} Установка успешно завершена!${CL}"
echo -e "${INFO}${YW} Сервис доступен по ссылке:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:3000${CL}"