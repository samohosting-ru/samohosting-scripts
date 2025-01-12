#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: MickLesk (Canbiz) & vhsdream
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://hoarder.app/

# App Default Values
APP="Hoarder"
var_tags="bookmark"
var_cpu="2"
var_ram="4096"
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
  if [[ ! -d /opt/hoarder ]]; then
    msg_error "Отсутствует установленная версия ${APP}"
    exit
  fi
  RELEASE=$(curl -s https://api.github.com/repos/hoarder-app/hoarder/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4) }')
  PREV_RELEASE=$(cat /opt/${APP}_version.txt)
  if [[ ! -f /opt/${APP}_version.txt ]] || [[ "${RELEASE}" != "${PREV_RELEASE}" ]]; then
    msg_info "Stopping Services"
    systemctl stop hoarder-web hoarder-workers hoarder-browser
    msg_ok "Stopped Services"
    msg_info "Обновляю ${APP} to v${RELEASE}"
    cd /opt
    mv /opt/hoarder/.env /opt/.env
    rm -rf /opt/hoarder
    wget -q "https://github.com/hoarder-app/hoarder/archive/refs/tags/v${RELEASE}.zip"
    unzip -q v${RELEASE}.zip
    mv hoarder-${RELEASE} /opt/hoarder
    cd /opt/hoarder/apps/web
    pnpm install --frozen-lockfile &>/dev/null
    pnpm exec next build --experimental-build-mode compile &>/dev/null
    cp -r /opt/hoarder/apps/web/.next/standalone/apps/web/server.js /opt/hoarder/apps/web
    cd /opt/hoarder/apps/workers
    pnpm install --frozen-lockfile &>/dev/null
    export DATA_DIR=/opt/hoarder_data
    cd /opt/hoarder/packages/db
    pnpm migrate &>/dev/null
    mv /opt/.env /opt/hoarder/.env
    sed -i "s/SERVER_VERSION=${PREV_RELEASE}/SERVER_VERSION=${RELEASE}/" /opt/hoarder/.env
    msg_ok "Updated ${APP} to v${RELEASE}"

    msg_info "Запускаю Services"
    systemctl start hoarder-browser hoarder-workers hoarder-web
    msg_ok "Запустил Services"
    msg_info "Cleaning up"
    rm -R /opt/v${RELEASE}.zip
    echo "${RELEASE}" >/opt/${APP}_version.txt
    msg_ok "Временные файлы установки - удалены!"
    msg_ok "Приложение успешно обновлено!"
  else
    msg_ok "No update required.  ${APP} is already at ${RELEASE}."
  fi
  exit
}

start
build_container
description

msg_ok "Установка успешно завершена!\n"
echo -e "${CREATING}${GN}${APP} Установка успешно завершена!${CL}"
echo -e "${INFO}${YW} Сервис доступен по ссылке:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:3000${CL}"