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

    return CoreToggle('toggle', args)
enddef

export def ToggleBlock(...args: list<any>): any
    if !args
        &operatorfunc = getstacktrace()[0].funcref
        return 'g@'
    endif

    return CoreToggle('toggle_block', args)
enddef

def CoreToggle(
        mode: string,
        args: list<any>
): any
    var markers: dict<any> = parse.ParseMarkers()

    if mode == 'toggle_block' && !markers.flags.has_bmarks
        echoerr 'Comentador: Block comment markers unavailable for this filetype'
        return null
    endif

    var [firstln, lastln] = utils.GetLineRange(args)
    var lines: list<string> = getline(firstln, lastln)
    var has_range: bool = (firstln != lastln)
    var type: string = ''

    if has_range
        type = select.SelectTypeRange(lines, markers)
    else
        type = select.SelectTypeLine(firstln, lines, markers)
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
    endif

    if mode == 'toggle'
        if type =~ 'inline\|inline_block'
            lines = strip.StripLine(lines, markers)
        elseif type =~ 'uncommented\|blank'
            lines = comment.CommentInline(lines, markers)
        endif
    else
        var has_block: bool = match(lines, markers.patterns.block_either) != -1

        if (type !~ 'inline_block\|block' && has_block)
            echoerr 'Comentador: Improper block usage'
            return null
        elseif (type == 'inline') && !has_range && !markers.flags.same_markers
            return null
        elseif (type == 'inline_block') || (type == 'inline' && markers.flags.same_markers)
            lines = strip.StripLine(lines, markers)
        elseif (type =~ 'uncommented\|blank') && !has_range
            lines = comment.CommentInlineBlock(lines, markers)
        elseif match(lines, '^\s*\S') != -1
            lines = comment.CommentBlock(lines, markers)
        else
            return null
        endif
    endif

    utils.SetLines(firstln, lastln, lines)

    if (type == 'blank') && !has_range
        var has_close: bool = (mode == 'toggle') ? markers.flags.has_iclose : 1
        var close_mark: string = (mode == 'toggle') ? markers.iclose : markers.bclose

        if has_close
            search(close_mark, 'W', line('.'))
            normal! h
        else
            execute 'normal! A  '
        endif

        startinsert
    endif

    return null
enddef

export def ToggleObject(
        obj_type: string,
        inner: bool = 0
): void
    var markers: dict<any> = parse.ParseMarkers()

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
            return
        endif
    endif

    [startln, endln] = select.SelectTrimBlank(startln, endln, inner)

    if startln <= endln
        execute 'normal! ' .. startln .. 'GV' .. endln .. 'G'
    endif
enddef
