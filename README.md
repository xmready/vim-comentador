# Comentador

A Vim9script plugin for toggling inline and block comments with full operator-pending support.

## Features

- Operator-pending mode: `gc{motion}` and `gb{motion}`
- Line-wise commands: `gcc` and `gbb`
- Visual mode: `gc` and `gb`
- Automatic marker detection from `'commentstring'` and `'comments'`
- Smart toggle: comments or uncomments based on context
- Supports inline (`//`), inline-block (`/* */`), and multi-line block comments

## Requirements

- Vim 9.0 or higher.

## Installation

<details>
<summary>vim-plug</summary>

```vim
Plug 'xmready/vim-comentador'
```
</details>

<details>
<summary>lazy.nvim</summary>

```lua
{ 'xmready/vim-comentador' }
```
</details>

<details>
<summary>packer.nvim</summary>

```lua
use 'xmready/vim-comentador'
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

| Mode   | Mapping      | Action                                           |
|--------|--------------|--------------------------------------------------|
| Normal | `gc{motion}` | Toggle inline comments over {motion}             |
| Normal | `gcc`        | Toggle inline comment on [count] lines           |
| Normal | `gcu`        | Uncomment contiguous inline comments             |
| Normal | `gb{motion}` | Toggle block comments over {motion}              |
| Normal | `gbb`        | Toggle inline-block comment on [count] lines     |
| Normal | `gbu`        | Uncomment contiguous inline-block comments       |
| Visual | `gc`         | Toggle comments on selection                     |
| Visual | `gb`         | Toggle multi-line block comment around selection |

> [!TIP]
> Use `gcc` to uncomment any comment type.
>
> Use `gbb` when you specifically want to comment or uncomment inline-block style comments.

### Behavior Details

**`gcc`**
- Commenting: Adds inline comment markers to the line
- On a blank line, positions cursor for typing
- Uncommenting: Removes inline, inline-block, *and* multi-line block comments
- Errors on "Improper block usage"

**`gc{motion}`**
- Commenting: Adds inline comment markers to each line in the motion
- Uncommenting: Removes inline, inline-block, *and* multi-line block comments
- Errors on "Improper block usage"

**`gcu`**
- Equivalent to `gcgc`
- Selects all adjacent commented lines (including surrounding blank lines)
- Removes inline, inline-block, and multi-line block comments

**`gbb`**
- Commenting: Adds inline-block markers (`/* text */`) to the line
- Uncommenting: Removes inline-block comments only
- Errors on "Block comment markers unavailable for this filetype", "Already inside a block comment", "Improper block usage", or "Existing inline comment"

**`gb{motion}`**
- Commenting: Wraps the motion range with block markers on separate lines
- Uncommenting: Removes inline-block comments only
- Errors on "Block comment markers unavailable for this filetype", "Already inside a block comment", "Improper block usage", or "Range contains multi-line block comment"

**`gbu`**
- Equivalent to `gbgb`
- Selects all adjacent inline-block commented lines
- Removes inline-block comments

**`{Visual}gc`**
- Commenting: Adds inline markers to each selected line
- Uncommenting: Removes multi-line block comments (if selection spans the entire
  block from opening to closing marker line), inline comments, and inline-block
  comments
- Errors on "Improper block usage"

**`{Visual}gb`**
- Commenting: Wraps selection with block markers on separate lines
- Uncommenting: Removes block marker lines if selection spans the entire block
- Errors on "Block comment markers unavailable for this filetype" or "Improper block usage"

### Text Objects

The `gc` and `gb` mappings work as text objects with other operators:

| Mapping | Action                                         |
|---------|------------------------------------------------|
| `dgc`   | Delete contiguous commented lines              |
| `cgc`   | Change contiguous commented lines              |
| `ygc`   | Yank contiguous commented lines                |
| `dgb`   | Delete contiguous inline-block commented lines |
| `cgb`   | Change contiguous inline-block commented lines |

Blank lines adjacent to comment blocks are included in the selection. With `d` or
`y`, leading blank lines are trimmed but trailing blank lines are preserved. With
`c`, blank lines are trimmed from both ends.

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

**`{Visual}gb` on lines 2-3** wraps in a multi-line block comment:

```javascript
function greet(name) {
    /*
    return "Hello, " + name;
    */
}
```

**`gcip` inside the function** comments the paragraph:

```javascript
function greet(name) {
    // return "Hello, " + name;
}
```

## Commands

| Command              | Action                            |
|----------------------|-----------------------------------|
| `:[range]Comentador` | Toggle inline comments on [range] |

Without a range, operates on the current line. Equivalent to `gc{motion}` for the
specified lines.

## Customization

### Mappings

Override default mappings using `<Plug>` mappings:

| Plug Mapping                  | Default | Mode                             | Description                  |
|-------------------------------|---------|----------------------------------|------------------------------|
| `<Plug>(Comentador)`          | `gc`    | Normal, Visual, Operator-pending | Inline comment operator      |
| `<Plug>(ComentadorLine)`      | `gcc`   | Normal                           | Inline comment [count] lines |
| `<Plug>(ComentadorBlock)`     | `gb`    | Normal, Visual, Operator-pending | Block comment operator       |
| `<Plug>(ComentadorBlockLine)` | `gbb`   | Normal                           | Inline-block [count] lines   |

Example:

```vim
nmap <leader>c  <Plug>(Comentador)
nmap <leader>cc <Plug>(ComentadorLine)
xmap <leader>c  <Plug>(Comentador)
omap <leader>c  <Plug>(Comentador)
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

## License

MIT
