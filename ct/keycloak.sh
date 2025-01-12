#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://www.keycloak.org/

# App Default Values
APP="Keycloak"
var_tags="access-management"
var_cpu="2"
var_ram="2048"
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
  if [[ ! -f /etc/systemd/system/keycloak.service ]]; then
    msg_error "Отсутствует установленная версия ${APP}"
    exit
  fi
  msg_info "Обновляю ${APP} LXC"

  msg_info "Обновляю packages"
  apt-get update &>/dev/null
  apt-get -y upgrade &>/dev/null

  RELEASE=$(curl -s https://api.github.com/repos/keycloak/keycloak/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
  msg_info "Обновляю Keycloak to v$RELEASE"
  cd /opt
  wget -q https://github.com/keycloak/keycloak/releases/download/$RELEASE/keycloak-$RELEASE.tar.gz
  mv keycloak keycloak.old
  tar -xzf keycloak-$RELEASE.tar.gz
  cp -r keycloak.old/conf keycloak-$RELEASE
  cp -r keycloak.old/providers keycloak-$RELEASE
  cp -r keycloak.old/themes keycloak-$RELEASE
  mv keycloak-$RELEASE keycloak

  msg_info "Delete temporary installation files"
  rm keycloak-$RELEASE.tar.gz
  rm -rf keycloak.old

  msg_info "Restating Keycloak"
  systemctl restart keycloak
  msg_ok "Приложение успешно обновлено!"
  exit
}

start
build_container
description

msg_ok "Установка успешно завершена!\n"
echo -e "${CREATING}${GN}${APP} Установка успешно завершена!${CL}"
echo -e "${INFO}${YW} Сервис доступен по ссылке:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8080/admin${CL}"
