vim9script

import autoload './parse.vim'
import autoload './select.vim'
import autoload './strip.vim'
import autoload './comment.vim'
import autoload './utils.vim'

export def Toggle(...args: list<any>): any
    if !args
        &operatorfunc = getstacktrace()[0].funcref
        return 'g@'
    endif

    var [firstln, lastln] = utils.GetLineRange(args)
    var markers: dict<any> = parse.ParseComments()
    var lines: list<string> = getline(firstln, lastln)
    var type: string = ''
    var has_range: bool = (firstln != lastln)

    if !has_range
        type = select.SelectTypeLine(firstln, lines, markers)
    else
        type = select.SelectTypeRange(lines, markers)
    endif

    if type == 'missing_bmark'
        echoerr 'Comentador: Improper block usage'
        return null
    elseif type == 'block'
        [firstln, lastln] = [line("'<"), line("'>")]
        lines = getline(firstln, lastln)
        lines = strip.StripBlock(lines, markers)
        utils.SetLines(firstln, lastln, lines, 1)
        return null
    elseif (type == 'inline') || (type == 'inline_block')
        lines = strip.StripLine(lines, markers)
    elseif (type == 'uncommented') || (type == 'blank')
        lines = comment.CommentInline(lines, markers)
    endif

    utils.SetLines(firstln, lastln, lines)

    if (type == 'blank') && !has_range
        utils.InsertAtMarker(markers.flags.has_iclose, markers.iclose)
    endif

    return null
enddef

export def ToggleBlock(...args: list<any>): any
    if !args
        &operatorfunc = getstacktrace()[0].funcref
        return 'g@'
    endif

    var markers: dict<any> = parse.ParseComments()

    if !markers.flags.has_bmarks
        echoerr 'Comentador: Block comment markers unavailable for this filetype'
        return null
    endif

    var [firstln, lastln] = utils.GetLineRange(args)
    var lines: list<string> = getline(firstln, lastln)
    var type: string = ''
    var has_block: bool = match(lines, markers.patterns.block_either) != -1
    var has_range: bool = (firstln != lastln)

    if !has_range
        type = select.SelectTypeLine(firstln, lines, markers)
    else
        type = select.SelectTypeRange(lines, markers)
    endif

    if type == 'missing_bmark'
        echoerr 'Comentador: Improper block usage'
        return null
    elseif type == 'block'
        echoerr 'Comentador: Already inside a block comment'
        return null
    elseif (type != 'inline_block') && has_block
        echoerr 'Comentador: Range contains multi-line block comment'
        return null
    elseif type == 'inline' && !has_range
        echoerr 'Comentador: Existing inline comment'
        return null
    elseif (type == 'inline_block') || (type == 'inline' && markers.flags.same_markers)
        lines = strip.StripLine(lines, markers)
    elseif (type == 'uncommented' || type == 'blank') && !has_range
        lines = comment.CommentInlineBlock(lines, markers)
    else
        lines = comment.CommentBlock(lines, markers)
        append(firstln, ['', ''])
    endif

    utils.SetLines(firstln, lastln, lines)

    if (type == 'blank') && !has_range
        utils.InsertAtMarker(1, markers.bclose)
    endif

    return null
enddef

export def ToggleObject(
        obj_type: string,
        inner: bool = false
): void
    var markers: dict<any> = parse.ParseComments()

    if obj_type == 'block' && !markers.flags.has_bmarks
        return
    endif

    var [startln, endln] = [line('.'), line('.')]
    var lines: list<string> = getline(startln, endln)
    var type: string = select.SelectTypeLine(startln, lines, markers)

    if type == 'block'
        [startln, endln] = [line("'<"), line("'>")]
        [startln, endln] = select.SelectExpandBlank(startln, endln)
    else
        var pattern: string
        if obj_type == 'block'
            pattern = markers.patterns.inline_block
        else
            pattern = markers.flags.has_bmarks
                ? markers.patterns.inline_either
                : markers.patterns.inline
        endif

        [startln, endln] = select.SelectMultiInline(pattern, startln, endln)

        if !startln
            normal! V
            return
        endif
    endif

    [startln, endln] = select.SelectTrimBlank(startln, endln, inner)

    if startln <= endln
        execute 'normal! ' .. startln .. 'GV' .. endln .. 'G'
    endif
enddef
