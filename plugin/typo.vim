if exists('g:loaded_typo')
  finish
endif
let g:loaded_typo = 1

function! s:exchange(word, i) abort
  return a:word[:a:i] . a:word[a:i+2] . a:word[a:i+1] . a:word[a:i+3:]
endfunction

function! s:delete(word, i) abort
  return a:word[:a:i] . a:word[a:i+2:]
endfunction

function! s:generateTypos(origString, maxDistance, currString = a:origString, currDistance = 0, typos = {}) abort
  let typos = a:typos

  if has_key(typos, a:currString)
    return typos
  endif

  let typos[a:currString] = a:origString

  if a:currDistance == a:maxDistance
    return typos
  endif

  for i in range(0, len(a:currString) - 4)
    let newString = s:exchange(a:currString, i)
    let newDistance = a:currDistance + 1
    let typos = s:generateTypos(a:origString, a:maxDistance, newString, newDistance, typos)
  endfor

  for i in range(0, len(a:currString) - 3)
    let newString = s:delete(a:currString, i)
    let newDistance = a:currDistance + 1
    let typos = s:generateTypos(a:origString, a:maxDistance, newString, newDistance, typos)
  endfor

  return typos
endfunction

function! s:typo(word, level) abort
  if len(a:word) < 3
    throw "too short string"
  endif

  let typos = s:generateTypos(a:word, a:level)

  for typo in keys(typos)
    if typo != a:word
      execute "iabbrev" "<buffer>" typo typos[typo]
    endif
  endfor
endfunction

function! s:typo_setup() abort
  if !get(b:, 'typo_did_setup', 0)
    let words = syntaxcomplete#OmniSyntaxList()
    let cache = {}

    for word in words
      if !has_key(cache, word) && len(word) >= 6
        call timer_start(0, function({ w -> s:typo(w, 1) }, [word]))
      endif
      let cache[word] = 1
    endfor
  endif

  let b:typo_did_setup = 1
endfunction

augroup Typo
  autocmd!
  autocmd InsertEnter * call <SID>typo_setup()
augroup END
