#!/bin/bash


#####################################################################
#	    Whenever you see SCRIPT_DIR in this installer,	    #
#     I highly recommend to look at the files that are involved.    #
#     They, usually, are config files that works for my machine     #
#####################################################################

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Check if root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi


#####################################################################
#	      Use the microcode that best fits your CPU		    #
#	   https://docs.voidlinux.org/config/firmware.html	    #
#####################################################################

echo ""
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "                          MICROCODE                             "
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
# Add non-free repository and install microcode for INTEL
# then regenerate initramfs
xbps-install -S void-repo-nonfree # Necessary to install the intel microcode (next line)
xbps-install -S intel-ucode
xbps-reconfigure -fa
read -p "Press enter to continue"


#####################################################################
#    By using Irish locale you can have '.' as decimal separator,   #
#     time format expressed as dd/mm/yyyy and euro as currency.     #
#								    #
# LC_COLLATE=C set the collation category to the same as standard C #
#     If you wish/need, you can also set LC_CTYPE, LC_MONETARY,     #
#			LC_NUMERIC and LC_TIME			    #
#####################################################################

echo ""
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "                           LOCALES                              "
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
# Uncomment en_IE.UTF-8 UTF-8 locale
sed -i -e "/en_IE.UTF-8 UTF-8/s/^#//" /etc/default/libc-locales
# Setting the system locale
echo "LANG=en_IE.utf8" > /etc/locale.conf
echo "LC_COLLATE=C" >> /etc/locale.conf
xbps-reconfigure -f glibc-locales
read -p "Press enter to continue"


#####################################################################
#    If you are dual booting Windows be careful and read the doc    #
#		    before setting HARDWARECLOCK:		    #
#	   https://docs.voidlinux.org/config/rc-files.html	    #
#								    #
#	  Change 'Europe' and 'Rome' to whatever you need	    #
#			(I live in Italy)			    #
#####################################################################

echo ""
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "                           RC-CONF                              "
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
# rc.conf settings (uncomment and select)
# Hardware clock settings
sed -i -e "/HARDWARECLOCK\=/s/^#//" /etc/rc.conf
sed -i -e "/HARDWARECLOCK\=/s/\=.*$/\=\"UTC\"/" /etc/rc.conf
# Timezone settings
sed -i -e "/TIMEZONE\=/s/^#//" /etc/rc.conf
sed -i -e "/TIMEZONE\=/s/\=.*$/\=\"Europe\/Rome\"/" /etc/rc.conf
# Keymap settings
sed -i -e "/KEYMAP\=/s/^#//" /etc/rc.conf
sed -i -e "/KEYMAP\=/s/\=.*$/\=\"us\"/" /etc/rc.conf
# Font settings
sed -i -e "/FONT\=/s/^#//" /etc/rc.conf
sed -i -e "/FONT\=/s/\=.*$/\=\"lat9w-16\"/" /etc/rc.conf
# ttys settings
sed -i -e "/TTYS\=/s/^#//" /etc/rc.conf
sed -i -e "/TTYS\=/s/\=.*$/\=8/" /etc/rc.conf
read -p "Press enter to continue"


#####################################################################
#		   Same thing here with timezone		    #
#####################################################################

echo ""
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "                          TIMEZONES                             "
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
# Date and Time settings
# Timezone
ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime
# Network Time Protocol
xbps-install -S ntp
ln -s /etc/sv/isc-ntpd /etc/runit/runsvdir/default/
read -p "Press enter to continue"


#####################################################################
#	    I mainly use acpid for tablet mode on X11 so,	    #
#		do not install it if you don't need it		    #
#####################################################################

echo ""
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "                      POWER MANAGEMENT                          "
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
# Power management
# acpid
# ln -s /etc/sv/acpid /etc/runit/runsvdir/default/ || xbps-install -S acpid && ln -s /etc/sv/acpid /etc/runit/runsvdir/default/
# cp -R $SCRIPT_DIR/etc/acpi /etc/
# elogind
xbps-install -S elogind
sed -i -e "/^Handle/s/^/#/" /etc/elogind/logind.conf
# Running elogind as a service is useless if you already run dbus
# since the latter will take care of automatically running the former when needed
# (decomment next line if you do not plan on installing dbus)
# ln -s /etc/sv/elogind /etc/runit/runsvdir/default/
# tlp
xbps-install -S tlp
ln -s /etc/sv/tlp /etc/runit/runsvdir/default/
cp -R $SCRIPT_DIR/etc/tlp.d /etc/
read -p "Press enter to continue"

