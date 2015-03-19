"=============================================================================
" FILE: autoload/vital/__latest__/ProjectFinder.vim
" AUTHOR: haya14busa
" License: MIT license
"=============================================================================
scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

" -- utilities

" empty('') is undocumented :h empty()
function! s:_empty(expr) abort
  return type(a:expr) is# type('') ? a:expr is# '' : empty(a:expr)
endfunction

function! s:_lcd(path) abort
  execute 'lcd' fnameescape(a:path)
endfunction

function! s:_is_winshell() abort
  return &shell =~? 'cmd' || exists('+shellslash') && !&shellslash
endfunction

" @return normalized path which substitute backslash to slash if on windows
function! s:_shellslash(path) abort
  return s:_is_winshell() ? substitute(a:path, '\\', '/', 'g') : a:path
endfunction

" is directory pattrn expression like `xxx/` not like 'xxx.txt'?
function! s:_is_dir_pattern(pattern) abort
  return a:pattern[len(a:pattern) - 1] is# '/'
endfunction

function! s:_cnt_char(str, char) abort
  " NOTE: are there any more efficient way?
  return len(filter(split(a:str, '\zs'), 'v:val is# a:char'))
endfunction

" -- main

" cwd: current working directory
" @rps root patterns
" @return empty string if not found
function! s:project_root_from_cwd(rps) abort
  " rp: normalized root pattern
  for rp in map(copy(a:rps), 's:_shellslash(v:val)')
    let level_to_root = 1 + s:_cnt_char(rp, '/')
    let Find = s:_is_dir_pattern(rp) ? function('finddir') : function('findfile')
    let target = call(Find, [rp, ';'])
    if !s:_empty(target)
      return fnamemodify(target, ':p' . repeat(':h', level_to_root))
    endif
  endfor
  return ''
endfunction


" @rps root patterns
" @from directory or file path searching root from (absolute/relative)
" @return project root directory, otherwise empty string if not found
function! s:project_root(rps, from) abort
  let default = '' " for not found
  let dir = isdirectory(a:from) ? a:from : fnamemodify(a:from, ':p:h')
  if !isdirectory(dir) | return default | endif
  let cwd_save = getcwd()
  try
    call s:_lcd(dir)
    return s:project_root_from_cwd(a:rps)
  finally
    call s:_lcd(cwd_save)
  endtry
  return default
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
