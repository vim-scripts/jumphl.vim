" Vim plugin - highlight the cursor line after a jump
" File:         jumphl.vim (C587.vim, after C388.vim)
" Created:      2010 Feb 19
" Last Change:  2010 Feb 19
" Rev Days:     0
" Author:       Andy Wokula <anwoku@yahoo.de>
" Version:      0.1

" Includes some suggestions from
" http://vim.wikia.com/wiki/Highlight_cursor_line_after_cursor_jump
"
" autocommand juggling {{{
" When a window is entered, WinEnter fires and then (only sometimes!)
" CursorMoved fires.  Both events need to communicate (attempted with
" w:jumphl_keep_hl) -- if they didn't, CursorMoved would undo the
" highlighting applied by WinEnter.  Now there is a little glitch: if
" CursorMoved doesn't fire right after WinEnter, then the next CursorMoved
" event will keep the highlighting (no matter how far the cursor moved); for
" example, after :split.  Not sure how to fix this.
" }}}

" Script Init Folklore:
if exists("loaded_jumphl")
    finish
endif
let loaded_jumphl = 1

if v:version < 700
    echomsg "jumphl: you need at least Vim 7.0"
    finish
endif

" Customization:
if !exists("g:jumphl_ignore_bufpat")
    let g:jumphl_ignore_bufpat = '_NERD_tree_\C'
endif

" Internal Vars:
" winnr, bufnr, lnum, col, want_col
let s:oldpos = [0,0,0,0,0]

" Functions:
func! s:OnCursorMoved(force_hl)
    let curpos = [winnr()] + getpos(".")

    let lnum_diff = curpos[2] - s:oldpos[2]
    let didjump = curpos[0:1] != s:oldpos[0:1]
        \ || lnum_diff > 1 || lnum_diff < -1

    if a:force_hl || didjump && !&cul
        call s:SetHighlight(1)
        if a:force_hl == 2
            let w:jumphl_keep_hl = 1
        endif
    elseif !didjump && &cul
        if exists("w:jumphl_keep_hl")
            unlet w:jumphl_keep_hl
        else
            call s:SetHighlight(0)
        endif
    endif

    let s:oldpos = curpos
endfunc

func! s:SetHighlight(enable)
    if bufname("") =~ g:jumphl_ignore_bufpat
        return
    endif
    if a:enable
        setl cursorline
    else
        setl nocursorline
    endif
endfunc

func! s:DoJumpHl(enable)
    if a:enable
        call s:OnCursorMoved(1)
        au! JumpHl
        au JumpHl CursorMoved,CursorMovedI * call s:OnCursorMoved(0)
        au JumpHl WinEnter * call s:OnCursorMoved(2)
        au JumpHl WinLeave * call s:SetHighlight(0)
    else
        au! JumpHl
        let s:oldpos = [0,0,0,0,0]
        call s:SetHighlight(0)
    endif
endfunc

augroup JumpHl
augroup End

" Commands:
com! DoJumpHl call s:DoJumpHl(1)
com! NoJumpHl call s:DoJumpHl(0)

" vim:set et fdm=marker:
