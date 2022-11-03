#!/bin/sh

_get_package_manager () {
  set -- "xbps-install" "pacman" "apt"

  for package_manager in "$@"; do
    if command -v "$package_manager" 2>/dev/null >&2; then
      echo "$package_manager"
    fi
  done
}

PACKAGE_MANAGER="$(_get_package_manager)"

_get_available_packages () {
  case "$PACKAGE_MANAGER" in
    "xbps-install") xpkg -a ;;
    "pacman") pacman -Slq ;;
    "apt") apt-cache pkgnames --generate ;;
  esac
}

_get_installed_packages () {
  case "$PACKAGE_MANAGER" in
    "xbps-install") xpkg ;;
    "pacman") pacman -Qq ;;
    "apt") dpkg --get-selections | sed 's:install$::' ;;
  esac
}

_do_installer () {
  package_list="$(_get_available_packages)"

  case "$PACKAGE_MANAGER" in
    "xbps-install") echo "$package_list" | fzf -m --preview-window="right:66%:wrap" --preview "xq {1}" | xargs -ro sudo xbps-install ;;
    "pacman") echo "$package_list" | fzf -m --preview-window="right:66%:wrap" --preview "pacman -Si {1}" | xargs -ro sudo pacman -S ;;
    "apt") echo "$package_list" | fzf -m --preview-window="right:66%:wrap" --preview "apt-cache show {1}" | xargs -ro sudo apt install ;;
  esac
}

_do_uninstaller () {
  package_list="$(_get_installed_packages)"

  case "$PACKAGE_MANAGER" in
    "xbps-install") echo "$package_list" | fzf -m --preview-window="right:66%:wrap" --preview "xq {1}" | xargs -ro sudo xbps-remove ;;
    "pacman") echo "$package_list" | fzf -m --preview-window="right:66%:wrap" --preview "pacman -Si {1}" | xargs -ro sudo pacman -R ;;
    "apt") echo "$package_list" | fzf -m --preview-window="right:66%:wrap" --preview "apt-cache show {1}" | xargs -ro sudo apt remove ;;
  esac
}

_help() {
  echo "xs.sh - Terminal user interface for package managers, written in POSIX sh"
  echo "Usage: ./xs.sh OPTIONS"
  echo ""
  echo "OPTIONS"
  echo " -i --install    Select packages to install"
  echo " -r --remove     Select packages to uninstall"
  echo " -h --help       Prints this message"
}

main () {
  case "$1" in
    "-i"|"--install") _do_installer ;;
    "-r"|"--remove") _do_uninstaller ;;
    "-h"|"--help") _help ;;
    *) echo "Invalid usage" && _help ;;
  esac
}

main "$1"
