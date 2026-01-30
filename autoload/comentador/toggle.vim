vim9script

import autoload './parse.vim'
import autoload './select.vim'
import autoload './strip.vim'
import autoload './comment.vim'

export def DoToggle(): void
    var markers: dict<string> = parse.DoParseComments()
    var result: string = select.DoSelectComment(markers)

    if result == 'commented'
        execute "normal! \<Esc>"
        var firstline: number = line("'<")
        var lastline: number = line("'>")
        var lines: list<string> = getline(firstline, lastline)

        lines = strip.DoStripBlock(lines, markers)
        lines = strip.DoStripLine(lines, markers)

        setline(firstline, lines)

        if len(lines) < (lastline - firstline + 1)
            deletebufline('', firstline + len(lines), lastline)
        endif

        normal! `<^
    else
        var lines: list<string> = getline('.', '.')

        lines = comment.DoComment(lines, markers)

        setline(line('.'), lines)

        normal! ^
    endif
enddef

export def DoToggleVisual(): void
    execute "normal! \<Esc>"

    var markers: dict<string> = parse.DoParseComments()
    var firstline: number = line("'<")
    var lastline: number = line("'>")
    var lines: list<string> = getline(firstline, lastline)

    if !empty(markers.bopen)
        var first_is_bopen: bool = match(lines[0], '^\s*' .. markers.bopen .. '\s*$') != -1
        var last_is_bclose: bool = match(lines[-1], '^\s*' .. markers.bclose .. '\s*$') != -1

        if first_is_bopen && last_is_bclose
            lines = strip.DoStripBlock(lines, markers)

            setline(firstline, lines)

            if len(lines) < (lastline - firstline + 1)
                deletebufline('', firstline + len(lines), lastline)
            endif

            normal! `<^

            return
        endif
    endif

    for line in lines
        if match(line, '^\s*' .. markers.iopen) != -1
            lines = strip.DoStripLine(lines, markers)

            setline(firstline, lines)

            normal! `<^

            return
        endif
    endfor

    lines = comment.DoComment(lines, markers)

    setline(firstline, lines)

    normal! `<^
enddef
