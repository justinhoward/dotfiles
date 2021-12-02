" let g:ale_sign_error = '✖'
" let g:ale_sign_warning = '⚠'

" let g:ale_linters = {
"   \ 'typescript': ['eslint', 'tslint'],
"   \ 'ruby': ['ruby', 'rubocop', 'brakeman'],
"   \ 'rust': ['cargo'],
"   \ 'c': ['cc', 'cpplint', 'cppcheck', 'flawfinder']
" \ }

" let g:ale_fixers = {
"   \ '*': ['remove_trailing_lines', 'trim_whitespace'],
"   \ 'ruby': ['rubocop'],
"   \ 'rust': ['rustfmt'],
"   \ 'scss': ['prettier']
" \ }

" let g:ale_ruby_rubocop_executable = 'bin/rubocop'
" let g:ale_haml_hamllint_executable = 'bin/haml-lint'
" let g:ale_rust_cargo_use_clippy = 1


" """ Copy config from cpp/cpplint.vim
" call ale#Set('c_cpplint_executable', 'cpplint')
" call ale#Set('c_cpplint_options', '')

" function! CpplintGetCommand(buffer) abort
"     let l:options = ale#Var(a:buffer, 'c_cpplint_options')

"     return '%e' . ale#Pad(l:options) . ' %s'
" endfunction

" call ale#linter#Define('c', {
" \   'name': 'cpplint',
" \   'output_stream': 'stderr',
" \   'executable': {b -> ale#Var(b, 'c_cpplint_executable')},
" \   'command': function('CpplintGetCommand'),
" \   'callback': 'ale#handlers#cpplint#HandleCppLintFormat',
" \   'lint_file': 1,
" \})
