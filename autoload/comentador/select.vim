vim9script

export def DoSelectComment(markers: dict<string>): string
    var ln: string = getline('.')

    if match(ln, '^\s*' .. markers.iopen) == 0
        normal! V
        return 'commented'
    elseif match(ln, '^\s*' .. markers.bopen) == 0
        normal! ^
        var endln: number = search(markers.bclose, 'nW')
        execute 'normal! V' .. endln .. 'G'
        return 'commented'
    elseif match(ln, '^\s*' .. markers.bclose) == 0
        var startln: number = search(markers.bopen, 'bnW')
        execute 'normal! V' .. startln .. 'G'
        return 'commented'
    endif

    var startln: number = search('^\s*' .. markers.bopen .. '$', 'bnW')
    var endln: number = search('^\s*' .. markers.bclose .. '$', 'nW')

    if startln > 0 && endln > 0 && startln < endln
        var mid_open: number = search('^\s*' .. markers.bopen .. '$', 'nW', endln - 1)
        if mid_open == 0
            execute 'normal! ' .. startln .. 'GV' .. endln .. 'G'
            return 'commented'
        endif
    endif

    return 'uncommented'
enddef
