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
  setlocal filetype=test-outline
  var lineNumber = 0
  for line in lines
    #append(lineNumber, strlen(line))
    append(lineNumber, line)
    lineNumber += 1
  endfor
  setlocal readonly nomodifiable
  # TODO
  # Extract line number of describe, context or it and put it into the id field
  # below
  # Before removing, save which key word is in this line (describe, it or
  # context) to use it for highlighting with prop_add
	#call prop_type_add("blubb", { "highlight": "Search", "bufnr": bufnr(bufferName) })
  #prop_add(1, 1, {  "length": 0, "type": "blubb", id: })
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
