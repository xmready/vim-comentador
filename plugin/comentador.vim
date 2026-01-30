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

command! -nargs=0 ComentadorToggle toggle.DoToggle()

noremap <Plug>ComentadorToggle <ScriptCmd>toggle.DoToggle()<CR>
xnoremap <Plug>ComentadorToggleVisual <ScriptCmd>toggle.DoToggleVisual()<CR>

noremenu Plugin.Comentador.Toggle <ScriptCmd>toggle.DoToggle()<CR>
xnoremenu Plugin.Comentador.ToggleVisual <ScriptCmd>toggle.DoToggleVisual()<CR>

if !hasmapto('<Plug>ComentadorToggle')
    nmap gcc <Plug>ComentadorToggle
endif

if !hasmapto('<Plug>ComentadorToggleVisual', 'x')
    xmap gc <Plug>ComentadorToggleVisual
endif

augroup comentador
    autocmd!
    autocmd FileType * if exists('b:comentador_markers') | unlet b:comentador_markers | endif
augroup END
