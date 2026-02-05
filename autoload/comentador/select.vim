vim9script

export def SelectTypeLine(
        startln: number,
        lines: list<string>,
        markers: dict<any>
): string
    if match(lines, markers.patterns.inline) != -1
        return 'inline'
    endif

    if markers.flags.has_bmarks
        if match(lines, markers.patterns.inline_block) != -1
            return 'inline_block'
        elseif match(lines, markers.patterns.bopen) == 0
            cursor(startln, 1)
            var block_end: number = search(markers.patterns.bclose, 'nW')
            var mid_open: number = search(markers.patterns.bopen, 'nW', block_end - 1)
            if (mid_open != 0) || (block_end == 0)
                return 'missing_bmark'
            else
                execute 'normal! V' .. block_end .. "G\<Esc>"
                return 'block'
            endif
        elseif match(lines, markers.patterns.bclose) == 0
            cursor(startln, 1)
            var block_start: number = search(markers.patterns.bopen, 'bnW')
            var mid_close: number = search(markers.patterns.bclose, 'bnW', block_start - 1)
            if (mid_close != 0) || (block_start == 0)
                return 'missing_bmark'
            else
                execute 'normal! V' .. block_start .. "G\<Esc>"
                return 'block'
            endif
        endif

        var block_start: number = search(markers.patterns.bopen, 'bnW')
        var block_end: number = search(markers.patterns.bclose, 'nW')

        if (block_start > 0) && (block_end > 0) && (block_start < block_end)
            var mid_open: number = search(markers.patterns.bopen, 'nW', block_end - 1)
            var mid_close: number = search(markers.patterns.bclose, 'bnW', block_start - 1)
            if (mid_open == 0) && (mid_close == 0)
                execute 'normal! ' .. block_start .. 'GV' .. block_end .. "G\<Esc>"
                return 'block'
            endif
        endif
    endif

    if match(lines, markers.patterns.blank) == 0
        return 'blank'
    else
        return 'uncommented'
    endif
enddef

export def SelectTypeRange(
        lines: list<string>,
        markers: dict<any>
): string
    if markers.flags.has_bmarks
        var first_is_bopen: bool = match(lines[0], markers.patterns.bopen) != -1
        var last_is_bclose: bool = match(lines[-1], markers.patterns.bclose) != -1

        if first_is_bopen != last_is_bclose
            return 'missing_bmark'
        elseif first_is_bopen && last_is_bclose
            return 'block'
        elseif match(lines, markers.patterns.inline_block) != -1
            return 'inline_block'
        endif
    endif

    if match(lines, markers.patterns.inline) != -1
        return 'inline'
    else
        return 'uncommented'
    endif
enddef
