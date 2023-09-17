#!/usr/bin/env bash

## ANSI colors
RED="$(printf '\033[31m')"      GREEN="$(printf '\033[32m')"
ORANGE="$(printf '\033[33m')"   BLUE="$(printf '\033[34m')"
MAGENTA="$(printf '\033[35m')"  CYAN="$(printf '\033[36m')"
WHITE="$(printf '\033[37m')"    BLACK="$(printf '\033[30m')"

## Reset terminal colors
reset_color() {
	tput sgr0   # reset attributes
	tput op     # reset color
    return
}

## Script termination
exit_on_signal_SIGINT() {
    echo -e ${RED}"\n[!] Script interrupted.\n"
	{ reset_color; exit 1; }
}

exit_on_signal_SIGTERM() {
    echo -e ${RED}"\n[!] Script terminated.\n"
	{ reset_color; exit 1; }
}

trap exit_on_signal_SIGINT SIGINT
trap exit_on_signal_SIGTERM SIGTERM

## List of packages
_dir="`pwd`"
_packages=(
		  # For sddm and it's theme
		  sddm
		  qtdeclarative5-dev
		  qml-module-qtgraphicaleffects
		  qml-module-qtquick-controls
		  qml-module-qtquick-controls2
		  libqt5svg5

		  # For Openbox
		  #ffmpeg
		  #nitrogen
		  #obconf
		  #openbox
		  #plank
		  #python2
		  #tint2
		  #xfce4-settings
		  #xfce4-terminal
		  #xmlstarlet

		  # For Bspwm
		  bspwm
		  feh
		  sxhkd
		  xsettingsd

		  # Common tools for Openbox and Bspwm
		  dunst
		  light
		  picom
		  polybar
		  pulsemixer
		  rofi
		  xfce4-power-manager

		  # Basic applications
		  atril
		  galculator
		  geany
		  geany-plugins
		  mplayer
		  thunar
		  thunar-archive-plugin
		  thunar-media-tags-plugin
		  thunar-volman
		  viewnior

		  # CLI tools
		  htop
		  ncdu
		  nethogs
		  ranger
		  vim
		  zsh

		  # Utilities
		  acpi
		  blueman
		  ffmpegthumbnailer
		  fonts-noto-core
		  highlight
		  inotify-tools
		  iw
		  jq
		  libwebp-dev
		  libavif-dev
		  libheif-dev
		  maim
		  meld
		  mpc
		  mpd
		  ncmpcpp
		  neofetch
		  pavucontrol
		  powertop
		  qt5ct
		  qt5-style-kvantum
		  simplescreenrecorder
		  trash-cli
		  tumbler
		  wmctrl
		  wmname
		  xclip
		  xdg-user-dirs
		  xdg-user-dirs-gtk
		  xdotool
		  yad

		  # Archives
		  bzip2
		  gzip
		  lrzip
		  lz4
		  lzip
		  lzop
		  p7zip
		  rar
		  tar
		  unzip
		  unrar
		  xarchiver
		  zip
		  zstd

		  # For networkmanager_dmenu
		  gir1.2-nm-1.0
		  libnm0

		  # for Ueberzug
		  python3-pil
		  python3-attr
		  python3-docopt
		  python3-xlib

		  # for Pywal
		  python3-pip
)
_failed_to_install=()

## Banner
banner() {
	clear
    cat <<- EOF
		${RED} ____  ____  ____  ____    __    _  _  ___  ____    __    ____  ____ 
		${RED}(  _ \( ___)(  _ \(_  _)  /__\  ( \( )/ __)(  _ \  /__\  ( ___)(_  _)
		${RED} )(_) ))__)  ) _ < _)(_  /(__)\  )  (( (__  )   / /(__)\  )__)   )(  
		${RED}(____/(____)(____/(____)(__)(__)(_)\_)\___)(_)\_)(__)(__)(__)   (__) ${WHITE}
		
		${CYAN}Debiancraft  ${WHITE}: ${MAGENTA}Install Archcraft on Debian 12
		${CYAN}Developed By ${WHITE}: ${MAGENTA}Alien-Tec
		
		${RED}Recommended  ${WHITE}: ${GREEN}Install this on a fresh installation of Debian 12 ${WHITE}
	EOF
}

