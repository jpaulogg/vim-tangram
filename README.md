# tangram.vim

Lightest snippet plugin on the vim market!  

For a while, I found different solutions for my basic needs with snippets. After noting that most
snippet plugins are much more complex and elaborate than my solutions, I decided to write this
little plugin. I hope it can be useful for other people as well.

Ps: If you want something even lighter, take a look at the [raw](https://github.com/jpaulogg/vim-tangram/tree/raw)
branch (~85 lines of code). No global variables, no concerns with registers and things like that,
just the script with my default options. Any changes must be done directly in the script, but it's
not like this is much more difficult than doing it on your vimrc.

## Features

- snippets by file type (easy to access when editing another file type)
- accept placeholders with default values
- accept placeholders with tags to replace in all file
- accept placeholders with vim expression
- very light, only ~143 lines of code.

## Mappings

`<C-s>i` inserts snippet that matches keyword under the cursor.

`<C-s>n` selects next placeholder (insert and select modes).

`<C-s>p` selects previous placeholder (insert and select modes).

`<C-s>d` deletes placeholders delimiters, keeping inner text (select mode).

`<C-s>r` prompts for text to replace all occurrences of selected placeholder (select mode).

`<C-s>e` expands vim expression within the selected placeholder (select mode).

Check [tangram-mappings] for all the mappings.

## Snippets files

Snippets files must be placed in the [tangram-directories](https://github.com/jpaulogg/vim-tangram/blob/cbdbc030c6ccd40d04e64e5363ff53520f70f867/doc/tangram.txt#L101-L113)
and must end with '.snip' extension, for example "~/.config/nvim/snippets/Foo.snip" (it is
recommended to capitalize first letter of main directory snippets). You can also place your snippets
in subdirectories within the main directory, for example "~/.config/nvim/snippets/python/foo.snip".

You can define the path to snippets directory with the `g:tangram_dir` variable.

## Placeholders

Placeholders marks parts of the snippet where you may want to insert some text, replace all its
occurrences, confirm the surrounded text or trigger a vim expression.

`<{...}>, <{replace all occurrences}>, <{default value}>, <{strftime('%c')}>`

You can define placeholders string with the placeholder delimiters with the `g:tangram_open` and
`g:tangram_close` [variables](https://github.com/jpaulogg/vim-tangram/blob/cbdbc030c6ccd40d04e64e5363ff53520f70f867/doc/tangram.txt#L115-L126).

## Installation

Install using your favorite package manager, or use (Neo)Vim's built-in package
support.

```vim
# vim-plug
Plug 'jpaulogg/vim-tangram'
:PlugInstall
```

```bash
# built-in package support (in vim use '~/.vim/' instead of '~/.config/nvim')
mkdir -p ~/.config/nvim/pack/anything/start/vim-tangram
cd ~/.config/nvim/pack/anything/start/vim-tangram
```

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
