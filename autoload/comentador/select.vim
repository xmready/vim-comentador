vim9script

export def DoSelectComment(markers: dict<string>): string
    var ln: string = getline('.')

    if match(ln, '^\s*' .. markers.iopen .. '.*' .. (empty(markers.iclose) ? '$' : markers.iclose .. '\s*$')) == 0
        normal! V
        return 'inline_comment'
    elseif match(ln, '^\s*' .. markers.bopen .. '.*' .. markers.bclose .. '\s*$') != -1
        normal! V
        return 'inline_block_comment'
    elseif match(ln, '^\s*' .. markers.bopen .. '\s*$') == 0
        normal! ^
        var endln: number = search(markers.bclose, 'nW')
        var mid_open: number = search('^\s*' .. markers.bopen .. '\s*$', 'nW', endln - 1)
        if mid_open == 0
            execute 'normal! V' .. endln .. 'G'
            return 'block_comment'
        else
            normal! V
            return 'missing_bmark'
        endif
    elseif match(ln, '^\s*' .. markers.bclose .. '\s*$') == 0
        var startln: number = search(markers.bopen, 'bnW')
        var mid_open: number = search('^\s*' .. markers.bclose .. '\s*$', 'bnW', startln - 1)
        if mid_open == 0
            execute 'normal! V' .. startln .. 'G'
            return 'block_comment'
        else
            normal! V
            return 'missing_bmark'
        endif
    endif

    var startln: number = search('^\s*' .. markers.bopen .. '\s*$', 'bnW')
    var endln: number = search('^\s*' .. markers.bclose .. '\s*$', 'nW')

    if (startln > 0) && (endln > 0) && (startln < endln)
        var mid_open: number = search('^\s*' .. markers.bopen .. '\s*$', 'nW', endln - 1)
        var mid_close: number = search('^\s*' .. markers.bclose .. '\s*$', 'bnW', startln - 1)
        if mid_open == 0 && mid_close == 0
            execute 'normal! ' .. startln .. 'GV' .. endln .. 'G'
            return 'block_comment'
        endif
    endif

    if match(ln, '^\s*$') == 0
        normal! V
        return 'blank_line'
    else
        normal! V
        return 'uncommented'
    endif
enddef
