#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://magicmirror.builders/

# App Default Values
APP="MagicMirror"
var_tags="smarthome"
var_cpu="1"
var_ram="512"
var_disk="3"
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
  if [[ ! -d /opt/magicmirror ]]; then
    msg_error "Отсутствует установленная версия ${APP}"
    exit
  fi
  if [[ "$(node -v | cut -d 'v' -f 2)" == "18."* ]]; then
    if ! command -v npm >/dev/null 2>&1; then
      echo "Installing NPM..."
      apt-get install -y npm >/dev/null 2>&1
      echo "Installed NPM..."
    fi
  fi
  msg_info "Обновляю ${APP} LXC"
  cd /opt/magicmirror
  git pull &>/dev/null
  npm install --only=prod --omit=dev &>/dev/null
  msg_ok "Приложение успешно обновлено!"
  exit
}

start
build_container
description

msg_ok "Установка успешно завершена!\n"
echo -e "${CREATING}${GN}${APP} Установка успешно завершена!${CL}"
echo -e "${INFO}${YW} Сервис доступен по ссылке:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8080${CL}"