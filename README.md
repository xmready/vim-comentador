# Comentador

![demo](https://gist.githubusercontent.com/xmready/f45fb61b401ccb14900b2cca9e8e9550/raw/20b00a32cf4a1d9a0e83c634eb903956e8537d26/comentador-demo.gif)

A Vim9script plugin for toggling both inline and block comments with full operator-pending support. While inspired by [tpope's Commentary plugin](https://github.com/tpope/vim-commentary), Comentador has its own unique behavior and features. A key difference being everything is a toggle. Another difference is not being able to comment an already commented line.

## Requirements

- Vim 9.0 or higher.

## Installation

<details>
<summary>Vim-Plug</summary>

```vim
Plug 'xmready/vim-comentador'
```
</details>

<details>
<summary>Pathogen</summary>

```bash
git clone https://github.com/xmready/vim-comentador ~/.vim/bundle/vim-comentador
```
</details>

<details>
<summary>Vundle</summary>

```vim
Plugin 'xmready/vim-comentador'
```
</details>

<details>
<summary>Vim packages</summary>

```bash
mkdir -p ~/.vim/pack/plugins/start
cd ~/.vim/pack/plugins/start
git clone https://github.com/xmready/vim-comentador.git
vim -u NONE -c "helptags vim-comentador/doc" -c q
```
</details>

## Usage

### Documentation

Use the `:help Comentador` command for a complete documentation of usage and behavior.

### Default Mappings

| Mode   | Mapping      | Action                                                                              |
|--------|--------------|-------------------------------------------------------------------------------------|
| Normal | `gcc`        | Toggle on comment [count] lines / Toggle off any comment type [count] lines         |
| Normal | `gc{motion}` | Toggle on comments over {motion} / Toggle off any comment type over {motion}        |
| Normal | `gcu`        | Toggle off contiguous comments / Toggle on comment                                  |
| Normal | `gbb`        | Toggle on block comment [count] lines / Toggle off block comments [count] lines     |
| Normal | `gb{motion}` | Toggle on block comment over {motion} / Toggle off block comments over {motion}     |
| Normal | `gbu`        | Toggle off contiguous inline-block comments / Toggle on inline-block comment        |
| Visual | `gc`         | Toggle on comments for selection / Toggle off any selected inline type comments     |
| Visual | `gb`         | Toggle on block comment for selection / Toggle off any selected block type comments |

> [!TIP]
> Use `gcc` to uncomment any comment type.
>
> Use `gbb` when you specifically want to comment or uncomment block style comments.

### Text Object Commands

The `gc` and `gb` mappings work as text objects with other operators:

| Commands | Action                                                  |
|----------|---------------------------------------------------------|
| `dgc`    | Delete any contiguous inline or single block comments   |
| `cgc`    | Change any contiguous inline or single block comments   |
| `ygc`    | Yank any contiguous inline or single block comments     |
| `dgb`    | Delete contiguous inline-block or single block comments |
| `cgb`    | Change contiguous inline-block or single block comments |

Blank lines adjacent to comment blocks are included in the selection. With `d` or
`y`, leading blank lines are trimmed but trailing blank lines are preserved. With
`c`, blank lines are trimmed from both ends.

### Command-line Commands

| Commands                  | Action                                                               |
|---------------------------|----------------------------------------------------------------------|
| `:[range]Comentador`      | Toggle on comments [range] / Toggle off any comment type [range]     |
| `:[range]ComentadorBlock` | Toggle on block comments [range] / Toggle off block comments [range] |

Without a range, commands operate on the current line.

## Customization

### Plug Mappings

Override default mappings using `<Plug>` mappings:

| Plug Mapping                  | Default | Mode                             |
|-------------------------------|---------|----------------------------------|
| `<Plug>(Comentador)`          | `gc`    | Normal, Visual, Operator-pending |
| `<Plug>(ComentadorLine)`      | `gcc`   | Normal                           |
| `<Plug>(ComentadorBlock)`     | `gb`    | Normal, Visual, Operator-pending |
| `<Plug>(ComentadorBlockLine)` | `gbb`   | Normal                           |

Example:

```vim
nnoremap <leader>c  <Plug>(Comentador)
nnoremap <leader>cc <Plug>(ComentadorLine)
xnoremap <leader>c  <Plug>(Comentador)
onoremap <leader>c  <Plug>(Comentador)
```

### Comment Markers

Markers are automatically parsed from `'commentstring'` and `'comments'` options
and cached in `b:comentador_markers`. For unsupported filetypes, set
`'commentstring'` for inline comments. If block markers are missing (no `s1` and
`ex` flags in `'comments'`), add them to the existing value:

```vim
autocmd FileType apache setlocal commentstring=#\ %s
autocmd FileType myfile setlocal comments+=s1:/*,ex:*/
```

> [!NOTE]
> If no comment format is defined for a filetype, all mappings will display
> "No comment format defined for this filetype".

## Examples

Given a JavaScript file:

```javascript
function greet(name) {
    return "Hello, " + name;
}
```

**`gcc` on line 2** adds an inline comment:

```javascript
function greet(name) {
    // return "Hello, " + name;
}
```

**`gbb` on line 2** adds an inline-block comment:

```javascript
function greet(name) {
    /* return "Hello, " + name; */
}
```

**`{Visual}gb` on lines 1-3** wraps in a multi-line block comment:

```javascript
/*
function greet(name) {
    return "Hello, " + name;
}
*/
```

**`gcap` on the function** comments the paragraph:

```javascript
// function greet(name) {
    // return "Hello, " + name;
// }
```

## License

MIT
