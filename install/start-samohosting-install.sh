#!/usr/bin/env bash

# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# Modified_by: samohosting.ru
# License: MIT
# https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

#set colors
GN=$(echo "\033[1;92m")
BL=$(echo "\033[36m")
BGN=$(echo "\033[4;92m")
CL=$(echo "\033[m")
YW=$(echo "\033[33m")
# Get the current private IP address
IP=$(hostname -I | awk '{print $1}')  # Private IP
# --------------------------------------------------------------------------------------------------------------------
msg_info "Устанавливаю зависимости(необходимое ПО).."
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
msg_ok "Зависимости(необходимое ПО) установлены."
msg_ok "--------------------------------------------------------------------------------------"
msg_ok "${BOLD}${YW}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!ВНИМАНИЕ!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${CL}"
msg_ok "${BOLD}${YW}Начинаю устанавливать набор приложений для домашенго сервера от samohosting.ru${CL}"
msg_ok "${BOLD}${YW}Это может занять какое-то время(не переживайте)${CL}"
msg_ok "${BOLD}${YW}Налейте чашечку чая.. почитайте книгу.. я все сделаю за Вас.. Приятного отдыха..${CL}"
msg_ok "--------------------------------------------------------------------------------------"
# --------------------------------------------------------------------------------------------------------------------
motd_ssh
customize

# --------------------------------------------------------------------------------------------------------------------
msg_info "Устанавливаю приложение Runtipi"
cd /opt
wget -q https://raw.githubusercontent.com/runtipi/runtipi/master/scripts/install.sh
chmod +x install.sh
$STD ./install.sh
chmod 666 /opt/runtipi/state/settings.json
chmod -R 777 /opt/runtipi/
msg_ok "Установлено приложение Runtipi"

# --------------------------------------------------------------------------------------------------------------------
msg_info "Устанавливаю Dashy Dashboard.."
mkdir -p /opt/dashy/user-data/
wget -qO/opt/dashy/user-data/conf.yml https://raw.githubusercontent.com/LiaGen/samohosting/refs/heads/main/files_from_videos/conf.yml
wget -qO/opt/dashy/user-data/conf2.yml https://raw.githubusercontent.com/LiaGen/samohosting/refs/heads/main/files_from_videos/conf2.yml
sed -i -e "s|localhost|$IP|g" /opt/dashy/user-data/conf.yml
sed -i -e "s|localhost|$IP|g" /opt/dashy/user-data/conf2.yml
msg_info "Устанавливаю Dashy Dashboard.."
mkdir -p /opt/dockge/stacks/samohosting-dashboard
cd /opt/dockge/stacks/samohosting-dashboard
cat <<EOF >/opt/dockge/stacks/samohosting-dashboard/compose.yaml
# <== "ЗАПУСТИТЬ"- ДЛЯ ЗАПУСКА <==
# <== "ИЗМЕНИТЬ" - ДЛЯ ИЗМЕНЕНИЯ ВАШИХ ДАННЫХ <==
# <== "ПЕРЕЗАПУСТИТЬ" - ДЛЯ ПРИМЕНЕНИЯ НОВЫХ НАСТРОЕК <==
#
# --------------------Ваши доступы-----------------------
# Адрес Вашего домашнего дашборда - http://$IP:1000
# -------------------------------------------------------
#
# --------------------О ПРИЛОЖЕНИИ-----------------------
# НАЗВАНИЕ: Dashy
# ОПИСАНИЕ: Ваш личный дашборд с удобным управлением мышью, темами и всем что Вам нужно для домашнего уюта
# СТРАНИЦА ПРОЕКТА: https://github.com/Lissy93/dashy
# ВИДЕО\ОБЗОР: https://www.youtube.com/@samohosting
# -------------------------------------------------------
services:
  dashy:
    ports:
      - 1000:8080
    container_name: samohosting-dashboard
    restart: always
    volumes:
      - /opt/dashy/user-data/conf.yml:/app/user-data/conf.yml
      - /opt/dashy/user-data/conf2.yml:/app/user-data/conf2.yml
    image: mirror.gcr.io/lissy93/dashy:latest
EOF
$STD docker compose up -d --quiet-pull
msg_ok "Dashy Dashboard установлен."
msg_info "Настраиваю Ваш линый дашборд by samohosting.ru"
msg_ok "Ваш личный дашборд by SAMOHOSTING.RU настроен"

