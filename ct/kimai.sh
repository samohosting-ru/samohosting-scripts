#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: MickLesk (Canbiz)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://www.kimai.org/

# App Default Values
APP="Kimai"
var_tags="time-tracking"
var_cpu="2"
var_ram="2048"
var_disk="7"
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
  if [[ ! -d /opt/kimai ]]; then
    msg_error "Отсутствует установленная версия ${APP}"
    exit
  fi
  RELEASE=$(curl -s https://api.github.com/repos/kimai/kimai/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
  if [[ ! -f /opt/${APP}_version.txt ]] || [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]]; then
    msg_info "Stopping Apache2"
    systemctl stop apache2
    msg_ok "Stopped Apache2"

    msg_info "Обновляю ${APP} до ${RELEASE}"
    cp /opt/kimai/.env /opt/.env
    rm -rf /opt/kimai
    wget -q "https://github.com/kimai/kimai/archive/refs/tags/${RELEASE}.zip"
    unzip -q ${RELEASE}.zip
    mv kimai-${RELEASE} /opt/kimai
    mv /opt/.env /opt/kimai/.env
    cd /opt/kimai
    composer install --no-dev --optimize-autoloader &>/dev/null
    bin/console kimai:update &>/dev/null
    chown -R :www-data .
    chmod -R g+r .
    chmod -R g+rw var/
    sudo chown -R www-data:www-data /opt/kimai
    sudo chmod -R 755 /opt/kimai
    echo "${RELEASE}" >/opt/${APP}_version.txt
    msg_ok "Приложение ${APP} обновлено до версии ${RELEASE}"

    msg_info "Запускаю Apache2"
    systemctl start apache2
    msg_ok "Запустил Apache2"

    msg_info "Провожу уборку. Удаляю временные файлы установки"
    rm -rf ${RELEASE}.zip
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
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}${CL}"