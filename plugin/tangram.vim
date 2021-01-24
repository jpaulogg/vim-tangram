" vim: set noet fdm=marker :
" 'zR' to open and 'zM' to close all folds

" tangram.vim - <https://github.com/jpaulogg/vim-tangram.git>
" Snippet plugin as minimal as a tangram puzzle!

" Branch:  master
" Licence: public domain
" Last Change: 2021/01/14  

if exists('g:loaded_tangram')
	finish
endif
let g:loaded_tangram = 1

" OPTIONS {{{1
" Define a directory for saving your snippets files. These are the defaults paths:
if has('nvim') && !exists('g:tangram_dir')
	let g:tangram_dir = $HOME."/.config/nvim/snippets/"
elseif !exists('g:tangram_dir')
	let g:tangram_dir = $HOME.".vim/snippets/"
endif

if g:tangram_dir !~ '/$'
	let g:tangram_dir .= '/'
endif

" You can also define delimiters for snippets place holders. They must start with
" single '<' and end with single '>'. Example:  let g:tangram_open  = '<-:'
if !exists('g:tangram_open')                  " let g:tangram_close = ':->'
	let g:tangram_open = '<{'
endif
if !exists('g:tangram_close')
	let g:tangram_close = '}>'
endif

" MAPPINGS {{{1
imap <unique><silent> <C-s>i <C-c>:call <SID>Insert()<CR>

" jump through place holders
nmap <silent> <SID>(select_next) :call search(g:tangram_open,   'z')<CR>va><C-g>
nmap <silent> <SID>(select_prev) :call search(g:tangram_close, 'be')<CR>va><C-g>

imap <unique> <C-s>n <C-c><SID>(select_next)
imap <unique> <C-s>p <C-c><SID>(select_prev)

" select next/previous inner placeholder
smap <unique> <C-s>n <C-c>`<<SID>(select_next)
smap <unique> <C-s>p <C-c>`><SID>(select_prev)

" select next/previous outter placeholder
smap <unique> <C-n>  <C-c>`><SID>(select_next)
smap <unique> <C-p>  <C-c>`<<SID>(select_prev)

" substitute all ocurrences of selected placeholder
smap <unique><silent> <C-s>s <C-c>:call <SID>SubstituteAll()<CR>

" expand simple expression within place holders - like '<{strftime('%c')}>'
smap <unique><silent> <C-s>e <C-c>:call <SID>ExpandExpression()<CR>

" add/delete 'g:tangram_open' and 'g:tangram_close' delimiters to/from selection
vmap <unique><silent> <C-s>a <C-c>:call <SID>Surround()<CR>
vmap <unique><silent> <C-s>d <C-c>:call <SID>Dsurround()<CR>

" INSERT SNIPPET {{{1
function s:Insert() abort
	let l:keyword = expand('<cWORD>')
	let l:subdir = &ft.'/'                                 " file type subdir
	let l:file = g:tangram_dir.l:subdir.l:keyword.'.snip'  " try subdir first

	if !filereadable(l:file)                               " otherwise, try main dir
		let l:file = g:tangram_dir.l:keyword.'.snip'
	endif
	delete _
	exec '-read '.l:file

	call cursor(line("'."), 1)
	call search(g:tangram_open, 'c')
	exec "normal va>\<C-g>"
endfunction

" DEALING WITH PLACEHOLDERS CONTENT {{{1
function s:ExpandVimExpr()
	let l:save_reg = @s
	normal gv"sy
	exec 'let l:expr = '.@s
	exec 'normal gvc'.l:expr
	normal v`<
	let @s = l:save_reg
endfunction

function s:SubstituteAll()
	let l:save_reg = @s
	normal gv"sy
	let l:sub = input('')
	exec '%s/'.@s.'/'.l:sub.'/g'
	let @s = l:save_reg
endfunction

" ADD/REMOVE PLACEHOLDERS DELIMITERS {{{1
function s:Surround()
	exec 'normal `>a'.g:tangram_close
	exec 'normal `<i'.g:tangram_open
	exec "normal va>"
endfunction

function s:Dsurround() abort
	let l:open_pos  = getpos("'<")[1:2]
	call cursor(l:open_pos)

	let l:close_pos = searchpairpos(g:tangram_open, '', g:tangram_close, 'n')
	if l:close_pos == [0, 0]
		return
	endif

	let l:open_len = len(g:tangram_open)
	exec 'normal '.l:open_len.'x'

	if l:open_pos[0] == l:close_pos[0]
		let l:close_pos[1] -= l:open_len
	endif
	call cursor(l:close_pos)

	let l:close_len = len(g:tangram_close)
	exec 'normal '.l:close_len.'x'

	" line and column for visual selection at the end
	if col('.') != 1
		normal be
	endif

	exec "normal v`<"
endfunction

" INS-COMPLETE FUNCTION {{{1
if &completefunc == ''
	set completefunc=TangramComplete
endif

function TangramComplete(findstart, base)
	if a:findstart
		let l:line  = getline('.')
		let l:start = col('.') - 1
		while l:start > 0 && l:line[start - 1] =~ '\k'
			let l:start -= 1
		endwhile
		return l:start
	else
        " complete subdirectories names like file completion
		if getline('.') =~ '/'
			let l:subdir = matchstr(getline('.'), "\\a\\+")
			let l:input  = split(glob(g:tangram_dir.l:subdir.'/*'))
		else
			let l:subdir = &ft.'/'
			let l:input  = split(glob(g:tangram_dir."*")) +
			             \ split(glob(g:tangram_dir.l:subdir."*"))
		endif
		let l:output = []
		for i in l:input
			if isdirectory(i)
				let l:item = fnamemodify(i, ":t").'/'
			else
				let l:item = fnamemodify(i, ":t:r")
			endif
			if l:item =~ a:base
				call add(l:output, {'word': l:item, 'menu': '[tangram]' })
			endif
		endfor
		return l:output
	endif
endfunction
" }}}1

