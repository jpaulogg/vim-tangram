" vim: set noet fdm=marker :
" 'zR' to open and 'zM' to close all folds

" tangram.vim - <https://github.com/jpaulogg/vim-tangram.git>
" Code snippets as minimal as a tangram puzzle!

" Branch:  raw
" Licence: public domain
" Last Change: 2021/01/17  

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

" jump to prev/next placeholder (outer level)
imap <unique> <C-s>n <C-c><SID>(select_next)
imap <unique> <C-s>p <C-c><SID>(select_prev)
imap <unique> <C-s><C-n> <C-s>n
imap <unique> <C-s><C-p> <C-s>p

smap <unique> <C-s>p <C-c>`<<SID>(select_prev)
" <C-s>n in select mode jumps to inner placeholder. I only need this after <C-s>d.
smap <unique> <C-s>n <C-c><SID>(select_next)

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

" INSERT {{{1
function s:Insert() abort
	let l:keyword = expand('<cWORD>')
	let l:subdir = &ft.'/'                         " file type subdir
	let l:file = s:dir.l:subdir.l:keyword.'.snip'  " try subdir first

	if !filereadable(l:file)                       " otherwise, try main dir
		let l:file = s:dir.l:keyword.'.snip'
	endif
	delete _
	exec '-read '.l:file

	call cursor(line("'."), 1)
	call search('<{', 'c')
	exec "normal va<\<C-g>"    
endfunction

" REPLACE {{{1
function s:ReplaceAll()
	normal gv"sy
	let l:sub = input('')
	exec '%s/'.@s.'/'.l:sub.'/g'
	call cursor(getpos("'<")[1:2])
	exec 'normal v'.(len(l:sub) - 1)."l\<C-g>"
endfunction

" COMPLETE FUNCTION {{{1
set completefunc=TangramComplete

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
			let l:input  = split(glob(s:dir.l:subdir.'/*'))
		else
			let l:subdir = &ft.'/'
			let l:input  = split(glob(s:dir."*")) +
			              \split(glob(s:dir.l:subdir."*"))
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
