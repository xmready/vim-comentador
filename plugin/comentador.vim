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

nnoremap <expr>   <Plug>(Comentador) toggle.Toggle()
nnoremap <expr>   <Plug>(ComentadorLine) toggle.Toggle() .. '_'
xnoremap <expr>   <Plug>(Comentador) toggle.Toggle()
onoremap <silent> <Plug>(Comentador) :<C-U>call <SID>toggle.ToggleObject('inline', get(v:, 'operator', '') ==# 'c')<CR>

nnoremap <expr>   <Plug>(ComentadorBlock) toggle.ToggleBlock()
nnoremap <expr>   <Plug>(ComentadorBlockLine) toggle.ToggleBlock() .. '_'
xnoremap <expr>   <Plug>(ComentadorBlock) toggle.ToggleBlock()
onoremap <silent> <Plug>(ComentadorBlock) :<C-U>call <SID>toggle.ToggleObject('block', get(v:, 'operator', '') ==# 'c')<CR>


if !hasmapto('<Plug>(Comentador)', 'n')
    nnoremap gc  <Plug>(Comentador)
    nnoremap gcu <Plug>(Comentador)<Plug>(Comentador)
endif

if !hasmapto('<Plug>(Comentador)', 'x')
    xnoremap gc  <Plug>(Comentador)
endif

if !hasmapto('<Plug>(Comentador)', 'o')
    onoremap gc  <Plug>(Comentador)
endif

if !hasmapto('<Plug>(ComentadorLine)', 'n')
    nnoremap gcc <Plug>(ComentadorLine)
endif

if !hasmapto('<Plug>(ComentadorBlock)', 'n')
    nnoremap gb  <Plug>(ComentadorBlock)
    nnoremap gbu <Plug>(ComentadorBlock)<Plug>(ComentadorBlock)
endif

if !hasmapto('<Plug>(ComentadorBlock)', 'x')
    xnoremap gb  <Plug>(ComentadorBlock)
endif

if !hasmapto('<Plug>(ComentadorBlock)', 'o')
    onoremap gb  <Plug>(ComentadorBlock)
endif

if !hasmapto('<Plug>(ComentadorBlockLine)', 'n')
    nnoremap gbb <Plug>(ComentadorBlockLine)
endif

augroup comentador
    autocmd!
    autocmd FileType * unlet! b:comentador_markers
augroup END
