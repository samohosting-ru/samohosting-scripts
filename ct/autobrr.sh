#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://autobrr.com/

# App Default Values
APP="Autobrr"
var_tags="arr;"
var_cpu="2"
var_ram="2048"
var_disk="8"
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
    if [[ ! -f /root/.config/autobrr/config.toml ]]; then
        msg_error "Отсутствует установленная версия ${APP}"
        exit
    fi
    msg_info "Stopping ${APP} LXC"
    systemctl stop autobrr.service
    msg_ok "Stopped ${APP} LXC"

    msg_info "Обновляю ${APP} LXC"
    rm -rf /usr/local/bin/*
    wget -q $(curl -s https://api.github.com/repos/autobrr/autobrr/releases/latest | grep download | grep linux_x86_64 | cut -d\" -f4)
    tar -C /usr/local/bin -xzf autobrr*.tar.gz
    rm -rf autobrr*.tar.gz
    msg_ok "Updated ${APP} LXC"

    msg_info "Запускаю ${APP} LXC"
    systemctl start autobrr.service
    msg_ok "Запустил ${APP} LXC"
    msg_ok "Приложение успешно обновлено!"
    exit
}

start
build_container
description

msg_ok "Установка успешно завершена!\n"
echo -e "${CREATING}${GN}${APP} Установка успешно завершена!${CL}"
echo -e "${INFO}${YW} Сервис доступен по ссылке:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:7474${CL}"