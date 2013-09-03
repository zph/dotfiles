" Hack for speeding up vim load when using rvm
let g:ruby_path = system('rvm current')

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
map <Space> <Leader>

" Use jk to escape
inoremap jk <ESC>

" Save marks and leaders for X files, currently 100, including Globals
set viminfo='100,f1

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
set nowrap  " Line wrapping off
" Preserve large pastes
set pastetoggle=<F2>
" For TagBar Toggle Plugin
" requires apt-get install exuberant-ctags in debian (or brew install
" ctags-exuberant for OSX or comparable
nnoremap <leader>ta :TagbarOpenAutoClose<CR>
nnoremap <leader>tg :!ctags -R .<CR>

nnoremap <leader>cl :close<CR>
set smartindent
set tabstop=2
set guioptions-=T
filetype on  " Automatically detect file types.

nnoremap <Leader>a :Ack 

nnoremap <Leader>g :GundoToggle<CR>

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
" Show $ at end of line and trailing space as ~.... disable this as
" it's distracting for screencasts
" set lcs=tab:\ \ ,eol:$,trail:~,extends:>,precedes:<
set lcs=tab:\ \ ,extends:&,precedes:<
" Courtesy of @alindeman
set listchars+=trail:💔

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
autocmd FileType ruby,eruby set omnifunc=rubycomplete#Complete
autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
autocmd FileType ruby,eruby let g:rubycomplete_rails = 1
autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1

"improve autocomplete menu color
highlight Pmenu ctermbg=238 gui=bold

" colorscheme Tomorrow-Night-Bright
colo detailed

" Hooray for integration with standard Ctrl-V -C -X etc
vmap <C-c> "+yi
vmap <C-x> "+c
vmap <C-v> c<ESC>"+p
imap <C-v> <ESC>"+pa

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
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Test functions from gary bernhardt
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! RunTestFile(...)
    if a:0
        let command_suffix = a:1
    else
        let command_suffix = ""
    endif

    " Run the tests for the previously-marked file.
    let in_test_file = match(expand("%"), '\(.feature\|_spec.rb\)$') != -1
    if in_test_file
        call SetTestFile()
    elseif !exists("t:grb_test_file")
        return
    end
    call RunTests(t:grb_test_file . command_suffix)
endfunction

function! RunNearestTest()
    let spec_line_number = line('.')
    call RunTestFile(":" . spec_line_number . " -b")
endfunction

function! SetTestFile()
    " Set the spec file that tests will be run for.
    let t:grb_test_file=@%
endfunction

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

" autocmd BufWritePost *.rb :call RunTestFile()
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

" autocmd BufWritePost *.rb :call RunTestFile()
" map <Leader>t :call RunTestFile()




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

autocmd FileType c,cpp,java,php,ruby,python autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ARROW KEYS ARE UNACCEPTABLE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""" EXPERIMENTAL
map <Left> <C-O>
map <Right> <C-I>
"""" Stable
map <Up> :echo "no!"<cr>
map <Down> :echo "no!"<cr>

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
imap <c-l> <space>->

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Clear search buffer when hitting return (also from Gary Bernhardt)
:nnoremap <CR> :nohlsearch<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  Start at last location in file
augroup vimrcEx
  " Clear all autocommand groups
  autocmd!
  autocmd FileType text setlocal textwidth=78
  autocmd FileType text set wrap linebreak nolist et
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
" map <Leader>t :w\|:RunTests<CR>

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
" Get rid of the delay when hitting esc!
set noesckeys

" command! Qall qall 
" Disable Ex mode
map Q <Nop>
" Remap Q to a useful command
command! Q q " Bind :Q to :q
nnoremap Q :q
" nnoremap Q ,

" Disable K looking stuff up ie instant manual lookups
map K <Nop>
" command! K :! 
nnoremap K :write<CR>

" When loading text files, wrap them and don't split up words.
au BufNewFile,BufRead *.txt setlocal wrap
au BufNewFile,BufRead *.txt setlocal lbr

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
imap <Leader>p <ESC>:CtrlPMixed<CR>
nmap <Leader>p :CtrlPMixed<CR>
let g:ctrlp_max_depth = 10

"" Custom CtrlP Config
" Multiple VCS's:
let g:ctrlp_extensions = ['tag', 'mark', 'register']
" let g:ctrlp_user_command = {
"   \ 'types': {
"     \ 1: ['.git', 'cd %s && git ls-files'],
"     \ 2: ['.hg', 'hg --cwd %s locate -I .'],
"     \ },
"   \ 'fallback': 'find %s -type f'
"   \ }
let g:ctrlp_user_command = {
  \ 'fallback': 'find %s -type f'
  \ }
" Sane Ignore For ctrlp
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$|\.yardoc\|public\/images\|public\/system\|data\|log\|tmp$',
  \ 'file': '\v\.(exe|so|dll)$|\.exe$\|\.so$\|\.dat$',
  \ }

