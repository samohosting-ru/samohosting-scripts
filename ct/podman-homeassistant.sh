#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE

# App Default Values
APP="Podman-Home Assistant"
var_tags="podman;smarthome"
var_cpu="2"
var_ram="2048"
var_disk="16"
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
  if [[ ! -f /etc/systemd/system/homeassistant.service ]]; then msg_error "Отсутствует установленная версия ${APP}"; exit; fi
  UPD=$(whiptail --backtitle "Proxmox VE Helper Scripts: Samohosting Edition v0.6.1" --title "UPDATE" --radiolist --cancel-button Exit-Script "Spacebar = Select" 11 58 4 \
  "1" "Update system and containers" ON \
  "2" "Install HACS" OFF \
  "3" "Install FileBrowser" OFF \
  "4" "Remove ALL Unused Images" OFF \
  3>&1 1>&2 2>&3)

if [ "$UPD" == "1" ]; then
  msg_info "Обновляю ${APP} LXC"
  apt-get update &>/dev/null
  apt-get -y upgrade &>/dev/null
  msg_ok "Приложение успешно обновлено!"

  msg_info "Обновляю All Containers\n"
  CONTAINER_LIST="${1:-$(podman ps -q)}"
  for container in ${CONTAINER_LIST}; do
    CONTAINER_IMAGE="$(podman inspect --format "{{.Config.Image}}" --type container ${container})"
    RUNNING_IMAGE="$(podman inspect --format "{{.Image}}" --type container "${container}")"
    podman pull "${CONTAINER_IMAGE}"
    LATEST_IMAGE="$(podman inspect --format "{{.Id}}" --type image "${CONTAINER_IMAGE}")"
    if [[ "${RUNNING_IMAGE}" != "${LATEST_IMAGE}" ]]; then
      echo "Updating ${container} image ${CONTAINER_IMAGE}"
      systemctl restart homeassistant
    fi
  done
  msg_ok "All containers updated."
  exit
fi
if [ "$UPD" == "2" ]; then
  msg_info "Устанавливаю Home Assistant Community Store (HACS)"
  apt update &>/dev/null
  apt install unzip &>/dev/null
  cd /var/lib/containers/storage/volumes/hass_config/_data
  bash <(curl -fsSL https://get.hacs.xyz) &>/dev/null
  msg_ok "Installed Home Assistant Community Store (HACS)"
  echo -e "\n Reboot Home Assistant and clear browser cache then Add HACS integration.\n"
  exit
fi
if [ "$UPD" == "3" ]; then
  IP=$(hostname -I | awk '{print $1}') 
  msg_info "Устанавливаю FileBrowser"
  curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash &>/dev/null
  filebrowser config init -a '0.0.0.0' &>/dev/null
  filebrowser config set -a '0.0.0.0' &>/dev/null
  filebrowser users add admin helper-scripts.com --perm.admin &>/dev/null
  msg_ok "Installed FileBrowser"

  msg_info "Creating Service"
  service_path="/etc/systemd/system/filebrowser.service"
  echo "[Unit]
  Description=Filebrowser
  After=network-online.target
  [Service]
    User=root
    WorkingDirectory=/root/
    ExecStart=/usr/local/bin/filebrowser -r /
  [Install]
    WantedBy=default.target" >$service_path

    systemctl enable --now filebrowser.service &>/dev/null
    msg_ok "Created Service"

    msg_ok "Установка успешно завершена!\n"
    echo -e "FileBrowser should be reachable by going to the following URL.
         ${BL}http://$IP:8080${CL}   admin|helper-scripts.com\n"
  exit
fi
if [ "$UPD" == "4" ]; then
  msg_info "Removing ALL Unused Images"
  podman image prune -a -f
  msg_ok "Removed ALL Unused Images"
  exit
fi

}

start
build_container
description

msg_ok "Установка успешно завершена!\n"
echo -e "${CREATING}${GN}${APP} Установка успешно завершена!${CL}"
echo -e "${INFO}${YW} Сервис доступен по ссылке:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8123${CL}"