#!/bin/sh

# this is really dirty, i have no clue how to fix it
_sanitize_zypper_packages () {
  DIRTY_PACKAGE_TABLE=$(echo "$1" | tail -n +6)
  DIRTY_PACKAGE_LIST=$(echo "$DIRTY_PACKAGE_TABLE" | cut -d '|' -f -2)
  PACKAGE_LIST=''

  for pkg in "$DIRTY_PACKAGE_LIST"; do
    PACKAGE_NAME=$(echo "$pkg" | sed "s:|::g; s: ::g; s:i+::g")
    PACKAGE_LIST="${PACKAGE_LIST}${PACKAGE_NAME}"
  done

  echo "$PACKAGE_LIST"
}

_get_package_manager () {
  set -- "xbps-install" "pacman" "apt" "zypper"

  for package_manager in "$@"; do
    if command -v "$package_manager" 2>/dev/null >&2; then
      echo "$package_manager"
    fi
  done
}

PACKAGE_MANAGER="$(_get_package_manager)"

_get_available_packages () {
  [ "$1" = "yay" ] && yay -Slaq && return
  case "$PACKAGE_MANAGER" in
    "xbps-install") xpkg -a ;;
    "pacman") pacman -Slq ;;
    "apt") apt-cache pkgnames --generate ;;
    "zypper") _sanitize_zypper_packages "$(zypper search)" ;;
  esac
}

_get_installed_packages () {
  [ "$1" = "yay" ] && echo "$(yay -Qqam)" && return
  case "$PACKAGE_MANAGER" in
    "xbps-install") xpkg ;;
    "pacman") pacman -Qq ;;
    "apt") dpkg --get-selections | sed 's:install$::' ;;
    "zypper") _sanitize_zypper_packages "$(zypper search -i)" ;;
  esac
}

_do_installer () {
  package_list="$(_get_available_packages)"

  case "$PACKAGE_MANAGER" in
    "xbps-install") echo "$package_list" | fzf -m --preview-window="right:66%:wrap" --preview "xq {1}" | xargs -ro sudo xbps-install ;;
    "pacman") echo "$package_list" | fzf -m --preview-window="right:66%:wrap" --preview "pacman -Si {1}" | xargs -ro sudo pacman -S ;;
    "apt") echo "$package_list" | fzf -m --preview-window="right:66%:wrap" --preview "apt-cache show {1}" | xargs -ro sudo apt install ;;
    "zypper") echo "$package_list" | fzf -m --preview-window="right:66%:wrap" --preview "zypper info {1} | tail -n +7" | xargs -ro sudo zypper install
  esac
}

_do_uninstaller () {
  package_list="$(_get_installed_packages)"

  case "$PACKAGE_MANAGER" in
    "xbps-install") echo "$package_list" | fzf -m --preview-window="right:66%:wrap" --preview "xq {1}" | xargs -ro sudo xbps-remove ;;
    "pacman") echo "$package_list" | fzf -m --preview-window="right:66%:wrap" --preview "pacman -Si {1}" | xargs -ro sudo pacman -R ;;
    "apt") echo "$package_list" | fzf -m --preview-window="right:66%:wrap" --preview "apt-cache show {1}" | xargs -ro sudo apt remove ;;
    "zypper") echo "$package_list" | fzf -m --preview-window="right:66%:wrap" --preview "zypper info {1} | tail -n +7" | xargs -ro sudo zypper remove
  esac
}

_do_yay_installer () {
  [ "$PACKAGE_MANAGER" != "pacman" ] && echo "You aren't using Arch!" && exit 1
  package_list="$(_get_available_packages 'yay')"
  echo "$package_list" | fzf -m --preview-window="right:66%:wrap" --preview "yay -Si {1}" | xargs -ro yay -S
}

_do_yay_uninstaller () {
  [ "$PACKAGE_MANAGER" != "pacman" ] && echo "You aren't using Arch!" && exit 1
  package_list="$(_get_installed_packages 'yay')"
  echo "$package_list" | fzf -m --preview-window="right:66%:wrap" --preview "yay -Si {1}" | xargs -ro yay -R
}

_help () {
  echo "xs.sh - Terminal user interface for package managers, written in POSIX sh"
  echo "Usage: ./xs.sh OPTIONS"
  echo ""
  echo "OPTIONS"
  echo " -i --install    Select packages to install"
  echo " -r --remove     Select packages to uninstall"
  echo " --yay-install   Starts the installer tui for the yay AUR helper"
  echo " --yay-remove    Starts the uninstaller tui for the yay AUR helper"
  echo " -h --help       Prints this message"
}

_main () {
  case "$1" in
    "-i"|"--install") _do_installer ;;
    "-r"|"--remove") _do_uninstaller ;;
    "--yay-install") _do_yay_installer ;;
    "--yay-remove") _do_yay_uninstaller ;;
    "-h"|"--help") _help ;;
    *) echo "Invalid usage" && _help ;;
  esac
}

_main "$1"
