set nocompatible

function s:GetConfigName()
  let l:configFile = $HOME . '/.vim/config'
  let l:defaultName = 'gcca'
  if filereadable(l:configFile)
    let l:config = readfile(l:configFile)
    return get(l:config, 0, l:defaultName)
  else
    return l:defaultName
  endif
endfunction

let s:configName = s:GetConfigName()

filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

Plugin 'ctrlpvim/ctrlp.vim'
let g:ctrlp_working_path_mode = '.'
let g:ctrlp_custom_ignore = '\v[\/](build|docs|api-doc|target|__pycache__|htmlcov|node_modules|.*media.*|.*\.zip|.*-env)$'

Plugin 'scrooloose/nerdcommenter'

" - - - - -
" COLORSCHEMES
" - - - - -
"Plugin 'flazz/vim-colorschemes'
"Plugin 'Erichain/vim-monokai-pro'
"Plugin 'lifepillar/vim-solarized8'
Plugin 'rafi/awesome-vim-colorschemes'
" - - - - -
let g:everforest_background = 'soft'
Plugin 'sainnhe/everforest'
" - - - - -
let g:vim_monokai_tasty_machine_tint = 1
let g:vim_monokai_tasty_italic = 1
Plugin 'patstockwell/vim-monokai-tasty'
" - - - - -
"Plugin 'chriskempson/base16-vim'
"if filereadable(expand("~/.vimrc_background"))
  "let base16colorspace=256
  "source ~/.vimrc_background
"endif
" - - - - -

"Plugin 'Shougo/unite.vim'
"Plugin 'Shougo/neomru.vim'

"Plugin 'her/central.vim'
let g:backfiles_prefix = '/dev/shm'
Plugin 'gcca/backfiles.vim'

let g:memoischema_toggle_chars = ['Ω', 'ω', 'æ']
let g:memoischema_file = "/dev/shm/schemaf"
Plugin 'gcca/memoischema.vim'

"Plugin 'octol/vim-cpp-enhanced-highlight'
"let g:cpp_class_scope_highlight = 1
"let g:cpp_member_variable_highlight = 1
"let g:cpp_class_decl_highlight = 1
"let g:cpp_experimental_simple_template_highlight = 1
""let g:cpp_experimental_template_highlight = 1
""#speed#
"let g:cpp_concepts_highlight = 1
"let g:cpp_no_function_highlight = 1
""let c_no_curly_error=1

Plugin 'ycm-core/YouCompleteMe'
let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/third_party/ycmd/.ycm_extra_conf.py'
let g:ycm_server_python_interpreter = '/invgate/insight-venv/bin/python' "'/usr/bin/python'
let g:ycm_min_num_of_chars_for_completion = 3
let g:ycm_max_num_candidates = 5
let g:ycm_auto_trigger = 0
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_complete_in_comments = 1
let g:ycm_complete_in_strings = 1
let g:ycm_add_preview_to_completeopt = 0
set completeopt-=preview
"nnoremap ˚ :YcmComplete GoTo<CR>
"autocmd BufNewFile,BufRead *.cu set filetype=cpp
"autocmd BufNewFile,BufRead *.cuh set filetype=cpp
"autocmd BufNewFile,BufRead /usr/include/* set filetype=cpp

Plugin 'moll/vim-bbye'

"Plugin 'lygaret/autohighlight.vim'
"pboettch/vim-highlight-cursor-words

"Plugin 'rhysd/vim-clang-format'
"let g:clang_format#code_style = 'LLVM'
"let g:clang_format#command = 'clang-format-16'
"let g:clang_format#extra_args = '-sort-includes'
"autocmd FileType c,cpp nnoremap <buffer><Leader>cf :<C-u>ClangFormat<CR>
"autocmd FileType c,cpp,objc,java vnoremap <buffer><Leader>cf :ClangFormat<CR>
"au BufNewFile,BufRead *.cu nnoremap <buffer><Leader>cf :<C-u>ClangFormat<CR>
"au BufNewFile,BufRead *.cuh vnoremap <buffer><Leader>cf :ClangFormat<CR>
"" ---
" if you install vim-operator-user
"autocmd FileType c,cpp,objc map <buffer><Leader>x <Plug>(operator-clang-format)
" Toggle auto formatting:
" nmap <Leader>C :ClangFormatAutoToggle<CR>
"autocmd FileType c ClangFormatAutoEnable
"map <F9> :YcmCompleter FixIt<CR>

Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'
autocmd BufWritePost * GitGutter

