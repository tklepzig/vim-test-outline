vim9script

import "../autoload/test_outline.vim" as main

command! TestOutlineOpen main.Open()
command! TestOutlineClose main.Close()
command! TestOutlineToggle main.Toggle()

# temp
nnoremap <silent> <leader><leader> :TestOutlineToggle<cr>
