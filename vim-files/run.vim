function! OverwriteCurrentBuffer(content)
  redir @z "put it in z register
  silent echo a:content
  redir END
  normal ggdG
  normal "zp
endfunction

function! ExecuteScript(...)
  if a:0 == 1
    let l:cmd=a:1
  elseif exists("t:runcmd")
    let l:cmd= t:runcmd
  elseif &filetype == "haskell"
    let l:cmd="runhaskell"
  elseif &filetype == "python"
    let l:cmd="python"
  elseif &filetype == "sh"
    let l:cmd="bash"
  elseif &filetype == "javascript.jsx"
    let l:cmd = "node"
  else
    echo "unknown filetype " . &filetype . " and no command passed in"
    return
  endif

  let l:contents = join(getline(1,'$'), "\n")
  let l:output = system(l:cmd, l:contents)

  if exists("t:RunBuffer") && bufnr(t:RunBuffer) != -1
    windo if bufnr('%') == t:RunBuffer |
          \   call OverwriteCurrentBuffer(l:output) |
          \ endif
  else
    rightbelow vertical new
    let t:RunBuffer=bufnr('%')
    au BufHidden,BufDelete <buffer> unlet t:RunBuffer
    call OverwriteCurrentBuffer(l:output)
  endif
endfunction
command! -nargs=? Run call ExecuteScript(<f-args>)
