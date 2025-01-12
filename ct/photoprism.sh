#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://www.photoprism.app/

# App Default Values
APP="PhotoPrism"
var_tags="media;photo"
var_cpu="2"
var_ram="3072"
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
  if [[ ! -d /opt/photoprism ]]; then
    msg_error "Отсутствует установленная версия ${APP}"
    exit
  fi
  msg_info "Stopping PhotoPrism"
  sudo systemctl stop photoprism
  msg_ok "Stopped PhotoPrism"

  msg_info "Обновляю PhotoPrism"
  apt-get install -y libvips42 &>/dev/null
  wget -q -cO - https://dl.photoprism.app/pkg/linux/amd64.tar.gz | tar -xzf - -C /opt/photoprism --strip-components=1
  msg_ok "Updated PhotoPrism"

  msg_info "Запускаю PhotoPrism"
  sudo systemctl start photoprism
  msg_ok "Запустил PhotoPrism"
  msg_ok "Update Successful"
  exit
}

start
build_container
description

msg_ok "Установка успешно завершена!\n"
echo -e "${CREATING}${GN}${APP} Установка успешно завершена!${CL}"
echo -e "${INFO}${YW} Сервис доступен по ссылке:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:2342${CL}"