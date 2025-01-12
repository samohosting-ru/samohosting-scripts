#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://shinobi.video/

# App Default Values
APP="Shinobi"
var_tags="nvr"
var_cpu="2"
var_ram="2048"
var_disk="8"
var_os="ubuntu"
var_version="22.04"
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
  if [[ ! -d /opt/Shinobi ]]; then
    msg_error "Отсутствует установленная версия ${APP}"
    exit
  fi
  msg_info "Обновляю Shinobi LXC"
  cd /opt/Shinobi
  sh UPDATE.sh
  pm2 flush
  pm2 restart camera
  pm2 restart cron
  msg_ok "Updated Shinobi LXC"
  exit
}

start
build_container
description

msg_ok "Установка успешно завершена!\n"
echo -e "${CREATING}${GN}${APP} Установка успешно завершена!${CL}"
echo -e "${INFO}${YW} Сервис доступен по ссылке:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8080/super${CL}"