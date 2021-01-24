# tangram.vim

This is the "raw" branch. Only ~85 lines of code. No global variables, no concerns with registers
and things like that, just the script with my default options. Any changes must be done directly in
the script, but it's not like this is much more difficult than doing it on your vimrc.

## Features

- snippets by file type (easy to access when editing another file type)
- accepts placeholders with vim expression
- replaces all occurrences of selected placeholder at once
- handles nested placeholders well 
- easy to jump through placeholders
- very light, only ~143 lines of code.

## Installation

To install "raw" branch:

```bash
# in vim use '~/.vim/' instead of '~/.config/nvim'
mkdir -p ~/.config/nvim/plugin/
cd ~/.config/nvim/plugin/
git clone -b raw https://github.com/jpaulogg/vim-tangram
rm -rf plugin/vim-tangram/.git* plugin/vim-tangram/README.md
```

## Similar Plugins

- [miniSnip](https://github.com/Jorengarenar/miniSnip)
