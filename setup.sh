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

# Add non-free repository and install microcode for INTEL
# then regenerate initramfs
xbps-install -S void-repo-nonfree # Necessary to install the intel microcode (next line)
xbps-install -S intel-ucode
xbps-reconfigure -fa


#####################################################################
#    By using Irish locale you can have '.' as decimal separator,   #
#     time format expressed as dd/mm/yyyy and euro as currency.     #
#								    #
# LC_COLLATE=C set the collation category to the same as standard C #
#     If you wish/need, you can also set LC_CTYPE, LC_MONETARY,     #
#			LC_NUMERIC and LC_TIME			    #
#####################################################################

# Uncomment en_IE.UTF-8 UTF-8 locale
sed -i -e "/en_IE.UTF-8 UTF-8/s/^#//" /etc/default/libc-locales
# Setting the system locale
echo "LANG=en_IE.utf8" > /etc/locale.conf
echo "LC_COLLATE=C" >> /etc/locale.conf
xbps-reconfigure -f glibc-locales


#####################################################################
#    If you are dual booting Windows be careful and read the doc    #
#		    before setting HARDWARECLOCK:		    #
#	   https://docs.voidlinux.org/config/rc-files.html	    #
#								    #
#	  Change 'Europe' and 'Berlin' to whatever you need	    #
#			(I live in Germany)			    #
#####################################################################

# rc.conf settings (uncomment and select)
# Hardware clock settings
sed -i -e "/HARDWARECLOCK\=/s/^#//" /etc/rc.conf
sed -i -e "/HARDWARECLOCK\=/s/\=.*$/\=\"UTC\"/" /etc/rc.conf
# Timezone settings
sed -i -e "/TIMEZONE\=/s/^#//" /etc/rc.conf
sed -i -e "/TIMEZONE\=/s/\=.*$/\=\"Europe\/Berlin\"/" /etc/rc.conf
# Keymap settings
sed -i -e "/KEYMAP\=/s/^#//" /etc/rc.conf
sed -i -e "/KEYMAP\=/s/\=.*$/\=\"us\"/" /etc/rc.conf
# Font settings
sed -i -e "/FONT\=/s/^#//" /etc/rc.conf
sed -i -e "/FONT\=/s/\=.*$/\=\"lat9w-16\"/" /etc/rc.conf
# ttys settings
sed -i -e "/TTYS\=/s/^#//" /etc/rc.conf
sed -i -e "/TTYS\=/s/\=.*$/\=8/" /etc/rc.conf


#####################################################################
#		   Same thing here with timezone		    #
#####################################################################

# Date and Time settings
# Timezone
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
# Network Time Protocol
xbps-install -S ntp
ln -s /etc/sv/isc-ntpd /var/service/


#####################################################################
#	    I mainly use acpid for tablet mode on X11 so,	    #
#		do not install it if you don't need it		    #
#####################################################################

# Power management
# acpid
ln -s /etc/sv/acpid /var/service/ || xbps-install -S acpid && ln -s /etc/sv/acpid /var/service/
cp -R $SCRIPT_DIR/etc/acpi /etc/
# elogind
xbps-install -S elogind
sed -i -e "/^Handle/s/^/#/" /etc/elogind/logind.conf
ln -s /etc/sv/elogind /var/service
# tlp
xbps-install -S tlp
ln -s /etc/sv/tlp /var/service/
cp -R $SCRIPT_DIR/etc/tlp.d /etc/

# NetworkManager
xbps-install -S NetworkManager
rm -rf /var/service/{dhcpcd,wpa_supplicant,wicd}
sudo xbps-install -S dbus-elogind dbus-elogind-libs dbus-elogind-x11
ls /var/service/dbus || ln -s /etc/sv/dbus /var/service/
ln -s /etc/sv/NetworkManager /var/service/


