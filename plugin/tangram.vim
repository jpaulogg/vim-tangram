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
imap <unique> <C-s><C-i> <C-s>i

" jump through place holders
nmap <silent> <SID>(select_next) :call search(g:tangram_open,   'z')<CR>va><C-g>
nmap <silent> <SID>(select_prev) :call search(g:tangram_close, 'be')<CR>va><C-g>

imap <unique> <C-s>n <C-c><SID>(select_next)
imap <unique> <C-s>p <C-c><SID>(select_prev)
imap <unique> <C-s><C-n> <C-s>n
imap <unique> <C-s><C-p> <C-s>p

" select next/previous inner placeholder
smap <unique> <C-s>n <C-c>`<<SID>(select_next)
smap <unique> <C-s>p <C-c>`><SID>(select_prev)

" select next/previous outter placeholder
smap <unique> <C-n>  <C-c>`><SID>(select_next)
smap <unique> <C-p>  <C-c>`<<SID>(select_prev)

" substitute all ocurrences of selected placeholder
smap <unique><silent> <C-s>r <C-c>:call <SID>ReplaceAll()<CR>

" expand simple expression within place holders - like '<{strftime('%c')}>'
smap <unique><silent> <C-s>e <C-c>:call <SID>ExpandVimExpr()<CR>

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
	exec 'let l:expr = '.substitute(@s, g:tangram_open.'\|'.g:tangram_close, '', 'g')
	exec 'normal gvc'.l:expr
	exec "normal v`<\<C-g>"
	let @s = l:save_reg
endfunction

function s:ReplaceAll()
	let l:save_reg = @s
	normal gv"sy
	let l:sub = input('')
	exec '%s/'.@s.'/'.l:sub.'/g'
	call cursor(line("'<"), col("'<"))
	exec 'normal v'.(len(l:sub) - 1)."l\<C-g>"
	let @s = l:save_reg
endfunction

" ADD/REMOVE PLACEHOLDERS DELIMITERS {{{1
function s:Surround()
	exec 'normal `>a'.g:tangram_close."\<Esc>"
	exec 'normal `<i'.g:tangram_open."\<Esc>"
	exec "normal va>"
endfunction

function s:Dsurround() abort
	let l:open_pos  = cursor(line("'<"), col("'<"))
	call cursor(l:open_pos)

	let l:close_pos = searchpairpos(g:tangram_open, '', g:tangram_close, 'n')
	if l:close_pos == [0, 0]
		return
	endif

	let l:open_len = len(g:tangram_open)
	exec 'normal '.l:open_len.'x'

	" if open and close are in the same line
	if l:open_pos[0] == l:close_pos[0]
		let l:close_pos[1] -= l:open_len
	endif
	call cursor(l:close_pos)

	let l:close_len = len(g:tangram_close)
	exec 'normal '.l:close_len.'x'

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
		let line  = getline('.')
		let start = col('.') - 1
		while start > 0 && line[start - 1] =~ '\k'
			let start -= 1
		endwhile
		return start
	else
        " complete subdirectories names like file completion
		let dirs   = empty(&ft) ? g:tangram_dir : s:dir.&ft.', '.s:dir
		let subdir = matchstr(getline('.'), '^\w\+/')
		let path   = empty(subdir) ? dirs : g:tangram_dir.subdir

		let output = map(globpath(path, '*', 1, 1), {
					\ list, item -> isdirectory(item) ?
					\ fnamemodify(item, ':t').'/' : fnamemodify(item, ':t:r')})

		call filter(output, 'v:val =~ "^".a:base')
		return map(output, {list, item -> {'word': item, 'menu': '[tangram]'}})
	endif
endfunction
