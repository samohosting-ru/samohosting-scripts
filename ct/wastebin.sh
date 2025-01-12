#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: MickLesk (Canbiz)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://github.com/matze/wastebin

# App Default Values
APP="Wastebin"
var_tags="file;code"
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
  if [[ ! -d /opt/wastebin ]]; then
    msg_error "Отсутствует установленная версия ${APP}"
    exit
  fi
  RELEASE=$(curl -s https://api.github.com/repos/matze/wastebin/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
  if [[ ! -f /opt/${APP}_version.txt ]] || [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]]; then
    msg_info "Stopping Wastebin"
    systemctl stop wastebin
    msg_ok "Wastebin Stopped"

    msg_info "Обновляю Wastebin"
    wget -q https://github.com/matze/wastebin/releases/download/${RELEASE}/wastebin_${RELEASE}_x86_64-unknown-linux-musl.tar.zst
    tar -xf wastebin_${RELEASE}_x86_64-unknown-linux-musl.tar.zst
    cp -f wastebin /opt/wastebin/
    chmod +x /opt/wastebin/wastebin
    echo "${RELEASE}" >/opt/${APP}_version.txt
    msg_ok "Updated Wastebin"

    msg_info "Запускаю Wastebin"
    systemctl start wastebin
    msg_ok "Запустил Wastebin"

    msg_info "Провожу уборку. Удаляю временные файлы установки"
    rm -rf wastebin_${RELEASE}_x86_64-unknown-linux-musl.tar.zst
    msg_ok "Временные файлы установки - удалены!"
    msg_ok "Приложение успешно обновлено!"
  else
    msg_ok "No update required. ${APP} is already at v${RELEASE}"
  fi
  exit
}

start
build_container
description

msg_ok "Установка успешно завершена!\n"
echo -e "${CREATING}${GN}${APP} Установка успешно завершена!${CL}"
echo -e "${INFO}${YW} Сервис доступен по ссылке:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8088${CL}"
