#!/bin/bash


#####################################################################
#	    Whenever you see SCRIPT_DIR in this installer,	    #
#     I highly recommend to look at the files that are involved.    #
#     They, usually, are config files that works for my machine     #
#####################################################################

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"


# Modify .bashrc
# Function declaration section header
sed -i -e "/# \.bashrc/ a\\
\\
\\
# Function declaration\n" $HOME/.bashrc

# appendpath function
sed -i -e "/# Function declaration/ a\\
# appendpath function\\
appendpath () {\\
    case \":\$PATH:\" in\\
        *:\"\$1\":*)\\
            ;;\\
        *)\\
            PATH=\"\${PATH:+\$PATH:}\$1\"\\
    esac\\
}" $HOME/.bashrc

# Aliases section header
sed -i -e "/^alias/ i\\
\\
# Aliases" $HOME/.bashrc

# PS1 section header
sed -i -e "/^PS1/ i\\
\\
\\
# PS1" $HOME/.bashrc

# PATH extension section header
sed -i -e "/^# PS1/ i\\
# PATH extension\\
\\
" $HOME/.bashrc

# Unset appendpath
sed -i -e "/^# PATH/ a\\
unset appendpath" $HOME/.bashrc

# Add $HOME/.loca/bin to PATH
sed -i -e "/^# PATH/ a\\
appendpath \$HOME'/.local/bin'" $HOME/.bashrc


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
sed -i -e "/^# PATH/ a\\
# Must be at the beginning of path in order to let LaTeX work properly\\
PATH='$(pwd)/bin/x86_64-linux:'\$PATH" $HOME/.bashrc


# Change

mkdir ~/Builds
cd ~/Builds

# Breeze hacked cursor theme
sudo xbps-install xcursorgen
mkdir breeze-hacked-cursor-theme && cd breeze-hacked-cursor-theme
git clone https://github.com/codejamninja/breeze-hacked-cursor-theme.git .
make install
cd ..

# xbps-src
git clone https://github.com/void-linux/void-packages.git
cd void-packages
./xbps-src binary-bootstrap
# Enable restricted
echo XBPS_ALLOW_RESTRICTED=yes >> etc/conf
# Install Zoom
./xbps-src pkg zoom
sudo xbps-install --repository hostdir/binpkgs/nonfree zoom
cd ..

# Suru plus aspromauros icons
wget -qO- https://raw.githubusercontent.com/gusbemacbe/suru-plus-aspromauros/master/install.sh | sh

# Setup vim
sudo xbps-remove -R vim
sudo xbps-install vim-huge-python3 python3-devel gcc cmake mono go nodejs openjdk11 flake8
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
cp $SCRIPT_DIR/home/kruayd/.vimrc ~/
vim -c 'PluginInstall' -c 'qa!'
cd ~/.vim/bundle/YouCompleteMe
python3 install.py --all
# more info at https://dev.to/shahinsha/how-to-make-vim-a-python-ide-best-ide-for-python-23e1

# copy themes for KDE
cp -R $SCRIPT_DIR/home/kruayd/.local/* ~/.local/
