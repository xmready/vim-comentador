vim9script

export def GetLineRange(args: list<any>): list<number>
    return len(args) > 1
        ? [args[0], args[1]]
        : [line("'["), line("']")]
enddef

export def SetLines(
        firstln: number,
        lastln: number,
        lines: list<string>,
        reset_cursor: bool = 0
): void
    if len(lines) < (lastln - firstln + 1)
        deletebufline('', firstln + len(lines), lastln)
    elseif len(lines) > (lastln - firstln + 1)
        append(firstln, ['', ''])
    endif

    setline(firstln, lines)

    if reset_cursor
        execute 'normal! ' .. firstln .. 'G^'
    endif
enddef

export def InsertAtMarker(
        has_close: bool,
        close: string
): void
    if has_close
        search(close, 'W', line('.'))
        normal! h
    else
        execute 'normal! A  '
    endif

    startinsert
enddef
