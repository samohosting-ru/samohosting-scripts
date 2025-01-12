#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://github.com/bastienwirtz/homer

# App Default Values
APP="Homer"
var_tags="dashboard"
var_cpu="1"
var_ram="512"
var_disk="2"
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
    if [[ ! -d /opt/homer ]]; then
        msg_error "Отсутствует установленная версия ${APP}"
        exit
    fi
    msg_info "Останавливаю работу приложения ${APP}"
    systemctl stop homer
    msg_ok "Приложение ${APP} остановлено"

    msg_info "Backing up assets directory"
    cd ~
    mkdir -p assets-backup
    cp -R /opt/homer/assets/. assets-backup
    msg_ok "Backed up assets directory"

    msg_info "Обновляю ${APP}"
    rm -rf /opt/homer/*
    cd /opt/homer
    wget -q https://github.com/bastienwirtz/homer/releases/latest/download/homer.zip
    unzip homer.zip &>/dev/null
    msg_ok "Updated ${APP}"

    msg_info "Происходит восстановление каталогов"
    cd ~
    cp -Rf assets-backup/. /opt/homer/assets/
    msg_ok "Каталоги восстановлены"

    msg_info "Провожу уборку. Удаляю временные файлы установки"
    rm -rf assets-backup /opt/homer/homer.zip
    msg_ok "Временные файлы установки - удалены!"

    msg_info "Запускаю ${APP}"
    systemctl start homer
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
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8010${CL}"