"\.git\/$\|
" Avoid holding shift to hit colon
" To repeat a F or T movement double tap semicolon
" map ; :
" noremap ;; ;

" Open Marked.app
" only works on OSX with Marked.app installed
imap <Leader>m <ESC>:!open -a Marked.app "%"<CR><CR>
nmap <Leader>m :!open -a Marked.app "%"<CR><CR>

" Run current file in ruby
imap <Leader>rr <ESC>:!ruby %<CR>
nmap <Leader>rr :!ruby %<CR>

nmap <Leader>st :%s/\n/ /g<CR>
nmap <Leader>sh :%!fmt -n 100<CR>
nmap <Leader>shh <Leader>st<Leader>sh
vnoremap <Leader>sh :!fmt -n 100<CR>
nmap <Leader>sm :%!fmt -n 75<CR>
vnoremap <Leader>sm :!fmt -n 75<CR>

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

" Add the pry debug line with \bp (or <Space>bp, if you did: map <Space> <Leader> )
map <Leader>bp orequire'pry';binding.pry<esc>:w<cr>
" Alias for one-handed operation:
" map <Leader><Leader>p <Leader>bp

" Keep pry from annoyingly hanging around when using, e.g. pry-rescue/minitest
map <f3> :wa<cr>:call system('kill-pry-rescue')<cr>

" Nab lines from ~/.pry_history (respects "count")
nmap <Leader>ph :<c-u>let pc = (v:count1 ? v:count1 : 1)<cr>:read !tail -<c-r>=pc<cr> ~/.pry_history<cr>:.-<c-r>=pc-1<cr>:norm <c-r>=pc<cr>==<cr>
" ↑ thanks to Houl, ZyX-i, and paradigm of #vim for all dogpiling on this one.

" RuboCop from Anywhere
nmap <Leader>ru :RuboCop<CR>
imap <Leader>ru <ESC>:RuboCop<CR>

nmap <Leader>rua :!rubocop<CR>
imap <Leader>rua <ESC>:rubocop<CR>

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
" use _ as 2nd leader to prefixing commands
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

map <Leader>t :SweetVimRspecRunFile<CR>
" map <Leader>s :SweetVimRspecRunFocused<CR>
map <Leader>l :SweetVimRspecRunPrevious<CR>

" ZenCoding Shortcut
vmap <Leader>z <C-Y>,
nmap <Leader>z <C-Y>,
imap <Leader>z <ESC><C-Y>,a

" Tidy Html and XML
"
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

" Async Test Running courtesy of Gary Bernhardt
" must start ~/bin/run_test.sh
" map <Leader>at :w\| :silent !echo rspec spec > test-commands
"
"
map <leader>q :q
command Rake :!rake

" YCM and UltiSnips Working Together
"set runtimepath+=~/.vim/bundle/ul
" let g:UltiSnipsExpandTrigger="<S-enter>"
" unlet g:UltiSnipsJumpForwardTrigger
" unlet g:UltiSnipsJumpBackwardTrigger

" function! g:UltiSnips_Complete()
"     call UltiSnips_ExpandSnippet()
"     if g:ulti_expand_res == 0
"         if pumvisible()
"             return "\<C-n>"
"         else
"             call UltiSnips_JumpForwards()
"             if g:ulti_jump_forwards_res == 0
"                return "\<TAB>"
"             endif
"         endif
"     endif
"     return ""
" endfunction

" au BufEnter * exec "inoremap <silent> " . g:UltiSnipsExpandTrigger . " <C-R>=g:UltiSnips_Complete()<cr>"

" let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsExpandTrigger="<c-j>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"
" Disable easytags warning
let g:easytags_updatetime_warn = 0

let g:ycm_filetype_specific_completion_to_disable = { 'ruby' : 1 }
" for floobits
let g:ycm_allow_changing_updatetime = 0

" Trick for saving vim sessions
" https://ajayfromiiit.wordpress.com/2009/10/15/vim-sessions/
" ie- :mksession vim_session_name.vim and restart with- vim -S
" vim_session_name.vim
set sessionoptions=blank,buffers,curdir,folds,globals,help,localoptions,options,resize,tabpages,winsize,winpos

" Elixir
" open iex with current file compiled
" :!iex %
" command! Iex :!iex %<cr>
nnoremap <leader>e :!iex %<CR>

" So as to not conflict with multi-cursors
let g:NumberToggleTrigger="<F5>"

" HACK: to reset multi-cursor mappings to default b/c of numbertoggle
" TODO: not working
" overwriting them
"" Default mapping
" let g:multi_cursor_use_default_mapping=0
" let g:multi_cursor_next_key='<C-m>'
" let g:multi_cursor_prev_key='<C-p>'
" let g:multi_cursor_skip_key='<C-x>'
" let g:multi_cursor_quit_key='<Esc>'

" Coffeescript
nnoremap <leader>cr :w\|:CoffeeRun<cr>

" project specific vimrcs
set exrc
set secure
