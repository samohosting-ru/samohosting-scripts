#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://cronicle.net/

# App Default Values
APP="Cronicle"
var_tags="task-scheduler"
var_cpu="1"
var_ram="512"
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
  UPD=$(whiptail --backtitle "Proxmox VE Helper Scripts: Samohosting Edition v0.6.1" --title "ПОДДЕРЖКА" --radiolist --cancel-button Exit-Script "Spacebar = Select" 11 58 2 \
    "1" "Update ${APP}" ON \
    "2" "Install ${APP} Worker" OFF \
    3>&1 1>&2 2>&3)

  if [ "$UPD" == "1" ]; then
    if [[ ! -d /opt/cronicle ]]; then
      msg_error "Отсутствует установленная версия ${APP}"
      exit
    fi
    if [[ "$(node -v | cut -d 'v' -f 2)" == "18."* ]]; then
      if ! command -v npm >/dev/null 2>&1; then
        echo "Installing NPM..."
        apt-get install -y npm >/dev/null 2>&1
        echo "Installed NPM..."
      fi
    fi
    msg_info "Обновляю ${APP}"
    /opt/cronicle/bin/control.sh upgrade &>/dev/null
    msg_ok "Updated ${APP}"
    exit
  fi
  if [ "$UPD" == "2" ]; then
    if [[ "$(node -v | cut -d 'v' -f 2)" == "18."* ]]; then
      if ! command -v npm >/dev/null 2>&1; then
        echo "Installing NPM..."
        apt-get install -y npm >/dev/null 2>&1
        echo "Installed NPM..."
      fi
    fi
    LATEST=$(curl -sL https://api.github.com/repos/jhuckaby/Cronicle/releases/latest | grep '"tag_name":' | cut -d'"' -f4)
    IP=$(hostname -I | awk '{print $1}')
    msg_info "Устанавливаю зависимости(необходимое ПО).."

    apt-get install -y git &>/dev/null
    apt-get install -y make &>/dev/null
    apt-get install -y g++ &>/dev/null
    apt-get install -y gcc &>/dev/null
    apt-get install -y ca-certificates &>/dev/null
    apt-get install -y gnupg &>/dev/null
    msg_ok "Зависимости(необходимое ПО) установлены."

    msg_info "Настраиваю Node.js Репозиторий"
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" >/etc/apt/sources.list.d/nodesource.list
    msg_ok "Репозиторий Node.js настроен"

    msg_info "Устанавливаю Node.js"
    apt-get update &>/dev/null
    apt-get install -y nodejs &>/dev/null
    msg_ok "Node.js установлен"

    msg_info "Устанавливаю Cronicle Worker"
    mkdir -p /opt/cronicle
    cd /opt/cronicle
    tar zxvf <(curl -fsSL https://github.com/jhuckaby/Cronicle/archive/${LATEST}.tar.gz) --strip-components 1 &>/dev/null
    npm install &>/dev/null
    node bin/build.js dist &>/dev/null
    sed -i "s/localhost:3012/${IP}:3012/g" /opt/cronicle/conf/config.json
    /opt/cronicle/bin/control.sh start &>/dev/null
    cp /opt/cronicle/bin/cronicled.init /etc/init.d/cronicled &>/dev/null
    chmod 775 /etc/init.d/cronicled
    update-rc.d cronicled defaults &>/dev/null
    msg_ok "Installed Cronicle Worker"
    echo -e "\n Add Masters secret key to /opt/cronicle/conf/config.json \n"
    exit
  fi
}

start
build_container
description

msg_ok "Установка успешно завершена!\n"
echo -e "${CREATING}${GN}${APP} Установка успешно завершена!${CL}"
echo -e "${INFO}${YW} Сервис доступен по ссылке:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:3012${CL}"