## Check command status
check_cmd_status() {
	if [[ "$?" != '0' ]]; then
		{ echo -e ${RED}"\n[!] Failed to $1 '$2'"; reset_color; exit 1; }
	fi
}

## Perform system upgrade
upgrade_system() {
	{ echo -e ${BLUE}"\n[*] Performing system upgrade..."; reset_color; }
	sudo apt update --yes
	if [[ "$?" != '0' ]]; then
		{ echo -e ${RED}"\n[!] Failed to retrieve new lists of packages\n"; reset_color; exit 1; }
	fi
	sudo apt upgrade --yes
	if [[ "$?" != '0' ]]; then
		{ echo -e ${RED}"\n[!] Failed to perform an upgrade\n"; reset_color; exit 1; }
	fi
}

## Install packages
install_pkgs() {
	upgrade_system
	{ echo -e ${BLUE}"\n[*] Installing required packages..."; reset_color; }
	for _pkg in "${_packages[@]}"; do
		{ echo -e ${ORANGE}"\n[+] Installing package : $_pkg"; reset_color; }
		sudo apt install "$_pkg" --yes
		if [[ "$?" != '0' ]]; then
			{ echo -e ${RED}"\n[!] Failed to install package: $_pkg"; reset_color; }
			_failed_to_install+=("$_pkg")
		fi		
	done

	# List failed packages
	echo
	for _failed in "${_failed_to_install[@]}"; do
		{ echo -e ${RED}"[!] Failed to install package : ${ORANGE}${_failed}"; reset_color; }
	done
	if [[ -n "${_failed_to_install}" ]]; then
		{ echo -e ${RED}"\n[!] Install these packages manually to continue, exiting...\n"; reset_color; exit 1; }
	fi
}

## Install Debian 12 Python
sudo rm /usr/lib/python3.11/EXTERNALLY-MANAGED

## Install extra packages
install_extra_pkgs() {
	{ echo -e ${BLUE}"[*] Installing extra packages..."; reset_color; }
	# Install alacritty deb package
	{ echo -e ${ORANGE}"\n[+] Installing alacritty from local package"; reset_color; }
	sudo dpkg --install "$_dir"/pkgs/alacritty_*.deb
	check_cmd_status 'install' 'alacritty'

	# Install pastel deb package
	{ echo -e ${ORANGE}"\n[+] Installing pastel from local package"; reset_color; }
	sudo dpkg --install "$_dir"/pkgs/pastel_*.deb
	check_cmd_status 'install' 'pastel'

	# Install ueberzug deb package
	{ echo -e ${ORANGE}"\n[+] Installing ueberzug from local package"; reset_color; }
	sudo dpkg --install "$_dir"/pkgs/ueberzug_*.deb
	check_cmd_status 'install' 'ueberzug'

	# Install pywal with pip3 and move wal to /u/l/b
	{ echo -e ${ORANGE}"\n[+] Installing pywal with pip3"; reset_color; }
	pip3 install pywal
	check_cmd_status 'install' 'pywal'
	_wal_bin="$HOME/.local/bin/wal"
	if [[ -e "$_wal_bin" ]]; then
		sudo cp --preserve=mode --force --recursive "$_wal_bin" /usr/local/bin
	fi
}

