call pathogen#infect()

call pathogen#helptags()
set nocompatible      " We're running Vim, not Vi!
syntax on             " Enable syntax highlighting
filetype on           " Enable filetype detection
filetype indent on    " Enable filetype-specific indenting
filetype plugin on    " Enable filetype-specific plugins

" Set Leader key
let mapleader = ","

" Since we mapped , as leader, let's map ',' default backwards ;
nnoremap \ ,

" Use jk to escape
inoremap jk <ESC>

" Basic standards of sanity
set encoding=utf-8
set scrolloff=3
set showmode
set showcmd
set hidden
set wildmode=longest,list
set visualbell
set cursorline
set ttyfast
set backspace=indent,eol,start
set winwidth=80
" Preserve large pastes 
set pastetoggle=<F2>
"set relativenumber
" For TagBar Toggle Plugin
" requires apt-get install exuberant-ctags in debian (or brew install
" ctags-exuberant for OSX or comparable
nnoremap <leader>c :TagbarOpenAutoClose<CR>
" close
nnoremap <leader>cl :close<CR>
" Buffer hotkey
" nnoremap <Leader>b :buffer 
set smartindent
set tabstop=2
set guioptions-=T
filetype on  " Automatically detect file types.

" Minibuffer Explorer Settings
" let g:miniBufExplMapWindowNavVim    = 1
" let g:miniBufExplMapWindowNavArrows = 1
" let g:miniBufExplMapCTabSwitchBufs  = 1
" let g:miniBufExplModSelTarget       = 1

" Use control and hjkl to move between splits
" nnoremap <C-h> <C-w>h
" nnoremap <C-j> <C-w>j
" nnoremap <C-k> <C-w>k
" nnoremap <C-l> <C-w>l

" Leader a for ack
nnoremap <Leader>a :Ack 

" Leader g for GundoToggle
nnoremap <Leader>g :GundoToggle<CR>

" XML Linting
nnoremap <Leader>x :%!xmllint --format -<CR>

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
" nnoremap <tab> %
" vnoremap <tab> %

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
set clipboard+=unnamed  " Yanks go on clipboard instead.
set autowrite  " Writes on make/shell commands
set ruler  " Ruler on
set nu  " Line numbers on
set timeoutlen=250  " Time to wait after ESC (default causes an annoying)

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

" Visual

set showmatch  " Show matching brackets.
set mat=5  " Bracket blinking.
set list
" Show $ at end of line and trailing space as ~.... disable this as
" it's distracting for screencasts
" set lcs=tab:\ \ ,eol:$,trail:~,extends:>,precedes:<
set lcs=tab:\ \ ,trail:~,extends:&,precedes:<
set novisualbell  " No blinking .
set noerrorbells  " No noise.
set laststatus=2  " Always show status line.

" Set font
set guifont=Source\ Code\ Pro:h13
" gvim specific
set mousehide  " Hide mouse after chars typed
set mouse=a  " Mouse in all modes

" Ruby autocomplete setup
" Credit:
" http://www.cuberick.com/2008/10/ruby-autocomplete-in-vim.html
" ruby
autocmd FileType ruby,eruby set omnifunc=rubycomplete#Complete
autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
autocmd FileType ruby,eruby let g:rubycomplete_rails = 1
autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" For Vimux : hack to make it work with vim and ruby 1.9.2
" ruby << EOF
" class Object
"   def flush; end unless Object.new.respond_to?(:flush)
" end
" EOF
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"improve autocomplete menu color
highlight Pmenu ctermbg=238 gui=bold

"colorscheme slate " Uncomment this to set a default theme
colorscheme Tomorrow-Night-Bright

" Hooray for integration with standard Ctrl-V -C -X etc
vmap <C-c> "+yi
vmap <C-x> "+c
vmap <C-v> c<ESC>"+p
imap <C-v> <ESC>"+pa

" Configuration for Vimrepress (wordpress via vim)
" let g:vimrepress_tags_completable = 'true'

"Statusline config
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
     "              | +-- rodified flag in square brackets
     "              +-- full path to file in the buffer
 " }
 "
" Taken from Gary Bernhardt's Dotfiles on github
function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'), 'file')
    if new_name != '' && new_name != old_name
        exec ':saveas ' . new_name
        exec ':silent !rm ' . old_name
        redraw!
    endif
