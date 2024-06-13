function! MakeHeader()
  let l:text = trim(getline('.'))
  let l:textlen = strlen(l:text)
  let l:headerlen = 79
  let l:row1 = repeat(join(['#'], ''), l:headerlen)
  let l:row2BeginLen = (l:headerlen - l:textlen - 2 + 1) / 2
  let l:row2EndLen = (l:headerlen - l:textlen - 2) / 2
  let l:row2 = repeat(join(['#'], ''), l:row2BeginLen) .
    \ ' ' . l:text . ' ' .
    \ repeat(join(['#'], ''), l:row2EndLen)

  call append(line('.'), l:row1)
  call append(line('.'), l:row2)
  call append(line('.'), l:row1)
  " for some reason internet says not to use normal in vimscript
  normal! dd
endfunction

command! -nargs=0 Header call MakeHeader()



function! MakeHeader2()
  let l:text = trim(getline('.'))
  let l:textlen = strlen(l:text)
  let l:headerlen = 79
  let l:row2BeginLen = (l:headerlen - l:textlen - 2 + 1) / 2
  let l:row2EndLen = (l:headerlen - l:textlen - 2) / 2
  let l:row2 = repeat(join(['#'], ''), l:row2BeginLen) .
    \ ' ' . l:text . ' ' .
    \ repeat(join(['#'], ''), l:row2EndLen)

  call append(line('.'), l:row2)
  " for some reason internet says not to use normal in vimscript
  normal! dd
endfunction
command! -nargs=0 Header2 call MakeHeader2()



function! MakeHeaderSql()
  let l:text = trim(getline('.'))
  let l:textlen = strlen(l:text)
  let l:headerlen = 79
  let l:row2BeginLen = (l:headerlen - l:textlen - 2 + 1) / 2
  let l:row2EndLen = (l:headerlen - l:textlen - 2) / 2
  let l:row2 = '/' .
    \ repeat(join(['*'], ''), l:row2BeginLen - 1) .
    \ ' ' . l:text . ' ' .
    \ repeat(join(['*'], ''), l:row2EndLen - 1) .
    \ '/'

  call append(line('.'), l:row2)
  " for some reason internet says not to use normal in vimscript
  normal! dd
endfunction
command! -nargs=0 HeaderSql call MakeHeaderSql()
