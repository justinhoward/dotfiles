" For toggling quickfix window from
" https://vim.fandom.com/wiki/Toggle_to_open_or_close_the_quickfix_window
function! s:get_buffer_list()
  redir =>buflist
  silent! ls!
  redir END
  return buflist
endfunction

function! s:toggle_list_window(bufname, pfx)
  let buflist = s:get_buffer_list()
  for bufnum in map(filter(split(buflist, '\n'), 'v:val =~ "'.a:bufname.'"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
    if bufwinnr(bufnum) != -1
      exec(a:pfx.'close')
      return
    endif
  endfor
  if a:pfx ==# 'l' && len(getloclist(0)) == 0
      echohl ErrorMsg
      echo 'Location List is Empty.'
      return
  endif
  let winnr = winnr()
  exec(a:pfx.'open')
  if winnr() != winnr
    wincmd p
  endif
endfunction

command! QuickfixToggle call <SID>toggle_list_window('Quickfix List', 'c')