# --------------------------------------------------------------------------------------------------------------------
msg_info "Устанавливаю Dockge для управления Docker контейнерами и стэками.."
mkdir -p /opt/dockge/stacks
mkdir -p /opt/dockge/data
mkdir -p /opt/dockge/stacks/dockge
cd /opt/dockge/stacks/dockge
cat <<EOF >/opt/dockge/stacks/dockge/compose.yaml
services:
  dockge:
    ports:
      - 5001:5001
    container_name: dockge
    restart: unless-stopped
    environment:
      - PUID=$(id -u)
      - PGID=$(id -g)
      - DOCKGE_STACKS_DIR=/opt/dockge/stacks
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /opt/dockge/data:/app/data
      - /opt/dockge/stacks:/opt/dockge/stacks
    image: mirror.gcr.io/louislam/dockge:latest
EOF
$STD docker compose up -d --quiet-pull
msg_ok "Dockge установлен."

# --------------------------------------------------------------------------------------------------------------------
msg_info "Устанавливаю веб-файл-браузер.."
mkdir -p /opt/dockge/stacks/filebrowser
cd /opt/dockge/stacks/filebrowser
cat <<EOF >/opt/dockge/stacks/filebrowser/compose.yaml
services:
  filebrowser:
    ports:
      - 1001:80
    container_name: filebrowser
    restart: unless-stopped
    environment:
      - PUID=$(id -u)
      - PGID=$(id -g)
    volumes:
      - /:/srv/ALL_FOLDERS_LXC-START-SAMOHOSTING
      - /opt:/srv/APPS_FOLDER
      - /opt/runtipi/logs:/srv/RUNTIPI_LOGS
      - /opt/runtipi/media/downloads:/srv/DOWNLOADS
      - /opt/filebrowser/data/db:/database
    image: mirror.gcr.io/filebrowser/filebrowser:s6
EOF
$STD docker compose up -d --quiet-pull
msg_ok "Веб-файл-браузер установлен."

# --------------------------------------------------------------------------------------------------------------------
msg_info "Устанавливаю Glances.."
mkdir -p /opt/dockge/stacks/glances
cd /opt/dockge/stacks/glances
cat <<EOF >/opt/dockge/stacks/glances/compose.yaml
# <== "ЗАПУСТИТЬ"- ДЛЯ ЗАПУСКА <==
# <== "ИЗМЕНИТЬ" - ДЛЯ ИЗМЕНЕНИЯ ВАШИХ ДАННЫХ <==
# <== "ПЕРЕЗАПУСТИТЬ" - ДЛЯ ПРИМЕНЕНИЯ НОВЫХ НАСТРОЕК <==
#
# --------------------Ваши доступы-----------------------
# Адрес Вашего Glances мониторинга - http://$IP:1002
# -------------------------------------------------------
#
# --------------------О ПРИЛОЖЕНИИ-----------------------
# НАЗВАНИЕ: Glances
# ОПИСАНИЕ: Сервис для мониторинга нагрузки Вашего сервера
# СТРАНИЦА ПРОЕКТА: https://github.com/nicolargo/glances
# ВИДЕО\ОБЗОР: https://www.youtube.com/@samohosting
# -------------------------------------------------------
services:
      glances:
        ports:
            - 1002:61208
        container_name: glance
        restart: unless-stopped
        pid: host
        environment:
            - GLANCES_OPT=-w
        volumes:
            - /var/run/docker.sock:/var/run/docker.sock:ro
        image: mirror.gcr.io/nicolargo/glances:latest-full
EOF
$STD docker compose up -d --quiet-pull
msg_ok "Glances установлен."

# --------------------------------------------------------------------------------------------------------------------
msg_info "Устанавливаю SAMBA(ОТКРЫТИЕ ПАПКИ ВАШЕГО СЕРВЕРА НА ДРУГИХ ПК,ТВ,..).."
mkdir -p /opt/dockge/stacks/samba
cd /opt/dockge/stacks/samba
cat <<EOF >/opt/dockge/stacks/samba/compose.yaml
# <== "ЗАПУСТИТЬ"- ДЛЯ ЗАПУСКА <==
# <== "ИЗМЕНИТЬ" - ДЛЯ ИЗМЕНЕНИЯ ВАШИХ ДАННЫХ <==
# <== "ПЕРЕЗАПУСТИТЬ" - ДЛЯ ПРИМЕНЕНИЯ НОВЫХ НАСТРОЕК <==
#
# --------------------Ваши доступы-----------------------
# Адрес Вашего Samba server - $IP\public
# по умолчанию заданы login:"LOGIN" password:"PASSWORD"
# -------------------------------------------------------
#
# --------------------О ПРИЛОЖЕНИИ-----------------------
# НАЗВАНИЕ: SMB СЕРВЕР
# ОПИСАНИЕ: Сервис для предоставления доступа к Вашим данным по протоколу smb с пк, тв, телефона, ..
# СТРАНИЦА ПРОЕКТА: https://github.com/dperson/samba/tree/master
# ВИДЕО\ОБЗОР: https://www.youtube.com/@samohosting
# -------------------------------------------------------
services:
  samba:
    restart: unless-stopped
    container_name: samba
    ports:
      - 139:139
      - 445:445
    volumes:
      - /opt/runtipi/media/downloads:/share
    image: mirror.gcr.io/dperson/samba
    command: -u "LOGIN;PASSWORD" -s "public;/share;yes;no;yes"
