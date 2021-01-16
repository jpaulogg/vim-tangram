" tangram.vim - <https://github.com/jpaulogg/vim-tangram.git>

" Licence: public domain
" Last Change: 2021/01/14  

" Snippet plugin written ins Vimscript. As minimal as a tangram puzzle!

if exists('g:loaded_tangram')
	finish
endif
let g:loaded_tangram = 1

" OPTIONS {{{1
" Define a directory for saving your snippets files. These are the defaults paths:
if has('nvim')
	let g:tangram_dir = $HOME."/.config/nvim/snippets/"
else
	let g:tangram_dir = $HOME.".vim/snippets/"
endif

" You can also define delimiters for snippets place holders. They must start with
" single '<' and end with single '>'. Example:  let g:tangram_open = '<-:'
if !exists('g:tangram_open')               " let g:tangram_close = ':->'
	let g:tangram_open = '<{'
endif
if !exists('g:tangram_close')
	let g:tangram_close = '}>'
endif

" MAPPINGS {{{1
imap <unique><silent> <C-s>i <C-c>:call <SID>Insert()<CR>

" jump through place holders
imap <unique><silent> <C-s>n <C-c>:call   <SID>Search(g:tangram_close,'cz')<CR>
smap <unique><silent> <C-s>n <C-c>:call   <SID>Search(g:tangram_open,  'z')<CR>
smap <unique><silent> <C-n>  <C-c>:call   <SID>Search(g:tangram_open,  'z')<CR>
imap <unique><silent> <C-s>p <C-c>:call   <SID>Search(g:tangram_open, 'cb')<CR>
smap <unique><silent> <C-s>p <C-c>F<:call <SID>Search(g:tangram_close, 'b')<CR>
smap <unique><silent> <C-p>  <C-c>F<:call <SID>Search(g:tangram_close, 'b')<CR>

" add/delete 'g:tangram_open' and 'g:tangram_close' delimiters to/from selection
" <C-s>e mapping depends on <C-s>d
vmap <unique> <C-s>a <C-c>:call <SID>Surround()<CR>
vmap <unique> <C-s>d <C-c>:call <SID>Dsurround()<CR>

" expand simple expression inside place holders (like '<{strftime('%c')}>')
" depends on <C-s>d mapping.
" overrides unnamed register
smap <unique> <C-s>e <C-s>d<C-g>c<C-r>=<C-r>"<CR><C-c>v`<<C-g>

" FUNCTIONS {{{1
function s:Insert() abort
	let l:keyword = expand('<cWORD>')
	let l:subdir = &ft.'/'
	let l:file = g:tangram_dir.l:subdir.l:keyword.'.snip'
	if !filereadable(l:file)                     " try to insert from file type subdirectory first
		let l:file = g:tangram_dir.l:keyword.'.snip'
	endif
	delete _
	exec '-read '.l:file
	call cursor(line("'."), 1)
	call s:Search(g:tangram_open, 'c')        " should find nested placeholders
endfunction

function s:Search(pattern, flags) abort
	if search(a:pattern, a:flags)                " placeholders must be inside '<' and '>'
		exec "normal va<\<C-g>"    
	endif
endfunction

function s:Surround()
	call cursor(line("'>"), col("'>"))
	exec 'normal a'.g:tangram_close
	call cursor(line("'<"), col("'<"))
	exec 'normal i'.g:tangram_open
	exec "normal va>\<C-g>"
endfunction

function s:Dsurround()
	call cursor(line("'>"), col("'>"))
	exec 'normal l'.len(g:tangram_open).'dhh'
	let l = line('.')
	let c = col('.') - len(g:tangram_open)
	call cursor(line("'<"), col("'<"))
	exec 'normal '.len(g:tangram_close).'x'
	exec 'normal v'.l.'G'.c."|\<C-g>"
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
		if getline('.') =~ '/'          " complete subdirectories names like file completion
			let l:subdir = matchstr(getline('.'), "\\a\\+")
			let l:input  = split(glob(g:tangram_dir.l:subdir.'/*'))
		else
			let l:input  = split(glob(g:tangram_dir."/*")) + split(glob(g:tangram_dir.&ft."/*"))
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

"  vim: set fdm=marker :
