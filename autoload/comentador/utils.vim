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
