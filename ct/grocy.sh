#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://grocy.info/

# App Default Values
APP="grocy"
var_tags="grocery;household"
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
  if [[ ! -f /etc/apache2/sites-available/grocy.conf ]]; then
    msg_error "Отсутствует установленная версия ${APP}"
    exit
  fi
  php_version=$(php -v | head -n 1 | awk '{print $2}')
  if [[ ! $php_version == "8.3"* ]]; then
    msg_info "Обновляю PHP"
    curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg
    echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ bookworm main" >/etc/apt/sources.list.d/php.list
    apt-get update
    apt-get install -y php8.3 php8.3-cli php8.3-{bz2,curl,mbstring,intl,sqlite3,fpm,gd,zip,xml}
    systemctl reload apache2
    apt autoremove
    msg_ok "Обновлен PHP"
  fi
  msg_info "Обновляю ${APP}"
  bash /var/www/html/update.sh
  msg_ok "Приложение успешно обновлено!"
  exit
}

start
build_container
description

msg_ok "Установка успешно завершена!\n"
echo -e "${CREATING}${GN}${APP} Установка успешно завершена!${CL}"
echo -e "${INFO}${YW} Сервис доступен по ссылке:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}${CL}"