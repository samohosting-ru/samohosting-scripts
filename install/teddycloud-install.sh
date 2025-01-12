#!/usr/bin/env bash

# Copyright (c) 2021-2025 community-scripts ORG
# Author: Dominik Siebel (dsiebel)
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
$STD apt-get install -y \
  curl \
  sudo \
  mc \
  libubsan1 \
  ffmpeg \
  curl \
  ca-certificates
msg_ok "Зависимости(необходимое ПО) установлены."

msg_info "Устанавливаю TeddyCloud"
RELEASE="$(curl -s https://api.github.com/repos/toniebox-reverse-engineering/teddycloud/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')"
VERSION="${RELEASE#tc_v}"
wget -q "https://github.com/toniebox-reverse-engineering/teddycloud/releases/download/${RELEASE}/teddycloud.amd64.release_v${VERSION}.zip"
unzip -q -d "/opt/teddycloud-${VERSION}" "teddycloud.amd64.release_v${VERSION}.zip"
ln -fns "/opt/teddycloud-${VERSION}" /opt/teddycloud
echo "${VERSION}" >"/opt/${APPLICATION}_version.txt"
msg_ok "Installed TeddyCloud"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/teddycloud.service
[Unit]
Description=TeddyCloud Server
After=network.target

[Service]
User=root
Type=simple
ExecStart=/opt/teddycloud/teddycloud
WorkingDirectory=/opt/teddycloud
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now -q teddycloud
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get --yes autoremove
$STD apt-get --yes autoclean
rm -rf "teddycloud.amd64.release_v${VERSION}.zip"
msg_ok "Временные файлы установки - удалены!"
