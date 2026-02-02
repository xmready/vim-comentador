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

nnoremap <expr> <Plug>(ComentadorToggleOperator) toggle.SetOperator('inline', 'motion')
nnoremap <expr> <Plug>(ComentadorToggle) toggle.SetOperator('inline', 'line')

nnoremap <expr> <Plug>(ComentadorToggleBlockOperator) toggle.SetOperator('block', 'motion')
nnoremap <expr> <Plug>(ComentadorToggleBlock) toggle.SetOperator('block', 'line')

xnoremap <Plug>(ComentadorToggleVisual) <ScriptCmd>toggle.DoToggleVisual()<CR>
xnoremap <Plug>(ComentadorToggleBlockVisual) <ScriptCmd>toggle.DoToggleBlockVisual()<CR>

if !hasmapto('<Plug>(ComentadorToggle)', 'n')
    nnoremap gc <Plug>(ComentadorToggleOperator)
    nnoremap gcc <Plug>(ComentadorToggle)
endif

if !hasmapto('<Plug>(ComentadorToggleBlock)', 'n')
    nnoremap gb <Plug>(ComentadorToggleBlockOperator)
    nnoremap gbb <Plug>(ComentadorToggleBlock)
endif

if !hasmapto('<Plug>(ComentadorToggleVisual)', 'x')
    xnoremap gc <Plug>(ComentadorToggleVisual)
endif

if !hasmapto('<Plug>(ComentadorToggleBlockVisual)', 'x')
    xnoremap gb <Plug>(ComentadorToggleBlockVisual)
endif

augroup comentador
    autocmd!
    autocmd FileType * unlet! b:comentador_markers
augroup END
