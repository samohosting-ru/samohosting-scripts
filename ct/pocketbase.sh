#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://pocketbase.io/

# App Default Values
APP="Pocketbase"
var_tags="database"
var_cpu="1"
var_ram="512"
var_disk="8"
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
  if [[ ! -f /etc/systemd/system/pocketbase.service || ! -x /opt/pocketbase/pocketbase ]]; then
    msg_error "Отсутствует установленная версия ${APP}"
    exit
  fi
  msg_info "Останавливаю работу приложения ${APP}"
  systemctl stop pocketbase
  msg_ok "Приложение ${APP} остановлено"

  msg_info "Обновляю ${APP}"
  /opt/pocketbase/pocketbase update
  msg_ok "Updated ${APP}"

  msg_info "Запускаю ${APP}"
  systemctl start pocketbase
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
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8080/_${CL}"
