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

ls ~/Builds || mdkir ~/Builds
cd ~/Builds

# Breeze hacked cursor theme
sudo xbps-install xcursorgen
mkdir breeze-hacked-cursor-theme && cd breeze-hacked-cursor-theme
git clone https://github.com/codejamninja/breeze-hacked-cursor-theme.git .
make install
cd ..

# Suru plus asoromauros icons
wget -qO- https://raw.githubusercontent.com/gusbemacbe/suru-plus-aspromauros/master/install.sh | sh

# Setup vim
sudo xbps-remove -R vim
sudo xbps-install vim-huge-python3 python3-devel gcc cmake mono go nodejs openjdk11
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
cd ~/.vim/bundle/YouCompleteMe
python3 install.py --all
cp SCRIPT_DIR/home/kruayd/.vimrc ~/
vim -c 'PluginInstall' -c 'qa!'
# more info at https://dev.to/shahinsha/how-to-make-vim-a-python-ide-best-ide-for-python-23e1

# copy themes for KDE
cp -R SCRIPT_DIR/home/kruayd/.local/* ~/.local/