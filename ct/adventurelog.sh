#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: MickLesk (Canbiz)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://adventurelog.app/

# App Default Values
APP="AdventureLog"
var_tags="traveling"
var_disk="7"
var_cpu="2"
var_ram="2048"
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
  if [[ ! -d /opt/adventurelog ]]; then
    msg_error "Отсутствует установленная версия ${APP}"
    exit
  fi
  RELEASE=$(curl -s https://api.github.com/repos/seanmorley15/AdventureLog/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4) }')
  if [[ ! -f /opt/${APP}_version.txt ]] || [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]]; then
    msg_info "Stopping Services"
    systemctl stop adventurelog-backend
    systemctl stop adventurelog-frontend
    msg_ok "Services Stopped"

    msg_info "Обновляю ${APP} до ${RELEASE}"
    mv /opt/adventurelog/ /opt/adventurelog-backup/
    wget -qO /opt/v${RELEASE}.zip "https://github.com/seanmorley15/AdventureLog/archive/refs/tags/v${RELEASE}.zip"
    unzip -q /opt/v${RELEASE}.zip -d /opt/
    mv /opt/AdventureLog-${RELEASE} /opt/adventurelog

    mv /opt/adventurelog-backup/backend/server/.env /opt/adventurelog/backend/server/.env
    mv /opt/adventurelog-backup/backend/server/media /opt/adventurelog/backend/server/media
    cd /opt/adventurelog/backend/server
    pip install --upgrade pip &>/dev/null
    pip install -r requirements.txt &>/dev/null
    python3 manage.py collectstatic --noinput &>/dev/null
    python3 manage.py migrate &>/dev/null

    mv /opt/adventurelog-backup/frontend/.env /opt/adventurelog/frontend/.env
    cd /opt/adventurelog/frontend
    pnpm install &>/dev/null
    pnpm run build &>/dev/null
    echo "${RELEASE}" >/opt/${APP}_version.txt
    msg_ok "Updated ${APP}"

    msg_info "Запускаю Services"
    systemctl start adventurelog-backend
    systemctl start adventurelog-frontend
    msg_ok "Запустил Services"

    msg_info "Провожу уборку. Удаляю временные файлы установки"
    rm -rf /opt/v${RELEASE}.zip
    rm -rf /opt/adventurelog-backup
    msg_ok "Временные файлы установки - удалены!"
    msg_ok "Приложение успешно обновлено!"
  else
    msg_ok "Обновление не требуется. ${APP} уже последней версии ${RELEASE}"
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
