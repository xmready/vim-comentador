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

nnoremap <expr> <Plug>ComentadorToggle <SID>toggle.DoToggle()

if !hasmapto('<Plug>ComentadorToggle')
    nmap gcc <Plug>ComentadorToggle
endif

augroup comentador
    autocmd!
    autocmd FileType * if exists('b:comentador_markers') | unlet b:comentador_markers | endif
augroup END
