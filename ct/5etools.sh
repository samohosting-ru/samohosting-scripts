#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: TheRealVira
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://5e.tools/

# App Default Values
APP="5etools"
var_tags="wiki"
var_cpu="1"
var_ram="512"
var_disk="13"
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

    # Check if installation is present | -f for file, -d for folder
    if [[ ! -d "/opt/${APP}" ]]; then
        msg_error "Отсутствует установленная версия ${APP}"
        exit
    fi

    RELEASE=$(curl -s https://api.github.com/repos/5etools-mirror-3/5etools-src/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
    if [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]] || [[ ! -f "/opt/${APP}_version.txt" ]]; then
        # Crawling the new version and checking whether an update is required
        msg_info "Обновляю System"
        apt-get update &>/dev/null
        apt-get -y upgrade &>/dev/null
        msg_ok "Система обновлена"

        # Execute Update
        msg_info "Обновляю base 5etools"
        cd /opt
        wget -q "https://github.com/5etools-mirror-3/5etools-src/archive/refs/tags/${RELEASE}.zip"
        unzip -q "${RELEASE}.zip"
        mv "/opt/${APP}/img" "/opt/img-backup"
        rm -rf "/opt/${APP}"
        mv "${APP}-src-${RELEASE:1}" "/opt/${APP}"
        mv "/opt/img-backup" "/opt/${APP}/img"
        cd /opt/5etools
        $STD npm install
        $STD npm run build
        cd ~
        echo "${RELEASE}" >"/opt/${APP}_version.txt"
        chown -R www-data: "/opt/${APP}"
        chmod -R 755 "/opt/${APP}"
        msg_ok "Updated base 5etools"
        # Cleaning up
        msg_info "Провожу уборку. Удаляю временные файлы установки"
        rm -rf /opt/${RELEASE}.zip
        $STD apt-get -y autoremove
        $STD apt-get -y autoclean
        msg_ok "Временные файлы установки - удалены!"
    else
        msg_ok "Обновление не требуется. База приложение ${APP} уже последней версии ${RELEASE}"
    fi

    IMG_RELEASE=$(curl -s https://api.github.com/repos/5etools-mirror-2/5etools-img/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
    if [[ "${IMG_RELEASE}" != "$(cat /opt/${APP}_IMG_version.txt)" ]] || [[ ! -f "/opt/${APP}_IMG_version.txt" ]]; then
        # Crawling the new version and checking whether an update is required
        msg_info "Обновляю System"
        apt-get update &>/dev/null
        apt-get -y upgrade &>/dev/null
        msg_ok "Система обновлена"

        # Execute Update
        msg_info "Обновляю 5etools images"
        curl -sSL "https://github.com/5etools-mirror-2/5etools-img/archive/refs/tags/${IMG_RELEASE}.zip" > "${IMG_RELEASE}.zip"
        unzip -q "${IMG_RELEASE}.zip"
        rm -rf "/opt/${APP}/img"
        mv "${APP}-img-${IMG_RELEASE:1}" "/opt/${APP}/img"
        echo "${IMG_RELEASE}" >"/opt/${APP}_IMG_version.txt"
        chown -R www-data: "/opt/${APP}"
        chmod -R 755 "/opt/${APP}"

        msg_ok "Обновляю  5etools images"

        # Cleaning up
        msg_info "Провожу уборку. Удаляю временные файлы установки"
        rm -rf /opt/${RELEASE}.zip
        rm -rf ${IMG_RELEASE}.zip
        $STD apt-get -y autoremove
        $STD apt-get -y autoclean
        msg_ok "Временные файлы установки - удалены!"
    else
        msg_ok "Обновление не требуется. ${APP} уже последней версии ${IMG_RELEASE}"
    fi

}

start
build_container
description

msg_ok "Установка успешно завершена!\n"
echo -e "${CREATING}${GN}${APP} Установка успешно завершена!${CL}"
echo -e "${INFO}${YW} Сервис доступен по ссылке:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}${CL}"
