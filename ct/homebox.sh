#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck | Co-Author: MickLesk (Canbiz)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://homebox.software/en/

# App Default Values
APP="HomeBox"
var_tags="inventory;household"
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
  if [[ ! -f /opt/homebox ]]; then
    msg_error "Отсутствует установленная версия ${APP}"
    exit
  fi
  RELEASE=$(curl -s https://api.github.com/repos/sysadminsmedia/homebox/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
  if [[ ! -f /opt/${APP}_version.txt ]] || [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]]; then
    msg_info "Останавливаю работу приложения ${APP}"
    systemctl stop homebox
    msg_ok "${APP} Stopped"

    msg_info "Обновляю ${APP} до ${RELEASE}"
    cd /opt
    rm -rf homebox_bak
    rm -rf /tmp/homebox.tar.gz
    mv homebox homebox_bak
    wget -qO /tmp/homebox.tar.gz https://github.com/sysadminsmedia/homebox/releases/download/${RELEASE}/homebox_Linux_x86_64.tar.gz
    tar -xzf /tmp/homebox.tar.gz -C /opt
    chmod +x /opt/homebox
    echo "${RELEASE}" >/opt/${APP}_version.txt
    msg_ok "Updated Homebox"

    msg_info "Запускаю ${APP}"
    systemctl start homebox
    msg_ok "Запустил ${APP}"

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
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:7745${CL}"