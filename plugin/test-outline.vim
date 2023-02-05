vim9script

import "../autoload/test_outline.vim" as main

command! TestOutlineOpen silent main.Open()
command! TestOutlineClose silent main.Close()
command! TestOutlineToggle silent main.Toggle()

# temp
nnoremap <silent> <leader><leader> :TestOutlineToggle<cr>
