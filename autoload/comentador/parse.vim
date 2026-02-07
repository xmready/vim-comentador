vim9script

export def ParseMarkers(): dict<any>
    if exists('b:comentador_markers')
        return b:comentador_markers
    endif

    b:comentador_markers = {
        'iopen': '',
        'iclose': '',
        'bopen': '',
        'bclose': ''
    }

    const cms_parts: list<string> = split(&commentstring, '%s', 1)

    if empty(cms_parts[1])
        var bmarks: list<string> = ParseBlockMarkers()
        b:comentador_markers.iopen = cms_parts[0]
        b:comentador_markers.bopen = bmarks[0]
        b:comentador_markers.bclose = bmarks[1]
    else
        b:comentador_markers.iopen = ParseInlineMarker()
        b:comentador_markers.bopen = cms_parts[0]
        b:comentador_markers.bclose = cms_parts[1]

        if empty(b:comentador_markers.iopen)
            b:comentador_markers.iopen = cms_parts[0]
            b:comentador_markers.iclose = cms_parts[1]
        endif
    endif

    if empty(b:comentador_markers.iopen) && empty(b:comentador_markers.bopen)
        echoerr 'Comentador: No comment format defined for this filetype'
    endif

    for key in keys(b:comentador_markers)
        b:comentador_markers[key] = escape(trim(b:comentador_markers[key]), '/*')
    endfor

    b:comentador_markers.patterns = BuildPatterns(b:comentador_markers)

    b:comentador_markers.flags = {
        'has_bmarks': !empty(b:comentador_markers.bopen) && !empty(b:comentador_markers.bclose),
        'has_iclose': !empty(b:comentador_markers.iclose),
        'same_markers': (b:comentador_markers.bopen == b:comentador_markers.iopen)
            && (b:comentador_markers.bclose == b:comentador_markers.iclose),
    }

    return b:comentador_markers
enddef

def ParseBlockMarkers(): list<string>
    var [bopen, bclose] = ['', '']

    for item in ParseCommentsOption()
        var [flags, str] = [item[0], item[1]]

        if flags =~ 's1' && !empty(str)
            bopen = str
        endif

        if flags =~ 'ex' && !empty(str)
            bclose = str
        endif
    endfor

    return [bopen, bclose]
enddef

def ParseInlineMarker(): string
    var candidates: list<string> = []

    for item in ParseCommentsOption()
        var [flags, str] = [item[0], item[1]]

        if empty(flags) && !empty(str)
            add(candidates, str)
        endif
    endfor

    if empty(candidates)
        return ''
    endif

    sort(candidates, (a, b) => len(a) - len(b))
    return candidates[0]
enddef

def ParseCommentsOption(): list<list<string>>
    var parts: list<list<string>> = []
    for part in split(&comments, ',')
        var colonpos: number = stridx(part, ':')
        if colonpos != -1
            add(parts, [strpart(part, 0, colonpos), strpart(part, colonpos + 1)])
        endif
    endfor
    return parts
enddef

def BuildPatterns(markers: dict<any>): dict<string>
    var patterns: dict<string> = {}

    patterns.inline = '^\s*' .. markers.iopen .. '.*'
        .. (empty(markers.iclose) ? '$' : markers.iclose .. '\s*$')

    patterns.inline_comment = '\1' .. markers.iopen
        .. (empty(markers.iclose) ? ' \2' : ' \2 ' .. markers.iclose) .. '\3'

    patterns.inline_strip = '^\s*\zs' .. markers.iopen .. '\s*\ze'
        .. (empty(markers.iclose) ? '' : '\|\zs\s*' .. markers.iclose .. '\s*\ze$')

    if !empty(markers.bopen) && !empty(markers.bclose)
        patterns.bopen = '^\s*' .. markers.bopen .. '\s*$'
        patterns.bclose = '^\s*' .. markers.bclose .. '\s*$'
        patterns.block_either = patterns.bopen .. '\|' .. patterns.bclose
        patterns.inline_block = '^\s*' .. markers.bopen .. '.*' .. markers.bclose .. '\s*$'
        patterns.inline_block_comment = '\1' .. markers.bopen .. ' \2 ' .. markers.bclose .. '\3'
        patterns.inline_either = patterns.inline .. '\|' .. patterns.inline_block
        patterns.blank_or_block = '^\s*$' .. '\|' .. patterns.block_either

        patterns.inline_block_strip = '^\(\s*\)' .. markers.bopen
            .. '\s*\(.\{-}\)\s*' .. markers.bclose .. '\s*$'
    else
        patterns.inline_either = patterns.inline
        patterns.blank_or_block = '^\s*$'
    endif

    return patterns
enddef
