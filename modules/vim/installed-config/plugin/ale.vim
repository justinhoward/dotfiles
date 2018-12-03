let g:ale_sign_error = '✖'
let g:ale_sign_warning = '⚠'

let g:ale_linters = {
	\ 'typescript': ['tslint', 'tsserver']
\ }

let g:ale_fixers = {
  \ '*': ['remove_trailing_lines', 'trim_whitespace'],
  \ 'ruby': ['rubocop']
\ }

let g:ale_ruby_rubocop_executable = 'bin/rubocop'
let g:ale_haml_hamllint_executable = 'bin/haml-lint'
