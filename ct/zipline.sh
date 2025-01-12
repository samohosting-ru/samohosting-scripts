#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: MickLesk (Canbiz)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://zipline.diced.sh/

# App Default Values
APP="Zipline"
var_tags="file;sharing"
var_cpu="2"
var_ram="2048"
var_disk="5"
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
  if [[ ! -d /opt/zipline ]]; then
    msg_error "Отсутствует установленная версия ${APP}"
    exit
  fi
  RELEASE=$(curl -s https://api.github.com/repos/diced/zipline/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4) }')
  if [[ ! -f /opt/${APP}_version.txt ]] || [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]]; then
    msg_info "Останавливаю работу приложения ${APP}"
    systemctl stop zipline
    msg_ok "${APP} Stopped"

    msg_info "Обновляю ${APP} до ${RELEASE}"
    cp /opt/zipline/.env /opt/
    rm -R /opt/zipline
    wget -q "https://github.com/diced/zipline/archive/refs/tags/v${RELEASE}.zip"
    unzip -q v${RELEASE}.zip
    mv zipline-${RELEASE} /opt/zipline
    cd /opt/zipline
    mv /opt/.env /opt/zipline/.env
    yarn install &>/dev/null
    yarn build &>/dev/null
    echo "${RELEASE}" >/opt/${APP}_version.txt
    msg_ok "Updated ${APP}"

    msg_info "Запускаю ${APP}"
    systemctl start zipline
    msg_ok "Запустил ${APP}"

    msg_info "Провожу уборку. Удаляю временные файлы установки"
    rm -rf v${RELEASE}.zip
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