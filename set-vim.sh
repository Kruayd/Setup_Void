sudo xbps-remove -R vim
sudo xbps-install vim-huge-python3 python3-devel gcc cmake mono go nodejs openjdk11
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
cd ~/.vim/bundle/YouCompleteMe
python3 install.py --all
