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
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_custom_ignore = '\v[\/](build|docs|api-doc|target|.*-env)$'

Plugin 'scrooloose/nerdcommenter'

"Plugin 'flazz/vim-colorschemes'
"Plugin 'Erichain/vim-monokai-pro'
Plugin 'rafi/awesome-vim-colorschemes'

Plugin 'chriskempson/base16-vim'
"if filereadable(expand("~/.vimrc_background"))
  "let base16colorspace=256
  "source ~/.vimrc_background
"endif

Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='powerlineish'

"Plugin 'Shougo/unite.vim'
"Plugin 'Shougo/neomru.vim'

Plugin 'her/central.vim'
set backup
set undofile
set swapfile

Plugin 'octol/vim-cpp-enhanced-highlight'
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_experimental_simple_template_highlight = 1
"let g:cpp_experimental_template_highlight = 1
"#speed#
let g:cpp_concepts_highlight = 1
let g:cpp_no_function_highlight = 1
"let c_no_curly_error=1

if 'gcca' != s:configName
  Plugin 'ycm-core/YouCompleteMe'
  let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/third_party/ycmd/.ycm_extra_conf.py'
  let g:ycm_server_python_interpreter = '/usr/bin/python3'
  let g:ycm_min_num_of_chars_for_completion = 3
  let g:ycm_max_num_candidates = 5
  let g:ycm_auto_trigger = 0
  let g:ycm_autoclose_preview_window_after_completion = 1
  let g:ycm_complete_in_comments = 1
  let g:ycm_complete_in_strings = 1
  let g:ycm_add_preview_to_completeopt = 0
  set completeopt-=preview
  nnoremap <C-y> :YcmComplete GoTo<CR>
  autocmd BufNewFile,BufRead *.cu set filetype=cpp
  autocmd BufNewFile,BufRead *.cuh set filetype=cpp
  autocmd BufNewFile,BufRead /usr/include/* set filetype=cpp
  autocmd BufNewFile,BufRead /home/gcca/src/llvm/projects/libcxx/include/* set filetype=cpp
endif

Plugin 'moll/vim-bbye'

"Plugin 'lygaret/autohighlight.vim'
"pboettch/vim-highlight-cursor-words

Plugin 'rhysd/vim-clang-format'
let g:clang_format#code_style = 'google'
let g:clang_format#command = 'clang-format'
let g:clang_format#extra_args = '-sort-includes'
autocmd FileType c,cpp,objc,java nnoremap <buffer><Leader>cf :<C-u>ClangFormat<CR>
autocmd FileType c,cpp,objc,java vnoremap <buffer><Leader>cf :ClangFormat<CR>
au BufNewFile,BufRead *.cu nnoremap <buffer><Leader>cf :<C-u>ClangFormat<CR>
au BufNewFile,BufRead *.cuh vnoremap <buffer><Leader>cf :ClangFormat<CR>
" if you install vim-operator-user
"autocmd FileType c,cpp,objc map <buffer><Leader>x <Plug>(operator-clang-format)
" Toggle auto formatting:
" nmap <Leader>C :ClangFormatAutoToggle<CR>
"autocmd FileType c ClangFormatAutoEnable
"map <F9> :YcmCompleter FixIt<CR>

"Plugin 'tpope/vim-fugitive'

"Plugin 'airblade/vim-gitgutter'

Plugin 'whatyouhide/vim-lengthmatters'

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

Plugin 'linluk/vim-c2h'

call vundle#end()
filetype plugin indent on

" --------------------------

set backspace=indent,eol,start

set number

set wildignorecase
set ignorecase
set smartcase
"set hlsearch
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
set wrap

syntax enable

set t_Co=256
let base16colorspace=256
set background=dark
colorscheme base16-monokai

if !has("gui_running")
	set termguicolors
  hi Normal guibg=NONE ctermbg=NONE
else
	set guioptions=
	set guifont=Ubuntu\ Mono\ 9
	"Monaco\ Regular\ 8
	set lines=999 columns=87 linespace=0
endif

set complete-=i
"set include=^\\s*#\\s*include\ \\(<boost/\\)\\@!

set comments=sl:/*,mb:\ *,elx:\ */

set tags+=~/.vim/tags/c++
set tags+=~/.vim/tags/gl
set tags+=~/.vim/tags/sdl
set tags+=~/.vim/tags/qt

autocmd BufWritePre * %s/\s\+$//e

inoremap <C-s> <Esc>:w!<CR>a
nnoremap <C-s> :w!<CR>

