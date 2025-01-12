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
$STD apt-get install -y sudo
$STD apt-get install -y mc
$STD apt-get install -y curl
$STD apt-get install -y ffmpeg
$STD apt-get install -y vlc
msg_ok "Зависимости(необходимое ПО) установлены."

msg_info "Устанавливаю Threadfin"
mkdir -p /opt/threadfin
wget -q -O /opt/threadfin/threadfin 'https://github.com/Threadfin/Threadfin/releases/latest/download/Threadfin_linux_amd64'
chmod +x /opt/threadfin/threadfin

msg_ok "Installed Threadfin"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/threadfin.service
[Unit]
Description=Threadfin: M3U Proxy for Plex DVR and Emby/Jellyfin Live TV
After=syslog.target network.target
[Service]
Type=simple
WorkingDirectory=/opt/threadfin
ExecStart=/opt/threadfin/threadfin
TimeoutStopSec=20
KillMode=process
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now threadfin.service
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Временные файлы установки - удалены!"
