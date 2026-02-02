vim9script

export def DoInlineComment(
        lines: list<string>,
        markers: dict<string>
): list<string>
    var mark_pattern: string = '\1' .. markers.iopen .. (empty(markers.iclose) ? ' \2' : ' \2 ' .. markers.iclose) .. '\3'

    return ApplyToLines(lines, markers, mark_pattern)
enddef

export def DoInlineBlockComment(
        lines: list<string>,
        markers: dict<string>
): list<string>
    var mark_pattern: string = '\1' .. markers.bopen .. ' \2 ' .. markers.bclose .. '\3'

    return ApplyToLines(lines, markers, mark_pattern)
enddef

export def DoBlockComment(
        lines: list<string>,
        markers: dict<string>
): list<string>
    var indent: string = matchstr(lines[0], '^\s*')

    insert(lines, indent .. markers.bopen, 0)
    add(lines, indent .. markers.bclose)

    lines[0] = substitute(lines[0], '\\', '', 'g')
    lines[-1] = substitute(lines[-1], '\\', '', 'g')

    return lines
enddef

def ApplyToLines(
        lines: list<string>,
        markers: dict<string>,
        mark_pattern: string
): list<string>
    var line_pattern: string = '\(^\s*\)\(.*\)\($\)'

    if indexof(lines, (_, str) => match(str, '^\s*$') == -1) == -1
        for i: number in range(len(lines))
            lines[i] = substitute(lines[i], line_pattern, mark_pattern, 'g')
            lines[i] = trim(lines[i])
        endfor
    else
        var block_pattern: string = ''
        if !empty(markers.bopen) && !empty(markers.bclose)
            block_pattern = '\|^\s*\(' .. markers.bopen .. '\|' .. markers.bclose .. '\)\s*$'
        endif

        for i: number in range(len(lines))
            if match(lines[i], '^\s*$' .. block_pattern) == -1
                lines[i] = substitute(lines[i], line_pattern, mark_pattern, 'g')
            endif
        endfor
    endif

    return lines
enddef