#####################################################################
#			  BE CAREFUL HERE!!!			    #
#	     Choose the correct drivers for your GPU and	    #
#     try to understand if you need to remove xorg-video-drivers    #
#		      to make modesetting work			    #
#   https://docs.voidlinux.org/config/graphical-session/index.html  #
#####################################################################

# Graphics drivers for Intel integrated gpu
xbps-install -S linux-firmware-intel mesa-dri vulkan-loader mesa-vulkan-intel intel-video-accel

# Xorg
xbps-install xorg
cp -R $SCRIPT_DIR/etc/X11/xorg.conf.d /etc/X11/
xbps-remove -F xorg-video-drivers # Intel specific (not sure)


#####################################################################
#      Everything that follows is intended to work under kde.	    #
#	    If you wish to use another DE, read the docs!	    #
#  https://docs.voidlinux.org/config/graphical-session/index.html   #
#####################################################################

# Wayland
xbps-install -S wayland qt5-wayland kwayland xorg-server-wayland

# No bitmap fonts:
ln -s /usr/share/fontconfig/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d/
xbps-reconfigure -f fontconfig

# KDE
xbps-install -S kde5 kde5-baseapps kdegraphics-thumbnailers ffmpegthumbss accountsservice
ln -s /etc/sv/sddm /var/service/
cp /usr/share/wayland-sessions/plasmawayland.desktop /usr/share/wayland-sessions/plasmawayland.desktop.old
cp /usr/share/xsession/plasma.desktop /usr/share/xsessions/plasma.desktop.old
sed -i -e "/^Exec\=/s/\=/\=env QT_QPA_PLATFORM\=wayland-egl MOZ_ENABLE_WAYLAND\=1 /" /usr/share/wayland-sessions/plasmawayland.desktop # we're gonna install firefox later


#####################################################################
#   sof-firmware is crucial for modern Digital Signal Processors.   #
#     If your sound still doesn't work after installation, try:     #
#   https://bbs.archlinux.org/viewtopic.php?pid=1933643#p1933643    #
#####################################################################

# Multimedia
xbps-install -S sof-firmware pipewire pipewire-doc pulseeffects libpulseaudio-pipewire alsa-pipewire libjack-pipewire gstreamer1-pipewire libspa-bluetooth
sed -i -e "/^Exec\=/s/MOZ_ENABLE_WAYLAND\=1 /MOZ_ENABLE_WAYLAND\=1 pipewire pipewire-pulse /" /usr/share/wayland-sessions/plasmawayland.desktop
sed -i -e "/^Exec\=/s/\=/\=pipewire pipewire-pulse /" /usr/share/xsessions/plasma.desktop
xbps-install -S bluez
ln -s /etc/sv/bluetoothd /var/service/

# Printing
xbps-install -S cups cups-filters
ln -s /etc/sv/cupsd /var/service/

# Useful Kernel modules
xbps-install -S v4l2loopback

# Foundamental stuffs
xbps-install -S wget git make cmake tar gzip ffmpeg


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

# Tablet mode
xbps-install -S iio-sensor-proxy
cp -R $SCRIPT_DIR/usr/local/bin /usr/local/
cp -R $SCRIPT_DIR/etc/sv/autorotate /etc/sv/
ln -s /etc/sv/autorotate /var/service/
# Need to understand how to install maliit keyboard
# or any other good virtual keyboard

# Useful softwares
xbps-install -S htop tree pass neofetch python3-pip python3-wheel python3-virtualenv dolphin konsole gwenview spectacle okular qtpass mpv firefox telegram-desktop element-desktop

# Production softwares
xbps-install -S pdftk ImageMagick kate5 libreoffice gimp inkscape krita obs texstudio # xournalpp (?)



echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""
echo "To finalize installation consult:"
echo "- https://docs.voidlinux.org/config/users-and-groups.html"
echo "- https://docs.voidlinux.org/config/ssd.html"
echo ""
echo "These sections are not covered by this script and require manual operations"