"Plugin 'whatyouhide/vim-lengthmatters'

Plugin 'dag/vim-fish'

"Plugin 'python-mode/python-mode'
"let g:pymode_python = 'python3'
"let g:pymode_lint_checkers = ['pylint']
""let g:pymode_lint_checkers = ['mccabe', 'pyflakes', 'pylint', 'pep8', 'pep257']
""let g:pymode_lint_ignore = 'E111,W0311'

"Plugin 'junegunn/goyo.vim'

"Plugin 'derekwyatt/vim-scala'

"Plugin 'reedes/vim-thematic'

Plugin 'vim-scripts/ScrollColors'

"Plugin 'linluk/vim-c2h'

Plugin 'preservim/nerdtree'
let g:NERDTreeWinSize=65
let g:NERDTreeIgnore = ['^node_modules$','^__pycache__$']
"let g:NERDTreeWinPos = "right"
"nnoremap <leader>n :NERDTreeFocus<CR>
"nnoremap <C-n> :NERDTree<CR>
"nnoremap <C-t> :NERDTreeToggle<CR>
"nnoremap <C-f> :NERDTreeFind<CR>
"autocmd VimEnter * NERDTree | wincmd p
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
function! s:NERDTreeAutoFind()
  autocmd BufRead * if &modifiable | NERDTreeFind | wincmd p | endif
endfunction
command NERDTreeAutoFind call s:NERDTreeAutoFind()

Plugin 'ryanoasis/vim-devicons'
set encoding=UTF-8

Plugin 'tiagofumo/vim-nerdtree-syntax-highlight'
"Plugin 'PhilRunninger/nerdtree-buffer-ops'

"used byt vim-airline
Plugin 'jmcantrell/vim-virtualenv'

"keep here
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='luna'  "'everforest' 'powerlineish'
autocmd BufDelete * call airline#extensions#tabline#buflist#invalidate()
"let g:airline#extensions#hunks#enabled = 0
"let g:airline_detect_iminsert=1

call vundle#end()
filetype plugin indent on

" --------------------------

set backspace=indent,eol,start

set number

set wildignorecase
set ignorecase
set smartcase
set hlsearch
set incsearch

set magic

set showmatch

set expandtab
set smarttab
set shiftwidth=2
set tabstop=2
set softtabstop=2

set smartindent

set ai
set si
set nowrap

syntax enable

if has("gui_running")
	set guioptions=
	set guifont=Fira\ Code\ 11
	"set lines=999 columns=87 linespace=0
	set lines=999 columns=999


  set background=light
  let g:solarized_extra_hi_groups = 1
  let g:solarized_old_cursor_style = 1
  let g:solarized_italics = 1

  hi clear
else
  "set t_Co=256
  "let base16colorspace=256
  "set background=dark
  let g:solarized_extra_hi_groups = 1
  let g:solarized_old_cursor_style = 1
  let g:solarized_italics = 1

  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

  set termguicolors
  "hi Normal guibg=NONE ctermbg=NONE
  "hi Search guibg=peru guifg=wheat
  set mouse=a
  hi clear
endif

"highlight clear LineNr
"term=underline ctermfg=247 ctermbg=254 guifg=#93a1a1 guibg=#eee8d5

set complete-=i
"set include=^\\s*#\\s*include\ \\(<boost/\\)\\@!

set comments=sl:/*,mb:\ *,elx:\ */

"set tags+=~/.vim/tags/c++
"set tags+=~/.vim/tags/gl
"set tags+=~/.vim/tags/sdl
"set tags+=~/.vim/tags/qt

autocmd BufWritePre * %s/\s\+$//e
inoremap <expr><CR> pumvisible() ? "\<C-y>" : "\<CR>"

inoremap <C-g> <Esc>:w!<CR> "a
nnoremap <C-g> :w!<CR>

nnoremap U :redo<CR>

if !empty($TMUX)
  "let g:ycm_key_invoke_completion = '˚'
  "imap ˚ <plug>(YCMComplete)
  nnoremap <C-k> :bprevious<CR>
  nnoremap <C-l> :bnext<CR>
  nnoremap <C-j> :Bwipeout<CR>
else
  "nnoremap <M-[> :bprevious<CR>
  "nnoremap <M-]> :bnext<CR>
  "nnoremap <M-\> :Bwipeout<CR>

  nnoremap « :bprevious<CR>
  nnoremap » :bnext<CR>
  nnoremap ¬ :Bwipeout<CR>
