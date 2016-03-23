function! s:show_history(...)
  if exists('a:1')
    let register = a:1
  else
    let register = '"'
  endif

  call fzf#run({
  \ 'source': s:get_history(register),
  \ 'down': '40%',
  \ 'options': '+m --delimiter="\t" --with-nth 2.. --tiebreak=index',
  \ 'sink': function('s:history_sink') })
endfunction

function! s:get_history(register)
  let histories = neoyank#_get_yank_histories()
  let reg_history = get(histories, a:register, [])
  return map(copy(reg_history), 'v:val[1] . "\t"  . v:val[0]')
endfunction

function! s:history_sink(line)
  let parts = split(a:line, "\t", 1)
  let regtype = parts[0]
  let text = join(parts[1:], "\t")
  call s:paste(text, 'p', regtype)
endfunction

function! s:paste(text, command, type)
  let old_reg = getreg('"')
  let old_regtype = getregtype('"')

  call setreg('"', a:text, a:type)
  try
    execute 'normal! ""' . a:command
  finally
    call setreg('"', old_reg, old_regtype)
  endtry
endfunction

command! -nargs=* FZFYank call s:show_history(<f-args>)
