vim9script

export def CommentInline(
        lines: list<string>,
        markers: dict<any>
): list<string>
    var mark_pattern: string = markers.patterns.inline_comment

    return Comment(lines, markers, mark_pattern)
enddef

export def CommentInlineBlock(
        lines: list<string>,
        markers: dict<any>
): list<string>
    var mark_pattern: string = markers.patterns.inline_block_comment

    return Comment(lines, markers, mark_pattern)
enddef

export def CommentBlock(
        lines: list<string>,
        markers: dict<any>
): list<string>
    var indent: string = matchstr(lines[0], '^\s*')

    insert(lines, indent .. markers.bopen, 0)
    add(lines, indent .. markers.bclose)

    lines[0] = substitute(lines[0], '\\', '', 'g')
    lines[-1] = substitute(lines[-1], '\\', '', 'g')

    return lines
enddef

def Comment(
        lines: list<string>,
        markers: dict<any>,
        mark_pattern: string
): list<string>
    if indexof(lines, (_, str) => match(str, markers.patterns.blank) == -1) == -1
        for i: number in range(len(lines))
            lines[i] = substitute(lines[i], markers.patterns.line, mark_pattern, 'g')
            lines[i] = trim(lines[i])
        endfor
    else
        for i: number in range(len(lines))
            if match(lines[i], markers.patterns.blank_or_block) == -1
                lines[i] = substitute(lines[i], markers.patterns.line, mark_pattern, 'g')
            endif
        endfor
    endif

    return lines
enddef
