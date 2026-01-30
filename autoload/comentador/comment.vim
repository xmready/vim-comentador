vim9script

export def DoComment(
        firstline: number,
        lastline: number,
        iopen: string,
        iclose: string
): void
    var lines: list<string> = getline(firstline, lastline)
    var match: string = '\(^\s*\)\(.*\)\($\)'
    var replace: string = '\1' .. iopen .. ' ' .. '\2' .. (empty(iclose) ? '' : ' ' .. iclose) .. '\3'

    for i: number in range(len(lines))
        if match(lines[i], '^\s*$') == -1
            lines[i] = substitute(lines[i], match, replace, 'g')
        endif
    endfor

    setline(firstline, lines)
enddef

export def DoBlockComment(
        firstline: number,
        lastline: number,
        top: string,
        bottom: string
): void
    var indent: string = matchstr(getline(firstline), '^\s*')

    append(firstline - 1, indent .. top)
    append(lastline + 1, indent .. bottom)
enddef
