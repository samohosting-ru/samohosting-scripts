#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: MickLesk (Canbiz)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://github.com/Donkie/Spoolman

# App Default Values
APP="Spoolman"
var_tags="3d-printing"
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
  if [[ ! -d /opt/spoolman ]]; then
    msg_error "Отсутствует установленная версия ${APP}"
    exit
  fi
  RELEASE=$(wget -q https://github.com/Donkie/Spoolman/releases/latest -O - | grep "title>Release" | cut -d " " -f 4)
  if [[ ! -f /opt/${APP}_version.txt ]] || [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]]; then

    msg_info "Stopping ${APP} Service"
    systemctl stop spoolman
    msg_ok "Stopped ${APP} Service"

    msg_info "Обновляю ${APP} до ${RELEASE}"
    cd /opt
    rm -rf spoolman_bak
    mv spoolman spoolman_bak
    wget -q https://github.com/Donkie/Spoolman/releases/download/${RELEASE}/spoolman.zip
    unzip -q spoolman.zip -d spoolman
    cd spoolman
    pip3 install -r requirements.txt >/dev/null 2>&1
    wget -q https://raw.githubusercontent.com/Donkie/Spoolman/master/.env.example -O .env
    echo "${RELEASE}" >/opt/${APP}_version.txt
    msg_ok "Приложение ${APP} обновлено до версии ${RELEASE}"

    msg_info "Запускаю ${APP} Service"
    systemctl start spoolman
    msg_ok "Запустил ${APP} Service"

    msg_info "Cleaning up"
    rm -rf /opt/spoolman.zip
    msg_ok "Временные файлы установки - удалены!"

    msg_ok "Updated Successfully!\n"
  else
    msg_ok "Обновление не требуется. ${APP} уже последней версии ${RELEASE}"
  fi
  exit
}

start
build_container
description

msg_ok "Установка успешно завершена!\n"
echo -e "${CREATING}${GN}${APP} Установка успешно завершена!${CL}"
echo -e "${INFO}${YW} Сервис доступен по ссылке:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:7912${CL}"