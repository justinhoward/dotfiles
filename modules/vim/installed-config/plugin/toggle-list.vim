if &cp || exists('g:toggle_list_loaded')
  finish
endif

if !exists('g:toggle_list_minimal')
  let g:toggle_list_minimal = "trail:-,precedes:«,extends:»"
endif

if !exists('g:toggle_list_normal')
  let g:toggle_list_normal = g:toggle_list_minimal . ",tab:▸\ ,eol:¬"
endif

if !exists('g:toggle_list_verbose')
  let g:toggle_list_verbose = g:toggle_list_normal . ",space:·"
endif

if !exists('g:toggle_list_mode')
  let g:toggle_list_mode = &list ? 1 : 0
endif

command! ToggleList call s:toggle_list_toggle()
command! ToggleListMinimal call s:toggle_list_set(0)
command! ToggleListNormal call s:toggle_list_set(1)
command! ToggleListVerbose call s:toggle_list_set(2)

func! s:toggle_list_toggle()
  call s:toggle_list_set((g:toggle_list_mode + 1) % 3)
endfunction

func! s:toggle_list_set(mode)
  set list

  if a:mode == 0
    let &listchars = g:toggle_list_minimal
  elseif a:mode == 1
    let &listchars = g:toggle_list_normal
  elseif a:mode == 2
    let &listchars = g:toggle_list_verbose
  endif

  let g:toggle_list_mode = a:mode
endfunction

call s:toggle_list_set(0)

let g:toggle_list_loaded = 1
