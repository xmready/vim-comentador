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

nnoremap <Plug>(ComentadorToggle) <ScriptCmd>toggle.DoToggle()<CR>
nnoremap <Plug>(ComentadorToggleInlineBlock) <ScriptCmd>toggle.DoToggleInlineBlock()<CR>
xnoremap <Plug>(ComentadorToggleVisual) <ScriptCmd>toggle.DoToggleVisual()<CR>
xnoremap <Plug>(ComentadorToggleBlockVisual) <ScriptCmd>toggle.DoToggleBlockVisual()<CR>

noremenu Plugin.Comentador.Toggle <ScriptCmd>toggle.DoToggle()<CR>
xnoremenu Plugin.Comentador.ToggleVisual <ScriptCmd>toggle.DoToggleVisual()<CR>

if !hasmapto('<Plug>(ComentadorToggle)', 'n')
    nnoremap gcc <Plug>(ComentadorToggle)
endif

if !hasmapto('<Plug>(ComentadorToggleInlineBlock)', 'n')
    nnoremap gcb <Plug>(ComentadorToggleInlineBlock)
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
