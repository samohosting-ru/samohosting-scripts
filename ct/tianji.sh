#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: MickLesk (Canbiz)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://tianji.msgbyte.com/

# App Default Values
APP="Tianji"
var_tags="monitoring"
var_cpu="4"
var_ram="4096"
var_disk="12"
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
  if [[ ! -d /opt/tianji ]]; then
    msg_error "Отсутствует установленная версия ${APP}"
    exit
  fi
  RELEASE=$(curl -s https://api.github.com/repos/msgbyte/tianji/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4) }')
  if [[ ! -f /opt/${APP}_version.txt ]] || [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]]; then
    msg_info "Stopping ${APP} Service"
    systemctl stop tianji
    msg_ok "Stopped ${APP} Service"
    
    msg_info "Обновляю ${APP} to v${RELEASE}"
    cd /opt
    cp /opt/tianji/src/server/.env /opt/.env
    mv /opt/tianji /opt/tianji_bak
    wget -q "https://github.com/msgbyte/tianji/archive/refs/tags/v${RELEASE}.zip"
    unzip -q v${RELEASE}.zip
    mv tianji-${RELEASE} /opt/tianji
    cd tianji
    pnpm install --filter @tianji/client... --config.dedupe-peer-dependents=false --frozen-lockfile >/dev/null 2>&1
    pnpm build:static >/dev/null 2>&1
    pnpm install --filter @tianji/server... --config.dedupe-peer-dependents=false >/dev/null 2>&1
    mkdir -p ./src/server/public >/dev/null 2>&1
    cp -r ./geo ./src/server/public >/dev/null 2>&1
    pnpm build:server >/dev/null 2>&1
    mv /opt/.env /opt/tianji/src/server/.env
    cd src/server
    pnpm db:migrate:apply >/dev/null 2>&1
    echo "${RELEASE}" >/opt/${APP}_version.txt
    msg_ok "Updated ${APP} to v${RELEASE}"
    
    msg_info "Запускаю ${APP}"
    systemctl start tianji
    msg_ok "Запустил ${APP}"
    
    msg_info "Cleaning up"
    rm -R /opt/v${RELEASE}.zip
    rm -rf /opt/tianji_bak
    rm -rf /opt/tianji/src/client
    rm -rf /opt/tianji/website
    rm -rf /opt/tianji/reporter
    msg_ok "Временные файлы установки - удалены!"
    msg_ok "Приложение успешно обновлено!"
  else
    msg_ok "No update required.  ${APP} is already at v${RELEASE}."
  fi
  exit
}

start
build_container
description

msg_ok "Установка успешно завершена!\n"
echo -e "${CREATING}${GN}${APP} Установка успешно завершена!${CL}"
echo -e "${INFO}${YW} Сервис доступен по ссылке:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:12345${CL}"
