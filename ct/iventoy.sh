#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://www.iventoy.com/en/index.html

# App Default Values
APP="iVentoy"
var_tags="pxe-tool"
var_disk="2"
var_cpu="1"
var_ram="512"
var_os="debian"
var_version="12"
var_unprivileged="0"

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
  if [[ ! -d /opt/iventoy ]]; then
    msg_error "Отсутствует установленная версия ${APP}"
    exit
  fi
  msg_error "Обновления отсутствуют."
  exit
}

start
build_container
description

msg_ok "Установка успешно завершена!\n"
echo -e "${CREATING}${GN}${APP} Установка успешно завершена!${CL}"
echo -e "${INFO}${YW} Сервис доступен по ссылке:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:26000${CL}"