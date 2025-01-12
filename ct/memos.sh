#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: MickLesk (Canbiz)
# License: MIT | https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
# Source: https://www.usememos.com/

# App Default Values
APP="Memos"
var_tags="notes"
var_cpu="2"
var_ram="2048"
var_disk="7"
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
  if [[ ! -d /opt/memos ]]; then
    msg_error "Отсутствует установленная версия ${APP}"
    exit
  fi
  msg_info "Обновляю $APP (Patience)"
  cd /opt/memos
  git reset --hard HEAD
  output=$(git pull --no-rebase)
  if echo "$output" | grep -q "Already up to date."; then
    msg_ok "$APP is already up to date."
    exit
  fi
  systemctl stop memos
  cd /opt/memos/web
  pnpm i --frozen-lockfile &>/dev/null
  pnpm build &>/dev/null
  cd /opt/memos
  mkdir -p /opt/memos/server/dist
  cp -r web/dist/* /opt/memos/server/dist/
  cp -r web/dist/* /opt/memos/server/router/frontend/dist/
  go build -o /opt/memos/memos -tags=embed bin/memos/main.go &>/dev/null
  systemctl start memos
  msg_ok "Updated $APP"
  exit
}

start
build_container
description

msg_ok "Установка успешно завершена!\n"
echo -e "${CREATING}${GN}${APP} Установка успешно завершена!${CL}"
echo -e "${INFO}${YW} Сервис доступен по ссылке:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:9030${CL}"
