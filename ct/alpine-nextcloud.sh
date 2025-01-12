#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE

# App Default Values
APP="Alpine-Nextcloud"
var_tags="alpine;cloud"
var_cpu="2"
var_ram="1024"
var_disk="2"
var_os="alpine"
var_version="3.20"
var_unprivileged="1"

# App Output & Base Settings
header_info "$APP"
base_settings

# Core 
variables
color
catch_errors

function update_script() {
  if [[ ! -d /usr/share/webapps/nextcloud ]]; then
    msg_error "Отсутствует установленная версия ${APP}"
    exit
  fi
  if ! apk -e info newt >/dev/null 2>&1; then
    apk add -q newt
  fi
  while true; do
    CHOICE=$(whiptail --backtitle "Proxmox VE Helper Scripts: Samohosting Edition v0.6.1" --title "ПОДДЕРЖКА" --radiolist --cancel-button Exit-Script "Spacebar = Select"  11 58 3 \
      "1" "Nextcloud Login Credentials" ON \
      "2" "Renew Self-signed Certificate" OFF \
      3>&1 1>&2 2>&3)      
    exit_status=$?
    if [ $exit_status == 1 ]; then
      clear
      exit-script
    fi
    header_info
    case $CHOICE in
    1)
      cat nextcloud.creds
      exit
      ;;
    2)
      openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout /etc/ssl/private/nextcloud-selfsigned.key -out /etc/ssl/certs/nextcloud-selfsigned.crt -subj "/C=US/O=Nextcloud/OU=Domain Control Validated/CN=nextcloud.local" > /dev/null 2>&1
      rc-service nginx restart
      exit
      ;;
    esac
  done
}

start
build_container
description

msg_ok "Установка успешно завершена!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}https://${IP}${CL} \n"
