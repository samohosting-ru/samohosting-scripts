#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: MickLesk (Canbiz)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://wallosapp.com/

# App Default Values
APP="Wallos"
var_tags="finance"
var_cpu="1"
var_ram="1024"
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
  if [[ ! -d /opt/wallos ]]; then
    msg_error "Отсутствует установленная версия ${APP}"
    exit
  fi
  RELEASE=$(curl -s https://api.github.com/repos/ellite/Wallos/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4) }')
  if [[ ! -f /opt/${APP}_version.txt ]] || [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]]; then
    msg_info "Обновляю ${APP} до ${RELEASE}"
    cd /opt
    wget -q "https://github.com/ellite/Wallos/archive/refs/tags/v${RELEASE}.zip"
    mkdir -p /opt/logos
    mv /opt/wallos/db/wallos.db /opt/wallos.db
    mv /opt/wallos/images/uploads/logos /opt/logos/
    unzip -q v${RELEASE}.zip
    rm -rf /opt/wallos
    mv Wallos-${RELEASE} /opt/wallos
    rm -rf /opt/wallos/db/wallos.empty.db
    mv /opt/wallos.db /opt/wallos/db/wallos.db
    mv /opt/logos/* /opt/wallos/images/uploads/logos
    chown -R www-data:www-data /opt/wallos
    chmod -R 755 /opt/wallos
    mkdir -p /var/log/cron
    curl http://localhost/endpoints/db/migrate.php &>/dev/null
    echo "${RELEASE}" >/opt/${APP}_version.txt
    msg_ok "Updated ${APP}"

    msg_info "Reload Apache2"
    systemctl reload apache2
    msg_ok "Apache2 Reloaded"

    msg_info "Провожу уборку. Удаляю временные файлы установки"
    rm -R /opt/v${RELEASE}.zip
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