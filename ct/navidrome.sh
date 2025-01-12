#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://www.navidrome.org/

# App Default Values
APP="Navidrome"
var_tags="music"
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
    if [[ ! -d /opt/navidrome ]]; then
        msg_error "Отсутствует установленная версия ${APP}"
        exit
    fi
    RELEASE=$(curl -s https://api.github.com/repos/navidrome/navidrome/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4) }')
    msg_info "Останавливаю работу приложения ${APP}"
    systemctl stop navidrome
    msg_ok "Stopped Navidrome"

    msg_info "Обновляю to v${RELEASE}"
    cd /opt
    wget -q https://github.com/navidrome/navidrome/releases/download/v${RELEASE}/navidrome_${RELEASE}_linux_amd64.tar.gz -O Navidrome.tar.gz
    tar -xvzf Navidrome.tar.gz -C /opt/navidrome/ &>/dev/null
    chmod +x /opt/navidrome/navidrome
    msg_ok "Updated ${APP}"
    rm -rf /opt/Navidrome.tar.gz

    msg_info "Запускаю ${APP}"
    systemctl start navidrome.service
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
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:4533${CL}"