EOF
$STD docker compose up -d --quiet-pull
msg_ok "SAMBA(ОТКРЫТИЕ ПАПКИ ВАШЕГО СЕРВЕРА НА ДРУГИХ ПК,ТВ,..) установлен."


#======================================================================================================================
#===========================установка подгтовленных конфигураций=======================================================
#======================================================================================================================

# --------------------------------------------------------------------------------------------------------------------
msg_info "Добавляю в конфигурацию qbittorrent runtipi - скачивать по умолчанию в /media/downloads"
mkdir -p /opt/runtipi/user-config/qbittorrent
cat <<EOF >/opt/runtipi/user-config/qbittorrent/docker-compose.yml
services:
  qbittorrent:
      volumes:
      - /opt/runtipi/media/torrents:/media/torrents
      - /opt/runtipi/media/downloads:/downloads
EOF
msg_ok "Добавил в конфигурацию qbittorrent runtipi - скачивать по умолчанию в /media/downloads"


# --------------------------------------------------------------------------------------------------------------------
msg_info "Добавляю OpenProject конфигурацию в Dockge"
mkdir -p /opt/dockge/stacks/openproject
cat <<EOF >/opt/dockge/stacks/openproject/compose.yaml
# <== "ЗАПУСТИТЬ"- ДЛЯ ЗАПУСКА <==
# <== "ИЗМЕНИТЬ" - ДЛЯ ИЗМЕНЕНИЯ ВАШИХ ДАННЫХ <==
# <== "ПЕРЕЗАПУСТИТЬ" - ДЛЯ ПРИМЕНЕНИЯ НОВЫХ НАСТРОЕК <==
#
# --------------------Ваши доступы-----------------------
# Адрес Вашего OpenProject - http://$IP:1080
# Логин и Пароль для первого входа admin\admin
# -------------------------------------------------------
#
# --------------------О ПРИЛОЖЕНИИ-----------------------
# НАЗВАНИЕ: OpenProject
# ОПИСАНИЕ: Сервис для ведения проектов. Канбан | Гантт | Задачи | Проекты
# СТРАНИЦА ПРОЕКТА: https://github.com/opf/openproject
# ВИДЕО\ОБЗОР: https://www.youtube.com/watch?v=E9nCQo3TOkw
# -------------------------------------------------------
services:
  openproject:
    image: mirror.gcr.io/openproject/community:13.4
    environment:
      - OPENPROJECT_SECRET_KEY_BASE=secret
      - OPENPROJECT_HOST__NAME=92.168.1.18:1080
      - OPENPROJECT_HTTPS=false
      - OPENPROJECT_MAIN__CONTENT__LANGUAGE=english
    # - EMAIL_DELIVERY_METHOD: smtp
    # - SMTP_ADDRESS: smtp.sendgrid.net
    # - SMTP_PORT: 587
    # - SMTP_DOMAIN: "your.domain.com"
    # - SMTP_AUTHENTICATION: login
    # - SMTP_ENABLE_STARTTLS_AUTO: "true"
    # - SMTP_USER_NAME: "apikey"
    # - SMTP_PASSWORD: "*********"
    volumes:
      - /opt/openproject/Files/AppData/openproject/pgdata:/var/openproject/pgdata
      - /opt/openproject/Files/AppData/openproject/logs:/var/log/supervisor
      - /opt/openproject/Files/AppData/openproject/static:/var/openproject/assets
    ports:
      - 1080:8080
    restart: unless-stopped
