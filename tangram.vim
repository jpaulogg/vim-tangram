" tangram.vim - <https://github.com/jpaulogg/vim-tangram.git>

" Licence: public domain
" Last Change: 2021/01/14  

" Snippet plugin as minimal as a tangram puzzle!

if exists('g:loaded_tangram')
	finish
endif
let g:loaded_tangram = 1

" OPTION - snippets main directory
let s:dir = $HOME.'.config/nvim/snippets/'

" MAPPINGS {{{1
imap <unique><silent> <C-s>i <C-c>:call <SID>Insert()<CR>

" jump through place holders
nmap <silent> <SID>(select_next) <Cmd>call search('<{',  'z')<CR>va><C-g>
nmap <silent> <SID>(select_prev) <Cmd>call search('}>', 'be')<CR>va><C-g>

imap <unique> <C-s>n <C-c><SID>(select_next)
smap <unique> <C-s>n <C-c><SID>(select_next)
smap <unique> <C-n>  <C-c><SID>(select_next)
imap <unique> <C-s>p <C-c><SID>(select_prev)
smap <unique> <C-s>p <C-c><SID>(select_prev)
smap <unique> <C-p>  <C-c><SID>(select_prev)

" add/delete 'g:tangram_open' and 'g:tangram_close' delimiters to/from selection
" <C-s>e mapping depends on <C-s>d
vmap <unique><silent> <C-s>a <C-c>`>a}><C-c>`<i<{<C-c>va><C-g>
vmap <unique><silent> <C-s>d <C-c>h2x`<2xv`>4h<C-g>

" expand simple expression within place holders - like '<{strftime('%c')}>'
" depends on <C-s>d mapping.
" overrides unnamed register
smap <unique> <C-s>e <C-s>d<C-g>c<C-r>=<C-r>"<CR><C-c>v`<<C-g>

" FUNCTIONS {{{1
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

" COMPLETE FUNCTION {{{1
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
		let s:dir = stdpath("config").'/snippets/'
		if getline('.') =~ '/'
			let l:subdir = matchstr(getline('.'), "\\a\\+")
			let l:input  = split(glob(s:dir.l:subdir.'/*'))
		else
			let l:subdir = &ft.'/'
			let l:input  = split(glob(s:dir."*")) +
			             \ split(glob(s:dir.l:subdir."*"))
		endif
		let l:output = []
		for i in l:input
			if isdirectory(i)
				let l:item = fnamemodify(i, ":t").'/'
			else
				let l:item = fnamemodify(i, ":t:r")
			endif
			if l:item =~ a:base
				call add(l:output, {'word': l:item, 'menu': '[snippet]' })
			endif
		endfor
		return l:output
	endif
endfunction
" }}}1

"  vim: set noet fdm=marker :
