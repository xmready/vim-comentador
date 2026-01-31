vim9script

import autoload './parse.vim'
import autoload './select.vim'
import autoload './strip.vim'
import autoload './comment.vim'

export def DoToggle(): void
    var markers: dict<string> = parse.DoParseComments()
    var result: string = select.DoSelectComment(markers)
    execute "normal! \<Esc>"

    var firstline: number = line("'<")
    var lastline: number = line("'>")
    var lines: list<string> = getline(firstline, lastline)

    if result == 'missing_bmark'
        echoerr 'Comentador: No matching block mark found'
        return
    elseif result == 'inline_comment' || result == 'inline_block_comment'
        lines = strip.DoStripLine(lines, markers)
    elseif result == 'block_comment'
        lines = strip.DoStripBlock(lines, markers)
        lines = strip.DoStripLine(lines, markers)
    elseif result == 'uncommented' || result == 'blank_line'
        lines = comment.DoInlineComment(lines, markers)
    endif

    setline(firstline, lines)

    if len(lines) < (lastline - firstline + 1)
        deletebufline('', firstline + len(lines), lastline)
    endif

    if (result == 'blank_line') && !empty(markers.iclose)
        search(markers.iclose, 'W', line('.'))
        normal! h
        startinsert
    else
        normal! `<^
    endif
enddef

export def DoToggleInlineBlock(): void
    var markers: dict<string> = parse.DoParseComments()

    if empty(markers.bopen)
        echoerr 'Comentador: Block comment markers unavailable for this filetype'
        return
    endif

    var result: string = select.DoSelectComment(markers)
    execute "normal! \<Esc>"
    var firstline: number = line("'<")
    var lastline: number = line("'>")
    var lines: list<string> = getline(firstline, lastline)
    var same_markers: bool = (markers.bopen == markers.iopen) && (markers.bclose == markers.iclose)

    if result == 'missing_bmark'
        echoerr 'Comentador: No matching block mark found'
        return
    elseif (result == 'inline_comment' && same_markers) || result == 'inline_block_comment'
        lines = strip.DoStripLine(lines, markers)
    elseif (result == 'uncommented') || (result == 'blank_line')
        lines = comment.DoInlineBlockComment(lines, markers)
    elseif result == 'inline_comment'
        return
    endif

    setline(firstline, lines)

    if result == 'blank_line' && !empty(markers.bclose)
        search(markers.bclose, 'W', line('.'))
        normal! h
        startinsert
    else
        normal! `<^
    endif
enddef

export def DoToggleVisual(): void
    execute "normal! \<Esc>"

    var markers: dict<string> = parse.DoParseComments()
    var firstline: number = line("'<")
    var lastline: number = line("'>")
    var lines: list<string> = getline(firstline, lastline)

    var first_is_bopen: bool = 0
    var last_is_bclose: bool = 0
    var has_iopen: bool = (indexof(lines, (_, str) => match(str, '^\s*' .. markers.iopen) != -1) != -1)
    var has_bopen: bool = 0

    if !empty(markers.bopen)
        first_is_bopen = match(lines[0], '^\s*' .. markers.bopen .. '\s*$') != -1
        last_is_bclose = match(lines[-1], '^\s*' .. markers.bclose .. '\s*$') != -1
        has_bopen = (indexof(lines, (_, str) => match(str, '^\s*' .. markers.bopen) != -1) != -1)
    endif

    if first_is_bopen != last_is_bclose
        echoerr 'Comentador: First or last line missing block marker'
        return
    elseif first_is_bopen && last_is_bclose
        lines = strip.DoStripBlock(lines, markers)
    elseif has_iopen || has_bopen
        lines = strip.DoStripLine(lines, markers)
    else
        lines = comment.DoInlineComment(lines, markers)
    endif

    setline(firstline, lines)

    if len(lines) < (lastline - firstline + 1)
        deletebufline('', firstline + len(lines), lastline)
    endif

    normal! `<^
enddef

export def DoToggleBlockVisual(): void
    execute "normal! \<Esc>"

    var markers: dict<string> = parse.DoParseComments()

    if empty(markers.bopen) || empty(markers.bclose)
        echoerr 'Comentador: Block comment markers unavailable for this filetype'
        return
    endif

    var firstline: number = line("'<")
    var lastline: number = line("'>")
    var lines: list<string> = getline(firstline, lastline)

    var first_is_bopen: bool = match(lines[0], '^\s*' .. markers.bopen .. '\s*$') != -1
    var last_is_bclose: bool = match(lines[-1], '^\s*' .. markers.bclose .. '\s*$') != -1

    if first_is_bopen != last_is_bclose
        echoerr 'Comentador: First or last line missing block marker'
        return
    elseif first_is_bopen && last_is_bclose
        lines = strip.DoStripBlock(lines, markers)
    else
        lines = comment.DoBlockComment(lines, markers)
        append(firstline, ['', ''])
    endif

    setline(firstline, lines)

    if len(lines) < (lastline - firstline + 1)
        deletebufline('', firstline + len(lines), lastline)
    endif

    normal! `<^
enddef
