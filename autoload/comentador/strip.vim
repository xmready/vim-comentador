vim9script

export def StripBlock(
        lines: list<string>,
        markers: dict<any>
): list<string>
    var to_remove: list<number> = []

    for i: number in range(len(lines))
        if match(lines[i], markers.patterns.block_either) != -1
            add(to_remove, i)
        endif
    endfor

    for i: number in reverse(to_remove)
        remove(lines, i)
    endfor

    return lines
enddef

export def StripLine(
        lines: list<string>,
        markers: dict<any>
): list<string>
    if markers.flags.has_bmarks
        for i: number in range(len(lines))
            lines[i] = substitute(lines[i], markers.patterns.inline_strip, '', 'g')
            lines[i] = substitute(lines[i], markers.patterns.inline_block_strip, '\1\2', '')
        endfor
    else
        for i: number in range(len(lines))
            lines[i] = substitute(lines[i], markers.patterns.inline_strip, '', 'g')
        endfor
    endif

    return lines
enddef
