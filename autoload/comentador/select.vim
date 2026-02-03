vim9script

export def DoSelectComment(markers: dict<any>): string
    var ln: string = getline('.')

    if match(ln, markers.patterns.inline) == 0
        normal! V
        return 'inline_comment'
    elseif match(ln, markers.patterns.inline_block) != -1
        normal! V
        return 'inline_block_comment'
    elseif match(ln, markers.patterns.bopen) == 0
        normal! ^
        var endln: number = search(markers.bclose, 'nW')
        var mid_open: number = search(markers.patterns.bopen, 'nW', endln - 1)
        if mid_open == 0
            execute 'normal! V' .. endln .. 'G'
            return 'block_comment'
        else
            normal! V
            return 'missing_bmark'
        endif
    elseif match(ln, markers.patterns.bclose) == 0
        var startln: number = search(markers.bopen, 'bnW')
        var mid_open: number = search(markers.patterns.bclose, 'bnW', startln - 1)
        if mid_open == 0
            execute 'normal! V' .. startln .. 'G'
            return 'block_comment'
        else
            normal! V
            return 'missing_bmark'
        endif
    endif

    var startln: number = search(markers.patterns.bopen, 'bnW')
    var endln: number = search(markers.patterns.bclose, 'nW')

    if (startln > 0) && (endln > 0) && (startln < endln)
        var mid_open: number = search(markers.patterns.bopen, 'nW', endln - 1)
        var mid_close: number = search(markers.patterns.bclose, 'bnW', startln - 1)
        if mid_open == 0 && mid_close == 0
            execute 'normal! ' .. startln .. 'GV' .. endln .. 'G'
            return 'block_comment'
        endif
    endif

    if match(ln, markers.patterns.blank) == 0
        normal! V
        return 'blank_line'
    else
        normal! V
        return 'uncommented'
    endif
enddef
