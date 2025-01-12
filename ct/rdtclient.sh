#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://github.com/rogerfar/rdt-client

# App Default Values
APP="RDTClient"
var_tags="torrent"
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
    if [[ ! -d /opt/rdtc/ ]]; then
        msg_error "Отсутствует установленная версия ${APP}"
        exit
    fi
    msg_info "Останавливаю работу приложения ${APP}"
    systemctl stop rdtc
    msg_ok "Приложение ${APP} остановлено"

    msg_info "Обновляю ${APP}"
    if dpkg-query -W dotnet-sdk-8.0 >/dev/null 2>&1; then
        apt-get remove --purge -y dotnet-sdk-8.0 &>/dev/null
        apt-get install -y dotnet-sdk-9.0 &>/dev/null
    fi
    mkdir -p rdtc-backup
    cp -R /opt/rdtc/appsettings.json rdtc-backup/
    wget -q https://github.com/rogerfar/rdt-client/releases/latest/download/RealDebridClient.zip
    unzip -oqq RealDebridClient.zip -d /opt/rdtc
    cp -R rdtc-backup/appsettings.json /opt/rdtc/
    msg_ok "Updated ${APP}"

    msg_info "Запускаю ${APP}"
    systemctl start rdtc
    msg_ok "Запустил ${APP}"

    msg_info "Провожу уборку. Удаляю временные файлы установки"
    rm -rf rdtc-backup RealDebridClient.zip
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
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:6500${CL}"