networks: {}
EOF
msg_ok "Конфигурация для запуска OpenProject в Dockge добавлена в шаблоны конфигураций"
# --------------------------------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------------------------------
msg_info "Добавляю Dockur-Windows конфигурацию в Dockge"
mkdir -p /opt/dockge/stacks/dockur-windows
cat <<EOF >/opt/dockge/stacks/dockur-windows/compose.yaml
# <== "ЗАПУСТИТЬ"- ДЛЯ ЗАПУСКА <==
# <== "ИЗМЕНИТЬ" - ДЛЯ ИЗМЕНЕНИЯ ВАШИХ ДАННЫХ <==
# <== "ПЕРЕЗАПУСТИТЬ" - ДЛЯ ПРИМЕНЕНИЯ НОВЫХ НАСТРОЕК <==
#
# --------------------Ваши доступы-----------------------
# Адрес Вашего dockur-windows - http://$IP:8106
# По умолчанию создается пользователь:
# USERNAME: "samohosting"
# PASSWORD: "samohosting"
# -------------------------------------------------------
#
# --------------------О ПРИЛОЖЕНИИ-----------------------
# НАЗВАНИЕ: Dockur-Windows
# ОПИСАНИЕ: Запуск виртуальной машины windows в докер контейнере 
# СТРАНИЦА ПРОЕКТА: https://github.com/dockur/windows
# ВИДЕО\ОБЗОР: https://www.youtube.com/watch?v=cSRZRPgwg64
# -------------------------------------------------------
services:
  windowstinycore:
    image: mirror.gcr.io/dockurr/windows
    container_name: windowstinycore
    environment:
      VERSION: core11
      REGION: en-US
      KEYBOARD: en-US
      DISK_SIZE: 10G
      RAM_SIZE: 4G
      CPU_CORES: "4"
      USERNAME: samohosting
      PASSWORD: samohosting
#      devices:
#        - /dev/kvm
#        - /dev/net/tun
      KVM: "N"
    cap_add:
      - NET_ADMIN
    ports:
      - 8106:8006
      - 3319:3389/tcp
      - 3319:3389/udp
    stop_grace_period: 2m
networks: {}
EOF
msg_ok "Конфигурация для запуска Dockur-Windows в Dockge добавлена в шаблоны конфигураций"
# --------------------------------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------------------------------
msg_info "Добавляю Dockur-MacOS конфигурацию в Dockge"
mkdir -p /opt/dockge/stacks/dockur-macos
cat <<EOF >/opt/dockge/stacks/dockur-macos/compose.yaml
# <== "ЗАПУСТИТЬ"- ДЛЯ ЗАПУСКА <==
# <== "ИЗМЕНИТЬ" - ДЛЯ ИЗМЕНЕНИЯ ВАШИХ ДАННЫХ <==
# <== "ПЕРЕЗАПУСТИТЬ" - ДЛЯ ПРИМЕНЕНИЯ НОВЫХ НАСТРОЕК <==
#
# --------------------Ваши доступы-----------------------
# Адрес Вашего dockur-macos - http://$IP:8107
# -------------------------------------------------------
#
# --------------------О ПРИЛОЖЕНИИ-----------------------
# НАЗВАНИЕ: Dockur-MacOS
# ОПИСАНИЕ: Запуск виртуальной машины windows в докер контейнере 
# СТРАНИЦА ПРОЕКТА: https://github.com/dockur/macos
# ВИДЕО\ОБЗОР: https://www.youtube.com/watch?v=cSRZRPgwg64
# -------------------------------------------------------
services:
  macos:
    image: mirror.gcr.io/dockurr/macos
    container_name: macos
    environment:
      VERSION: "13"
    # devices:
    #   - /dev/kvm
    #   - /dev/net/tun
    KVM: "N"  
    cap_add:
      - NET_ADMIN
    ports:
      - 8107:8006
      - 5900:5900/tcp
      - 5900:5900/udp
    stop_grace_period: 2m
networks: {}
EOF
msg_ok "Конфигурация для запуска Dockur-MacOS в Dockge добавлена в шаблоны конфигураций"
# --------------------------------------------------------------------------------------------------------------------


