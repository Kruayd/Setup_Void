"  Highlight search
set hlsearch

set nocompatible              " required
filetype off                  " required

" Set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" Let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Add all your plugins here (note older versions of Vundle
" Used Bundle instead of Plugin)

" Better folding + docstrings for folded code
Plugin 'tmhedberg/SimpylFold'

" Auto-indentation
Plugin 'vim-scripts/indentpython.vim'

" Check syntax plugin + PEP8 checking
Plugin 'vim-syntastic/syntastic'
Plugin 'nvie/vim-flake8'

" More color scheme
Plugin 'jnurmine/Zenburn'
Plugin 'altercation/vim-colors-solarized'
Plugin 'ajmwagar/vim-deus'

" File tree + use tabs + hide .pyc files
Plugin 'preservim/nerdtree'
Plugin 'jistr/vim-nerdtree-tabs'

" Search for files
Plugin 'kien/ctrlp.vim'

" Git commands integration
Plugin 'tpope/vim-fugitive'

" Powerline
Plugin 'powerline/powerline', {'rtp': 'powerline/bindings/vim/'}

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

set splitbelow
set splitright

" Split navigations
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Enable folding
set foldmethod=indent
set foldlevel=99

" Enable folding with the spacebar
nnoremap <space> za

" Better folding + docstrings for folded code
let g:SimpylFold_docstring_preview=1

" PEP 8 indentation
au BufNewFile,BufRead *.py
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set textwidth=79 |
    \ set expandtab |
    \ set autoindent |
    \ set fileformat=unix

" js, html and css indentation
au BufNewFile,BufRead *.js,*.html,*.css
    \ set tabstop=2 |
    \ set softtabstop=2 |
    \ set shiftwidth=2

" UTF-8 support
set encoding=utf-8

" Auto-Complete + close window when used and shortcut for goto definition
Bundle 'Valloric/YouCompleteMe'
let g:ycm_autoclose_preview_window_after_completion=1
map <leader>g  :YcmCompleter GoToDefinitionElseDeclaration<CR>

" Python with virtualenv support
py3 << EOF
import os
import sys
if 'VIRTUAL_ENV' in os.environ:
  project_base_dir = os.environ['VIRTUAL_ENV']
  activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
  execfile(activate_this, dict(__file__=activate_this))
EOF

" Let code look pretty + syntax highlight enable
let python_highlight_all=1
syntax on

" Colorscheme section: comment and uncomment with
" respect to your preferences

" Logic for solarized colorscheme
"if has('gui_running')
"  set background=dark
"  colorscheme solarized
"else
"  set background=dark
"  let g:solarized_termcolors=256
"  colorscheme solarized
"endif

" Logic for deus colorscheme
set t_Co=256
set termguicolors

let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

set background=dark    " Setting dark mode
colorscheme spaceman
let g:deus_termcolors=256

" Flag unecessary whitespace
highlight BadWhitespace ctermbg=red guibg=darkred
au BufRead,BufNewFile *.py,*.pyw,*.c,*.h
    \ match BadWhitespace /\s\+$/

" Switch between solarized dark and light
call togglebg#map("<F5>")

" File tree + use tabs + hide .pyc files
let NERDTreeIgnore=['\.pyc$', '\~$'] "ignore files in NERDTree

" Line numbering
set nu

" System clipboard
set clipboard=unnamed

set laststatus=2  " always display the status line

" Enable glsl highlighting:
au BufNewFile,BufRead *.frag,*.vert,*.fp,*.vp,*.glsl setf glsl
