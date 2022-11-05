if exists('g:vscode')
  " VSCode extension
  " call plug#begin()
  " call plug#end()
else
  " ordinary neovim
  call plug#begin()
  """" Fundamentals
  Plug 'tpope/vim-abolish'
  Plug 'tpope/vim-classpath'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-dispatch'
  Plug 'tpope/vim-endwise'
  Plug 'tpope/vim-eunuch'
  Plug 'tpope/vim-fireplace'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-rhubarb'
  Plug 'tpope/vim-git'
  Plug 'tpope/vim-markdown'
  Plug 'tpope/vim-obsession'
  Plug 'tpope/vim-projectionist'
  Plug 'tpope/vim-ragtag'
  Plug 'tpope/vim-repeat'
  Plug 'tpope/vim-rsi'
  Plug 'tpope/vim-scriptease'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-unimpaired'
  Plug 'tpope/vim-vinegar'
  "let g:prettier#autoformat = 0
  " autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.vue PrettierAsync
  autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.graphql,*.vue PrettierAsync
  if !has('nvim')
    Plug 'tpope/vim-sensible'
  endif

  """"" Javascript/Typescript
  Plug 'prettier/vim-prettier', { 'do': 'npm install -g' }
  Plug 'othree/yajs.vim'
  "Plug 'raichoo/purescript-vim'
  " Vim/typescript/jsx/tsx
  Plug 'cakebaker/scss-syntax.vim'
  Plug 'hail2u/vim-css3-syntax'
  Plug 'jparise/vim-graphql'
  Plug 'leafgarland/typescript-vim'
  Plug 'leafgarland/typescript-vim'
  Plug 'pangloss/vim-javascript'
  Plug 'peitalin/vim-jsx-typescript'
  Plug 'styled-components/vim-styled-components', { 'branch': 'main' }

  """"" CSS
  Plug 'ap/vim-css-color'

  """"" Display
  Plug 'bling/vim-airline'
  Plug 'bogado/file-line'
  Plug 'vim-airline/vim-airline-themes'

  """"" Controls
  Plug 'Shougo/neosnippet-snippets'
  Plug 'Shougo/neosnippet.vim'
  Plug 'Shougo/vimproc.vim', { 'do': 'make' }
  Plug 'Shougo/unite.vim'
  Plug 'Raimondi/delimitMate'
  Plug 'ctrlpvim/ctrlp.vim'
  Plug 'tmhedberg/matchit'
  Plug 'jpalardy/vim-slime'
  let g:slime_target = "tmux"
  let g:slime_paste_file = "$HOME/.slime_paste"
  Plug 'ervandew/supertab'
  Plug 'godlygeek/tabular'
  Plug 'honza/vim-snippets'
  Plug 'jeffkreeftmeijer/vim-numbertoggle'
  Plug 'kana/vim-textobj-user'
  Plug 'mattn/ctrlp-mark'
  Plug 'mattn/ctrlp-register'
  Plug 'mattn/emmet-vim'
  Plug 'mileszs/ack.vim'
  Plug 'nazo/pt.vim'

  Plug 'sjl/gundo.vim'
  Plug 'vim-scripts/AutoTag'
  Plug 'vim-scripts/ZoomWin'

  """"" Security
  " Security Patch: https://github.com/numirias/security/blob/master/doc/2019-06-04_ace-vim-neovim.md
  Plug 'zph/securemodelines'

  """"" Color
  Plug 'rking/vim-detailed'

  """"" Misc

  """"" Elixir/Erlang
  Plug 'elixir-lang/vim-elixir'
  Plug 'jimenezrick/vimerl'
  Plug 'slashmili/alchemist.vim'

  """"" Golang
  Plug 'fatih/vim-go'

  """"" Haskell/Nix
  Plug 'neovimhaskell/haskell-vim'
  let g:ale_linters = {'haskell': ['hlint', 'ghc']}
  let g:ale_haskell_ghc_options = '-fno-code -v0 -isrc'
  Plug 'LnL7/vim-nix'

  """"" Clojure/Lisp
  " Rainbow parens
  Plug 'raymond-w-ko/vim-niji'

  """"" Ruby
  " Slow startup
  "Plug 'nelstrom/vim-textobj-rubyblock'
  " Plug 'skalnik/vim-vroom'
  " Plug 't9md/vim-ruby-xmpfilter'
  " Plug 'terryma/vim-expand-region'
  " Plug 'terryma/vim-multiple-cursors'
  Plug 'vim-ruby/vim-ruby'
  " Plug 'janko-m/vim-test'
  " nmap <silent> <leader>t :TestNearest<CR>
  " nmap <silent> <leader>T :TestFile<CR>
  " nmap <silent> <leader><leader>t :TestSuite<CR>
  " nmap <silent> <leader>l :TestLast<CR>

  """"" Bash
  Plug 'Chiel92/vim-autoformat'
  noremap <F3> :Autoformat<CR>
  let g:formatterpath = [$HOME.'/bin']
  let g:formatdef_bash_strict_mode = '"bash_strict_mode"'
  let g:formatters_sh = ['bash_strict_mode']
  autocmd FileType sh,bash autocmd BufWritePre <buffer> :Autoformat



  " Experimental
  Plug 'xolox/vim-misc'
  Plug 'dag/vim-fish'
  Plug 'rhysd/vim-crystal'
  Plug 'w0rp/ale'
  " gem install sqlint
  let g:ale_linters = {
  \   'javascript': ['eslint'],
  \   'sql': ['sqlint'],
  \   'yaml': ['prettier']
  \}
  let g:ale_fixers = {
  \   '*': ['remove_trailing_lines', 'trim_whitespace'],
  \   'elixir': ['mix_format'],
  \   'javascript': ['prettier'],
  \   'sql': ['pg_format'],
  \   'yaml': ['prettier']
  \}
  let g:ale_fix_on_save = 1
  Plug 'editorconfig/editorconfig-vim'
  let g:EditorConfig_exclude_patterns = ['fugitive://.\*']
  Plug 'chase/vim-ansible-yaml'
  Plug 'ludovicchabant/vim-gutentags'
  let g:gutentags_ctags_tagfile = ".tags"
  let g:gutentags_cache_dir = "~/tmp"
  " Bug related to quick editing a single file when in large repo
  " where tag creation job continues after vim exit and appears to hang.
  " https://github.com/ludovicchabant/vim-gutentags/issues/168
  " https://github.com/ludovicchabant/vim-gutentags/issues/178
  let g:gutentags_exclude_filetypes = ['gitcommit', 'gitrebase']
  " Ptags doesn't work because it doesn't accept the --append command
  " in ctags that gutentags relies on. - 2019
  " if executable('ptags')
  "   let g:gutentags_ctags_executable = 'ptags'
  " endif

  if executable('rg')
    let g:gutentags_file_list_command = 'rg --files'
  endif

  """" Postgres
  Plug 'lifepillar/pgsql.vim'
  let g:sql_type_default = 'pgsql'
  Plug 'hashivim/vim-terraform'
  " Very slow startup
  " Plug 'fiatjaf/neuron.vim'
  " let g:path_neuron = $HOME.'/.nix-profile/bin/neuron'
  " let g:zkdir = $HOME.'/.notes'
  " let g:path_jq = '/usr/local/bin/jq'

  if has('nvim')
    Plug 'kassio/neoterm'
    tnoremap <Esc> <C-\><C-n>
    Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
  else
    Plug 'Shougo/deoplete.nvim'
    Plug 'roxma/nvim-yarp'
    Plug 'roxma/vim-hug-neovim-rpc'
    " Don't bother about checking whether Escape is being used as a means to enter
    " " a Meta-key combination, just register Escape immediately
    set noesckeys
  endif

  "Golang
  Plug 'fatih/vim-go'
  Plug 'junegunn/fzf.vim'
  Plug 'junegunn/fzf'
  Plug 'LnL7/vim-nix'

  Plug 'neoclide/coc.nvim', {'branch': 'release'}

  call plug#end()

  " if has('nvim')
  "   " Terminal mode
  "   tnoremap <Esc> <C-\><C-n>
  "   tnoremap <M-[> <Esc>
  "   tnoremap <C-v><Esc> <Esc>
  " endif

  if has('nvim')
    let g:python_host_prog = $HOME.'/.pyenv/versions/neovim2/bin/python'
    let g:python3_host_prog = $HOME.'/.pyenv/versions/neovim3/bin/python'
  endif

  let g:deoplete#enable_at_startup = 1
  """""""""""""""""""""""""""""""
  """""""""""""""""""""""""""""""
  " Credit: https://gist.github.com/jecxjo/544d4bc3db417c367e6e6caa7146a4b5
  " Keybase - saltpack
  augroup SALTPACK
    au!
    " Make sure nothing is written to ~/.viminfo
    au BufReadPre,FileReadPre *.saltpack set viminfo=
    " No other files with unencrypted info
    au BufReadPre,FileReadPre *.saltpack set noswapfile noundofile nobackup

    " Reading Files, assumes you can decrypt
    "au BufReadPost,FileReadPost *.saltpack :%!keybase decrypt 2> /dev/null
    au BufReadPost,FileReadPost *.saltpack :%!keybase decrypt 2> /dev/null

    " Writing requires users
    au BufWritePre,FileReadPre *.saltpack let usernames = input('Users: ')
    au BufWritePre,FileReadPre *.saltpack :exec "%!keybase encrypt " . usernames
    au BufWritePost,FileReadPost *.saltpack u
  augroup END
  """""""""""""""""""""""""""""""


  autocmd BufRead,BufNewFile *.go set tabstop=4 shiftwidth=4 noexpandtab softtabstop=4
  autocmd BufRead,BufNewFile *.go set lcs=tab:\ \ ,nbsp:_,extends:&,precedes:<
  " Return indent (all whitespace at start of a line), converted from
  " tabs to spaces if what = 1, or from spaces to tabs otherwise.
  " When converting to tabs, result has no redundant spaces.
  function! Indenting(indent, what, cols)
    let spccol = repeat(' ', a:cols)
    let result = substitute(a:indent, spccol, '\t', 'g')
    let result = substitute(result, ' \+\ze\t', '', 'g')
    if a:what == 1
      let result = substitute(result, '\t', spccol, 'g')
    endif
    return result
  endfunction

  " Convert whitespace used for indenting (before first non-whitespace).
  " what = 0 (convert spaces to tabs), or 1 (convert tabs to spaces).
  " cols = string with number of columns per tab, or empty to use 'tabstop'.
  " The cursor position is restored, but the cursor will be in a different
  " column when the number of characters in the indent of the line is changed.
  function! IndentConvert(line1, line2, what, cols)
    let savepos = getpos('.')
    let cols = empty(a:cols) ? &tabstop : a:cols
    execute a:line1 . ',' . a:line2 . 's/^\s\+/\=Indenting(submatch(0), a:what, cols)/e'
    call histdel('search', -1)
    call setpos('.', savepos)
  endfunction
  command! -nargs=? -range=% Space2Tab call IndentConvert(<line1>,<line2>,0,<q-args>)
  command! -nargs=? -range=% Tab2Space call IndentConvert(<line1>,<line2>,1,<q-args>)
  command! -nargs=? -range=% RetabIndent call IndentConvert(<line1>,<line2>,&et,<q-args>)
  """""""""
  "let g:syntastic_enable_ruby_checker = 0
  let g:syntastic_javascript_checkers = ['eslint']
  let g:syntastic_mode_map = { 'mode': 'active',
                              \ 'active_filetypes': ['python', 'javascript'],
                              \ 'passive_filetypes': [] }
  set statusline+=%#warningmsg#
  set statusline+=%{SyntasticStatuslineFlag()}
  set statusline+=%*

  let g:syntastic_always_populate_loc_list = 1
  let g:syntastic_auto_loc_list = 0
  let g:syntastic_check_on_open = 1
  let g:syntastic_check_on_wq = 0
  let g:syntastic_python_checkers = ['flake8', 'pyflakes', 'python']
  let g:haddock_browser="/Applications/Google Chrome.app"

  vmap v <Plug>(expand_region_expand)
  vmap <C-v> <Plug>(expand_region_shrink)
  vnoremap <silent> s //e<C-r>=&selection=='exclusive'?'+1':''<CR><CR>
      \:<C-u>call histdel('search',-1)<Bar>let @/=histget('search',-1)<CR>gv
  omap s :normal vs<CR>
  " vp doesn't replace paste buffer
  function! RestoreRegister()
    let @" = s:restore_reg
    return ''
  endfunction
  function! s:Repl()
    let s:restore_reg = @"
    return "p@=RestoreRegister()\<cr>"
  endfunction
  vmap <silent> <expr> p <sid>Repl()
  " For specclj
  " https://github.com/guns/vim-clojure-static/pull/45/files
  augroup CustomEvents
    autocmd!
    autocmd FileType clojure setlocal lispwords+=describe,it,context,around,should=,should-not,should,should-be,with
  augroup END

  " Tell Neosnippet about the other snippets
  let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets'
  " Plugin key-mappings.
  imap <C-k>     <Plug>(neosnippet_expand_or_jump)
  smap <C-k>     <Plug>(neosnippet_expand_or_jump)
  xmap <C-k>     <Plug>(neosnippet_expand_target)

  " SuperTab like snippets behavior.
  imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
  \ "\<Plug>(neosnippet_expand_or_jump)"
  \: pumvisible() ? "\<C-n>" : "\<TAB>"
  smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
  \ "\<Plug>(neosnippet_expand_or_jump)"
  \: "\<TAB>""

  "let g:ag_mapping_message=0

  set nocompatible      " We're running Vim, not Vi!
  syntax on             " Enable syntax highlighting
  filetype on           " Enable filetype detection
  filetype indent on    " Enable filetype-specific indenting
  filetype plugin on    " Enable filetype-specific plugins

  " Set Leader key
  let mapleader = ","

  "Since we mapped , as leader, let's map ',' default backwards ;
  nnoremap \ ,
  map <Space> <Leader>

  " Use jk to escape
  inoremap jk <ESC>

  " Save marks and leaders for X files, currently 100, including Globals
  set viminfo='100,f1

  " Basic standards of sanity
  set encoding=utf-8
  set t_Co=256
  set scrolloff=3
  set showmode
  set showcmd
  set hidden
  set wildmode=longest,list
  set visualbell
  set cursorline
  set ttyfast
  set backspace=indent,eol,start
  set winwidth=100
  set nowrap  " Line wrapping off
  " Preserve large pastes
  set pastetoggle=<F2>

  nnoremap <leader>cl :close<CR>
  set smartindent
  set tabstop=2
  set guioptions-=T
  filetype on  " Automatically detect file types.

  " nnoremap <Leader>g :GundoToggle<CR>

  " XML Linting
  nnoremap <Leader>xm :%!xmllint --format -<CR>

  " Quickly edit/reload the vimrc file
  nmap <silent> <Leader>ev :e $MYVIMRC<CR>
  nmap <silent> <Leader>sv :so $MYVIMRC<CR>

  " Improved history commands
  set history=1000         " remember more commands and search history
  set undolevels=1000      " use many muchos levels of undo
  set wildignore=*.swp,*.bak,*.pyc,*.class
  set title                " change the terminal's title
  set visualbell           " don't beep
  "
  " Fix forward searching
  nnoremap / /\v
  vnoremap / /\v
  set ignorecase
  set smartcase

  " set gdefault " defaults the // subs to global
  set incsearch
  set hlsearch
  nnoremap <Leader><space> :noh<cr>

  " Remap F1 to escape
  inoremap <F1> <ESC>
  nnoremap <F1> <ESC>
  vnoremap <F1> <ESC>

  " Remap Leader w to open and switch to vertical split
  nnoremap <Leader>w <C-w>v<C-w>l

  " alt+n or alt+p to navigate between entries in QuickFix
  map <silent> <m-p> :cp <cr>
  map <silent> <m-n> :cn <cr>

  " Change which file opens after executing :Rails command
  let g:rails_default_file='config/database.yml'

  """"""""""""""""
  " syntax enable
  set cf  " Enable error files & error jumping.
  " Necessary when using Vim in Tmux
  if $TMUX == ''
      set clipboard+=unnamed
  endif
  set autowrite  " Writes on make/shell commands
  set autoread
  set ruler  " Ruler on
  set nu  " Line numbers on
  " Time to wait after ESC and LEADER, 250 is awful
  set timeoutlen=700  " Time to wait after ESC (default causes an annoying)

  " Formatting (some of these are for coding in C and C++)
  set ts=2  " Tabs are 2 spaces
  set bs=2  " Backspace over everything in insert mode
  set shiftwidth=2  " Tabs under smart indent
  set nocp incsearch
  set cinoptions=:0,p0,t0
  set cinwords=if,else,while,do,for,switch,case
  set formatoptions=tcqr
  set cindent
  set autoindent
  set smarttab
  set expandtab

  set showmatch  " Show matching brackets.
  set mat=5  " Bracket blinking.
  set list

  set novisualbell  " No blinking .
  set noerrorbells  " No noise.
  set laststatus=2  " Always show status line.

  " Set font
  set guifont=Fira\ Code:Retina
  " gvim specific
  set mousehide  " Hide mouse after chars typed
  set mouse=a  " Mouse in all modes

  " Ruby autocomplete setup
  " Credit:
  " http://www.cuberick.com/2008/10/ruby-autocomplete-in-vim.html
  " autocmd FileType ruby,eruby set omnifunc=rubycomplete#Complete
  " autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
  " autocmd FileType ruby,eruby let g:rubycomplete_rails = 1
  " autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1

  "improve autocomplete menu color
  highlight Pmenu ctermbg=238 gui=bold

  " Hooray for integration with standard Ctrl-V -C -X etc
  vmap <C-c> "+yi
  vmap <C-x> "+c
  vmap <C-v> c<ESC>"+p
  imap <C-v> <ESC>"+pa

  "Statusline config
  "set statusline=%F%m%r%h%w[%L][%{&ff}]%y[%p%%][%04l,%04v]
  set statusline=%F%m%r%h%w[%L][%{&ff}]%y[%p%%][%04l,%04v]
  "              | | | | |  |   |      |  |     |    |
  "              | | | | |  |   |      |  |     |    + current
  "              | | | | |  |   |      |  |     |       column
  "              | | | | |  |   |      |  |     +-- current line
  "              | | | | |  |   |      |  +-- current % into file
  "              | | | | |  |   |      +-- current syntax in
  "              | | | | |  |   |          square brackets
  "              | | | | |  |   +-- current fileformat
  "              | | | | |  +-- number of lines
  "              | | | | +-- preview flag in square brackets
  "              | | | +-- help flag in square brackets
  "              | | +-- readonly flag in square brackets
  "              | +-- modified flag in square brackets
  "              +-- full path to file in the buffer
  " }
  "
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#branch#enabled = 0

  let g:airline#extensions#hunks#enabled = 1
  let g:airline#extensions#hunks#non_zero_only = 1
  " let g:airline_section_b = '%{airline#util#wrap(airline#extensions#hunks#get_hunks(),0)}'
  " let g:airline_section_y = '%{airline#util#wrap(airline#extensions#branch#get_head(),0)}'
  let g:airline_section_y = ''
  let g:airline_section_a = ''
  " let g:airline_section_y = '%{airline#util#wrap(airline#extensions#hunks#get_hunks(),0)}'
  let g:airline_theme = 'murmur'

  " let g:airline_section_b = '%{system("branch-name | cut -c 1-20 | tr -d "\n")}'
  "let g:airline_section_warning = '%{airline#util#wrap(airline#extensions#syntastic#get_warnings(),0)}%{airline#util#wrap(airline#extensions#whitespace#check(),0)}'
  ""
  "
  let g:airline#extensions#default#section_truncate_width = {
        \ 'a' : 20,
        \ 'b' : 10,
        \ 'x' : 60,
        \ 'y' : 88,
        \ 'z' : 45,
        \ }

  if !exists('g:airline_symbols')
    let g:airline_symbols = {}
  endif

  " unicode symbols
  let g:airline_left_sep = '»'
  let g:airline_left_sep = '▶'
  let g:airline_right_sep = '«'
  let g:airline_right_sep = '◀'
  let g:airline_symbols.linenr = '␊'
  let g:airline_symbols.linenr = '␤'
  let g:airline_symbols.linenr = '¶'
  let g:airline_symbols.branch = '⎇'
  let g:airline_symbols.paste = 'ρ'
  let g:airline_symbols.paste = 'Þ'
  let g:airline_symbols.paste = '∥'
  let g:airline_symbols.whitespace = 'Ξ'
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Always strip trailing whitespace
  " Courtesy of MarkSim: https://github.com/marksim/.dotfiles/blob/master/.vimrc#L120-L130
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
  endfun

  autocmd FileType c,cpp,java,php,ruby,python,haml,javascript autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()
  autocmd BufEnter Brewfile setlocal filetype=ruby


  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " ARROW KEYS ARE UNACCEPTABLE
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  " Old config (disable arrow keys)
  " map <Left> <nop>
  " map <Right> <nop>
  " map <Up> <nop>
  " map <Down> <nop>
  """" EXPERIMENTAL
  map <Left> :lprevious<CR>
  map <Right> :lnext<CR>
  """" Stable
  map <Up> :bnext<cr>
  map <Down> :bprevious<cr>

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " OPEN FILES IN DIRECTORY OF CURRENT FILE
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  cnoremap %% <C-R>=expand('%:h').'/'<cr>
  " map <leader>e :edit %%
  map <leader>v :view %%

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " InsertTime COMMAND
  " Insert the current time
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  command! InsertTime :normal a<c-r>=strftime('%F %H:%M:%S.0 %z')<cr>
  nnoremap <Leader>, :b#<CR>

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Maps ctrl L to hash rocket
  imap <c-h> <space>=><space>

  " Maps ctrl k to stabby lambda
  imap <c-l> <space>-><space>

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Clear search buffer when hitting return (also from Gary Bernhardt)
  :nnoremap <CR> :nohlsearch<cr>
  " Maybe borks things in location list?

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  "  Start at last location in file
  augroup vimrcEx
    " Clear all autocommand groups
    autocmd!
    autocmd FileType text setlocal textwidth=78
    autocmd FileType text set wrap linebreak nolist et
    " autocmd For markdown style
    autocmd FileType md,markdown set wrap nolist et

    " Jump to last cursor position
    autocmd BufReadPost *
      \ if line("'\"") > 0 && line("'\"") <= line('$') |
      \   exe "normal g`\"" |
      \ endif

    autocmd FileType ruby,haml,eruby,yaml,html,javascript,json,sass set ai sw=2 sts=2 et
    autocmd FileType python set sw=4 sts=4 et
  augroup END

  " make tab completion for files/buffers work like bash
  set wildmenu

  " Slime tmux settings
  let g:slime_target = "tmux"

  " Slimux settings
  let g:slimux_select_from_current_window = 1
  map <Leader>s :SlimuxREPLSendLine<CR>
  vmap <Leader>s :SlimuxREPLSendSelection<CR>
  map <Leader>d :SlimuxShellLast<CR>

  " For jumplist... since tab is clobbered
  " go back
  nnoremap g, <C-O>
  " go forward
  nnoremap g. <C-I>
  "nnoremap <C-k> <C-i>

  " Shortcut '%%' to enter PWD on commandline
  cnoremap <expr> %%  getcmdtype() == ':' ? expand('%:h').'/' : '%%'

  " Command to create non-existant directory after trying to save file as such
  " :!mkdir -p %:h
  " Save file using sudo when session started as normal user
  " :w !sudo tee % > /dev/null
  "
  " Shortcuts for vim-fugitive
  map <Leader>gs :Gstatus<CR>
  map <Leader>gc :Gcommit<CR>

  " From Ben Orenstein
  " map ZX <esc>:wq<CR>
  " Override standard VIM save and exit command (ZZ)
  " map <Leader>z <esc>:w<CR>

  set noswapfile
  " This folder is automatically created in zph's .zshrc
  set backupdir=~/tmp/vim
  set directory=~/tmp/vim " Don't clutter my dirs up with swp and tmp files
  " EXPERIMENTAL
  " Set persistent undo for vim using tempdir
  set undodir=~/tmp/vim
  set undofile

  " command! Qall qall
  " Disable Ex mode
  map Q <Nop>
  " Remap Q to a useful command
  command! Q q " Bind :Q to :q
  nnoremap Q :q

  " Disable K looking stuff up ie instant manual lookups
  map K <Nop>
  nnoremap K :r!


  " When loading text files, wrap them and don't split up words.
  au BufNewFile,BufRead *.txt setlocal wrap
  au BufNewFile,BufRead *.txt setlocal lbr

  let g:xmpfilter_cmd = "seeing_is_believing"

  " auto insert mark at appropriate spot.
  autocmd FileType ruby nmap <buffer> <F6> <Plug>(seeing_is_believing-run)
  autocmd FileType ruby xmap <buffer> <F6> <Plug>(seeing_is_believing-run)
  autocmd FileType ruby imap <buffer> <F6> <Plug>(seeing_is_believing-run)

  autocmd FileType ruby nmap <buffer> <F7> <Plug>(seeing_is_believing-mark)
  autocmd FileType ruby xmap <buffer> <F7> <Plug>(seeing_is_believing-mark)
  autocmd FileType ruby imap <buffer> <F7> <Plug>(seeing_is_believing-mark)

  autocmd FileType ruby nmap <buffer> <F8> <Plug>(seeing_is_believing-clean)
  autocmd FileType ruby xmap <buffer> <F8> <Plug>(seeing_is_believing-clean)
  autocmd FileType ruby imap <buffer> <F8> <Plug>(seeing_is_believing-clean)

  " xmpfilter compatible
  autocmd FileType ruby nmap <buffer> <F9> <Plug>(seeing_is_believing-run_-x)
  autocmd FileType ruby xmap <buffer> <F9> <Plug>(seeing_is_believing-run_-x)
  autocmd FileType ruby imap <buffer> <F9> <Plug>(seeing_is_believing-run_-x)


  " For folding
  function! FoldingOn()
    nnoremap <Space> za
    set foldmethod=indent
    autocmd FileType ruby,haml,eruby,yaml,html,javascript,sass set foldmethod=syntax et
    " Set all folds to open
    " execute "normal zR"
  endfunction

  command! FoldingOn call FoldingOn()

  " nnoremap <Leader><Leader>f :FoldingOn<CR>

  " Reminders of commands b/c of infreq. use
  " command	effect
  " zi	switch folding on or off
  " za	toggle current fold open/closed
  " zc	close current fold
  " zR	open all folds
  " zM	close all folds
  " zv	expand folds to reveal cursor

  "Tabular mappings
  "http://vimcasts.org/episodes/aligning-text-with-tabular-vim/
  " if exists(":Tabularize")
  "   nmap <Leader>a= :Tabularize /=<CR>
  "   vmap <Leader>a= :Tabularize /=<CR>
  "   nmap <Leader>a: :Tabularize /:\zs<CR>
  "   vmap <Leader>a: :Tabularize /:\zs<CR>
  " endif

  " Use leader-b for Easy Buffer Access
  "TODO : write function to open MRU instead of 'files' if pwd is ~/
  imap <Leader>b <ESC>:Buffers<CR>
  nmap <Leader>b :Buffers<CR>
  imap <Leader>h <ESC>:History<CR>
  nmap <Leader>h :History<CR>
  imap <Leader>l <ESC>:BLines<CR>
  nmap <Leader>l :BLines<CR>
  imap <Leader>L <ESC>:Lines<CR>
  nmap <Leader>L :Lines<CR>
  imap <Leader>t <ESC>:BTags<CR>
  nmap <Leader>t :BTags<CR>
  imap <Leader>T <ESC>:Tags<CR>
  nmap <Leader>T :Tags<CR>
  imap <Leader>mr <ESC>:CtrlPMRUFiles<CR>
  nmap <Leader>mr :CtrlPMRUFiles<CR>
  imap <Leader>p <ESC>:CtrlPMixed<CR>
  nmap <Leader>p :CtrlPMixed<CR>

  " imap <Leader>b <ESC>:CtrlPBuffer<CR>
  " nmap <Leader>b :CtrlPBuffer<CR>
  " imap <Leader>mr <ESC>:CtrlPMRUFiles<CR>
  " nmap <Leader>mr :CtrlPMRUFiles<CR>
  " imap <C-p> <ESC>:Unite file_rec/async<CR>
  " nmap <C-p> :Unite file_rec/async<CR>
  " nnoremap <silent> ,g :<C-u>Unite grep:. -buffer-name=search-buffer<CR>
  if executable('rg')
    let g:unite_source_grep_command = 'rg'
    let g:unite_source_grep_default_opts = '--nogroup --nocolor'
    let g:unite_source_grep_recursive_opt = ''
    let g:unite_source_grep_encoding = 'utf-8'
  endif
  imap <C-o> <ESC>:GFiles<CR>
  nmap <C-o> :GFiles<CR>
  nmap <Leader>F :Files<CR>
  let g:ctrlp_max_depth = 10

  " Custom CtrlP Config
  " Multiple VCS's:
  let g:ctrlp_extensions = ['tag', 'mark', 'register']
  let g:ctrlp_user_command = {
    \ 'types': {
      \ 1: ['.git', 'cd %s && git ls-files'],
      \ 2: ['.hg', 'hg --cwd %s locate -I .'],
      \ },
    \ 'fallback': 'find %s -type f'
    \ }
  " Sane Ignore For ctrlp
  let g:ctrlp_custom_ignore = {
    \ 'dir':  '\v[\/]\.(git|hg|svn)$|\.yardoc\|public\/images\|public\/system\|data\|log\|tmp$',
    \ 'file': '\v\.(exe|so|dll)$|\.exe$\|\.so$\|\.dat$',
    \ }
  " Avoid holding shift to hit colon
  " To repeat a F or T movement double tap semicolon
  map ; :
  noremap ;; ;

  " Open Marked.app
  " only works on OSX with Marked.app installed
  imap <Leader>m <ESC>:!open -a Marked.app "%"<CR><CR>
  nmap <Leader>m :!open -a Marked.app "%"<CR><CR>

  " Run current file in ruby
  imap <Leader>rr <ESC>:!ruby %<CR>
  nmap <Leader>rr :!ruby %<CR>

  if executable('pry')
    imap <Leader>pi <ESC>:call PryToggle()<CR>
    nmap <Leader>pi :call PryToggle()<CR>

    fu! PryToggle()
        let @a = "require 'pry'; binding.pry"
        let wordsFromLine = getline('.')
        if @a ==? wordsFromLine
          :normal dd
        else
          :normal o"ap
        endif
    endfu
    " Courtesy of rking's ruby-pry.vim
    " …also, Insert Mode as bpry<space>
    iabbr bpry require'pry';binding.pry
    " And admit that the typos happen:
    iabbr bpry require'pry';binding.pry
    " And pry-remote
    iabbr bpryr require'pry-remote';binding.pry_remote

    " Keep pry from annoyingly hanging around when using, e.g. pry-rescue/minitest
    map <f3> :wa<cr>:call system('kill-pry-rescue')<cr>

    " Nab lines from ~/.pry_history (respects "count")
    nmap <Leader>ph :<c-u>let pc = (v:count1 ? v:count1 : 1)<cr>:read !tail -<c-r>=pc<cr> ~/.pry_history<cr>:.-<c-r>=pc-1<cr>:norm <c-r>=pc<cr>==<cr>
    " ↑ thanks to Houl, ZyX-i, and paradigm of #vim for all dogpiling on this one.
  endif

  " " Ctags Shortcuts
  set tags=$HOME/.vimtags,%:p,$HOME

  " " main mapping, go to first matching tag
  map <Leader>tt <C-]>
  " move forward and back through matching tags
  map <Leader>tp :tprevious<CR>
  map <Leader>tn :tnext<CR>
  " Easytags - turn off highlighting
  autocmd FileType * let b:easytags_auto_highlight = 0
  " let b:easytags_auto_highlight = 0

  " TODO
  " use - as 2nd leader to prefixing commands
  map - <Leader><Leader>

  " Proper linewrap behavior
  "http://vimcasts.org/episodes/soft-wrapping-text/
  command! -nargs=* Wrap set wrap linebreak nolist
  " nnoremap <Leader><Leader>wr :Wrap<CR>

  " Easy Save shortcut
  map <Leader>j :write<CR>

  " Set ft=text for prose editing
  map <Leader>text :set ft=text<CR>

  " Settings for path
  """"""""""""""""""""""""""""""""""""""""""""""""""""""""
  " http://vim.wikia.com/wiki/Change_to_the_directory_of_the_current_file
  let s:default_path = escape(&path, '\ ') " store default value of 'path'

  " Always add the current file's directory to the path and tags list if not
  " already there. Add it to the beginning to speed up searches.
  autocmd BufRead *
        \ let s:tempPath=escape(escape(expand("%:p:h"), ' '), '\ ') |
        \ exec "set path-=".s:tempPath |
        \ exec "set path-=".s:default_path |
        \ exec "set path^=".s:tempPath |
        \ exec "set path^=".s:default_path

  " Filetype shortcut
  map <Leader>ft :set ft=

  " ZenCoding/Emmet Shortcut
  vmap <Leader>z <C-Y>,
  nmap <Leader>z <C-Y>,
  imap <Leader>z <ESC><C-Y>,a

  " Tidy Html and XML
  :command Thtml :%!tidy -q -i --show-errors 0
  :command Txml  :%!tidy -q -i --show-errors 0 -xml

  " Hex Vim
  " ex command for toggling hex mode - define mapping if desired
  command -bar Hexmode call ToggleHex()

  " helper function to toggle hex mode
  function ToggleHex()
    " hex mode should be considered a read-only operation
    " save values for modified and read-only for restoration later,
    " and clear the read-only flag for now
    let l:modified=&mod
    let l:oldreadonly=&readonly
    let &readonly=0
    let l:oldmodifiable=&modifiable
    let &modifiable=1
    if !exists("b:editHex") || !b:editHex
      " save old options
      let b:oldft=&ft
      let b:oldbin=&bin
      " set new options
      setlocal binary " make sure it overrides any textwidth, etc.
      let &ft="xxd"
      " set status
      let b:editHex=1
      " switch to hex editor
      %!xxd
    else
      " restore old options
      let &ft=b:oldft
      if !b:oldbin
        setlocal nobinary
      endif
      " set status
      let b:editHex=0
      " return to normal editing
      %!xxd -r
    endif
    " restore values for modified and read only state
    let &mod=l:modified
    let &readonly=l:oldreadonly
    let &modifiable=l:oldmodifiable
  endfunction

  " Hardmode
  nnoremap <leader>h <Esc>:call ToggleHardMode()<CR>

  map <leader>q :q

  " let g:UltiSnipsJumpForwardTrigger="<tab>"
  let g:UltiSnipsExpandTrigger="<c-j>"
  let g:UltiSnipsJumpForwardTrigger="<c-j>"
  let g:UltiSnipsJumpBackwardTrigger="<c-k>"
  " Disable easytags warning
  let g:easytags_updatetime_warn = 0

  " Trick for saving vim sessions
  " https://ajayfromiiit.wordpress.com/2009/10/15/vim-sessions/
  " ie- :mksession vim_session_name.vim and restart with- vim -S
  " vim_session_name.vim
  set sessionoptions=blank,buffers,curdir,folds,globals,help,localoptions,options,resize,tabpages,winsize,winpos

  " Elixir
  " open iex with current file compiled
  " :!iex %
  " command! Iex :!iex %<cr>
  nnoremap <leader>e :!elixir %<CR>
  nnoremap <leader>ee :!iex -r % -S mix<CR>

  " So as to not conflict with multi-cursors
  " let g:NumberToggleTrigger="<F5>"

  " project specific vimrcs
  " ie in root of project have a .vimrc
  set exrc
  set secure

  " Pipe request to waiting window on test-commands.sh loop
  "o:w\|:silent !echo "bundle exec m -l 92 spec/routes/routes_spec.rb" > test-commands
  ":nnoremap <leader>ra :w\|:silent !echo "bundle exec m -l 92 %" > test-commands<CR>
  "
  " Redraw screen via :redraw or C-l
  au BufRead,BufNewFile *.jar,*.war,*.ear,*.sar,*.rar set filetype=zip
  augroup gzip
    autocmd!
    autocmd BufReadPre,FileReadPre *.gz set bin
    autocmd BufReadPost,FileReadPost   *.gz '[,']!gunzip
    autocmd BufReadPost,FileReadPost   *.gz set nobin
    autocmd BufReadPost,FileReadPost   *.gz execute ":doautocmd BufReadPost " . expand("%:r")
    autocmd BufWritePost,FileWritePost *.gz !mv <afile> <afile>:r
    autocmd BufWritePost,FileWritePost *.gz !gzip <afile>:r
    autocmd FileAppendPre      *.gz !gunzip <afile>
    autocmd FileAppendPre      *.gz !mv <afile>:r <afile>
    autocmd FileAppendPost     *.gz !mv <afile> <afile>:r
    autocmd FileAppendPost     *.gz !gzip <afile>:r
  augroup END

  au BufRead,BufNewFile *.gem set filetype=gz

  " For old vim-commentary muscle memory
  xmap \\ gcc

  if executable('sack')
    function! Sack()
      let l:sack_output = substitute(join(readfile($HOME."/.sack_shortcuts"), "\n"), $HOME, "~", "g")
  ""  let l:sack_output = substitute(l:sack_output, $HOME, "~", 'g')
      let &efm='%f|%l col %c|%m'
      " :set errorformat="%f>%l:%c:%t:%n:%m"
      cexpr l:sack_output
      copen
      " Taken from Ack.vim bindings for consistency and awesomeness
      exec "nnoremap <silent> <buffer> q :ccl<CR>"
      exec "nnoremap <silent> <buffer> t <C-W><CR><C-W>T"
      exec "nnoremap <silent> <buffer> T <C-W><CR><C-W>TgT<C-W><C-W>"
      exec "nnoremap <silent> <buffer> o <CR>"
      exec "nnoremap <silent> <buffer> go <CR><C-W><C-W>"
      exec "nnoremap <silent> <buffer> h <C-W><CR><C-W>K"
      exec "nnoremap <silent> <buffer> H <C-W><CR><C-W>K<C-W>b"
      exec "nnoremap <silent> <buffer> v <C-W><CR><C-W>H<C-W>b<C-W>J<C-W>t"
      exec "nnoremap <silent> <buffer> gv <C-W><CR><C-W>H<C-W>b<C-W>J"
    endfunction
    command! Sack call Sack()
    nnoremap <Leader>sa :Sack<CR>
  endif

  " Vim resizing of splits
  " Resize windows quickly
  " reset with <c-w>=
  " http://tom-clements.com/blog/2011/12/29/vim-my-vimrc-highlights/
  " nmap <c-w>l :vertical res +20<cr>
  " nmap <c-w>h :vertical res -20<cr>
  " nmap <c-w>j :res +20<cr>
  " nmap <c-w>k :res -20<cr>
  nnoremap :vs :vsplit<cr><c-w>l
  nnoremap :hs :split<cr><c-w>j
  nnoremap :ts :tabnew<CR>
  nnoremap :tn :tabnew<CR>
  nnoremap :bd :bd<CR>
  nnoremap :X :x

  " hi CursorLine   cterm=NONE ctermbg=lightblue guibg=lightblue
  set nocursorline

  if executable('html2slim')
    function! HTMLtoSlim()
      :r system("pbpaste | html2slim")<CR>
    endfunction
    command! HTMLtoSlim call HTMLtoSlim()
  endif

  nnoremap <Leader>gg :GitGutterDisable<CR>
  " The Silver Searcher
  " http://robots.thoughtbot.com/faster-grepping-in-vim/

  if executable('ag')
    " Use ag over grep
    set grepprg=ag\ --nogroup\ --nocolor

    " Use ag for ack if present
    let g:ackprg = 'ag --vimgrep'
    " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
    let g:ctrlp_user_command = {
      \ 'fallback': 'ag %s -l --nocolor -g ""'
      \ }

    "ag is fast enough that CtrlP doesn't need to cache
    let g:ctrlp_use_caching = 0

    " Map over Ack commands to Ag commands, so I don't need to retrain muscles
    " for command in ['Ack', 'AckAdd', 'AckFromSearch', 'LAck', 'LAckAdd', 'AckFile', 'AckHelp', 'LAckHelp', 'AckWindow', 'LAckWindow']
    "   exe 'command ' . substitute(command, 'Ack', 'Ag', "") . ' ' . command
    " endfor
    " nnoremap <Leader>a :Ack!<SPACE>
    " nnoremap <Leader>aa :Ack! <cword><CR>
    nmap <Leader>a :Ag<SPACE>
    nmap <Leader>aa :Ag<SPACE><cword><SPACE><CR>
  endif

  " TODO: combine ag/rg/pt and unify on just one of them
  if executable('rg')
    let g:ackprg = 'rg --vimgrep'
    " Use rg in CtrlP for listing files. Lightning fast and respects .gitignore
  endif

  if executable('pt')
    nmap <Leader>p :Pt<SPACE>
    nmap <Leader>pp :Pt<SPACE><cword><CR>
  endif

  " Needed for editing crontab
  autocmd FileType crontab set nobackup nowritebackup

  nnoremap <Leader>ss :Switch<CR>
  "
  " " Don't bother drawing the screen while executing macros or other automated
  " or
  " " scripted processes, just draw the screen as it is when the operation
  " " completes
  set lazyredraw
  "
  " " Improve redrawing smoothness by assuming that my terminal is reasonably
  " " fast
  set ttyfast
  "
  " " Never use any kind of bell, visual or not
  " set visualbell t_vb=
  "
  " " Require less than one second between keys for mappings to work correctly
  set timeout
  set timeoutlen=1000

  " " Require less than a twentieth of a second between keys for key codes to
  " work
  " " correctly; I don't use Escape as a meta key anyway
  set ttimeout
  set ttimeoutlen=50"

  " Yank from cursor to end of line
  nnoremap Y y$

  " Insert newline
  map <leader><Enter> o<ESC>

  " Search and replace word under cursor (,*)
  nnoremap <leader>* :%s/\<<C-r><C-w>\>//gc<Left><Left><Left>

  " Strip trailing whitespace (,ss)
  function! StripWhitespace ()
      let save_cursor = getpos(".")
      let old_query = getreg('/')
      :%s/\s\+$//e
      call setpos('.', save_cursor)
      call setreg('/', old_query)
  endfunction

  command! -bang StripWhitespace call StripWhitespace()
  " noremap <leader>ss :call StripWhitespace ()<CR>

  " Join lines and restore cursor location (J)
  nnoremap J mjJ`j

  " Indent/unident block (,]) (,[)
  nnoremap <leader>] >i{<CR>
  nnoremap <leader>[ <i{<CR>

  set fcs=fold:-
  " Show $ at end of line and trailing space as ~.... disable this as
  " it's distracting for screencasts
  " set lcs=tab:\ \ ,eol:$,trail:~,extends:>,precedes:<
  set listchars=tab:›\ ,nbsp:_,extends:&,precedes:<
  set listchars+=trail:»

  nnoremap <silent> <leader>c :set nolist!<CR>

  " resize current buffer by +/- 5
  nnoremap <C-left> :vertical resize +3<cr>
  nnoremap <C-down> :resize +3<cr>
  nnoremap <C-up> :resize -3<cr>
  nnoremap <C-right> :vertical resize -3<cr>"

  " Close quickfix pane from any other pane
  nnoremap <leader>cc :cclose
  let g:gitgutter_realtime = 0
  let g:gitgutter_eager = 0
  nnoremap <leader>sh :GitGutterStageHunk<CR>
  nnoremap <leader>rh :GitGutterRevertHunk<CR>
  nnoremap <leader>gt :GitGutterToggle<CR>

  let g:NumberToggleTrigger="<F8>"

  autocmd BufNewFile,BufRead *.es6 set ft=javascript " use this instead of vim-json
  autocmd BufNewFile,BufRead *.jsx set ft=javascript " use this instead of vim-json

  " Make those debugger statements painfully obvious
  au BufEnter,BufWritePost *.rb syn match error contained "\<binding.pry\>"
  au BufEnter,BufWritePost *.rb syn match error contained "\<debugger\>"
  au BufEnter,BufWritePost *.coffee syn match error contained "console.log"
  au BufEnter,BufWritePost *.js syn match error contained "console.log"
  au BufEnter,BufWritePost *.coffee syn match error contained "console.log"

  nnoremap <leader>l :silent! \| :redraw!<cr>
  nnoremap <leader>v :!bundle exec approvals verify -d vimdiff -a<cr>
  nnoremap <silent> <C-W>z :wincmd z<Bar>cclose<Bar>lclose<CR>
  nnoremap <leader>n :NERDTreeToggle<CR>
  set colorcolumn=81
  nnoremap <leader>fm :silent :!gofmt -w %<cr>

  nnoremap :qq :qa!<CR>

  " Don't try to highlight lines longer than 800 characters. Prevent horrible
  " slowness
  set synmaxcol=400

  " Highlight VCS conflict markers
  match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'
  " colorscheme Tomorrow-Night-Bright
  colo detailed

  " Create Parent Directories
  "-----------------------------------------------------------------------------
  " Create directories if the parent directory for a
  " file doesn't exist.
  " from: http://stackoverflow.com/a/4294176/108857
  function! s:MkNonExDir(file, buf)
    if empty(getbufvar(a:buf, '&buftype')) && a:file!~#'\v^\w+\:\/'
      let dir=fnamemodify(a:file, ':h')
      if !isdirectory(dir)
        call mkdir(dir, 'p')
      endif
    endif
  endfunction

  augroup BWCCreateDir
    autocmd!
    autocmd BufWritePre * :call s:MkNonExDir(expand('<afile>'), +expand('<abuf>'))
  augroup END

  " " Extra vimrcs with direnv
  " if exists("$EXTRA_VIM")
  "   for path in split($EXTRA_VIM, ':')
  "     exec "source ".path
  "   endfor
  " endif

  " Fireplace.vim
  nnoremap <leader>e :%Eval<CR>

  " Typo fixes thanks @joshfrench
  command! -bang -nargs=* -complete=file E e<bang> <args>
  command! -bang -nargs=* -complete=file W w<bang> <args>
  command! -bang -nargs=* -complete=file Wq wq<bang> <args>
  command! -bang -nargs=* -complete=file WQ wq<bang> <args>
  command! -bang Wa wa<bang>
  command! -bang WA wa<bang>

  set diffopt=vertical

  " command! -bang AGopen call AGopen()

  "set verbosefile=~/.vimdebugging.log
  "set verbose=15
  "

  """""""""""""""""""""""""""""""
  """""" Ansible Vault """"""""""
  au BufNewFile,BufRead *.vault*,*.vault* call s:DetectAnsibleVault()

  fun! s:DetectAnsibleVault()
      let n=1
      while n<10 && n < line("$")
          if getline(n) =~ 'ANSIBLE_VAULT'
              set filetype=ansible-vault
          endif
          let n = n + 1
      endwhile
  endfun

  augroup ansible-vault
    " We don't want a various options which write unencrypted data to disk
    autocmd FileType ansible-vault set noswapfile noundofile nobackup
    autocmd FileType ansible-vault silent !ansible-vault decrypt %
    autocmd FileType ansible-vault autocmd BufWritePre,FileWritePre * silent !ansible-vault encrypt %
  augroup END

  nnoremap <Leader>f :PrettierAsync<CR>
endif
