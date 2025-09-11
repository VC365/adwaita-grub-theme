#!/bin/bash
### Made by VC365 <https://github.com/VC365>

script="$(cd -- "$(dirname "$0")" && pwd)"
none="\033[0m"
green="\033[0;32m"
red="\033[0;31m"
yellow="\033[0;33m"

## Folders
F_assets="$script/source/assets"
F_config="$script/source/tconfigs"
F_icons="$script/source/icons"
F_fonts="$script/source/fonts"
F_bg="$script/source/backgrounds"
F_box="$F_assets/_BOX_"
F_boxN="$F_assets/_BOX_N_"
F_menu="$F_assets/_MENU_"
F_select="$F_assets/_SELECT_"

theme_root(){
  tempX=$(mktemp -d -t theme-XXXXXX)
  trap 'rm -rf "$tempX"' EXIT
  theme="$tempX/$1"
  mkdir "$theme" &&
  cp "$F_box/$1/"* "$theme/" &> /dev/null
  cp "$F_boxN/$1.png" "$theme/boxN_c.png" &> /dev/null
  cp "$F_menu/$1.png" "$theme/menu.png" &> /dev/null
  cp "$F_select/$1/"* "$theme/" &> /dev/null
  cp "$F_fonts/"* "$theme/" &> /dev/null
  cp "$F_bg/$1.jpeg" "$theme/dood.jpeg" &> /dev/null
  cp -r "$F_icons/$1" "$theme/icons" &> /dev/null
  cp "$F_config/$1" "$theme/theme.txt" &> /dev/null
}

grub_mkconfig(){
  echo -e "\n${green}Generating grub config ...${none}"
  update-grub 2> /dev/null ||
  grub-mkconfig -o /boot/grub/grub.cfg 2> /dev/null ||
  grub2-mkconfig -o /boot/grub2/grub.cfg 2> /dev/null ||
  grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg 2> /dev/null ||
  echo -e "\n ${red}Error:${none} No grub update command succeeded"
}

grub_default(){
    cp -an /etc/default/grub /etc/default/grub.bak

    # Replace & Append GRUB_GFXMODE
    grep -q "GRUB_GFXMODE=" /etc/default/grub &&
      (sed -i "s|.*GRUB_GFXMODE=.*|GRUB_GFXMODE=auto|" /etc/default/grub || true) ||
        echo "GRUB_GFXMODE=auto" >> /etc/default/grub

    # remove GRUB_BACKGROUND
    grep -q "GRUB_BACKGROUND=" /etc/default/grub &&
      sed -i '/GRUB_BACKGROUND=/d' /etc/default/grub

    grep -q '^GRUB_THEME=' /etc/default/grub &&
      (sed -i -E "s|^[[:space:]]*GRUB_THEME=.*|GRUB_THEME=\"${theme_dir}/theme.txt\"|" /etc/default/grub || true) ||
        echo "GRUB_THEME=\"${theme_dir}/theme.txt\"" >> /etc/default/grub
}

install(){
  echo -e "${green}Installing $2 ...${none}"
  theme_root "$1"
  theme_dir="/usr/share/grub/themes/$2"
  echo -e "${yellow}installing theme${none}"
  mkdir -p "$theme_dir"
  cp -r "$theme/"* "$theme_dir"
  grub_default
  grub_mkconfig
  echo -e "${green}Done!${none}"
}

uninstall(){
  [ "$1" == "adw" ] || [ "$1" == "adw-dim" ] ||
    echo -e "${red}Error${none}:The theme entered is wrong." && exit 1

  echo -e "${red}Uninstalling $1${none}"
  theme_dir="/usr/share/grub/themes/$1"
  [ -d "$theme_dir" ] && rm -rf "$theme_dir"
  [ -f /etc/default/grub.bak ] || cp -an /etc/default/grub /etc/default/grub.bak
  sed -i '/GRUB_THEME=/d' /etc/default/grub
  grub_mkconfig
  echo -e "${green}Done!${none}"
}

main(){
  if [ "$UID" -eq 0 ] && [ -d "$script/source" ]; then
    if [ "$1" == "install" ]; then
      if [ "$2" == "adw" ] || [ "$2" == "adw-dim" ]; then
        install "$2" "$([ "$2" == "adw" ] && echo 'adwaita-theme' || echo 'adwaita-dim-theme')"
      else
        echo -e "${red}Error${none}:The theme entered is wrong." && exit 1
      fi
    elif [ "$1" == "uninstall" ]; then
        uninstall "$2"
    else
        echo -e "${red} Options $0 {install 'adw' & 'adw-dim' | uninstall 'adw' & 'adw-dim'}${none}"
        exit 1
    fi
  else
    echo -e "${red}Please run as root!!${none}"
    exit 1
  fi
}

# LOL
main "$@"
