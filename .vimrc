"配置插件管理工具vundle
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

"补全ptyhon代码的工具
Plugin 'maralla/completor.vim'
"检查代码语法的工具
Plugin 'vim-syntastic/syntastic'
"代码风格检查
Plugin 'nvie/vim-flake8'
"给vim添加一个树形目录"
Plugin 'scrooloose/nerdtree'
"给vim添加状态栏"
Plugin 'Lokaltog/vim-powerline'
" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
"Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" Git plugin not hosted on GitHub
"Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
"Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
"Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
" Plugin 'ascenator/L9', {'name': 'newL9'}

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
"设置completor
let g:completor_python_binary = 'python' "completor好像这样才能用
"""
"关闭代码预览窗口,这样就不会在补全python的时候，提供相关函数的信息,打开这个之后有个bug（你打空格的时候就马上会有代码补全提示）
set completeopt-=preview
"syntastic推荐设置
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_python_python_exe = 'python' "自己加的
let g:syntastic_python_checkers = ['flake8'] "自己加的
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
"""""""
"设置nerdtree“
map <C-n> :NERDTreeToggle<CR> "键盘映射打开树形目录"

"""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""


set number "显示行号
set hlsearch "搜索高亮,(用/搜索时
set encoding=utf-8 "使用utf-8编码好了
syntax on"语法高亮
set tabstop=4

"设置python代码风格
au BufNewFile,BufRead *.py
\ set autoindent "自动缩进

"一键python
map <F5> :call RunPython()<CR>
func! RunPython()
	exec "W"
	if &filetype == 'python'
		exec "!python %"
	endif
endfunc
"听说这样才能用tab补全(在有completor的前提下
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr> pumvisible() ? "\<C-y>\<cr>" : "\<cr>"
