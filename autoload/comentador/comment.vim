vim9script

export def DoComment(
        lines: list<string>,
        markers: dict<string>
): list<string>
    var line_pattern: string = '\(^\s*\)\(.*\)\($\)'
    var line_replace: string = '\1' .. markers.iopen .. ' ' .. '\2' .. (empty(markers.iclose) ? '' : ' ' .. markers.iclose) .. '\3'

    for i: number in range(len(lines))
        if match(lines[i], '^\s*$') == -1
            lines[i] = substitute(lines[i], line_pattern, line_replace, 'g')
        endif
    endfor

    return lines
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