nnoremap U :redo<CR>

nnoremap <C-PageUp> :bprevious<CR>
nnoremap <C-PageDown> :bnext<CR>
nnoremap <C-q> :Bdelete<CR>

nnoremap <C-Left> :bprevious<CR>
nnoremap <C-Right> :bnext<CR>

"nmap <F2> :set et sw=2 ts=2 sts=2<CR>
"nmap <F3> :set noet sw=2 ts=2 sts=2<CR>
"imap <F2> <ESC>:w<CR>i

"map <F4> :e %:p:s,.h$,.X123X,:s,.cpp$,.h,:s,.X123X$,.cpp,<CR>

"map <F5> :!ctags -R –c++-kinds=+p –fields=+iaS –extra=+q .<CR>
"map <F6> :Dox<CR>
"map <F7> :make<CR>
"map <S-F7> :make clean all<CR>
"map <F12> <C-]>

"if &diff
  "map <M-Down> ]c
  "map <M-Up> [c
  "map <M-Left> do
  "map <M-Right> dp
  "map <F9> :new<CR>:read !svn diff<CR>:set syntax=diff buftype=nofile<CR>gg
"else
  ":setlocal spell spelllang=en
  "set spellfile=~/.vim/spellfile.add
  "map <M-Down> ]s
  "map <M-Up> [s
"endif

"augroup vimrc_autocmds
  "autocmd BufEnter * highlight OverLength ctermbg=red ctermfg=white guibg=#592929
  "autocmd BufEnter * match OverLength /\%81v.\+/
"augroup END

autocmd BufNewFile,BufRead /usr/include/* set syntax=cpp

function! CppSetSyntax()
	if expand('%:p') =~? 'libstdc++'
		set syntax=cpp
	endif
endfunction

autocmd BufNewFile,BufRead * call CppSetSyntax()

"autocmd BufNewFile,BufRead /home/gcca/lib/* set noet sw=4 ts=4 sts=4"
"autocmd BufNewFile,BufRead /home/gcca/blazingdb/Simplicity/* colorscheme base16-gruvbox-dark-hard

"set clipboard=unnamed
set clipboard=unnamedplus

autocmd Filetype python setlocal et ts=2 sts=2 sw=2
autocmd Filetype cmake setlocal et ts=2 sts=2 sw=2
autocmd Filetype cpp setlocal et ts=2 sts=2 sw=2
autocmd Filetype java setlocal et ts=2 sts=2 sw=2

autocmd FileType cuda set ft=c.cuda
autocmd FileType cuda set ft=cpp.cuda

"let g:thematic#themes = {
"\ 'bubblegum'  : { 'typeface': 'Menlo',
"\                  'font-size': 11,
"\                  'transparency': 10,
"\                  'linespace': 2,
"\                },
"\ 'pencil_dark' :{ 'colorscheme': 'pencil',
"\                  'background': 'dark',
"\                  'airline-theme': 'badwolf',
"\                  'ruler': 1,
"\                  'laststatus': 0,
"\                  'typeface': 'Source Code Pro Light',
"\                  'font-size': 11,
"\                  'transparency': 10,
"\                  'linespace': 8,
"\                },
"\ 'pencil_lite' :{ 'colorscheme': 'pencil',
"\                  'background': 'light',
"\                  'airline-theme': 'light',
"\                  'laststatus': 0,
"\                  'ruler': 1,
"\                  'typeface': 'Source Code Pro',
"\                  'fullscreen': 1,
"\                  'transparency': 0,
"\                  'font-size': 11,
"\                  'linespace': 6,
"\                },
"\ 'matrix' :{ 'colorscheme': 'base16-greenscreen',
"\             'typeface': 'Dotrice Condensed',
"\             'font-size': '16',
"\           },
"\ }

"let g:thematic#theme_name = 'matrix'

function s:GZ_VSplit()
  vsplit
  vertical resize 86
endfunction

function s:GZ_HighLight()
  hi Normal guibg=NONE ctermbg=NONE
endfunction

let s:GZCommandByName = {
      \ 'VSplit': function('s:GZ_VSplit'),
      \ 'HighLight': function('s:GZ_HighLight'),
      \ }

function s:GZExecute(CommandName)
  call s:GZCommandByName[a:CommandName]()
endfunction

function s:GZSubCommandNames(ArgLead, CmdLine, CursorPos)
  return reverse(keys(s:GZCommandByName))
endfunction

command -nargs=1 -complete=customlist,s:GZSubCommandNames
      \ GZ call s:GZExecute(<f-args>)
