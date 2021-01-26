" vim: set noet fdm=marker :
" 'zR' to open and 'zM' to close all folds

" tangram.vim - <https://github.com/jpaulogg/vim-tangram.git>
" Code snippets as minimal as a tangram puzzle!

" Branch:  raw
" Licence: public domain
" Last Change: 2021/01/26  

if exists('g:loaded_tangram')
	finish
endif
let g:loaded_tangram = 1

" OPTION - snippets main directory
let s:dir = $HOME.'/.config/nvim/snippets/'

" MAPPINGS {{{1
imap <unique><silent> <C-s>i <C-c>:call <SID>Insert()<CR>
imap <unique> <C-s><C-i> <C-s>i

" jump through place holders
nmap <silent> <SID>(select_next) <Cmd>call search('<{', 'z')<CR>va><C-g>
nmap <silent> <SID>(select_prev) <Cmd>call search('}>', 'b')<CR>va><C-g>

imap <unique> <C-s>n <C-c><SID>(select_next)
imap <unique> <C-s>p <C-c><SID>(select_prev)
imap <unique> <C-s><C-n> <C-s>n
imap <unique> <C-s><C-p> <C-s>p

" <C-s>n in select mode jumps to inner placeholder. I only need this after <C-s>d.
smap <unique> <C-s>n <C-c><SID>(select_next)
smap <unique> <C-s>p <C-c>`<<SID>(select_prev)

smap <unique> <C-p>  <C-c>`<<SID>(select_prev)
smap <unique> <C-n>  <C-c>`><SID>(select_next)

" replace all occurrences of selected placeholder
smap <unique> <C-s>r <C-c>:call <SID>ReplaceAll()<CR>

" expand simple expression within place holders - like ' <{strftime('%c')}> '
" overrides 's' register
smap <unique> <C-s>e <C-c>F}"syi}gvc<C-r>=<C-r>s<CR><C-c>v`<<C-g>

" add/delete '<{' and '}>' delimiters to/from selection
vmap <unique><silent> <C-s>a <C-c>`>a}><C-c>`<i<{<C-c>va>
vmap <unique><silent> <C-s>d <C-c>`<2x`>F}2xbev`<

" INSERT FUNCTION {{{1
function s:Insert() abort
	let keyword = expand('<cWORD>')
	let subdir = &ft.'/'                         " file type subdir
	let file = s:dir.subdir.keyword.'.snip'      " try subdir first

	if !filereadable(file)                       " otherwise, try main dir
		let file = s:dir.keyword.'.snip'
	endif
	delete _
	exec '-read '.file

	call cursor(line("'."), 1)
	call search('<{', 'c')
	exec "normal va<\<C-g>"    
endfunction

" REPLACE FUNCTION {{{1
function s:ReplaceAll()
	normal gv"sy
	let new_text = input('')
	exec '%s/'.@s.'/'.new_text.'/g'
	call cursor(getpos("'<")[1:2])
	exec 'normal v'.(len(l:sub) - 1)."l\<C-g>"
endfunction

" COMPLETE FUNCTION {{{1
set completefunc=TangramComplete

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
		let dirs   = empty(&ft) ? s:dir : s:dir.&ft.','.s:dir
		let subdir = matchstr(getline('.'), '^\w\+/')
		let pathlist = empty(subdir) ? dirs : s:dir.subdir

		let output = map(globpath(pathlist, '*', 1, 1), {
		           \ list, item -> isdirectory(item) ?
		           \ fnamemodify(item, ':t').'/' : fnamemodify(item, ':t:r')
		           \ })

		call filter(output, 'v:val =~ "^".a:base')
		return map(output, {list, item -> {'word': item, 'menu': '[tangram]'}})
	endif
endfunction
