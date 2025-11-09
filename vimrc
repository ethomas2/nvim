set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
set nohlsearch
set inccommand=nosplit


set rtp+=~/.fzf
" set rtp+=~/.vim/bundle/vim-colors-solarized

" let g:solarized_termtrans = 1
" let g:solarized_bold = 1
" let g:solarized_termcolors = 256
" set background=dark
" colorscheme solarized


if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
 autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
"
" " " Language/IDE like things
" " Plug 'https://github.com/dense-analysis/ale' " REally slow on mac
"
" " Coloring/syntax highlighting
" Plug 'https://github.com/vim-python/python-syntax'
" let g:python_highlight_all = 1
" Plug 'https://github.com/lifepillar/pgsql.vim'
" let g:sql_type_default = 'pgsql'
" Plug 'https://github.com/hashivim/vim-terraform'
" let g:terraform_fmt_on_save=1
"
"
" " Verbs
" Plug 'tpope/vim-surround'
" Plug 'https://github.com/tpope/vim-commentary'
" Plug 'https://github.com/tommcdo/vim-lion'
" Plug 'https://github.com/machakann/vim-swap'
"
" " Text objects
" Plug 'https://github.com/kana/vim-textobj-entire'
" Plug 'https://github.com/ethomas2/vim-indent-object', {
"   \ 'branch': 'fix-bug',
"   \ }
" Plug 'https://github.com/kana/vim-textobj-user'
" Plug 'https://github.com/glts/vim-textobj-comment'
" Plug 'https://github.com/wellle/targets.vim'
" Plug 'https://github.com/coderifous/textobj-word-column.vim'
"
" " Other
" " Plug 'https://github.com/jackMort/ChatGPT.nvim'
" Plug 'https://github.com/jgdavey/tslime.vim'
" Plug 'https://github.com/tpope/vim-dispatch'
" Plug 'https://github.com/jceb/vim-editqf'
" Plug 'https://github.com/ethomas2/vim-unstack' " can't get this to work
" Plug 'https://github.com/mattboehm/vim-accordion'
" Plug 'https://github.com/tpope/vim-fugitive'
" Plug 'https://github.com/tpope/vim-rhubarb'
" Plug 'https://github.com/kshenoy/vim-signature'
" " Plug 'https://github.com/fisadev/vim-isort'
" let g:SignatureMarkLineHL = 'Search' " Consider other highlight groups. This one is sort of annoying
" let g:SignatureMarkTextHL = 'None'
" let g:SignatureForceRemoveGlobal = 1 " See https://github.com/kshenoy/vim-signature/issues/72
" " Plug 'https://github.com/jiangmiao/auto-pairs'
" "
call plug#end()


set noswapfile

let mapleader=" "

" Turn on line numbering. Turn it on and of with set number and set number!
set nu


" Stop vim from inserting two periods after formatting something with gq
" https://stackoverflow.com/questions/4760428/how-can-i-make-vims-j-and-gq-commands-use-one-space-after-a-period
set nojoinspaces

syntax enable

function! EraseTrailingWhiteSpace()
  if search('\s\+$', 'nw') != 0
    %s/\s\+$//e
    normal!``
  endif
endfunction

