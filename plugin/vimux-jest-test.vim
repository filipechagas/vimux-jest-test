let g:JestCommand = "jest"
let g:JestDebugCommand = "node --inspect-brk $(which jest) --runInBand"

command! RunJest :call _run_jest("", g:JestCommand)
command! RunJestOnBuffer :call RunJestOnBuffer(g:JestCommand)
command! RunJestFocused :call RunJestFocused(g:JestCommand)

command! DebugJest :call _run_jest("", g:JestDebugCommand)
command! DebugJestOnBuffer :call RunJestOnBuffer(g:JestDebugCommand)
command! DebugJestFocused :call RunJestFocused(g:JestDebugCommand)

function! RunJestOnBuffer(command)
  call _run_jest(expand("%"), a:command)
endfunction

function! RunJestFocused(command)
  let test_name = _jest_test_search('\<test(\|\<it(\|\<test.only(')
  if test_name == ""
    echoerr "Couldn't find test name to run focused test."
    return
  endif

  call _run_jest(expand("%") . " -t " . test_name, a:command)
endfunction

function! _jest_test_search(fragment)
  " Save the entire state of the window, including cursor position
  let save_view = winsaveview()

  let line_num = search(a:fragment, "bs")
  if line_num > 0
    ''
    let tokens_split_on_parens  = split(getline(line_num), "(")
    if len(tokens_split_on_parens) > 1
      " Restore the window state before returning
      call winrestview(save_view)
      return split(tokens_split_on_parens[1], ",")[0]
    endif

    " Restore the window state before returning
    call winrestview(save_view)
    return split(getline(line_num + 1), ",")[0]
  else
    " Restore the window state before returning
    call winrestview(save_view)
    return ""
  endif
endfunction

function! _run_jest(test, command)
  call VimuxRunCommand(a:command . " " . a:test)
endfunction