echo ""
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "                           NETWORK                              "
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
# NetworkManager
xbps-install -S NetworkManager
rm -rf /etc/runit/runsvdir/default/{dhcpcd,wpa_supplicant,wicd}
xbps-install -S dbus-elogind dbus-elogind-libs dbus-elogind-x11
ls /etc/runit/runsvdir/default/dbus || ln -s /etc/sv/dbus /etc/runit/runsvdir/default/
ln -s /etc/sv/NetworkManager /etc/runit/runsvdir/default/
read -p "Press enter to continue"


#####################################################################
#			  BE CAREFUL HERE!!!			    #
#	     Choose the correct drivers for your GPU and	    #
#     try to understand if you need to remove xorg-video-drivers    #
#		      to make modesetting work			    #
#   https://docs.voidlinux.org/config/graphical-session/index.html  #
#####################################################################

echo ""
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "                           GRAPHICS                             "
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
# Graphics drivers for Intel integrated gpu
xbps-install -S linux-firmware-intel mesa-dri vulkan-loader mesa-vulkan-intel intel-video-accel

# Xorg
xbps-install -S xorg
cp -R $SCRIPT_DIR/etc/X11/xorg.conf.d /etc/X11/
xbps-remove -F xorg-video-drivers # Intel specific (not sure)
read -p "Press enter to continue"


#####################################################################
#      Everything that follows is intended to work under kde.	    #
#	    If you wish to use another DE, read the docs!	    #
#  https://docs.voidlinux.org/config/graphical-session/index.html   #
#####################################################################

echo ""
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "                             DE                                 "
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
# Wayland
xbps-install -S wayland qt5-wayland kwayland xorg-server-xwayland

# No bitmap fonts:
ln -s /usr/share/fontconfig/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d/
xbps-reconfigure -f fontconfig

# KDE
xbps-install -S kde5 kde5-baseapps kdegraphics-thumbnailers ffmpegthumbs accountsservice
ln -s /etc/sv/sddm /etc/runit/runsvdir/default/
cp /usr/share/wayland-sessions/plasmawayland.desktop /usr/share/wayland-sessions/plasmawayland.desktop.old
sed -i -e "/^Exec\=/s/\=/\=env QT_QPA_PLATFORM\=wayland-egl ELM_DISPLAY\=wl SDL_VIDEODRIVER\=wayland MOZ_ENABLE_WAYLAND\=1 /" /usr/share/wayland-sessions/plasmawayland.desktop # we're gonna install firefox later
read -p "Press enter to continue"


#####################################################################
#   sof-firmware is crucial for modern Digital Signal Processors.   #
#     If your sound still doesn't work after installation, try:     #
#   https://bbs.archlinux.org/viewtopic.php?pid=1933643#p1933643    #
#####################################################################

echo ""
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "              MULTIMEDIA AND FOUNDAMENTAL STUFFS                "
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
# Multimedia with PipeWire
xbps-install -S sof-firmware rtkit pipewire pipewire-doc easyeffects libspa-bluetooth alsa-pipewire libjack-pipewire gstreamer1-pipewire pulseaudio-utils qpwgraph pavucontrol
mkdir -p /etc/pipewire/pipewire.conf.d
ln -s /usr/share/examples/wireplumber/10-wireplumber.conf /etc/pipewire/pipewire.conf.d/
ln -s /usr/share/examples/pipewire/20-pipewire-pulse.conf /etc/pipewire/pipewire.conf.d/
mkdir -p /etc/alsa/conf.d
ln -s /usr/share/alsa/alsa.conf.d/50-pipewire.conf /etc/alsa/conf.d
ln -s /usr/share/alsa/alsa.conf.d/99-pipewire-default.conf /etc/alsa/conf.d
xbps-install -S bluez
ln -s /etc/sv/bluetoothd /etc/runit/runsvdir/default/
xbps-install -S xdg-desktop-portal
#KDE specific
xbps-install -S xdg-desktop-portal-kde

