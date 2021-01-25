# tangram.vim

This is the "raw" branch. No global variables, no concerns with registers and things like that, just
the script with my default options. Any changes must be done directly in the script, but it's not
like this is much more difficult than doing it on your vimrc.

## Features

- snippets by file type
- easy to access when editing another file type (just type subdirectory before)
- completion function that works similar to file completion (will set `completefunc` option)
- accepts placeholders with vim expression
- replaces all occurrences of selected placeholder at once
- handles nested placeholders well 
- easy to jump through placeholders
- very light, only ~90 lines of code.

## Installation

To install "raw" branch:

```bash
# in vim use '~/.vim/' instead of '~/.config/nvim'
curl -fLo ~/.config/nvim/plugin/vim-tangram -- create-dirs \
	https://raw.githubusercontent.com/jpaulogg/vim-tangram/raw/tangram.vim
```

## Similar Plugins

- [miniSnip](https://github.com/Jorengarenar/miniSnip)
