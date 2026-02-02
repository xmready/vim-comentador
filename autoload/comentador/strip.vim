vim9script

export def DoStripBlock(
        lines: list<string>,
        markers: dict<string>
): list<string>
    var block_pattern: string = '^\s*' .. markers.bopen .. '\s*$\|^\s*' .. markers.bclose .. '\s*$'
    var to_remove: list<number> = []

    for i: number in range(len(lines))
        if match(lines[i], block_pattern) != -1
            add(to_remove, i)
        endif
    endfor

    for i: number in reverse(to_remove)
        remove(lines, i)
    endfor

    return lines
enddef

export def DoStripLine(
        lines: list<string>,
        markers: dict<string>
): list<string>
    var inline_pattern: string = '^\s*\zs' .. markers.iopen .. '\s*\ze' .. (empty(markers.iclose) ? '' : '\|\zs\s*' .. markers.iclose .. '\s*\ze$')
    var inline_block_pattern: string = '^\(\s*\)' .. markers.bopen .. '\s*\(.\{-}\)\s*' .. markers.bclose .. '\s*$'

    for i: number in range(len(lines))
        lines[i] = substitute(lines[i], inline_pattern, '', 'g')
        lines[i] = substitute(lines[i], inline_block_pattern, '\1\2', '')
    endfor

    return lines
enddef
