#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck | Co-Author: MountyMapleSyrup (MountyMapleSyrup)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://gitlab.com/LazyLibrarian/LazyLibrarian

# App Default Values
APP="LazyLibrarian"
var_tags="eBook"
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
    if [[ ! -d /opt/LazyLibrarian/ ]]; then
        msg_error "Отсутствует установленная версия ${APP}"
        exit
    fi
    msg_info "Stopping LazyLibrarian"
    systemctl stop lazylibrarian
    msg_ok "LazyLibrarian Stopped"

    msg_info "Обновляю $APP LXC"
    git -C /opt/LazyLibrarian pull origin master &>/dev/null
    msg_ok "Обновлен LXC контейнер приложения $APP"

    msg_info "Запускаю LazyLibrarian"
    systemctl start lazylibrarian
    msg_ok "Запустил LazyLibrarian"

    msg_ok "Приложение успешно обновлено!"
    exit
}

start
build_container
description

msg_ok "Установка успешно завершена!\n"
echo -e "${CREATING}${GN}${APP} Установка успешно завершена!${CL}"
echo -e "${INFO}${YW} Сервис доступен по ссылке:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:5299${CL}"