#!/usr/bin/env bash

# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# Co-Author: MickLesk
# License: MIT
# https://raw.githubusercontent.com/samohosting-ru/samohosting-scripts/ru_dev/LICENSE

# This sets verbose mode if the global variable is set to "yes"
# if [ "$VERBOSE" == "yes" ]; then set -x; fi

# This function sets color variables for formatting output in the terminal
# Colors
YW=$(echo "\033[33m")
YWB=$(echo "\033[93m")
BL=$(echo "\033[36m")
RD=$(echo "\033[01;31m")
GN=$(echo "\033[1;92m")

# Formatting
CL=$(echo "\033[m")
UL=$(echo "\033[4m")
BOLD=$(echo "\033[1m")
BFR="\\r\\033[K"
HOLD=" "
TAB="  "

# Icons
CM="${TAB}✔️${TAB}${CL}"
CROSS="${TAB}✖️${TAB}${CL}"
INFO="${TAB}💡${TAB}${CL}"

# This sets error handling options and defines the error_handler function to handle errors
set -Eeuo pipefail
trap 'error_handler $LINENO "$BASH_COMMAND"' ERR

# This function handles errors
function error_handler() {
  if [ -n "$SPINNER_PID" ] && ps -p $SPINNER_PID > /dev/null; then kill $SPINNER_PID > /dev/null; fi
  printf "\e[?25h"
  local exit_code="$?"
  local line_number="$1"
  local command="$2"
  local error_message="${RD}[ERROR]${CL} in line ${RD}$line_number${CL}: exit code ${RD}$exit_code${CL}: while executing command ${YW}$command${CL}"
  echo -e "\n$error_message\n"
}

