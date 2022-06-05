
" https://missing.csail.mit.edu/2020/editors/
" https://github.com/anishathalye/dotfiles/blob/master/vimrc#L84
" https://github.com/JJGO/dotfiles/blob/master/vim/.vimrc#L26
" https://github.com/JJGO/dotfiles/blob/master/vim/.vimrc#L26

" =============================================================================
"   PLUGINS
" =============================================================================
call plug#begin()

Plug 'scrooloose/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'Yggdroot/indentLine'
Plug 'majutsushi/tagbar'

Plug 'ryanoasis/vim-devicons'
    
"comments
Plug 'tpope/vim-commentary'

" Search
Plug 'romainl/vim-cool'               " Disables highlight when search is done

Plug 'haya14busa/incsearch.vim'       " Better incremental search

" todo learn fzf 
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'xuyuanp/nerdtree-git-plugin'    " Show status of files in NerdTree

" bottom bar 
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Syntactic language support
"Plug 'w0rp/ale'                        " Linting engine
"Plug 'maximbaz/lightline-ale'          " Lightline + Ale
Plug 'dense-analysis/ale'

" c , c ++ :
Plug 'vim-scripts/c.vim', {'for': ['c', 'cpp']}
Plug 'rhysd/vim-clang-format'

" Colorschemes
" Previously used : onehalf , ayu-vim , gruvbox, vim-one, molokai 
Plug 'sainnhe/edge'

"no need 
" Plug 'neoclide/coc.nvim', {'branch': 'release'}
    
call plug#end()



" =============================================================================
"   TWEAKS
" =============================================================================