## Install the files
install_files() {
	_copy_cmd='sudo cp --preserve=mode --force --recursive'
	_rootfs="$_dir/files"
	_skel='/etc/skel'
	_libdir='/usr/lib'
	_bindir='/usr/local/bin'
	_sharedir='/usr/share'

	{ echo -e ${BLUE}"\n[*] Installing required files..."; reset_color; }

	# Copy libraries
	{ echo -e ${ORANGE}"\n[+] Installing libraries..."; reset_color; }
	${_copy_cmd} --verbose "$_rootfs"/usr/lib/* "$_libdir"

	# Copy binaries and scripts
	{ echo -e ${ORANGE}"\n[+] Installing binaries and scripts..."; reset_color; }
	${_copy_cmd} --verbose "$_rootfs"/usr/local/bin/* "$_bindir"
	sudo chmod 755 "$_bindir"/*
	
	# Copy shared files
	{ echo -e ${ORANGE}"\n[+] Installing shared files..."; reset_color; }
	${_copy_cmd} "$_rootfs"/usr/share/* "$_sharedir"

	# Copy sddm configs
	{ echo -e ${ORANGE}"\n[+] Installing sddm config files..."; reset_color; }
	${_copy_cmd} --verbose "$_rootfs"/etc/{sddm.conf.d,sddm.conf} /etc

	# Copy config files
	{ echo -e ${ORANGE}"\n[+] Installing config files..."; reset_color; }
	${_copy_cmd} "$_rootfs"/etc/skel/. "$_skel"

	# Copy Misc files
	{ echo -e ${ORANGE}"\n[+] Installing misc config files..."; reset_color; }
	${_copy_cmd} "$_rootfs"/etc/xdg/autostart/* /etc/xdg/autostart
	${_copy_cmd} "$_rootfs"/etc/udev/rules.d/70-backlight.rules /etc/udev/rules.d
	${_copy_cmd} "$_rootfs"/etc/X11/xorg.conf.d/02-touchpad-ttc.conf /etc/X11/xorg.conf.d
}

## Copy files in user's directory
copy_files_in_home() {
	_cp_cmd='cp --preserve=mode --force --recursive'
	_skel_dir='/etc/skel'
	_bnum=`echo $RANDOM`

	{ echo -e ${BLUE}"\n[*] Copying config files in $HOME directory..."; reset_color; }
	_cfiles=(
		  '.cache'
		  '.config'
		  '.dmrc'
		  '.face'
		  '.fehbg'
		  '.gtkrc-2.0'
		  '.hushlogin'
		  '.icons'
		  '.mpd'
		  '.ncmpcpp'
		  '.oh-my-zsh'
		  '.vimrc'
		  '.vim_runtime'
		  '.zshrc'
		  Bilder
		  Musik
		  )
	
	for _file in "${_cfiles[@]}"; do
		if [[ -e "$HOME/$_file" ]]; then
			{ echo -e ${MAGENTA}"\n[*] Backing-up : $HOME/$_file"; reset_color; }
			mv "$HOME/$_file" "$HOME/${_file}_backup_${_bnum}"
			{ echo -e ${CYAN}"[*] Backup stored in : $HOME/${_file}_backup_${_bnum}"; reset_color; }
		fi
		{ echo -e ${ORANGE}"[+] Copying $_skel_dir/$_file in $HOME directory"; reset_color; }
		${_cp_cmd} "$_skel_dir/$_file" "$HOME"
	done
}

## Copy files in root directory
copy_files_in_root() {
	_cp_cmd='sudo cp --preserve=mode --force --recursive'
	_skel_dir='/etc/skel'
	_bnum=`echo $RANDOM`

	{ echo -e ${BLUE}"\n[*] Copying config files in /root directory..."; reset_color; }
	_cfiles=(
		  '.config'
		  '.gtkrc-2.0'
		  '.oh-my-zsh'
		  '.vimrc'
		  '.vim_runtime'
		  '.zshrc'
		  )
	
	for _file in "${_cfiles[@]}"; do
		if [[ -e "/root/$_file" ]]; then
			{ echo -e ${MAGENTA}"\n[*] Backing-up : /root/$_file"; reset_color; }
			sudo mv "/root/$_file" "/root/${_file}_backup_${_bnum}"
			{ echo -e ${CYAN}"[*] Backup stored in : /root/${_file}_backup_${_bnum}"; reset_color; }
		fi
		{ echo -e ${ORANGE}"[+] Copying $_skel_dir/$_file in /root directory"; reset_color; }
		${_cp_cmd} "$_skel_dir/$_file" /root
	done
}

## Manage services
manage_services() {
	{ echo -e ${BLUE}"\n[*] Managing services..."; reset_color; }

	# Disable gdm service
	{ echo -e ${ORANGE}"\n[-] Disabling gdm service..."; reset_color; }
	if systemctl is-enabled gdm.service &>/dev/null; then
		sudo systemctl disable gdm.service
		check_cmd_status 'disable' 'gdm service'
	fi

	# Enable sddm service
	{ echo -e ${ORANGE}"\n[+] Enabling sddm service..."; reset_color; }
	if ! systemctl is-enabled sddm.service &>/dev/null; then
		sudo systemctl enable sddm.service
		check_cmd_status 'enable' 'sddm service'
	fi

	# Enable betterlockscreen service
	{ echo -e ${ORANGE}"\n[+] Enabling betterlockscreen service..."; reset_color; }
	if ! systemctl is-enabled betterlockscreen@$USER.service &>/dev/null; then
		sudo systemctl enable betterlockscreen@$USER.service
		check_cmd_status 'enable' 'lockscreen service'
	fi
}

## Remove gnome desktop
remove_gnome_desktop() {
	{ echo; read -p ${RED}"[?] Do you want to remove Debian's desktop [y/n]: "${WHITE}; }
	if [[ "$REPLY" =~ ^(y|Y)$ ]]; then
		cat <<- EOF
		
		    ${ORANGE}1. Remove Gnome Desktop Only
		    ${ORANGE}2. Remove Gnome Desktop And All The Gnome Apps
		    ${ORANGE}3. Skip This Step And Don't Remove Debian Desktop

		EOF
		read -p ${BLUE}"[?] Choose Option [1/2/3]: "${WHITE}
		if [[ "$REPLY" == 1 ]]; then
			_pkg_to_remove=(debian-desktop gnome-shell)
			for _pkg in "${_pkg_to_remove[@]}"; do
				{ echo -e ${ORANGE}"\n[-] Removing $_pkg"; reset_color; }
				sudo apt purge "$_pkg" --yes
			done
		elif [[ "$REPLY" == 2 ]]; then
			_pkg_to_remove=(debian-desktop
							gnome-shell
							gnome-calculator
							gnome-characters
							gnome-disk-utility
							gnome-font-viewer
							gnome-logs
							gnome-menus
							gnome-power-manager
							gnome-remote-desktop
							gnome-system-monitor
							gnome-terminal
							gnome-user-docs
							gedit
							seahorse
							eog
							evince
							nautilus
							file-roller
							debian-wallpapers
							yaru-theme-gnome-shell
							yaru-theme-gtk
							yaru-theme-icon
							yaru-theme-sound
							)
			for _pkg in "${_pkg_to_remove[@]}"; do
				{ echo -e ${ORANGE}"\n[-] Removing $_pkg"; reset_color; }
				sudo apt purge "$_pkg" --yes
			done
		else
			{ echo -e ${GREEN}"\n[*] Skipping, Debian desktop is not removed."; reset_color; }
		fi
	else
		{ echo -e ${GREEN}"[*] Debian desktop is not removed."; reset_color; }
	fi
}

## Finalization
finalization() {
	{ echo -e ${BLUE}"\n[*] Adding $USER to 'video' group..."; reset_color; }
	sudo usermod -a -G video "$USER"

	{ echo -e ${BLUE}"\n[*] Changing ${USER}'s shell to zsh..."; reset_color; }
	sudo chsh -s /bin/zsh "$USER"

	{ echo -e ${BLUE}"\n[*] Cleaning up..."; reset_color; }

	# Remove all unused packages
	{ echo -e ${ORANGE}"\n[-] Removing unused packages..."; reset_color; }
	sudo apt autoremove --yes

	# Erase downloaded archive files
	{ echo -e ${ORANGE}"\n[-] Removing downloaded package archives..."; reset_color; }
	sudo apt clean --yes

	# Completed
	{ echo -e ${GREEN}"\n[*] Installation Completed, you may now reboot your computer.\n"; reset_color; }
}

## Main ------------
banner
install_pkgs
install_extra_pkgs
install_files
copy_files_in_home
copy_files_in_root
manage_services
remove_gnome_desktop
finalization
