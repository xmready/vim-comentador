vim9script

export def DoParseComments(): dict<string>
    if exists('b:comentador_markers')
        return b:comentador_markers
    endif

    var iopen: string = ''
    var iclose: string = ''
    var bopen: string = ''
    var bclose: string = ''

    var cms_parts: list<string> = split(&commentstring, '%s', 1)
    var cms_open = get(cms_parts, 0, '')
    var cms_close = get(cms_parts, 1, '')

    if empty(cms_close)
        iopen = cms_open
        iclose = ''

        [bopen, bclose] = ParseBlockMarkers()

        if empty(bopen)
            bopen = ''
            bclose = ''
        endif
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
        b:comentador_markers[key] = trim(b:comentador_markers[key])
        b:comentador_markers[key] = escape(b:comentador_markers[key], '/*')
    endfor

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
