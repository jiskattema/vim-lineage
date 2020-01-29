# Lineage

Run vimdiff on a currently open file, and a previous version from git.

## Installation

Install via your prefferred plugin manager, I'm using Plugin:
```vim
Plugin 'jiskattema/vim-lineage'
```

## Usage

Add the following to your .vimrc.
```vim
map <silent> <Leader>] :<C-U>call Lineage(v:count, 'next')<CR>
map <silent> <Leader>= :<C-U>call Lineage(v:count, 'prev')<CR>
```
