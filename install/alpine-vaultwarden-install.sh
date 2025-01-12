#!/usr/bin/env bash

# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT
# https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE
source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"

color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Устанавливаю зависимости(необходимое ПО).."
$STD apk add newt
$STD apk add curl
$STD apk add openssl
$STD apk add openssh
$STD apk add nano
$STD apk add mc
$STD apk add argon2
msg_ok "Зависимости(необходимое ПО) установлены."

msg_info "Устанавливаю Alpine-Vaultwarden"
$STD apk add vaultwarden
sed -i -e 's|export WEB_VAULT_ENABLED=.*|export WEB_VAULT_ENABLED=true|' /etc/conf.d/vaultwarden
echo -e "export ADMIN_TOKEN=''" >>/etc/conf.d/vaultwarden
echo -e "export ROCKET_ADDRESS=0.0.0.0" >>/etc/conf.d/vaultwarden
msg_ok "Installed Alpine-Vaultwarden"

msg_info "Устанавливаю Web-Vault"
$STD apk add vaultwarden-web-vault
msg_ok "Installed Web-Vault" 

msg_info "Запускаю Alpine-Vaultwarden"
$STD rc-service vaultwarden start
$STD rc-update add vaultwarden default
msg_ok "Запустил Alpine-Vaultwarden"

motd_ssh
customize
