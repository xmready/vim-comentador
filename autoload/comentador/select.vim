vim9script

export def DoSelectComment(
        iopen: string,
        bopen: string,
        bclose: string
): string
    var ln: string = getline('.')

    if match(ln, '^\s*$') != -1
        return 'blank'
    elseif match(ln, '^\s*' .. iopen) == 0
        normal! V
        return 'commented'
    elseif match(ln, '^\s*' .. bopen) == 0
        normal! ^
        var endln: number = search(bclose, 'nW')
        execute 'normal! V' .. endln .. 'G'
        return 'commented'
    elseif match(ln, '^\s*' .. bclose) == 0
        var startln: number = search(bopen, 'bnW')
        execute 'normal! V' .. startln .. 'G'
        return 'commented'
    endif

    var startln: number = search('^\s*' .. bopen .. '$', 'bnW')
    var endln: number = search('^\s*' .. bclose .. '$', 'nW')

    if startln > 0 && endln > 0 && startln < endln
        var mid_open: number = search('^\s*' .. bopen .. '$', 'nW', endln - 1)
        if mid_open == 0
            execute 'normal! ' .. startln .. 'GV' .. endln .. 'G'
            return 'commented'
        endif
    endif

    return 'uncommented'
enddef
