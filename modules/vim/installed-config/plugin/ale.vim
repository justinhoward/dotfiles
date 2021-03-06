let g:ale_sign_error = '✖'
let g:ale_sign_warning = '⚠'

let g:ale_linters = {
  \ 'typescript': ['eslint', 'tslint'],
  \ 'ruby': ['ruby', 'rubocop', 'brakeman'],
  \ 'rust': ['cargo']
\ }

let g:ale_fixers = {
  \ '*': ['remove_trailing_lines', 'trim_whitespace'],
  \ 'ruby': ['rubocop'],
  \ 'rust': ['rustfmt'],
  \ 'scss': ['prettier']
\ }

let g:ale_ruby_rubocop_executable = 'bin/rubocop'
let g:ale_haml_hamllint_executable = 'bin/haml-lint'
let g:ale_rust_cargo_use_clippy = 1
