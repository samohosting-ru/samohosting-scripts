#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: Dominik Siebel (dsiebel)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://github.com/toniebox-reverse-engineering/teddycloud

# App default values
APP="TeddyCloud"
var_tags="media"
var_cpu="2"
var_disk="8"
var_ram="1024"
var_os="debian"
var_version="12"

# App Output & Base Settings
header_info "${APP}"
base_settings

# Core
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if [[ ! -d /opt/teddycloud ]]; then msg_error "Отсутствует установленная версия ${APP}"; exit; fi
  RELEASE="$(curl -s https://api.github.com/repos/toniebox-reverse-engineering/teddycloud/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')"
  VERSION="${RELEASE#tc_v}"
  if [[ ! -f "/opt/${APP}_version.txt" || "${VERSION}" != "$(cat /opt/${APP}_version.txt)" ]]; then
    msg_info "Останавливаю работу приложения ${APP}"
    systemctl stop teddycloud
    msg_ok "Приложение ${APP} остановлено"

    msg_info "Обновляю ${APP} to v${VERSION}"
    PREVIOUS_VERSION="$(readlink -f /opt/teddycloud)"
    wget -q "https://github.com/toniebox-reverse-engineering/teddycloud/releases/download/${RELEASE}/teddycloud.amd64.release_v${VERSION}.zip"
    unzip -q -d "/opt/teddycloud-${VERSION}" "teddycloud.amd64.release_v${VERSION}.zip"
    ln -fns "/opt/teddycloud-${VERSION}" /opt/teddycloud
    echo "${VERSION}" >"/opt/${APP}_version.txt"
    cp -R "${PREVIOUS_VERSION}/certs" /opt/teddycloud
    cp -R "${PREVIOUS_VERSION}/config" /opt/teddycloud
    cp -R "${PREVIOUS_VERSION}/data" /opt/teddycloud
    msg_ok "Updated ${APP} to v${VERSION}"

    msg_info "Запускаю ${APP}"
    systemctl start teddycloud
    msg_ok "Запустил ${APP}"

    msg_info "Cleaning up"
    rm "teddycloud.amd64.release_v${VERSION}.zip"
    rm -rf "${PREVIOUS_VERSION}"
    msg_ok "Временные файлы установки - удалены!"
  else
    msg_ok "No update required. ${APP} is already at v${VERSION}"
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
