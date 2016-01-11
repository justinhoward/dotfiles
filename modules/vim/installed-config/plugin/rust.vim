let g:neomake_rust_rustc_maker = {
	\ 'args': ['-Zparse-only'],
	\ 'errorformat': '%E%f:%l:%c: %\d%#:%\d%# %.%\{-}error:%.%\{-} %m,'   .
	\ '%W%f:%l:%c: %\d%#:%\d%# %.%\{-}warning:%.%\{-} %m,' .
	\ '%C%f:%l %m,' .
	\ '%-Z%.%#'
\ }
