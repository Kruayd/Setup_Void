#!/bin/bash


#####################################################################
#	    Whenever you see SCRIPT_DIR in this installer,	    #
#     I highly recommend to look at the files that are involved.    #
#     They, usually, are config files that works for my machine     #
#####################################################################

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"


# Backup .bashrc
mv $HOME/.bashrc $HOME/.bashrc_old
# Copy everything
cp -r $SCRIPT_DIR/home/kruayd/. $HOME/

mkdir ~/Builds
cd ~/Builds

# xbps-src
git clone https://github.com/void-linux/void-packages.git
cd void-packages
./xbps-src binary-bootstrap
# Enable restricted
echo XBPS_ALLOW_RESTRICTED=yes >> etc/conf
# Install Zoom
./xbps-src pkg zoom
sudo xbps-install --repository hostdir/binpkgs/nonfree zoom
# Install MS fonts
./xbps-src pkg msttcorefonts
sudo xbps-install --repository hostdir/binpkgs/nonfree msttcorefonts
cd ..

# Icons
# cp -r $SCRIPT_DIR/home/kruayd/.local/share/icons $HOME/.local/share/
# Already taken care by cp -r $SCRIPT_DIR/home/kruayd/* $HOME/

# copy themes for KDE
# cp -R $SCRIPT_DIR/home/kruayd/.local/* ~/.local/
# Already taken care by cp -r $SCRIPT_DIR/home/kruayd/* $HOME/
