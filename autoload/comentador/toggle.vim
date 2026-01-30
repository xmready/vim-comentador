vim9script

import autoload './parse.vim'
import autoload './select.vim'
import autoload './strip.vim'
import autoload './comment.vim'

export def DoToggle(): void
    var markers: dict<string> = parse.DoParseComments()

    var result: string = select.DoSelectComment(
        markers.iopen,
        markers.bopen,
        markers.bclose
    )

    if result == 'blank'
        return
    elseif result == 'commented'
        execute "normal! \<Esc>"
        var firstline: number = line("'<")
        var lastline: number = line("'>")
        strip.DoStrip(
            firstline, lastline,
            markers.iopen, markers.iclose,
            markers.bopen, markers.bclose
        )
        normal! `<^
    else
        var curline: number = line('.')
        comment.DoComment(
            curline, curline,
            markers.iopen, markers.iclose
        )
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
            strip.DoStripBlock(
                firstline, lastline,
                markers.bopen, markers.bclose
            )
            normal! `<^
            return
        endif
    endif

    for line in lines
        if match(line, '^\s*' .. markers.iopen) != -1
            strip.DoStripLine(
                firstline, lastline,
                markers.iopen, markers.iclose,
                markers.bopen, markers.bclose
            )
            normal! `<^
            return
        endif
    endfor

    comment.DoComment(
        firstline, lastline,
        markers.iopen, markers.iclose
    )
    normal! `<^
enddef
