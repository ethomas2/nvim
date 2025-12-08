" Tab navigation like chrome
nnoremap <S-tab> gT
nnoremap <tab> gt
nnoremap <C-t> :tabnew<CR>


"t change windows
nmap <silent> <C-k> :wincmd k<CR>
nmap <silent> <C-j> :wincmd j<CR>
nmap <silent> <C-h> :wincmd h<CR>
nmap <silent> <C-l> :wincmd l<CR>

" open current buffer in new window
nmap <C-w>h :exe 'topleft  vsplit'<CR>
nmap <C-w>l :exe 'botright vsplit'<CR>
nmap <C-w>k :exe 'topleft  split'<CR>
nmap <C-w>j :exe 'botright split'<CR>

" new frame from frame
nmap <C-f>h :leftabove  vsplit<CR>
nmap <C-f>l :rightbelow vsplit<CR>
nmap <C-f>k :leftabove  split<CR>
nmap <C-f>j :rightbelow split<CR>

" easy split resizing
nnoremap <silent> <C-Right> <C-w>>
nnoremap <silent> <C-Left> <C-w><lt>
nnoremap <silent> <C-Up> <C-w>+
nnoremap <silent> <C-Down> <C-w>-

nnoremap <C-w>e <C-w>T

"C-w H move buffer to left
"C-w K move buffer to up ... etc
"C-w r rotate windows

" Window titles are now handled by lua/custom/window_titles.lua