" using default 
"let mapleader = "`"

set encoding=UTF-8

" " if hidden is not set, TextEdit might fail.
" set hidden " Some servers have issues with backup files, see #649 set nobackup set nowritebackup 
" " Better display for messages set cmdheight=2 " You will have bad experience for diagnostic messages when it's default 4000.
" set updatetime=300

" don't give |ins-completion-menu| messages.
set shortmess+=c

" always show signcolumns
set signcolumn=yes

" session management
let g:session_directory = "~/.vim/session"
let g:session_autoload = "yes"
let g:session_autosave = "yes"
let g:session_command_aliases = 1

" =============================================================================
"   KEY BINDINGS
" =============================================================================

" tagbae
nmap <F8> :TagbarToggle<CR>


" nerdtree
nnoremap <Leader>n :NERDTreeToggle<CR>


" Neat X clipboard integration
" ,p will paste clipboard into buffer
" ,c will copy entire buffer into clipboard
noremap <leader>p :read !xsel --clipboard --output<cr>
noremap <leader>c :w !xsel -ib<cr><cr>


 "Open new file adjacent to current file
nnoremap <leader>e :e <C-R>=expand("%:p:h") . "/" <CR>

"" Tabs
" nnoremap <silent> <S-t> :tabnew<CR>
" nnoremap th  :tabfirst<CR>
" nnoremap tj  :tabnext<CR>
" nnoremap tk  :tabprev<CR>
" nnoremap tl  :tablast<CR>
" nnoremap tt  :tabedit<Space>
" nnoremap tm  :tabm<Space>
" nnoremap td  :tabclose<CR>

cnoremap <C-P> <C-R>=expand("%:p:h") . "/" <CR>
nnoremap <silent> <leader>b :Buffers<CR>
nnoremap <silent> <leader>e :FZF -m<CR>
"Recovery commands from history through FZF
nmap <leader>y :History:<CR>

"" Clean search (highlight)
" nnoremap <silent> <leader><space> :noh<cr>


"" Spaces 
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set tabstop=4       " number of visual spaces per TAB
set softtabstop=4   " number of spaces in tab when editing
set shiftwidth=4    " Insert 4 spaces on a tab
set expandtab       " tabs are spaces, mainly because of python

" UI Config
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set number              " show line numbers
set relativenumber      " show relative numbering
set showcmd             " show command in bottom bar
set cursorline          " highlight current line
filetype indent on      " load filetype-specific indent files
filetype plugin on      " load filetype specific plugin files
set wildmenu            " visual autocomplete for command menu
set showmatch           " highlight matching [{()}]
set laststatus=2        " Show the status line at the bottom
set mouse+=a            " A necessary evil, mouse support
set noerrorbells visualbell t_vb=    "Disable annoying error noises
" set splitbelow          " Open new vertical split bottom
set splitright          " Open new horizontal splits right
set linebreak           " Have lines wrap instead of continue off-screen
set scrolloff=12        " Keep cursor in approximately the middle of the screen
" set updatetime=100      " Some plugins require fast updatetime
set ttyfast             " Improve redrawing

" Buffers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set hidden              " Allows having hidden buffers (not displayed in any window)


" Sensible stuff
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" The backspace key has slightly unintuitive behavior by default. For example,
" by default, you can't backspace before the insertion point set with 'i'.
" This configuration makes backspace behave more reasonably, in that you can
" backspace over anything.
set backspace=indent,eol,start



" Unbind some useless/annoying default key bindings.
map <C-a> <Nop>
map <C-x> <Nop>
nmap Q <Nop>


" Disable the default Vim startup message.
set shortmess+=I


" I can type :help on my own, thanks.
map <F1> <Esc>
imap <F1> <Esc>



"Searching
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set incsearch           " search as characters are entered
set hlsearch            " highlight matches
set ignorecase          " Ignore case in searches by default
set smartcase           " But make it case sensitive if an uppercase is entered
" turn off search highlight
vnoremap <C-h> :nohlsearch<cr>
nnoremap <C-h> :nohlsearch<cr>
" Ignore files for completion
set wildignore+=*/.git/*,*/tmp/*,*.swp




" Undo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set undofile " Maintain undo history between sessions
set undodir=~/.vim/undodir





" Folding
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set foldenable          " enable folding
set foldlevelstart=10   " open most folds by default
set foldnestmax=10      " 10 nested fold max
" space open/closes folds
nnoremap <space> za
set foldmethod=syntax   " fold based on indent level


" Movement
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" (Shift)Tab (de)indents code
vnoremap <Tab> >
vnoremap <S-Tab> <

" Capital JK move code lines/blocks up & down
" TODO improve functionality
nnoremap K :move-2<CR>==
nnoremap J :move+<CR>==
xnoremap K :move-2<CR>gv=gv
xnoremap J :move'>+<CR>gv=gv

" Search results centered please
" nnoremap <silent> n nzz
" nnoremap <silent> N Nzz
" nnoremap <silent> * *zz
" nnoremap <silent> # #zz
" nnoremap <silent> g* g*zz
" nnoremap <C-o> <C-o>zz
" nnoremap <C-i> <C-i>zz

" Very magic by default
" nnoremap ? ?\v
" nnoremap / /\v
" cnoremap %s/ %sm/

" "  - |     --  Split with leader
" nnoremap <Leader-h> :sp<CR>
" nnoremap <Leader-v> :vsp<CR>

" " movement relative to display lines
" nnoremap <silent> <Leader>d :call ToggleMovementByDisplayLines()<CR>
" function SetMovementByDisplayLines()
"     noremap <buffer> <silent> <expr> k v:count ? 'k' : 'gk'
"     noremap <buffer> <silent> <expr> j v:count ? 'j' : 'gj'
"     noremap <buffer> <silent> 0 g0
"     noremap <buffer> <silent> $ g$
" endfunction
" function ToggleMovementByDisplayLines()
"     if !exists('b:movement_by_display_lines')
"         let b:movement_by_display_lines = 0
"     endif
"     if b:movement_by_display_lines
"         let b:movement_by_display_lines = 0
"         silent! nunmap <buffer> k
"         silent! nunmap <buffer> j
"         silent! nunmap <buffer> 0
"         silent! nunmap <buffer> $
"     else
"         let b:movement_by_display_lines = 1
"         call SetMovementByDisplayLines()
"     endif
" endfunction


" Enable mouse support. You should avoid relying on this too much, but it can
" sometimes be convenient.
set mouse+=a

" Try to prevent bad habits like using the arrow keys for movement. This is
" not the only possible bad habit. For example, holding down the h/j/k/l keys
" for movement, rather than using more efficient movement commands, is also a
" bad habit. The former is enforceable through a .vimrc, while we don't know
" how to prevent the latter.
" Do this in normal mode...
nnoremap <Left>  :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up>    :echoe "Use k"<CR>
nnoremap <Down>  :echoe "Use j"<CR>
" ...and in insert mode
inoremap <Left>  <ESC>:echoe "Use h"<CR>
inoremap <Right> <ESC>:echoe "Use l"<CR>
inoremap <Up>    <ESC>:echoe "Use k"<CR>
inoremap <Down>  <ESC>:echoe "Use j"<CR>


" my additional config 

set guifont:SF\ Pro\ Display\ 15
nnoremap <C-c> :!./%:r.out
nnoremap <C-s> :!g++ -std=c++17 -Wshadow -DLOCAL -Wall  % -fsanitize=address -fsanitize=undefined -D_GLIBCXX_DEBUG -g <Enter>
" command Run execute "!g++ -std=c++17 -Wshadow -Wall  % -fsanitize=address -fsanitize=undefined -D_GLIBCXX_DEBUG -g <Enter>"
autocmd BufWritePost *.cpp :!g++ -std=c++17 -Wshadow -DLOCAL -Wall   -fsanitize=address -fsanitize=undefined -D_GLIBCXX_DEBUG -g % -o %:r.out

command Q q
command WQ wq
command W w
command Wq wq

set termguicolors
set background=light
colorscheme edge
let g:airline_theme = 'edge'
