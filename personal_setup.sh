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
cp -r $SCRIPT_DIR/home/kruayd/* $HOME/

# Install TeX live
mkdir ~/Programs
mkdir ~/Programs/LaTeX
cd ~/Programs/LaTeX
wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
tar -xzvf install-tl-unx.tar.gz
rm install-tl-unx.tar.gz
export TEXLIVE_INSTALL_PREFIX=$(pwd)
perl $(ls | sort | tail -n 1)/install-tl -portable
# Add LaTeX utilities to PATH
# sed -i -e "/^# PATH/ a\\
# # Must be at the beginning of path in order to let LaTeX work properly\\
# PATH='$(pwd)/bin/x86_64-linux:'\$PATH" $HOME/.bashrc
# Latex is already added to PATH in .bashrc


# Change

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

# Setup vim
sudo xbps-remove -R vim
sudo xbps-install vim-huge-python3 python3-devel gcc cmake mono go nodejs openjdk17 flake8 black
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
# cp -r $SCRIPT_DIR/home/kruayd/.vim ~/
# cp $SCRIPT_DIR/home/kruayd/.vimrc ~/
# Already taken care by cp -r $SCRIPT_DIR/home/kruayd/* $HOME/
vim -c 'PluginInstall' -c 'qa!'
cd ~/.vim/bundle/YouCompleteMe
python3 install.py --all
# more info at https://dev.to/shahinsha/how-to-make-vim-a-python-ide-best-ide-for-python-23e1

# Icons
# cp -r $SCRIPT_DIR/home/kruayd/.local/share/icons $HOME/.local/share/
# Already taken care by cp -r $SCRIPT_DIR/home/kruayd/* $HOME/

# copy themes for KDE
# cp -R $SCRIPT_DIR/home/kruayd/.local/* ~/.local/
# Already taken care by cp -r $SCRIPT_DIR/home/kruayd/* $HOME/
