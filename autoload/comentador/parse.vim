vim9script

export def ParseComments(): dict<any>
    if exists('b:comentador_markers')
        return b:comentador_markers
    endif

    var iopen: string = ''
    var iclose: string = ''
    var bopen: string = ''
    var bclose: string = ''

    var cms_parts: list<string> = split(&commentstring, '%s', 1)
    var cms_open: string = get(cms_parts, 0, '')
    var cms_close: string = get(cms_parts, 1, '')

    if empty(cms_close)
        iopen = cms_open
        iclose = ''

        [bopen, bclose] = ParseBlockMarkers()
    else
        bopen = cms_open
        bclose = cms_close

        iopen = ParseInlineMarker()

        if empty(iopen)
            iopen = bopen
            iclose = bclose
        else
            iclose = ''
        endif
    endif

    if empty(iopen) && empty(bopen)
        echoerr 'Comentador: No comment format defined for this filetype'
    endif

    b:comentador_markers = {
        'iopen': iopen,
        'iclose': iclose,
        'bopen': bopen,
        'bclose': bclose
    }

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
    var bopen: string = ''
    var bclose: string = ''

    for part in split(&comments, ',')
        var colonpos: number = stridx(part, ':')
        if colonpos == -1
            continue
        endif
        var flags: string = strpart(part, 0, colonpos)
        var str: string = strpart(part, colonpos + 1)

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

    for part in split(&comments, ',')
        var colonpos: number = stridx(part, ':')
        if colonpos == -1
            continue
        endif
        var flags: string = strpart(part, 0, colonpos)
        var str: string = strpart(part, colonpos + 1)

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

def BuildPatterns(markers: dict<any>): dict<string>
    var patterns: dict<string> = {}

    patterns.blank = '^\s*$'
    patterns.line = '\(^\s*\)\(.*\)\($\)'

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
        patterns.blank_or_block = patterns.blank .. '\|' .. patterns.block_either

        patterns.inline_block_strip = '^\(\s*\)' .. markers.bopen
            .. '\s*\(.\{-}\)\s*' .. markers.bclose .. '\s*$'
    else
        patterns.inline_either = patterns.inline
        patterns.blank_or_block = patterns.blank
    endif

    return patterns
enddef
