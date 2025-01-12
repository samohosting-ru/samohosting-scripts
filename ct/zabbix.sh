#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://www.zabbix.com/

# App Default Values
APP="Zabbix"
var_tags="monitoring"
var_cpu="2"
var_ram="4096"
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
    if [[ ! -f /etc/zabbix/zabbix_server.conf ]]; then
        msg_error "Отсутствует установленная версия ${APP}"
        exit
    fi
    msg_info "Stopping ${APP} Services"
    systemctl stop zabbix-server zabbix-agent2
    msg_ok "Stopped ${APP} Services"

    msg_info "Обновляю $APP LXC"
    mkdir -p /opt/zabbix-backup/
    cp /etc/zabbix/zabbix_server.conf /opt/zabbix-backup/
    cp /etc/apache2/conf-enabled/zabbix.conf /opt/zabbix-backup/
    cp -R /usr/share/zabbix/ /opt/zabbix-backup/
    #cp -R /usr/share/zabbix-* /opt/zabbix-backup/ Remove temporary
    rm -Rf /etc/apt/sources.list.d/zabbix.list
    cd /tmp
    wget -q https://repo.zabbix.com/zabbix/7.2/release/debian/pool/main/z/zabbix-release/zabbix-release_latest+debian12_all.deb
    dpkg -i zabbix-release_latest+debian12_all.deb &>/dev/null
    apt-get update &>/dev/null
    apt-get install --only-upgrade zabbix-server-pgsql zabbix-frontend-php zabbix-agent2 zabbix-agent2-plugin-* &>/dev/null

    msg_info "Запускаю ${APP} Services"
    systemctl start zabbix-server zabbix-agent2
    systemctl restart apache2
    msg_ok "Запустил ${APP} Services"

    msg_info "Провожу уборку. Удаляю временные файлы установки"
    rm -rf /tmp/zabbix-release_latest+debian12_all.deb
    msg_ok "Временные файлы установки - удалены!"
    msg_ok "Приложение успешно обновлено!"
    exit
}

start
build_container
description

msg_ok "Установка успешно завершена!\n"
echo -e "${CREATING}${GN}${APP} Установка успешно завершена!${CL}"
echo -e "${INFO}${YW} Сервис доступен по ссылке:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}/zabbix${CL}"