endfunction
" map <leader>n :call RenameFile()<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ARROW KEYS ARE UNACCEPTABLE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <Left> :echo "no!"<cr>
map <Right> :echo "no!"<cr>
map <Up> :echo "no!"<cr>
map <Down> :echo "no!"<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OPEN FILES IN DIRECTORY OF CURRENT FILE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
cnoremap %% <C-R>=expand('%:h').'/'<cr>
map <leader>e :edit %%
map <leader>v :view %%

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" InsertTime COMMAND
" Insert the current time
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
command! InsertTime :normal a<c-r>=strftime('%F %H:%M:%S.0 %z')<cr>
nnoremap <Leader>, :b#<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maps ctrl L to hash rocket
imap <c-l> <space>=><space>

" Maps ctrl k to stabby lambda
imap <c-k> <space>->

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Clear search buffer when hitting return (also from Gary Bernhardt)
:nnoremap <CR> :nohlsearch<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  Start at last location in file
augroup vimrcEx
  " Clear all autocommand groups
  autocmd!
  " autocmd FileType text setlocal textwidth=78
  " autocmd FileType text set wrap linebreak nolist et
  " autocmd For markdown style
  " autocmd FileType md,markdown set wrap nolist et

  " Jump to last cursor position
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line('$') |
    \   exe "normal g`\"" |
    \ endif

  autocmd FileType ruby,haml,eruby,yaml,html,javascript,sass set ai sw=2 sts=2 et
  autocmd FileType python set sw=4 sts=4 et
augroup END

" make tab completion for files/buffers work like bash 
set wildmenu

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Promote Variable to Rspec Let
function! PromoteToLet()
  :normal! dd
  :normal! P
  :.s/\(\w\+\) = \(.*\)$/let(:\1) { \2 }/
  :normal ==
endfunction
:command! PromoteToLet :call PromoteToLet()
:map <Leader>u :PromoteToLet<CR>
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" SWITCH BETWEEN TEST AND PRODUCTION CODE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" function! OpenTestAlternate()
"   let new_file = AlternateForCurrentFile()
"   exec ':e ' . new_file
" endfunction
" function! AlternateForCurrentFile()
"   let current_file = expand("%")
"   let new_file = current_file
"   let in_spec = match(current_file, '^spec/') != -1
"   let going_to_spec = !in_spec
"   let in_app = match(current_file, '\<controllers\>') != -1 || match(current_file, '\<models\>') != -1 || match(current_file, '\<views\>') != -1
"   let in_lib = match(current_file, '\<lib\>') != -1
"   if going_to_spec
"     if in_app
"       let new_file = substitute(new_file, '^app/', '', '')
"     end
"     if in_lib
"       let new_file = substitute(new_file, '^lib/', '', '')
"     end
"     let new_file = substitute(new_file, '\.rb$', '_spec.rb', '')
"     let new_file = 'spec/' . new_file
"   else
"     let new_file = substitute(new_file, '_spec\.rb$', '.rb', '')
"     let new_file = substitute(new_file, '^spec/', '', '')
"     if in_app
"       let new_file = 'app/' . new_file
"     end
"     if in_lib
"       let new_file = 'lib/' . new_file
"     end

"   endif
"   return new_file
" endfunction
" nnoremap <leader>. :call OpenTestAlternate()<cr>
""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" RUNNING TESTS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" map <leader>t :call RunTestFile()<cr>
" map <leader>T :call RunNearestTest()<cr>
" " map <leader>a :call RunTests('')<cr>
" map <leader>c :w\|:!script/features<cr>
" map <leader>w :w\|:!script/features --profile wip<cr>

" function! RunTestFile(...)
"     if a:0
"         let command_suffix = a:1
"     else
"         let command_suffix = ""
"     endif

"     " Run the tests for the previously-marked file.
"     let in_test_file = match(expand("%"), '\(.feature\|_spec.rb\)$') != -1
"     if in_test_file
"         call SetTestFile()
"     elseif !exists("t:grb_test_file")
"         return
"     end
"     call RunTests(t:grb_test_file . command_suffix)
" endfunction

" function! RunNearestTest()
"     let spec_line_number = line('.')
"     call RunTestFile(":" . spec_line_number . " -b")
" endfunction

" function! SetTestFile()
"     " Set the spec file that tests will be run for.
"     let t:grb_test_file=@%
" endfunction

