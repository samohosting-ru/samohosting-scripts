#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://linkwarden.app/

# App Default Values
APP="Linkwarden"
var_tags="bookmark"
var_cpu="2"
var_ram="2048"
var_disk="12"
var_os="ubuntu"
var_version="22.04"

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
  if [[ ! -d /opt/linkwarden ]]; then
    msg_error "Отсутствует установленная версия ${APP}"
    exit
  fi
  RELEASE=$(curl -s https://api.github.com/repos/linkwarden/linkwarden/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
  if [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]] || [[ ! -f /opt/${APP}_version.txt ]]; then
    msg_info "Останавливаю работу приложения ${APP}"
    systemctl stop linkwarden
    msg_ok "Приложение ${APP} остановлено"

    msg_info "Обновляю ${APP} до ${RELEASE}"
    cd /opt
    mv /opt/linkwarden/.env /opt/.env
    RELEASE=$(curl -s https://api.github.com/repos/linkwarden/linkwarden/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
    wget -q "https://github.com/linkwarden/linkwarden/archive/refs/tags/${RELEASE}.zip"
    unzip -q ${RELEASE}.zip
    mv linkwarden-${RELEASE:1} /opt/linkwarden
    cd /opt/linkwarden
    yarn &>/dev/null
    npx playwright install-deps &>/dev/null
    yarn playwright install &>/dev/null
    cp /opt/.env /opt/linkwarden/.env
    yarn build &>/dev/null
    yarn prisma migrate deploy &>/dev/null
    echo "${RELEASE}" >/opt/${APP}_version.txt
    msg_ok "Приложение ${APP} обновлено до версии ${RELEASE}"

    msg_info "Запускаю ${APP}"
    systemctl start linkwarden
    msg_ok "Запустил ${APP}"
    msg_info "Cleaning up"
    rm -rf /opt/${RELEASE}.zip
    rm -rf /opt/linkwarden_bak
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