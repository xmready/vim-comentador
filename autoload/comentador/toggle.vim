vim9script

import autoload './parse.vim'
import autoload './select.vim'
import autoload './strip.vim'
import autoload './comment.vim'

var startln: number = 0

export def SetOperator(type: string, mode: string): string
    startln = line('.')
    &operatorfunc = type == 'block' ? 'g:ComentadorToggleBlock' : 'g:ComentadorToggle'
    return mode == 'line' ? 'g@_' : 'g@'
enddef

def g:ComentadorToggle(_: string): void
    var markers: dict<any> = parse.DoParseComments()
    var firstline: number = line("'[")
    var lastline: number = line("']")
    execute 'normal! ' .. startln .. 'G'
    var type: string = select.DoSelectComment(markers)
    echom 'Comentador: ' .. type
    execute "normal! \<Esc>"

    if type == 'block_comment'
        firstline = line("'<")
        lastline = line("'>")
    endif

    var lines: list<string> = getline(firstline, lastline)
    var has_inline: bool = (indexof(lines, (_, str) => match(str, markers.patterns.inline_either) != -1) != -1)

    if type == 'missing_bmark'
        echoerr 'Comentador: No matching block marker found'
        return
    elseif type == 'block_comment'
        lines = strip.DoStripBlock(lines, markers)
    elseif (type == 'inline_comment' || type == 'inline_block_comment') || has_inline
        lines = strip.DoStripLine(lines, markers)
    elseif type == 'uncommented' || type == 'blank_line'
        lines = comment.DoInlineComment(lines, markers)
    endif

    setline(firstline, lines)

    if len(lines) < (lastline - firstline + 1)
        deletebufline('', firstline + len(lines), lastline)
    endif

    if type == 'blank_line' && !empty(markers.iclose) && firstline == lastline
        search(markers.iclose, 'W', line('.'))
        normal! h
        startinsert
    elseif startln < lastline
        normal! ']
    else
        normal! '[
    endif
enddef

def g:ComentadorToggleBlock(_: string): void
    var markers: dict<any> = parse.DoParseComments()

    if empty(markers.bopen) || empty(markers.bclose)
        echoerr 'Comentador: Block comment markers unavailable for this filetype'
        return
    endif

    var firstline: number = line("'[")
    var lastline: number = line("']")
    execute 'normal! ' .. startln .. 'G'
    var type: string = select.DoSelectComment(markers)
    execute "normal! \<Esc>"

    if type == 'missing_bmark'
        echoerr 'Comentador: No matching block marker found'
        return
    elseif type == 'block_comment'
        echoerr 'Comentador: Already inside a block comment'
        return
    endif

    var lines: list<string> = getline(firstline, lastline)
    var same_markers: bool = (markers.bopen == markers.iopen) && (markers.bclose == markers.iclose)
    var has_inline_block: bool = (indexof(lines, (_, str) => match(str, markers.patterns.inline_block) != -1) != -1)
    var has_block: bool = (indexof(lines, (_, str) => match(str, markers.patterns.block_either) != -1) != -1)

    if !has_inline_block && has_block
        echoerr 'Comentador: Range contains multi-line block comment'
        return
    elseif (type == 'inline_comment' && same_markers) || type == 'inline_block_comment' || (type != 'inline_comment' && has_inline_block)
        lines = strip.DoStripLine(lines, markers)
    elseif type == 'uncommented' || type == 'blank_line'
        lines = comment.DoInlineBlockComment(lines, markers)
    elseif type == 'inline_comment'
        echoerr 'Comentador: Existing inline comment'
        return
    endif

    setline(firstline, lines)

    if type == 'blank_line' && firstline == lastline
        search(markers.bclose, 'W', line('.'))
        normal! h
        startinsert
    elseif startln < lastline
        normal! ']
    else
        normal! '[
    endif
enddef

export def DoToggleVisual(): void
    execute "normal! \<Esc>"

    var markers: dict<any> = parse.DoParseComments()
    var firstline: number = line("'<")
    var lastline: number = line("'>")
    var lines: list<string> = getline(firstline, lastline)

    var first_is_bopen: bool = 0
    var last_is_bclose: bool = 0
    var has_inline: bool = (indexof(lines, (_, str) => match(str, markers.patterns.inline_either) != -1) != -1)

    if !empty(markers.bopen)
        first_is_bopen = match(lines[0], markers.patterns.bopen) != -1
        last_is_bclose = match(lines[-1], markers.patterns.bclose) != -1
    endif

    if first_is_bopen != last_is_bclose
        echoerr 'Comentador: First or last line missing block marker'
        return
    elseif first_is_bopen && last_is_bclose
        lines = strip.DoStripBlock(lines, markers)
    elseif has_inline
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

    var markers: dict<any> = parse.DoParseComments()

    if empty(markers.bopen) || empty(markers.bclose)
        echoerr 'Comentador: Block comment markers unavailable for this filetype'
        return
    endif

    var firstline: number = line("'<")
    var lastline: number = line("'>")
    var lines: list<string> = getline(firstline, lastline)

    var first_is_bopen: bool = match(lines[0], markers.patterns.bopen) != -1
    var last_is_bclose: bool = match(lines[-1], markers.patterns.bclose) != -1

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
