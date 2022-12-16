vim9script

var bufferName = "test-outline"

var GetLineNr = (line: string) => {

  }

var GetType = (line: string): string => {
  if line =~ "describe"
    return "describe"
  elseif line =~ "context"
    return "context"
  elseif line =~ "it"
    return "it"
  endif
  return "unknown"
  }  

var Build = (): list<any> => {
  const describes = execute('g/^\s*describe')
  const contexts = execute('g/^\s*context')
  const its = execute('g/^\s*it')


  var result = map(split(describes .. contexts .. its, "\n"), (_, x) => trim(x))
  #echo join(sort(result, (a, b) => a > b ? 1 : -1), "\n")

  var blubb: list<any> = []
  for line in result
    const indent = match(line[stridx(trim(line), " ") :], "[^ ]")
    #TODO: find way to have level instead of indent and start at 0, not 3 (bc
    #of 3 spaces of the first describe block)
    const lineNr = line[0 : stridx(trim(line), " ") - 1] 
    const text = trim(line[stridx(trim(line), " ") :])
    ->substitute("' do", "", "g")
    ->substitute("it '", "it ", "g")
    ->substitute("context '", "", "g")
    ->substitute("describe '", "", "g")

    blubb->add({
    type: GetType(line),
    lineNr: lineNr,
    text: text,
    indent: indent})
  endfor
  return sort(blubb, (a, b) => a.lineNr->str2nr() > b.lineNr->str2nr() ? 1 : -1)
  }

var TestOutline = () => {
  var result = Build()
  var lines = result->map((_, x) => x.text)

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
  }

command! TestOutline TestOutline()

var Close = () => {
  var outlineBuffer = bufnr(bufferName)
  if outlineBuffer > 0 && bufexists(outlineBuffer)
    execute 'bwipeout! ' .. outlineBuffer
  endif
  }

# temp
nnoremap <silent> <leader>to :TestOutline<cr>
