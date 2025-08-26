#!/bin/bash
### Made by VC365 <https://github.com/VC365>

SCRIPT_DIR="$(cd -- "$(dirname "$0")" && pwd)"
theme_dir="/usr/share/grub/themes/adwaita-grub-theme"
none=" \033[0m"
green=" \033[0;32m"
red=" \033[0;31m"
yellow=" \033[0;33m"

grub_mkconfig(){
  update-grub ||
  grub-mkconfig -o /boot/grub/grub.cfg ||
  grub2-mkconfig -o /boot/grub2/grub.cfg ||
  grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg ||
  echo "Error: No grub update command succeeded"
}

install(){
  echo -e "${yellow}installing theme${none}"
  mkdir -p "$theme_dir"
  cp -r "$SCRIPT_DIR/Theme/"* "$theme_dir"
  cp -an /etc/default/grub /etc/default/grub.bak
  sed -i -E "s|^[[:space:]]*GRUB_THEME=.*|GRUB_THEME=\"$theme_dir/theme.txt\"|" /etc/default/grub
  grub_mkconfig
  echo -e "${green}done${none}"
}
uninstall(){
  echo -e "${red}Uninstalling theme${none}"
  rm -rf "$theme_dir"
  cp -an /etc/default/grub /etc/default/grub.bak
  sed -i '/GRUB_THEME=/d' /etc/default/grub
  grub_mkconfig
  echo -e "${green}done${none}"
}
main(){
  if [ "$UID" -eq 0 ]; then
    if [ "$1" == "install" ]; then
        install
    elif [ "$1" == "uninstall" ]; then
        uninstall
    else
        echo -e "${red} Options $0 {install|uninstall}${none}"
        exit 1
    fi
  else
    echo "${red}Please run as root!!${none}"
    exit 1
  fi
}
# LOL
main "$@"
