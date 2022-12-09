vim9script

var bufferName = "test-outline"

def TestOutline()
  var describes = execute('g/^\s*describe')
  var contexts = execute('g/^\s*context')
  var its = execute('g/^\s*it')
  var result = describes .. contexts .. its
  result = substitute(result, "' do", "", "g")
  result = substitute(result, "it '", "it ", "g")
  result = substitute(result, "context '", "", "g")
  result = substitute(result, "describe '", "", "g")
  var lines = sort(split(result, "\n"))

  new
  execute 'file ' .. bufferName
  execute "resize " .. 15
  setlocal filetype=testoutline
  setline(1, lines)
  nnoremap <script> <silent> <nowait> <buffer> q <scriptcmd>Close()<cr>
enddef

command! TestOutline TestOutline()

def Close()
  var outlineBuffer = bufnr(bufferName)
  if outlineBuffer > 0 && bufexists(outlineBuffer)
    execute 'bwipeout! ' .. outlineBuffer
  endif
enddef

# temp
nnoremap <silent> <leader>to :TestOutline<cr>
