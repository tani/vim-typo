if exists('g:loaded_typo')
  finish
endif
let g:loaded_typo = 1

function! s:exchange(str, i, j) abort
  return a:str[:a:i-1] . a:str[a:j-1] . a:str[a:i:a:j-2] . a:str[a:i-1] . a:str[a:j:]
endfunction

function! s:delete(str, i) abort
  return a:str[:a:i-1] . a:str[a:i+1:]
endfunction

function! s:generateTypos(origString, maxDistance, currString = a:origString, currDistance = 0, typos = {}) abort
  let currString = a:currString
  let currDistance = a:currDistance
  let typos = a:typos

  if has_key(typos, currString)
    return typos
  endif

  let typos[currString] = a:origString

  if currDistance == a:maxDistance
    return typos
  endif

  for i in range(1, len(currString) - 1)
    let newString = s:exchange(currString, i, i + 1)
    let newDistance = currDistance + 1
    let typos = s:generateTypos(a:origString, a:maxDistance, newString, newDistance, typos)
  endfor

  for i in range(1, len(currString))
    let newString = s:delete(currString, i)
    let newDistance = currDistance + 1
    let typos = s:generateTypos(a:origString, a:maxDistance, newString, newDistance, typos)
  endfor

  return typos
endfunction

function! s:async_cmd(cmd) abort
  call timer_start(0, { -> execute(a:cmd) })
endfunction

function! s:typo(str, level) abort
  if len(a:str) < 3
    throw "too short string"
  endif

  let hd = a:str[:1]
  let md = a:str[1:-2]
  let tl = a:str[-1:]

  let typos = s:generateTypos(md, a:level)

  for md in keys(typos)
    let abbrev = hd . md . tl
    if abbrev != a:str
      call s:async_cmd("iabbrev <buffer> " . abbrev . " " . a:str)
    endif
  endfor
endfunction

function! s:typo_setup() abort
  if !getbufvar(bufnr(), 'typo_activated', 0)
    let words = syntaxcomplete#OmniSyntaxList()

    for word in words
      if len(word) >= 6
        let level = len(word) >= 12 ? 2 : 1
        call s:typo(word, level)
      endif
    endfor
  endif

  let b:typo_activated = 1
endfunction

augroup Typo
  autocmd!
  autocmd InsertEnter * nested call <SID>typo_setup()
augroup END
