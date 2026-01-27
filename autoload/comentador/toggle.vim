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