augroup mygroup
  "every time you source ~/.vimrc, it re-adds everything in this group
  "multiple source ~/.vimrc will end up with multiple copies of the same autocmd
  "therefore erase this group before making all the autocmds,
  autocmd!

  "open vim with with cursor position where it was last
  autocmd BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \   exe "normal! g`\"" |
        \ endif

  "erase whitespace at the end of new lines
  autocmd BufWritePre *
    \ if  argv(0) != ".git/addp-hunk-edit.diff" |
    \   call EraseTrailingWhiteSpace() |
    \ endif

  "if you change vimrc, resource it
  autocmd BufWritePost  .vimrc  source %
  autocmd BufWritePost  local.vim  source %
  autocmd BufWritePost */plugin/mystuff/*.vim source %

augroup END



"tabs
" set expandtab "Use spaces instead of tabs
" set smarttab "Be smart when using tabs ;)
" " 1 tab == 2 spaces
" set shiftwidth=2
" set softtabstop=2
" set ai "Auto indent (copy indent from current line onto next line)
" set si "Smart indent (indent where the syntax would want an indent)
" set wrap "Wrap lines
" " Indent automatically depending on filetype
" filetype indent on
" set laststatus=2

" default backpace behavior in vim is dumb
" https://vi.stackexchange.com/questions/2162/why-doesnt-the-backspace-key-work-in-insert-mode
" set backspace=indent,eol,start


nnoremap n /<CR>
nnoremap N ?<CR>


let g:textobj_comment_no_default_key_mappings = 1
xmap agc <Plug>(textobj-comment-a)
omap agc <Plug>(textobj-comment-a)
xmap igc <Plug>(textobj-comment-i)
omap igc <Plug>(textobj-comment-i)


xmap cm  <Plug>Commentary
nmap cm  <Plug>Commentary
omap cm  <Plug>Commentary
nmap cmm <Plug>CommentaryLine
nmap cgc <Plug>ChangeCommentary
nmap cmu <Plug>Commentary<Plug>Commentary

nnoremap ; :

nnoremap <C-p> :FZF<CR>
if !has('nvim')
  set cryptmethod=blowfish
endif

set ruler


vmap <C-c><C-c> <Plug>SendSelectionToTmux
nmap <C-c><C-c> <Plug>NormalModeSendToTmux
nmap <C-c><C-q> :Tmux q<CR>
let g:tslime_always_current_session = 1
let g:tslime_always_current_window = 1

" Adapted from https://stackoverflow.com/questions/2974192/how-can-i-pare-down-vims-buffer-list-to-only-include-active-buffers
function! CloseHiddenBuffers()
  " figure out which buffers are visible in any tab
  let visible = {}
  for t in range(1, tabpagenr('$'))
    for b in tabpagebuflist(t)
      let visible[b] = 1
    endfor
  endfor
  " close any buffer that are loaded and not visible
  let l:tally = 0
  for b in range(1, bufnr('$'))
    if buflisted(b) && !has_key(visible, b)
      let l:tally += 1
      exe 'bw ' . b
    endif
  endfor
  echon "Deleted " . l:tally . " buffers"
endfun
command! -nargs=* CleanBuf call CloseHiddenBuffers()
command! -nargs=* BufClean call CloseHiddenBuffers()

" FZF Config
function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
endfunction
let g:fzf_action = {
  \ 'ctrl-q': function('s:build_quickfix_list'),
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }
let g:fzf_layout = {'down': '45%'}

command! -bang -nargs=* Ag
  \ call fzf#vim#ag(<q-args>, fzf#vim#with_preview('right:35%'))


command! -nargs=* -complete=dir RgFixedString
  \ call fzf#vim#grep(
  \   "rg --column --line-number --no-heading --fixed-strings --smart-case --hidden --color=always ".<q-args>, 1,
  \ fzf#vim#with_preview('right:35%'),
  \ )

command! -nargs=* -complete=dir Rg
  \ call fzf#vim#grep(
  \   "rg --column --line-number --no-heading --smart-case --hidden --color=always ".<q-args>, 1,
  \ fzf#vim#with_preview('right:35%'),
  \ )

command! -bang -nargs=* Lines
  \ call fzf#vim#lines(<q-args>, fzf#vim#with_preview('right:35%'))

" Immediately trigger a search for the current keyword if there is one
nnoremap <expr> <leader>g (expand("<cword>") ==? "") ? ":Rg " : ":Rg '\\b\<C-r>\<C-w>\\b'<CR>"

" Immediately trigger a search for the current selection if there is one
xnoremap <leader>g "zy:exe "Rg ".@z.""<CR>

let g:prettier#exec_cmd_path = "~/.config/yarn/global/node_modules/.bin/prettier"
let g:prettier#exec_cmd_async = 1
let g:prettier#autoformat = 0

nnoremap <C-B> :Buffers<CR>

command! -nargs=* TSlimeReset unlet g:tslime
command! -nargs=* TS unlet g:tslime
command! -nargs=* Ts unlet g:tslime
" cnoreabbrev ts TSlimeReset

if filereadable("local.vim")
  source local.vim
endif


command! -nargs=0 NoScroll diffoff | windo set nocursorbind | windo set noscrollbind

function! Dbase()
  " fnamemodify: https://stackoverflow.com/a/24463362/4993041
  let l:path = fnamemodify(expand("%"), ":~:.")
  let l:ft = &ft
  let l:orig_window = winnr()
  :windo diffoff
  exe "normal! " . l:orig_window . "\<C-W>\<C-W>"
  :diffthis
  :new
  exe ".!git show $(git base):" . l:path
  exe "set ft=" . l:ft
  :diffthis
  au BufUnload <buffer> windo NoScroll
  exe ":normal! \<C-W>p"
endfunction
command! -nargs=0 Dbase call Dbase()
command! -nargs=0 GDbase call Dbase()
command! -nargs=0 Gdbase call Dbase()

function! Gdt(...)
  let commit = a:0 > 0 ? a:1 : "HEAD"
  " fnamemodify: https://stackoverflow.com/a/24463362/4993041
  let l:path = fnamemodify(expand("%"), ":~:.")
  let l:ft = &ft
  let l:orig_window = winnr()
  :windo diffoff
  exe "normal! " . l:orig_window . "\<C-W>\<C-W>"
  :diffthis
  :new
  exe ".!git show " . commit . ":" . l:path
  exe "set ft=" . l:ft
  :diffthis
  au BufUnload <buffer> windo NoScroll
  " BufUnload function() { normal! l:orig_window "\<C-W>\<C-W>"; }
  exe ":normal! \<C-W>p"
endfunction
command! -nargs=? Gdt call Gdt(<f-args>)
cnoreabbrev gdt Gdt


function! Gshow(...)
  let commit = a:1
  " fnamemodify: https://stackoverflow.com/a/24463362/4993041
  let l:path = fnamemodify(expand("%"), ":~:.")
  let l:ft = &ft
  :new
  exe ".!git show " . commit . ":" . l:path
  exe "set ft=" . l:ft
endfunction
command! -nargs=? Gshow call Gdt(<f-args>)

" <tab> is remapped to gt, (which also overrides <C-I>), so remap <C-J> to
" <C-I>/<tab>
nnoremap <C-n> <tab>

" For local replace
nnoremap gr :%s/<C-R><C-w>//gc<left><left><left>

" For global replace
nnoremap gR gD:%s/<C-R>///gc<left><left><left>

" disable GOD DAMN MOTHER FUCKING SCROLL WHEEL FOR THE FUCKING LOVE OF CHRIST
" noremap <UP> <nop>
" noremap <DOWN> <nop>
" cnoremap <UP> <nop>
" cnoremap <DOWN> <nop>
" inoremap <UP> <nop>
" inoremap <DOWN> <nop>

" cnoreabbrev nt NERDTreeToggle

" see https://stackoverflow.com/a/11450865/4993041
" only clears global marks
command! -nargs=0 ClearMarks delmarks A-Za-z | SignatureRefresh

" let g:loaded_clipboard_provider = 1
" set clipboard^=unnamedplus

" from https://stackoverflow.com/questions/4256697/vim-search-and-highlight-but-do-not-jump
nnoremap <silent> <Leader>s :let @/='\<<C-R>=expand("<cword>")<CR>\>'<CR>:set hls<CR>
xnoremap <silent> <Leader>s "zy<CR>:let @/='<C-R>z'<CR>:set hls<CR>
" xnoremap <silent> <Leader>s "/y<CR>:let @/='<C-R>z'<CR>:set hls<CR>
" xnoremap <silent> <Leader>s "zy:let @/='\<<C-R>z'<CR>
nnoremap <silent> <Leader>h :set nohls<CR>


cnoremap <C-a> <C-b>

" https://vim.fandom.com/wiki/Simplifying_regular_expressions_using_magic_and_no-magic
" cnoremap %s/ %smagic/
" cnoremap \>s/ \>smagic/

autocmd BufNewFile,BufRead .envrc set filetype=sh

command! -nargs=0 FoldPython :%g/^\s*def/norm f)jzfii

function! RunThis()
  let l:filepath = expand('%:p')

  if &filetype == "python"
    let l:cmd = "python"
  elseif &filetype == "sh"
    let l:cmd = "bash"
  elseif &filetype == "go"
    let l:cmd = "go run"
  elseif &filetype == "haskell"
    let l:cmd = "runhaskell"
  elseif &filetype == "javascript.jsx"
    let l:cmd = "node"
  elseif &filetype == "rust"
    let l:cmd = "rustrun"
  else
    echo "Unknown filetype " . &filetype . " and no command passed in"
    return
  endif

  execute "Tmux time " . l:cmd . " " . l:filepath
endfunction

nnoremap <leader>t :call RunThis()<CR>

nnoremap <leader>d :call system("tmux send-keys -t " . g:tslime['pane'] . " C-d")<CR>

command! -nargs=0 Gblame :Git blame


function! DeleteEmptyBuffers()
    let [i, n; empty] = [1, bufnr('$')]
    while i <= n
        if bufexists(i) && bufname(i) == ''
            call add(empty, i)
        endif
        let i += 1
    endwhile
    if len(empty) > 0
        exe 'bdelete' join(empty)
    endif
endfunction
command! -nargs=0 DeleteEmptyBuffers call DeleteEmptyBuffers()

lua <<EOF
function GetMostRecentFriday()
    local currentDate = os.date("*t")
    local year = currentDate.year
    local month = currentDate.month
    local day = currentDate.day
    local currentDayOfWeek = currentDate.wday

    if currentDayOfWeek == 6 then -- Friday
        print(os.date("%Y-%m-%d"))
        return os.date("%Y-%m-%d")
    elseif currentDayOfWeek > 6 then
        local diff = currentDayOfWeek - 6
        local previousFriday = os.time{year = year, month = month, day = day} - (diff * 24 * 60 * 60)
        print(os.date("%Y-%m-%d", previousFriday))
        return os.date("%Y-%m-%d", previousFriday)
    else
        local diff = 6 - currentDayOfWeek
        local previousFriday = os.time{year = year, month = month, day = day} - ((7 - diff) * 24 * 60 * 60)
        print(os.date("%Y-%m-%d", previousFriday))
        return os.date("%Y-%m-%d", previousFriday)
    end
end
EOF
command! -nargs=0 GetMostRecentFriday :lua GetMostRecentFriday()


luafile ~/.vim/mystuff/luaUtils.lua



function! OpenThoughts()
    let last_friday_date = luaeval("get_last_friday()")

    let next_thursday_date = luaeval("get_next_thursday()")

    let filename = '~/notes/Main/Thoughts/2023/' . last_friday_date . ' -- ' . next_thursday_date . '.md'
    let filename = expand(filename)

    if !filereadable(filename)
        silent execute '!mkdir -p ' . fnameescape(fnamemodify(filename, ':h'))
        silent execute 'write ' . fnameescape(filename)
        echo 'Created file: ' . filename
    else
        echo 'File already exists: ' . filename
    endif

    " Open the newly created notes file in a new Vim tab
    silent execute 'tabedit ' . fnameescape(filename)
endfunction

command! -nargs=* OpenThoughts call OpenThoughts()

command! -nargs=0 OpenNotes :FZF ~/notes/

function! OpenTodo()
    let last_friday_date = luaeval("get_last_friday()")
    let next_thursday_date = luaeval("get_next_thursday()")

    " Obtain the current year using strftime
    let current_year = strftime('%Y')

    " Use the current year in your directory path
    let dirpath = '~/notes/Main/Todo/' . current_year . '/' . last_friday_date . ' -- ' . next_thursday_date . '/'
    let dirpath = expand(dirpath)
    silent execute '!mkdir -p ' . fnameescape(fnamemodify(dirpath, ':h'))

    let planfilepath = dirpath . 'Plan.md'
    echo planfilepath
    execute '!touch ' . fnameescape(planfilepath)

    let todofilepath = dirpath . 'Todo.md'
    execute '!touch ' . fnameescape(todofilepath)

    let timelinefilepath = dirpath . 'Timeline.md'
    execute '!touch ' . fnameescape(timelinefilepath)

    " silent execute 'tabedit ' . fnameescape(dirpath)
    " normal! R
    tabnew
    execute 'NvimTreeOpen ' . dirpath
endfunction

command! -nargs=* OpenTodo call OpenTodo()


" Function to select the entire buffer
function! SelectEntireBuffer()
  normal! gg0vG$
endfunction

" Map ae to select the entire buffer in visual and operator-pending mode
xnoremap ae :<C-U>call SelectEntireBuffer()<CR>
onoremap ae :<C-U>call SelectEntireBuffer()<CR>
