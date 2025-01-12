#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://mafl.hywax.space/

# App Default Values
APP="Mafl"
var_tags="dashboard"
var_cpu="2"
var_ram="2048"
var_disk="6"
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
  if [[ ! -d /opt/mafl ]]; then
    msg_error "Отсутствует установленная версия ${APP}"
    exit
  fi
  RELEASE=$(curl -s https://api.github.com/repos/hywax/mafl/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4) }')
  msg_info "Обновляю Mafl to v${RELEASE} (Patience)"
  systemctl stop mafl
  wget -q https://github.com/hywax/mafl/archive/refs/tags/v${RELEASE}.tar.gz
  tar -xzf v${RELEASE}.tar.gz
  cp -r mafl-${RELEASE}/* /opt/mafl/
  rm -rf mafl-${RELEASE}
  cd /opt/mafl
  yarn install
  yarn build
  systemctl start mafl
  msg_ok "Updated Mafl to v${RELEASE}"
  exit
}

start
build_container
description

msg_ok "Установка успешно завершена!\n"
echo -e "${CREATING}${GN}${APP} Установка успешно завершена!${CL}"
echo -e "${INFO}${YW} Сервис доступен по ссылке:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:3000${CL}"