# Printing
xbps-install -S cups cups-filters
ln -s /etc/sv/cupsd /etc/runit/runsvdir/default/

# Useful Kernel modules
xbps-install -S v4l2loopback

# Foundamental stuffs
xbps-install -S wget git make cmake tar gzip ffmpeg curl bash-completion

# SMB client
xbps-install -S cifs-utils smbclient

# exFAT compatibility
xbps-install -S fuse-exfat exfat-utils

# Thunderbolt demon
ln -s /etc/sv/boltd /etc/runit/runsvdir/default/
read -p "Press enter to continue"


#####################################################################
# Tablet mode is detected by libinput through the intel-hid module. #
#      If cat /sys/devices/virtual/dmi/id/chassis_type returns      #
# 31 (convertible) or 32 (detachable), there should be no problem.  #
# If it returns a different number, even if it should be 31 or 32,  #
#	  then read this post here* and write an e-mail to	    #
#	      eliadevito@gmail.com, hdegoede@redhat.com		    #
#		  or simply commit a change here**		    #
#####################################################################

# * https://www.reddit.com/r/linuxquestions/comments/kjewee/detecting_tablet_mode_for_autorotation/
# ** https://github.com/torvalds/linux/blob/master/drivers/platform/x86/intel-hid.c

echo ""
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "                           TABLET                               "
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
# Tablet mode
xbps-install -S iio-sensor-proxy
ln -s /etc/sv/iio-sensor-proxy /etc/runit/runsvdir/default/
# cp -R $SCRIPT_DIR/usr/local/bin /usr/local/
# cp -R $SCRIPT_DIR/etc/sv/autorotate /etc/sv/
# ln -s /etc/sv/autorotate /etc/runit/runsvdir/default/
# Need to understand how to install maliit keyboard
# or any other good virtual keyboard
read -p "Press enter to continue"

echo ""
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "                          SOFTWARES                             "
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
# Useful softwares
xbps-install -S htop tree pass neofetch python3 python3-virtualenv dolphin konsole gwenview spectacle okular qtpass mpv firefox telegram-desktop transmission qemu

# Additional fonts
xbps-install -S noto-fonts-cjk noto-fonts-emoji

# Scientific softwares
xbps-install -S python3-numpy python3-scipy python3-matplotlib python3-pandas python3-occ freecad kicad paraview

# Production softwares
xbps-install -S pdftk ImageMagick kate5 libreoffice gimp inkscape krita obs texstudio xournalpp calibre

# Gaming related softwares
xbps-install -S sc-controller minigalaxy steam
read -p "Press enter to continue"

echo ""
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "                             WINE                               "
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
while true; do
    read -p "Do you wish to install wine? [Y/n]" yn
    case $yn in
        [Yy]* ) # 32-bit repo
		sudo xbps-install void-repo-multilib
		sudo xbps-install -S
		# wine
		# CONTAINS INTEL SPECIFIC!
		sudo xbps-install wine wine-32bit winetricks zenity mesa-dri-32bit vulkan-loader-32bit mesa-vulkan-intel-32bit
		break;;
        [Nn]* ) break;;
        * ) echo "Please, answer yes or no.";;
    esac
done
read -p "Press enter to continue"


echo ""
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "                       USER SECTION                             "
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "Changing root default shell to bash"
chsh -s /bin/bash root
echo ""
echo "Input your user name"
read -r user_name
useradd -m -g users -G wheel,floppy,lp,audio,video,cdrom,optical,scanner,network,kvm,xbuilder,bluetooth $user_name
passwd $user_name



echo ""
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "To finalize installation consult:"
echo "- https://docs.voidlinux.org/config/users-and-groups.html"
echo "- https://docs.voidlinux.org/config/ssd.html"
echo ""
echo "These sections are not covered by this script and require manual operations"