function! RunTests(filename)
    " Write the file and run tests for the given filename
    :w
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    if match(a:filename, '\.feature$') != -1
        exec ":!script/features " . a:filename
    else
        if filereadable("script/test")
            exec ":!script/test " . a:filename
        elseif filereadable("Gemfile")
            exec ":!bundle exec rspec --color " . a:filename
        else
            exec ":!rspec --color " . a:filename
        end
    end
endfunction

command! RunTests call RunTests(expand("%"))
map <Leader>t :w\|:RunTests<CR>


" Set path for gf to include rubygems folder based on GEM_HOME of RVM
" set path+=include;$GEM_HOME

" :command! -complete=file -nargs=1 Rpdf :r !pdftotext -nopgbrk <q-args> -
" :command! -complete=file -nargs=1 Rpdf :r !pdftotext -nopgbrk <q-args> - |fmt -csw78

" Slime tmux settings
let g:slime_target = "tmux"

" Slimux settings
map <Leader>s :SlimuxREPLSendLine<CR>
vmap <Leader>s :SlimuxREPLSendSelection<CR>
map <Leader>d :SlimuxShellLast<CR>

" For jumplist... since tab is clobbered
" go back
nnoremap g, <C-O>
" go forward
nnoremap g. <C-I>
nnoremap <C-k> <C-i>

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
" remap CTRL-S as save
" Allows aving with C-s or C-S
" Changed from C-s to C-something else because OSX eats my C-s
" map <C-j> <esc>:w<CR>
" imap <C-J> <esc>:w<CR>
map ZX <esc>:wq<CR>
" Override standard VIM save and exit command (ZZ)
map ZZ <esc>:w<CR>

" Tell Vim not to create swp files"
set nobackup
set noswapfile
" This folder is automatically created in zph's .zshrc
set backupdir=~/tmp/vim
set directory=~/tmp/vim " Don't clutter my dirs up with swp and tmp files
" EXPERIMENTAL
" Set persistent undo for vim using tempdir
set undodir=~/tmp/vim
set undofile
" Get rid of the delay when hitting esc!
set noesckeys

" command! Qall qall 
" Disable Ex mode
map Q <Nop>
" Remap Q to a useful command
command! Q q " Bind :Q to :q
nnoremap Q :q

" Disable K looking stuff up ie instant manual lookups
map K <Nop>
command! K :! 
nnoremap K :! 

" When loading text files, wrap them and don't split up words.
" au BufNewFile,BufRead *.txt setlocal wrap 
" au BufNewFile,BufRead *.txt setlocal lbr
au BufNewFile,BufRead *.snip set syntax=snippet ft=snippet foldmethod=indent
au BufNewFile,BufRead *.snippet set syntax=snippet ft=snippet foldmethod=indent

" for ruby omnicomplete and supertab combo
" let g:SuperTabDefaultCompletionType = "<C-X><C-O>"
" Ultisnip sane tab behavior
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

function! IncludeRCodeTools()
  " For rcodetools
  " plain annotations
  map <silent> <F10> !xmpfilter -a<cr>
  nmap <silent> <F10> V<F10>
  imap <silent> <F10> <ESC><F10>a

  " Test::Unit assertions; use -s to generate RSpec expectations instead
  map <silent> <S-F10> !xmpfilter -u<cr>
  nmap <silent> <S-F10> V<S-F10>
  imap <silent> <S-F10> <ESC><S-F10>a

  " Annotate the full buffer
  " I actually prefer ggVG to %; it's a sort of poor man's visual bell 
  nmap <silent> <F11> mzggVG!xmpfilter -a<cr>'z
  imap <silent> <F11> <ESC><F11>

  " assertions
  nmap <silent> <S-F11> mzggVG!xmpfilter -u<cr>'z
  imap <silent> <S-F11> <ESC><S-F11>a

  " Add # => markers
  vmap <silent> <F12> !xmpfilter -m<cr>
  nmap <silent> <F12> V<F12>
  imap <silent> <F12> <ESC><F12>a

  " Remove # => markers
  vmap <silent> <S-F12> ms:call RemoveRubyEval()<CR>
  nmap <silent> <S-F12> V<S-F12>
  imap <silent> <S-F12> <ESC><S-F12>a


  function! RemoveRubyEval() range
    let begv = a:firstline
    let endv = a:lastline
    normal Hmt
    set lz
    execute ":" . begv . "," . endv . 's/\s*# \(=>\|!!\).*$//e'
    normal 'tzt`s
    set nolz
    redraw
  endfunction
