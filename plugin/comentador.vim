if !has('vim9script') || v:version < 900
    echoerr "Comentador: Needs Vim v9 or higher"
    finish
endif

vim9script

if exists('g:loaded_comentador') && g:loaded_comentador
    finish
endif
g:loaded_comentador = 1

import autoload '../autoload/comentador/toggle.vim'

command! -range -bar Comentador call toggle.Toggle(<line1>, <line2>)

nnoremap <expr> <Plug>(Comentador) toggle.Toggle()
nnoremap <expr> <Plug>(ComentadorLine) toggle.Toggle() .. '_'
xnoremap <expr> <Plug>(Comentador) toggle.Toggle()

nnoremap <expr> <Plug>(ComentadorBlock) toggle.ToggleBlock()
nnoremap <expr> <Plug>(ComentadorBlockLine) toggle.ToggleBlock() .. '_'
xnoremap <expr> <Plug>(ComentadorBlock) toggle.ToggleBlock()


if !hasmapto('<Plug>(Comentador)')
    nnoremap gc <Plug>(Comentador)
    xnoremap gc <Plug>(Comentador)
endif

if !hasmapto('<Plug>(ComentadorLine)')
    nnoremap gcc <Plug>(ComentadorLine)
endif

if !hasmapto('<Plug>(ComentadorBlock)')
    nnoremap gb <Plug>(ComentadorBlock)
    xnoremap gb <Plug>(ComentadorBlock)
endif

if !hasmapto('<Plug>(ComentadorBlockLine)')
    nnoremap gbb <Plug>(ComentadorBlockLine)
endif

augroup comentador
    autocmd!
    autocmd FileType * unlet! b:comentador_markers
augroup END
