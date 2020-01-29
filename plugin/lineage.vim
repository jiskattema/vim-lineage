" File: lineage.vim
" Author: Jisk Attema
" Version: 0.1
" Last Modified: January 28, 2020
" Copyright: Copyright (C) 2020 Jisk Attema

" After this function, the cursor is in the window and buffer mean for the
" diff
function! LineageOpen ()
  if exists("t:lineage_window_open")
    call win_gotoid(t:lineage_winid)
    execute ':b ' . t:lineage_bufnr
  else
    let l:filetype = &ft

    let t:lineage_window_open = 1
    let t:original_bufnr = bufnr()
    let t:original_winid = win_getid()
    :diffthis

    :vnew
    let t:lineage_bufnr = bufnr()
    let t:lineage_winid = win_getid()
    execute 'set filetype=' . l:filetype
    setlocal buftype=nofile
    setlocal nobuflisted
    setlocal bufhidden=hide
    setlocal noswapfile
    :diffthis
  endif
endfunction

function! LineageClose ()
  if !exists("t:lineage_window_open")
    echo "No diff window open"
    return
  endif
  call win_gotoid(t:lineage_winid)
  execute ':q!'
  execute ':bd! ' . t:lineage_bufnr
  execute ':unlet t:lineage_window_open'
  execute ':unlet t:original_winid'
  execute ':unlet t:original_bufnr'
  execute ':unlet t:lineage_winid'
  execute ':unlet t:lineage_bufnr'
  :diffoff
endfunction

" First-time press: open diff with HEAD
" Further presses:
" * if the diff window is still open, increase offset with head, reuse it for the next diff
" * if the diff window was closed, reopen it
"
function! Lineage(count, direction)
  if exists("b:lineage_commits_from_head")
    " We have been called before
    if exists("t:lineage_window_open")
      " .. and the window is still open.
      if a:count == 0
        " without count, assume a step of 1
        let l:count = 1
      else
        let l:count = a:count
      endif
      if a:direction == 'next'
        let b:lineage_commits_from_head = b:lineage_commits_from_head + l:count
      elseif a:direction == 'prev'
        let b:lineage_commits_from_head = b:lineage_commits_from_head - l:count
      else
        echo 'Illegal direction'
      endif
    else
      " .. but the window was closed
      let b:lineage_commits_from_head = b:lineage_commits_from_head + a:count
    endif
  else
    " First-time press, compare to HEAD if count=0
    if a:count == 0
      " without count, assume a step of 1
      let l:count = 1
    else
      let l:count = a:count
    endif
    let b:lineage_commits_from_head = l:count
  endif

  if b:lineage_commits_from_head < 0
    let b:lineage_commits_from_head = 0
  endif

  " because we switch buffers, copy the count to a local var
  let l:lineage_commits_from_head = b:lineage_commits_from_head

  let l:name = expand('%:p')
  let l:gitname = trim( system('git ls-files --full-name ' . l:name) )
  let l:oneline = trim(
        \ system ('git log --pretty=oneline ' . l:name . ' |
          \  head -' . l:lineage_commits_from_head . ' |
          \ tail -1'
          \ )
        \ )
  let l:commit = strpart(l:oneline, 0, 40)
  let l:message = strpart(l:oneline, 41)

  call LineageOpen()

  execute 'f [ HEAD~' . l:lineage_commits_from_head . ' ]'

  setlocal noreadonly
  silent execute '%! git show '. l:commit . ':' . l:gitname
  setlocal readonly

  call win_gotoid(t:original_winid)
  execute 'silent normal! zO'

  " TODO: is an auto command like below useful?
  "autocmd BufLeave <buffer> ++once call LineageClose()
endfunction