endfunction

command! IncludeRCodeTools call IncludeRCodeTools()
" execute ":IncludeRCodeTools"
autocmd FileType ruby,haml,eruby,yaml,html,javascript,sass execute ":IncludeRCodeTools"

" Shortcuts for VimRepress
nnoremap <silent> <Leader>bl  :BlogList<CR>
nnoremap <silent> <Leader>bn  :BlogNew<CR>
nnoremap <silent> <Leader>bsp :BlogSave publish<CR>

" Sweet-rspec
" map <D-r> :SweetVimRspecRunFile<CR> " (CMD-r)  or (Apple-r)
" map <D-R> :SweetVimRspecRunFocused<CR> "(SHIFT-CMD-r) 
" map <M-D-r> :SweetVimRspecRunPrevious<CR> "(OPT-CMD-r)
" highlight RSpecFailed guibg=#671d1a
" highlight RSpecPending guibg=#54521a

" For folding
function! FoldingOn()
  nnoremap <Space> za
  set foldmethod=indent
  autocmd FileType ruby,haml,eruby,yaml,html,javascript,sass set foldmethod=syntax et
  " Set all folds to open
  " execute "normal zR"
endfunction

command! FoldingOn call FoldingOn()

set nowrap  " Line wrapping off
" 
" Reminders of commands b/c of infreq. use
" command	effect
" zi	switch folding on or off
" za	toggle current fold open/closed
" zc	close current fold
" zR	open all folds
" zM	close all folds
" zv	expand folds to reveal cursor

" How to redirect output from shell into vim below current line
" :r !COMMAND_GOES_HERE

" Command for soft wrap
" :set wrap linebreak textwidth=0

" Remap ; to : to save shifting
" nnoremap ; :

" if has("autocmd")
"   autocmd bufwritepost .vimrc source $MYVIMRC
" endif

"Tabular mappings
"http://vimcasts.org/episodes/aligning-text-with-tabular-vim/
" if exists(":Tabularize")
  nmap <Leader>a= :Tabularize /=<CR>
  vmap <Leader>a= :Tabularize /=<CR>
  nmap <Leader>a: :Tabularize /:\zs<CR>
  vmap <Leader>a: :Tabularize /:\zs<CR>
" endif

" Use leader-b for Easy Buffer Access
"TODO : write function to open MRU instead of 'files' if pwd is ~/
imap <Leader>b <ESC>:CtrlPBuffer<CR>
nmap <Leader>b :CtrlPBuffer<CR>
imap <Leader>mr <ESC>:CtrlPMRUFiles<CR>
nmap <Leader>mr :CtrlPMRUFiles<CR>
let g:ctrlp_max_depth = 20

"" Custom CtrlP Config
" Multiple VCS's:
let g:ctrlp_extensions = ['tag']
" let g:ctrlp_user_command = {
"   \ 'types': {
"     \ 1: ['.git', 'cd %s && git ls-files'],
"     \ 2: ['.hg', 'hg --cwd %s locate -I .'],
"     \ },
"   \ 'fallback': 'find %s -type f'
"   \ }
" Sane Ignore For ctrlp
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\.git$\|\.hg$\|\.svn$\|\.yardoc\|public\/images\|public\/system\|data\|log\|tmp$',
  \ 'file': '\.exe$\|\.so$\|\.dat$'
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

nmap <Leader>st :%s/\n//g<CR>
nmap <Leader>sh :%!fmt -n 100<CR>
vnoremap <Leader>sh :!fmt -n 100<CR>

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

" Add the pry debug line with \bp (or <Space>bp, if you did: map <Space> <Leader> )
map <Leader>bp orequire'pry';binding.pry<esc>:w<cr>
" Alias for one-handed operation:
map <Leader><Leader>p <Leader>bp

" Keep pry from annoyingly hanging around when using, e.g. pry-rescue/minitest
map <f3> :wa<cr>:call system('kill-pry-rescue')<cr>

" Nab lines from ~/.pry_history (respects "count")
nmap <Leader>ph :<c-u>let pc = (v:count1 ? v:count1 : 1)<cr>:read !tail -<c-r>=pc<cr> ~/.pry_history<cr>:.-<c-r>=pc-1<cr>:norm <c-r>=pc<cr>==<cr>
" ↑ thanks to Houl, ZyX-i, and paradigm of #vim for all dogpiling on this one.
