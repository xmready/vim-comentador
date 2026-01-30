vim9script

export def DoStrip(
        firstline: number,
        lastline: number,
        iopen: string,
        iclose: string,
        bopen: string,
        bclose: string
): void
    var lines: list<string> = getline(firstline, lastline)

    var block_pattern: string = '^\s*' .. bopen .. '\s*$\|^\s*' .. bclose .. '\s*$'
    var to_remove: list<number> = []

    for i: number in range(len(lines))
        if match(lines[i], block_pattern) != -1
            add(to_remove, i)
        endif
    endfor

    for i: number in reverse(to_remove)
        remove(lines, i)
    endfor

    var inline_pattern: string = '^\s*\zs' .. iopen .. '\s*\ze' .. (empty(iclose) ? '' : '\|\zs\s*' .. iclose .. '\s*\ze$')

    for i: number in range(len(lines))
        lines[i] = substitute(lines[i], inline_pattern, '', 'g')
    endfor

    var inline_block_pattern: string = '^\s*\zs' .. bopen .. '\s*\ze\|\zs\s*' .. bclose .. '\s*\ze$'

    for i: number in range(len(lines))
        lines[i] = substitute(lines[i], inline_block_pattern, '', 'g')
    endfor

    setline(firstline, lines)

    if len(lines) < (lastline - firstline + 1)
        deletebufline('', firstline + len(lines), lastline)
    endif
enddef

export def DoStripLine(
        firstline: number,
        lastline: number,
        iopen: string,
        iclose: string,
        bopen: string,
        bclose: string
): void
    var lines: list<string> = getline(firstline, lastline)

    var inline_pattern: string = '^\s*\zs' .. iopen .. '\s*\ze' .. (empty(iclose) ? '' : '\|\zs\s*' .. iclose .. '\s*\ze$')

    for i: number in range(len(lines))
        lines[i] = substitute(lines[i], inline_pattern, '', 'g')
    endfor

    var inline_block_pattern: string = '^\s*\zs' .. bopen .. '\s*\ze\|\zs\s*' .. bclose .. '\s*\ze$'

    for i: number in range(len(lines))
        lines[i] = substitute(lines[i], inline_block_pattern, '', 'g')
    endfor

    setline(firstline, lines)
enddef

export def DoStripBlock(
        firstline: number,
        lastline: number,
        bopen: string,
        bclose: string
): void
    var lines: list<string> = getline(firstline, lastline)

    var block_pattern: string = '^\s*' .. bopen .. '\s*$\|^\s*' .. bclose .. '\s*$'
    var to_remove: list<number> = []

    for i: number in range(len(lines))
        if match(lines[i], block_pattern) != -1
            add(to_remove, i)
        endif
    endfor

    for i: number in reverse(to_remove)
        remove(lines, i)
    endfor

    setline(firstline, lines)

    if len(lines) < (lastline - firstline + 1)
        deletebufline('', firstline + len(lines), lastline)
    endif
enddef