# This function displays a spinner.
function spinner() {
  local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local spin_i=0
  local interval=0.1
  printf "\e[?25l"

  local color="${YWB}"

  while true; do
    printf "\r ${color}%s${CL}" "${frames[spin_i]}"
    spin_i=$(( (spin_i + 1) % ${#frames[@]} ))
    sleep "$interval"
  done
}

# This function displays an informational message with a yellow color.
function msg_info() {
  local msg="$1"
  echo -ne "${TAB}${YW}${HOLD}${msg}${HOLD}"
  spinner &
  SPINNER_PID=$!
}

# This function displays a success message with a green color.
function msg_ok() {
  if [ -n "$SPINNER_PID" ] && ps -p $SPINNER_PID > /dev/null; then kill $SPINNER_PID > /dev/null; fi
  printf "\e[?25h"
  local msg="$1"
  echo -e "${BFR}${CM}${GN}${msg}${CL}"
}

# This function displays a error message with a red color.
function msg_error() {
  if [ -n "$SPINNER_PID" ] && ps -p $SPINNER_PID > /dev/null; then kill $SPINNER_PID > /dev/null; fi
  printf "\e[?25h"
  local msg="$1"
  echo -e "${BFR}${CROSS}${RD}${msg}${CL}"
}

# This checks for the presence of valid Container Storage and Template Storage locations
msg_info "Проверяю Хранилище"
VALIDCT=$(pvesm status -content rootdir | awk 'NR>1')
if [ -z "$VALIDCT" ]; then
  msg_error "Не удалось определить корректное расположение хранилища для контейнера"
  exit 1
fi
VALIDTMP=$(pvesm status -content vztmpl | awk 'NR>1')
if [ -z "$VALIDTMP" ]; then
  msg_error "Не удалось определить корректное расположение хранилища для шаблона"
  exit 1
fi

# This function is used to select the storage class and determine the corresponding storage content type and label.
function select_storage() {
  local CLASS=$1
  local CONTENT
  local CONTENT_LABEL
  case $CLASS in
  container)
    CONTENT='rootdir'
    CONTENT_LABEL='Container'
    ;;
  template)
    CONTENT='vztmpl'
    CONTENT_LABEL='Container template'
    ;;
  *) false || { msg_error "Invalid storage class."; exit 1; } ;;
  esac

  # This Queries all storage locations
  local -a MENU
  while read -r line; do
    local TAG=$(echo $line | awk '{print $1}')
    local TYPE=$(echo $line | awk '{printf "%-10s", $2}')
    local FREE=$(echo $line | numfmt --field 4-6 --from-unit=K --to=iec --format %.2f | awk '{printf( "%9sB", $6)}')
    local ITEM="Type: $TYPE Free: $FREE "
    local OFFSET=2
    if [[ $((${#ITEM} + $OFFSET)) -gt ${MSG_MAX_LENGTH:-} ]]; then
      local MSG_MAX_LENGTH=$((${#ITEM} + $OFFSET))
    fi
    MENU+=("$TAG" "$ITEM" "OFF")
  done < <(pvesm status -content $CONTENT | awk 'NR>1')

  # Select storage location
  if [ $((${#MENU[@]}/3)) -eq 1 ]; then
    printf ${MENU[0]}
  else
    local STORAGE
    while [ -z "${STORAGE:+x}" ]; do
      STORAGE=$(whiptail --backtitle "Proxmox VE Helper Scripts: Samohosting Edition v0.6.1" --title "ХРАНИЛИЩЕ ДЛЯ ДАННЫХ" --radiolist \
      "Which storage pool you would like to use for the ${CONTENT_LABEL,,}?\nTo make a selection, use the ПРОБЕЛ.\n" \
      16 $(($MSG_MAX_LENGTH + 23)) 6 \
      "${MENU[@]}" 3>&1 1>&2 2>&3) || { msg_error "Menu aborted."; exit 1; }
      if [ $? -ne 0 ]; then
        echo -e "${CROSS}${RD} Меню отменено пользователем.${CL}"
        exit 0
      fi
    done
    printf "%s" "$STORAGE"
  fi
}
# Test if required variables are set
[[ "${CTID:-}" ]] || { msg_error "You need to set 'CTID' variable."; exit 1; }
[[ "${PCT_OSTYPE:-}" ]] || { msg_error "You need to set 'PCT_OSTYPE' variable."; exit 1; }

# Test if ID is valid
[ "$CTID" -ge "100" ] || { msg_error "ID cannot be less than 100."; exit 1; }

# Test if ID is in use
if pct status $CTID &>/dev/null; then
  echo -e "ID '$CTID' is already in use."
  unset CTID
  msg_error "Не могу использовать ID который уже занят другим контейнером."
  exit 1
fi

# Get template storage
TEMPLATE_STORAGE=$(select_storage template) || exit
msg_ok "Использую ${BL}$TEMPLATE_STORAGE${CL} ${GN} для хранилища шаблона."

# Get container storage
CONTAINER_STORAGE=$(select_storage container) || exit
msg_ok "Использую ${BL}$CONTAINER_STORAGE${CL} ${GN} для хранилища контейнера."

# Update LXC template list
msg_info "Обновляю LXC Template List"
pveam update >/dev/null
msg_ok "Обновлен список LXC шаблонов."

# Get LXC template string
# PVE 9.x prints "section  template  arch" (older PVE printed "template<TAB>size"),
# so pick the field that is an actual template filename instead of matching to end of line.
TEMPLATE_SEARCH=${PCT_OSTYPE}-${PCT_OSVERSION:-}
mapfile -t TEMPLATES < <(pveam available -section system | awk -v s="$TEMPLATE_SEARCH" '{for(i=1;i<=NF;i++) if ($i ~ /\.tar\.(gz|zst)$/ && index($i,s)==1) {print $i; break}}' | sort -t - -k 2 -V)
[ ${#TEMPLATES[@]} -gt 0 ] || { msg_error "Unable to find a template when searching for '$TEMPLATE_SEARCH'."; exit 1; }
TEMPLATE="${TEMPLATES[-1]}"

# Download LXC template if needed
# pveam list prints a full volid in column 1 ("local:vztmpl/<file>"), so compare the basename.
if ! pveam list "$TEMPLATE_STORAGE" | awk -v t="$TEMPLATE" '{n=$1; sub(/^.*\//,"",n); if (n==t) f=1} END {exit !f}'; then
  msg_info "Скачиваю LXC шаблон"
  pveam download "$TEMPLATE_STORAGE" "$TEMPLATE" >/dev/null ||
    { msg_error "A problem occured while downloading the LXC template."; exit 1; }
  msg_ok "Скачиваю LXC шаблон"
fi

# Combine all options
DEFAULT_PCT_OPTIONS=(
  -arch $(dpkg --print-architecture))

PCT_OPTIONS=(${PCT_OPTIONS[@]:-${DEFAULT_PCT_OPTIONS[@]}})
[[ " ${PCT_OPTIONS[@]} " =~ " -rootfs " ]] || PCT_OPTIONS+=(-rootfs $CONTAINER_STORAGE:${PCT_DISK_SIZE:-8})

# Create container
msg_info "Создаю LXC контейнер"
pct create $CTID ${TEMPLATE_STORAGE}:vztmpl/${TEMPLATE} ${PCT_OPTIONS[@]} >/dev/null ||
  msg_error "Возникла проблема при попытке создать контейнер!"
  exit 1
msg_ok "LXC контейнер ${BL}$CTID${CL} ${GN}был успешно создан."
