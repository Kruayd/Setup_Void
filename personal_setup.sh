#!/bin/bash


#####################################################################
#	    Whenever you see SCRIPT_DIR in this installer,	    #
#     I highly recommend to look at the files that are involved.    #
#     They, usually, are config files that works for my machine     #
#####################################################################

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Install TeX live
mkdir ~/Programs
mkdir ~/Programs/LaTeX
cd ~/Programs/LaTeX
wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
tar -xzvf install-tl-unx.tar.gz
rm install-tl-unx.tar.gz
export TEXLIVE_INSTALL_PREFIX=$(pwd)
perl $(ls | sort | tail -n 1)/install-tl -portable
sudo sed -i -e "/^# Set our default path.*/i # Must be at the beginning of path in order to let LaTeX to work properly\nPATH\='$(pwd)\/bin\/x86_64-linux:'\$PATH\n" /etc/profile


# Change

mkdir ~/Builds
cd ~/Builds

# Breeze hacked cursor theme
sudo xbps-install xcursorgen
mkdir breeze-hacked-cursor-theme && cd breeze-hacked-cursor-theme
git clone https://github.com/codejamninja/breeze-hacked-cursor-theme.git .
make install
cd ..

# Suru plus aspromauros icons
wget -qO- https://raw.githubusercontent.com/gusbemacbe/suru-plus-aspromauros/master/install.sh | sh

# Setup vim
sudo xbps-remove -R vim
sudo xbps-install vim-huge-python3 python3-devel gcc cmake mono go nodejs openjdk11
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
cp $SCRIPT_DIR/home/kruayd/.vimrc ~/
vim -c 'PluginInstall' -c 'qa!'
cd ~/.vim/bundle/YouCompleteMe
python3 install.py --all
# more info at https://dev.to/shahinsha/how-to-make-vim-a-python-ide-best-ide-for-python-23e1

# copy themes for KDE
cp -R $SCRIPT_DIR/home/kruayd/.local/* ~/.local/
