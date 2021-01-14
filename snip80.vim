" snip80.vim - <https://github.com/jpaulogg/vim-snip80.git>

" Author:  João Paulo G. Garcia
" Licence: public domain
" Last Change: 2021/01/13  

" Snippets with only 80 lines of code!
" Insert snippets with CTRL-S_I. Move through tags with CTRL-S_CTRL-N (next)
" and CTRL-S_CTRL-P (previous). Other functionalities in 'mappings' section.

" load once
if exists('g:loaded_snip80')
	finish
endif
let g:loaded_snip80 = 1

" you can change both snippets directory path and tags delimiter below.
" (delimiter must end with '>')
let s:dir   = "~/.config/nvim/snippets/"
let s:delim = '}>'

" INSERT SNIPPET
" mappings {{{1
imap <unique><silent> <C-s>i <C-c>:call   <SID>Insert()<CR>

" jump through tags
imap <unique><silent> <C-s><C-n> <C-c>:call  <SID>Search('z')<CR>
smap <unique><silent> <C-s><C-n> <C-c>:call  <SID>Search('z')<CR>
imap <unique><silent> <C-s><C-p> <C-c>h:call <SID>Search('b')<CR>
smap <unique><silent> <C-s><C-p> <C-c>h:call <SID>Search('b')<CR>

" add/delete delimiters '<{}>' to/from selection
vmap <unique> <C-s>a <C-c>`>a}><C-c>`<i<{<C-c>va<<C-g>
vmap <unique> <C-s>d <C-c>`<2xm`f>h2xhv``<C-g>

" expand simple expression inside tags (like '<{strftime('%c')}>', for example)
smap <unique> <C-s>e <C-s>d<C-g>"sc<C-r>=<C-r>s<CR><C-c>v`<<C-g>

" functions {{{1
function s:Insert() abort
	let l:name = getline('.')
	if !filereadable(s:dir.l:name.'.snip')
		let l:subdir = &ft.'/'
	else
		let l:subdir = ''
	endif
	delete _
    exec '-read '.s:dir.l:subdir.l:name.'.snip'
	call cursor(line("'."), col("'."))
	call s:Search('cz')
endfunction

function s:Search(flags) abort
    let l:tag = search(s:delim, a:flags)
	if l:tag > 0
		exec "normal va<\<C-g>"    
	endif
endfunction

" }}}1

" COMPLETE SNIPPETS NAMES
set completefunc=SnipComplete    " {{{1

function SnipComplete(findstart, base) abort
    if a:findstart
        let l:line = getline('.')
        let l:start = col('.') - 1
        while l:start > 0 && l:line[start - 1] =~ '\k'
            let l:start -= 1
        endwhile
        return l:start
    else
		if getline('.') =~ '/'
			let l:subdir = matchstr(getline('.'), "\\a\\+")
			let l:input  = split(glob(s:dir.l:subdir.'/*'))
		else
			let l:subdir = &ft
			let l:input  = split(glob(s:dir."/*")) + split(glob(s:dir.l:subdir."/*"))
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

" }}}

" vim: set fdm=marker :
