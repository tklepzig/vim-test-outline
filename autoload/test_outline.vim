vim9script

import "./test_outline/utils.vim" as utils

const ConfigWindowWidth = () =>
  get(g:, "TestOutlineWidth", 40)
const ConfigWindowHeight = () =>
  get(g:, "TestOutlineHeight", 10)
const ConfigOrientation = () =>
  get(g:, "TestOutlineOrientation", "vertical")


const bufferName = "test-outline"
var orientation = ConfigOrientation()
var previousBufferNr = -1
var previousWinId = -1

const Build = (): list<any> => {
  const describes = utils.CollectBlocks("describe")
  const contexts = utils.CollectBlocks("context")
  const its = utils.CollectBlocks("it")

  var result = map(sort(split(describes .. contexts .. its, "\n")), (_, x) => trim(x))

  if len(result) == 0
    return []
  endif

  const firstIndent = utils.GetIndent(result[0])

  return result->reduce((lines, line) => {
    const indent = utils.GetIndent(line) - firstIndent
    const lineNr = str2nr(line[0 : stridx(trim(line), " ") - 1]) 
    const text = trim(line[stridx(trim(line), " ") :])
      ->substitute("' do", "", "g")
      ->substitute("it '", "it ", "g")
      ->substitute("context '", "", "g")
      ->substitute("describe '", "", "g")
    # TODO how to distinguish ruby or jest?
    #->substitute("describe('", "", "g")
    #->substitute("it('", "it ", "g")
    #->substitute("', () => {", "", "g")
    return lines->add({
      type: utils.GetType(line),
      lineNr: lineNr,
      text: text,
      indent: indent })
  }, [])
}

export const Close = () => {
  var outlineBuffer = bufnr(bufferName)
  if outlineBuffer > 0 && bufexists(outlineBuffer)
    if previousWinId > 0
      win_gotoid(previousWinId)
    endif
    execute 'bwipeout! ' .. outlineBuffer
  endif
}

const SelectBufferLine = (lineNr: number) => {
  win_gotoid(previousWinId)
  execute 'silent buffer ' .. previousBufferNr
  setpos(".", [previousBufferNr, lineNr, 1])
}

const Select = () => {
  const props = prop_list(line("."))
  if len(props) == 0
    return
  endif

  Close()
  SelectBufferLine(props[0].id)
}

const Preview = () => {
  const props = prop_list(line("."))
  if len(props) == 0
    return
  endif

  const curWinId = win_getid()
  SelectBufferLine(props[0].id)
  win_gotoid(curWinId)
}

const ToggleOrientation = () => {
  if (bufname("%") != bufferName)
    return
  endif

  if orientation == "vertical"
    orientation = "horizontal"
    wincmd K
    wincmd J
    execute "resize " .. ConfigWindowHeight()
  else
    orientation = "vertical"
    wincmd H
    execute "vertical resize " .. ConfigWindowWidth()
  endif
}

export const Open = () => {
  var outlineBuffer = bufnr(bufferName)
  if outlineBuffer > 0 && bufexists(outlineBuffer)
    return
  endif

  const outline = Build()

  if len(outline) == 0
    echohl ErrorMsg
    echo  "Not a valid test file"
    echohl None
    return
  endif

  previousBufferNr = bufnr("%")
  previousWinId = win_getid()

  if orientation == "horizontal"
    new
    execute "resize " .. ConfigWindowHeight()
  else
    aboveleft vnew
    execute "vertical resize " .. ConfigWindowWidth()
  endif

  execute "file " .. bufferName
  setlocal filetype=test-outline

  prop_type_add("describe", { "highlight": "TestOutlineDescribe", "bufnr": bufnr(bufferName) })
  prop_type_add("context", { "highlight": "TestOutlineContext", "bufnr": bufnr(bufferName) })
  prop_type_add("it", { "highlight": "TestOutlineIt", "bufnr": bufnr(bufferName) })

  var lineNumber = 0
  for item in outline
    const line = repeat(" ", item.indent) .. item.text
    append(lineNumber, line)
    lineNumber += 1
    prop_add(lineNumber, 1, { length: strlen(line), type: item.type, id: item.lineNr })
  endfor
  setlocal readonly nomodifiable

  nnoremap <script> <silent> <nowait> <buffer> m <scriptcmd>ToggleOrientation()<cr>
  nnoremap <script> <silent> <nowait> <buffer> q <scriptcmd>Close()<cr>
  nnoremap <script> <silent> <nowait> <buffer> o <scriptcmd>Select()<cr>
  nnoremap <script> <silent> <nowait> <buffer> p <scriptcmd>Preview()<cr>
}

export const Toggle = () => {
  var outlineBuffer = bufnr(bufferName)
  if outlineBuffer > 0 && bufexists(outlineBuffer)
    Close()
  else
    Open()
  endif
}
