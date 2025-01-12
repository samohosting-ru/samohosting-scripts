#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: MickLesk (Canbiz)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://ersatztv.org/

# App Default Values
APP="ErsatzTV"
var_tags="iptv"
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
    if [[ ! -d /opt/ErsatzTV ]]; then
        msg_error "Отсутствует установленная версия ${APP}"
        exit
    fi

    msg_info "Stopping ErsatzTV"
    systemctl stop ersatzTV
    msg_ok "Stopped ErsatzTV"

    msg_info "Обновляю ErsatzTV"
    RELEASE=$(curl -s https://api.github.com/repos/ErsatzTV/ErsatzTV/releases | grep -oP '"tag_name": "\K[^"]+' | head -n 1)
    cp -R /opt/ErsatzTV/ ErsatzTV-backup
    rm ErsatzTV-backup/ErsatzTV
    rm -rf /opt/ErsatzTV
    wget -qO- "https://github.com/ErsatzTV/ErsatzTV/releases/download/${RELEASE}/ErsatzTV-${RELEASE}-linux-x64.tar.gz" | tar -xz -C /opt
    mv "/opt/ErsatzTV-${RELEASE}-linux-x64" /opt/ErsatzTV
    cp -R ErsatzTV-backup/* /opt/ErsatzTV/
    rm -rf ErsatzTV-backup
    msg_ok "Updated ErsatzTV"

    msg_info "Запускаю ErsatzTV"
    systemctl start ersatzTV
    msg_ok "Запустил ErsatzTV"
    msg_ok "Приложение успешно обновлено!"
    exit
}

start
build_container
description

msg_ok "Установка успешно завершена!\n"
echo -e "${CREATING}${GN}${APP} Установка успешно завершена!${CL}"
echo -e "${INFO}${YW} Сервис доступен по ссылке:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8409${CL}"