endif


"" - - - - - - -
"autocmd TextYankPost * call system("wl-copy", @")
vnoremap ø :w !wl-copy<CR><CR>
nnoremap π :r !wl-paste --no-newline<CR>
"" - - - - - - -
"xnoremap "+y y:call system("wl-copy", @")<cr>
"nnoremap "+p :let @"=substitute(system("wl-paste --no-newline"), '<C-v><C-m>', '', 'g')<cr>p
"nnoremap "*p :let @"=substitute(system("wl-paste --no-newline --primary"), '<C-v><C-m>', '', 'g')<cr>p

let g:ycm_key_invoke_completion = '<C-h>'
nnoremap <C-h> :YcmComplete GoTo<CR>

"nmap <F3> :set et sw=4 ts=4 sts=4<CR>
"nmap <F3> :set noet sw=2 ts=2 sts=2<CR>
"map <F4> :e %:p:s,.h$,.X123X,:s,.cpp$,.h,:s,.X123X$,.cpp,<CR>
"map <F5> :!ctags -R –c++-kinds=+p –fields=+iaS –extra=+q .<CR>
"autocmd BufNewFile,BufRead /usr/include/* set syntax=cpp

"function! CppSetSyntax()
	"if expand('%:p') =~? 'libstdc++'
		"set syntax=cpp
	"endif
"endfunction
"autocmd BufNewFile,BufRead * call CppSetSyntax()
"autocmd BufNewFile,BufRead /home/gcca/lib/* set noet sw=4 ts=4 sts=4"
"autocmd BufNewFile,BufRead /home/gcca/blazingdb/Simplicity/* colorscheme base16-gruvbox-dark-hard

"set clipboard=unnamed
set clipboard=unnamedplus

autocmd Filetype python setlocal et ts=4 sts=4 sw=4
autocmd Filetype cmake setlocal et ts=2 sts=2 sw=2
autocmd Filetype cpp setlocal et ts=2 sts=2 sw=2
autocmd FileType cuda set ft=c.cuda
autocmd FileType cuda set ft=cpp.cuda


function s:GZ_VSplit()
  vsplit
  vertical resize 98
endfunction

function s:GZ_HighLight()
  hi Normal guibg=NONE ctermbg=NONE
endfunction

let s:gz_cur_guifont = &guifont

function! s:GZ_InFontSize()
  let l:fs = substitute(&guifont, '^.* \(\d\+\)$', '\1', '')
  let l:gs = l:fs + 1
  let l:guifont = substitute(&guifont, l:fs, l:gs, '')
  let &guifont = l:guifont
endfunction

function! s:GZ_DeFontSize()
  let l:fs = substitute(&guifont, '^.* \(\d\+\)$', '\1', '')
  let l:gs = l:fs - 1
  let l:guifont = substitute(&guifont, l:fs, l:gs, '')
  let &guifont = l:guifont
endfunction

function! s:GZ_ReFontSize()
  let &guifont = s:gz_cur_guifont
endfunction

function! s:GZ_FontSize(gs)
  let l:fs = substitute(&guifont, '^.* \(\d\+\)$', '\1', '')
  let l:guifont = substitute(&guifont, l:fs, a:gs, '')
  let &guifont = l:guifont
endfunction

function! s:GZ_VSize(n)
  vertical resize str2nr(a:n)
endfunctio

let s:GZCommandByName = {
      \ 'VSize': function('s:GZ_VSize'),
      \ 'VSplit': function('s:GZ_VSplit'),
      \ 'HighLight': function('s:GZ_HighLight'),
      \ 'InFontSize': function('s:GZ_InFontSize'),
      \ 'DeFontSize': function('s:GZ_DeFontSize'),
      \ 'ReFontSize': function('s:GZ_ReFontSize'),
      \ 'FontSize': function('s:GZ_FontSize'),
      \ }

function s:GZExecute(nme, ...)
  call call(s:GZCommandByName[a:nme], a:000)
endfunction

function s:GZSubCommandNames(ArgLead, CmdLine, CursorPos)
  return reverse(keys(s:GZCommandByName))
endfunction

command -nargs=* -complete=customlist,s:GZSubCommandNames GZ call s:GZExecute(<f-args>)

"sp
"res 49
"vs
"vert res 151