# --------------------------------------------------------------------------------------------------------------------
msg_info "Добавляю Webtop-linux-in-docker конфигурацию в Dockge"
mkdir -p /opt/dockge/stacks/webtop
cat <<EOF >/opt/dockge/stacks/webtop/compose.yaml
# <== "ЗАПУСТИТЬ"- ДЛЯ ЗАПУСКА <==
# <== "ИЗМЕНИТЬ" - ДЛЯ ИЗМЕНЕНИЯ ВАШИХ ДАННЫХ <==
# <== "ПЕРЕЗАПУСТИТЬ" - ДЛЯ ПРИМЕНЕНИЯ НОВЫХ НАСТРОЕК <==
#
# --------------------Ваши доступы-----------------------
# Адрес Вашего OpenProject - http://$IP:3000
# -------------------------------------------------------
#
# --------------------О ПРИЛОЖЕНИИ-----------------------
# НАЗВАНИЕ: Webtop - linux in docker
# ОПИСАНИЕ: Запуск виртуальной машины windows в докер контейнере 
# СТРАНИЦА ПРОЕКТА: https://github.com/linuxserver/docker-webtop
# ВИДЕО\ОБЗОР: https://www.youtube.com/watch?v=cSRZRPgwg64
# -------------------------------------------------------
services:
  webtop:
    image: lscr.io/linuxserver/webtop:latest
    container_name: webtop
    security_opt:
      - seccomp:unconfined #optional
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      # - SUBFOLDER=/ #optional
      - TITLE=SAMOHOSTING #optional
    volumes:
      - /path/to/data:/config
      - /var/run/docker.sock:/var/run/docker.sock #optional
    ports:
      - 3000:3000
      - 3001:3001
    # devices:
    #   - /dev/dri:/dev/dri #optional
    shm_size: "1gb" #optional
    restart: unless-stopped
networks: {}
EOF
msg_ok "Конфигурация для запуска Webtop-linux-in-docker в Dockge добавлена в шаблоны конфигураций"
# --------------------------------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------------------------------
msg_info "Добавляю Firefox3 конфигурацию в Dockge"
mkdir -p /opt/dockge/stacks/firefox3
cat <<EOF >/opt/dockge/stacks/firefox3/compose.yaml
services:
  firefox:
    image: lscr.io/linuxserver/firefox:latest
    container_name: firefox3
    security_opt:
      - seccomp:unconfined #optional
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - FIREFOX_CLI=https://www.samohosting.ru/ #optional
    volumes:
      - /opt/firefox3/data/config:/config
    ports:
      - 3003:3000
      # - 3001:3001
    shm_size: 1gb
    restart: unless-stopped
EOF
msg_ok "Конфигурация для запуска Firefox3 в Dockge добавлена в шаблоны конфигураций"
# --------------------------------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------------------------------
msg_info "Добавляю Firefox4 конфигурацию в Dockge"
mkdir -p /opt/dockge/stacks/firefox4
cat <<EOF >/opt/dockge/stacks/firefox4/compose.yaml
#  <== ДЛЯ ЗАПУСКА СЕРВИСА ЖМИ КНОПКУ ЗАПУСТИТЬ <==
#  <== ДЛЯ ОТКРЫТИЯ ЖМИ КНОПКУ С НОМЕРОМ ПОРТА ПРИЛОЖЕНИЯ <==

#  НАЗВАНИЕ: Веб-браузер в докере!
#  Описание: Если Вам нужен изолированный бразуер, живущий в докере, это - ОНО  
#  Страница проекта: https://docs.linuxserver.io/images/docker-firefox/
#  Видео\обзор: https://www.youtube.com/@samohosting
#----------------------------------------------------------------------

services:
  firefox:
    image: lscr.io/linuxserver/firefox:latest
    container_name: firefox4
    security_opt:
      - seccomp:unconfined #optional
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - FIREFOX_CLI=https://www.samohosting.ru/ #optional
    volumes:
      - /opt/firefox4/data/config:/config
    ports:
      - 3004:3000
      # - 3001:3001
    shm_size: 1gb
    restart: unless-stopped
EOF
msg_ok "Конфигурация для запуска Firefox4 в Dockge добавлена в шаблоны конфигураций"
# --------------------------------------------------------------------------------------------------------------------

msg_info "Провожу уборку. Нет, не генеральную.."
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Временные файлы установки - удалены!"
msg_ok "--------------------------------------------------------------------------------------"
msg_ok "Ваш новенький домашний сервер собран и установлен!"

# echo -e "     ${YW}Важная информация:${CL}"
# echo -e "     ${YW}Пожалуйста начните с создания аккаунта Portianer. На его регистрацию у Вас 5 минут после установки.${CL}"
# echo -e "     ${YW}Если Вы не успеете - потребуется перезагрузка Docker\LXC контейнера для регистрации в сервисе.${CL}"
# echo -e "     ${YW}Для регистрации перейдите по ссылке ${CL} ==>> ${BGN}https://${IP}:9443${CL}"
echo -e "     ${BOLD}${BL}Начните изучать Ваш домашний сервер by samohosting.ru${CL} ==>> ${BGN}http://${IP}:1000${CL} Удачного самохостинга!"
echo -e "${TAB}${HOSTNAME}${BL} Начните изучать Ваш домашний сервер by samohosting.ru${CL} ==>> ${BGN}http://${IP}:1000${CL} Удачного самохостинга!" >> /etc/motd

