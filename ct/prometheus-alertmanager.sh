#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: Andy Grunwald (andygrunwald)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://prometheus.io/

# App Default Values
APP="Prometheus-Alertmanager"
var_tags="monitoring;alerting"
var_cpu="1"
var_ram="1024"
var_disk="2"
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
  if [[ ! -f /etc/systemd/system/prometheus-alertmanager.service ]]; then
    msg_error "Отсутствует установленная версия ${APP}"
    exit
  fi
  RELEASE=$(curl -s https://api.github.com/repos/prometheus/alertmanager/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4) }')
  if [[ ! -f /opt/${APP}_version.txt ]] || [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]]; then
    msg_info "Останавливаю работу приложения ${APP}"
    systemctl stop prometheus-alertmanager
    msg_ok "Приложение ${APP} остановлено"

    msg_info "Обновляю ${APP} to v${RELEASE}"
    cd /opt
    wget -q https://github.com/prometheus/alertmanager/releases/download/v${RELEASE}/alertmanager-${RELEASE}.linux-amd64.tar.gz
    tar -xf alertmanager-${RELEASE}.linux-amd64.tar.gz
    cp -rf alertmanager-${RELEASE}.linux-amd64/alertmanager alertmanager-${RELEASE}.linux-amd64/amtool /usr/local/bin/
    rm -rf alertmanager-${RELEASE}.linux-amd64 alertmanager-${RELEASE}.linux-amd64.tar.gz
    echo "${RELEASE}" >/opt/${APP}_version.txt
    msg_ok "Updated ${APP} to v${RELEASE}"

    msg_info "Запускаю ${APP}"
    systemctl start prometheus-alertmanager
    msg_ok "Запустил ${APP}"
    msg_ok "Приложение успешно обновлено!"
  else
    msg_ok "No update required. ${APP} is already at v${RELEASE}"
  fi
  exit
}

start
build_container
description

msg_ok "Установка успешно завершена!\n"
echo -e "${CREATING}${GN}${APP} Установка успешно завершена!${CL}"
echo -e "${INFO}${YW} Сервис доступен по ссылке:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:9093${CL}"