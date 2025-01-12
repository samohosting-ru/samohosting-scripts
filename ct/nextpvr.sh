#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: MickLesk (Canbiz)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE
# Source: https://nextpvr.com/

# App Default Values
APP="NextPVR"
var_tags="pvr"
var_cpu="1"
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
    if [[ ! -d /opt/nextpvr ]]; then
        msg_error "Отсутствует установленная версия ${APP}"
        exit
    fi
    msg_info "Останавливаю работу приложения ${APP}"
    systemctl stop nextpvr-server
    msg_ok "Приложение ${APP} остановлено"

    msg_info "Обновляю LXC packages"
    apt-get update &>/dev/null
    apt-get -y upgrade &>/dev/null
    msg_ok "Updated LXC packages"

    msg_info "Обновляю ${APP}"
    cd /opt
    wget -q https://nextpvr.com/nextpvr-helper.deb
    dpkg -i nextpvr-helper.deb &>/dev/null
    msg_ok "Updated ${APP}"

    msg_info "Запускаю ${APP}"
    systemctl start nextpvr-server
    msg_ok "Запустил ${APP}"

    msg_info "Провожу уборку. Удаляю временные файлы установки"
    rm -rf /opt/nextpvr-helper.deb
    msg_ok "Временные файлы установки - удалены!"
    msg_ok "Приложение успешно обновлено!"
    exit
}

start
build_container
description

msg_ok "Установка успешно завершена!\n"
echo -e "${CREATING}${GN}${APP} Установка успешно завершена!${CL}"
echo -e "${INFO}${YW} Сервис доступен по ссылке:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8866${CL}"