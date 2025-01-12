#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://emby.media/

# App Default Values
APP="Emby"
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
    if [[ ! -d /opt/emby-server ]]; then
        msg_error "Отсутствует установленная версия ${APP}"
        exit
    fi
    LATEST=$(curl -sL https://api.github.com/repos/MediaBrowser/Emby.Releases/releases/latest | grep '"tag_name":' | cut -d'"' -f4)
    msg_info "Останавливаю работу приложения ${APP}"
    systemctl stop emby-server
    msg_ok "Приложение ${APP} остановлено"

    msg_info "Обновляю ${APP}"
    wget https://github.com/MediaBrowser/Emby.Releases/releases/download/${LATEST}/emby-server-deb_${LATEST}_amd64.deb &>/dev/null
    dpkg -i emby-server-deb_${LATEST}_amd64.deb &>/dev/null
    rm emby-server-deb_${LATEST}_amd64.deb
    msg_ok "Updated ${APP}"

    msg_info "Запускаю ${APP}"
    systemctl start emby-server
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
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8096${CL}"
