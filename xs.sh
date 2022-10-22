#!/bin/sh

_get_package_manager () {
  package_managers=('xbps-install' 'pacman' 'apt')

  for package_manager in "${package_managers[@]}"; do
    if command -v "$package_manager" 2>/dev/null >&2; then
      echo "$package_manager"
    fi
  done
}

PACKAGE_MANAGER=$(_get_package_manager)

_get_available_packages () {
  case $PACKAGE_MANAGER in
    xbps-install) xpkg -a ;;
    pacman) pacman -Slq ;;
    apt) apt-cache pkgnames --generate ;;
  esac
}

_get_installed_packages () {
  case $PACKAGE_MANAGER in
    xbps-install) xpkg ;;
    pacman) pacman -Qq ;;
    apt) dpkg --get-selections | sed 's:install$::' ;;
  esac
}

_do_installer () {
  package_list="$(_get_available_packages)"

  case $PACKAGE_MANAGER in
    xbps-install) echo "$package_list" | fzf -m --preview-window=right:66%:wrap --preview "xq {1}" | xargs -ro sudo xbps-install ;;
    pacman) echo "$package_list" | fzf -m --preview-window=right:66%:wrap --preview "pacman -Si {1}" | xargs -ro sudo pacman -S ;;
    apt) echo "$package_list" | fzf -m --preview-window=right:66%:wrap --preview "apt-cache show {1}" | xargs -ro sudo apt install ;;
  esac
}

_do_uninstaller () {
  package_list="$(_get_installed_packages)"

  case $PACKAGE_MANAGER in
    xbps-install) echo "$package_list" | fzf -m --preview-window=right:66%:wrap --preview "xq {1}" | xargs -ro sudo xbps-remove ;;
    pacman) echo "$package_list" | fzf -m --preview-window=right:66%:wrap --preview "pacman -Si {1}" | xargs -ro sudo pacman -R ;;
    apt) echo "$package_list" | fzf -m --preview-window=right:66%:wrap --preview "apt-cache show {1}" | xargs -ro sudo apt remove ;;
  esac
}

main () {
  if [ "$1" == "-i" ]; then
    _do_installer

  elif [ "$1" == "-r" ]; then
    _do_uninstaller

  else
    echo "invalid usage"
  fi
}

main $1
