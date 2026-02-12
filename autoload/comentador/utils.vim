vim9script

export def GetLineRange(args: list<any>): list<number>
    if len(args) > 1
        return [args[0], args[1]]
    elseif args[0] == 'char'
        execute "normal! V\<Esc>"
        return [line("'<"), line("'>")]
    endif

    return [line("'["), line("']")]
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

export def ExpandInline(
        pattern: string,
        startln: number,
        endln: number
): list<number>
    var start: number = startln
    var end: number = endln

    if match(getline(start), pattern) == -1
        return [0, 0]
    endif

    while (start > 1) && (match(getline(start - 1), pattern) != -1)
        start -= 1
    endwhile

    while (end < line('$')) && (match(getline(end + 1), pattern) != -1)
        end += 1
    endwhile

    return ExpandBlank(start, end)
enddef

export def ExpandBlank(
        startln: number,
        endln: number
): list<number>
    var start: number = startln
    var end: number = endln

    while (start > 1) && (getline(start - 1) =~ '^\s*$')
        start -= 1
    endwhile
    while (end < line('$')) && (getline(end + 1) =~ '^\s*$')
        end += 1
    endwhile

    return [start, end]
enddef

export def TrimBlank(
        startln: number,
        endln: number,
        inner: bool
): list<number>
    var start: number = startln
    var end: number = endln

    while (inner || end != line('$')) && (getline(start) =~ '^\s*$')
        start += 1
    endwhile
    while inner && (getline(end) =~ '^\s*$')
        end -= 1
    endwhile

    return [start, end]
enddef
