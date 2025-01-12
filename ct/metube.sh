#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: MickLesk (Canbiz)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://github.com/alexta69/metube

# App Default Values
APP="MeTube"
var_tags="media;youtube"
var_cpu="1"
var_ram="1024"
var_disk="10"
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
  if [[ ! -d /opt/metube ]]; then
    msg_error "Отсутствует установленная версия ${APP}"
    exit
  fi
  msg_info "Stopping ${APP} Service"
  systemctl stop metube
  msg_ok "Stopped ${APP} Service"

  msg_info "Обновляю ${APP} to latest Git"
  cd /opt
  if [ -d metube_bak ]; then
    rm -rf metube_bak
  fi
  mv metube metube_bak
  git clone https://github.com/alexta69/metube /opt/metube >/dev/null 2>&1
  cd /opt/metube/ui
  npm install >/dev/null 2>&1
  node_modules/.bin/ng build >/dev/null 2>&1
  cd /opt/metube
  cp /opt/metube_bak/.env /opt/metube/
  pip3 install pipenv >/dev/null 2>&1
  pipenv install >/dev/null 2>&1

  if [ -d "/opt/metube_bak" ]; then
    rm -rf /opt/metube_bak
  fi
  msg_ok "Updated ${APP} to latest Git"

  msg_info "Запускаю ${APP} Service"
  systemctl start metube
  sleep 1
  msg_ok "Запустил ${APP} Service"
  msg_ok "Updated Successfully!\n"
  exit
}

start
build_container
description

msg_ok "Установка успешно завершена!\n"
echo -e "${CREATING}${GN}${APP} Установка успешно завершена!${CL}"
echo -e "${INFO}${YW} Сервис доступен по ссылке:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8081${CL}"