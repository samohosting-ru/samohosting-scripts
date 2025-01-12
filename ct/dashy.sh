#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://dashy.to/

# App Default Values
APP="Dashy"
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
  if [[ ! -d /opt/dashy/public/ ]]; then
    msg_error "Отсутствует установленная версия ${APP}"
    exit
  fi

  RELEASE=$(curl -sL https://api.github.com/repos/Lissy93/dashy/releases/latest | grep '"tag_name":' | cut -d'"' -f4)
  if [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]] || [[ ! -f /opt/${APP}_version.txt ]]; then
    msg_info "Останавливаю работу приложения ${APP}"
    systemctl stop dashy
    msg_ok "Приложение ${APP} остановлено"

    msg_info "Делаю резервную копию Вашего файла conf.yml"
    cd ~
    if [[ -f /opt/dashy/public/conf.yml ]]; then
      cp -R /opt/dashy/public/conf.yml conf.yml
    else
      cp -R /opt/dashy/user-data/conf.yml conf.yml
    fi
    msg_ok "Забекапировал Ваш conf.yml"

    msg_info "Обновляю ${APP} до ${RELEASE}"
    rm -rf /opt/dashy
    mkdir -p /opt/dashy
    wget -qO- https://github.com/Lissy93/dashy/archive/refs/tags/${RELEASE}.tar.gz | tar -xz -C /opt/dashy --strip-components=1
    cd /opt/dashy
    npm install
    npm run build
    echo "${RELEASE}" >/opt/${APP}_version.txt
    msg_ok "Приложение ${APP} обновлено до версии ${RELEASE}"

    msg_info "Восстанавливаю из бекапа Ваш conf.yml"
    cd ~
    cp -R conf.yml /opt/dashy/user-data
    msg_ok "Restored conf.yml"

    msg_info "Провожу уборку. Удаляю временные файлы установки"
    rm -rf conf.yml /opt/dashy/public/conf.yml
    msg_ok "Временные файлы установки - удалены!"

    msg_info "Запускаю Dashy"
    systemctl start dashy
    msg_ok "Запустил Dashy"
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
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:4000${CL}"