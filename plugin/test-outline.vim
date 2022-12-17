vim9script

const bufferName = "test-outline"

const GetLevel = (lastLine, currentIndent): number => {
  if currentIndent > lastLine._indent
    return lastLine.level + 1
  elseif currentIndent < lastLine._indent
    return lastLine.level - 1
  endif

  return lastLine.level
}

const GetType = (line: string): string => {
  if line =~ "describe"
    return "describe"
  elseif line =~ "context"
    return "context"
  elseif line =~ "it"
    return "it"
  endif
  return "unknown"
}  

const Build = (): list<any> => {
  const describes = execute('g/^\s*describe')
  const contexts = execute('g/^\s*context')
  const its = execute('g/^\s*it')

  var result = map(sort(split(describes .. contexts .. its, "\n")), (_, x) => trim(x))

  return result->reduce((lines, line) => {
    const indent = match(line[stridx(trim(line), " ") :], "[^ ]")
    const level = lines->len() > 0 ? GetLevel(lines[lines->len() - 1], indent) : 0
    const lineNr = str2nr(line[0 : stridx(trim(line), " ") - 1]) 
    const text = trim(line[stridx(trim(line), " ") :])
      ->substitute("' do", "", "g")
      ->substitute("it '", "it ", "g")
      ->substitute("context '", "", "g")
      ->substitute("describe '", "", "g")
    return lines->add({
      type: GetType(line),
      lineNr: lineNr,
      text: text,
      _indent: indent,
      level: level })
  }, [])
}

const Select = () => {
  const props = prop_list(line("."))

  if len(props) == 1
    echo props[0].id
    # TODO: select line in correct buffer
  endif
}

const TestOutline = () => {
  var outline = Build()

  new
  execute 'file ' .. bufferName
  execute "resize " .. 15
  setlocal filetype=test-outline

  prop_type_add("describe", { "highlight": "TestOutlineDescribe", "bufnr": bufnr(bufferName) })
  prop_type_add("context", { "highlight": "TestOutlineContext", "bufnr": bufnr(bufferName) })
  prop_type_add("it", { "highlight": "TestOutlineIt", "bufnr": bufnr(bufferName) })

  var lineNumber = 0
  for item in outline
    const line = repeat("  ", item.level) .. item.text
    append(lineNumber, line)
    lineNumber += 1
    prop_add(lineNumber, 1, { length: strlen(line), type: item.type, id: item.lineNr })
  endfor
  setlocal readonly nomodifiable

  nnoremap <script> <silent> <nowait> <buffer> q <scriptcmd>Close()<cr>
  nnoremap <script> <silent> <nowait> <buffer> o <scriptcmd>Select()<cr>
}

command! TestOutline TestOutline()

const Close = () => {
  var outlineBuffer = bufnr(bufferName)
  if outlineBuffer > 0 && bufexists(outlineBuffer)
    execute 'bwipeout! ' .. outlineBuffer
  endif
}

# temp
nnoremap <silent> <leader>to :TestOutline<cr>
