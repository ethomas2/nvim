inoremap <C-j>pdb import pdb; pdb.set_trace()  # noqa: E702
inoremap <C-j>rdb from celery.contrib import rdb; rdb.set_trace()
inoremap <C-j>mx nnoremap < <backspace>leader>x :Tmux < <backspace>CR><left><left><left><left>
inoremap <C-j>mk nnoremap < <backspace>leader>x :Tmux < <backspace>CR><left><left><left><left>
inoremap <C-j>x nnoremap < <backspace>leader>x :Tmux < <backspace>CR><left><left><left><left>
inoremap <C-j>ilog import logging; logger = logging.getLogger(__name__)  # noqa: E702
inoremap <C-j>tr logger.info(f'TRACE ')<left><left>
inoremap <C-j>log logger.info(f'TRACE ')<left><left>
inoremap <C-j>hist <Esc>!!cat ~/.vim/snippets/hist<CR>}i
inoremap <C-j>tbl <Esc>!!cat ~/.vim/snippets/tbl<CR>}}}o<esc>o
inoremap <C-j>table <Esc>!!cat ~/.vim/snippets/tbl<CR>}}}o<esc>o
inoremap <C-j>prof <Esc>!!cat ~/.vim/snippets/prof<CR>}o<esc>0i
inoremap <C-j>err <Esc>!!cat ~/.vim/snippets/python_error_hook<CR>}o<esc>0i
inoremap <C-j>sep ------------------------------------------------------------------------------


inoremap <C-j>pset \pset null 'Ø'
inoremap <C-j>eset Ø
inoremap <C-j>null Ø
