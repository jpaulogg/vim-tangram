" snip120.vim - <https://github.com/jpaulogg/vim-snip120.git>

" Author:  João Paulo G. Garcia
" Licence: public domain
" Last Change: 2021/01/14  

" Snippets with only 120 lines of vimscript!
"
" Insert snippets with CTRL-S_I. Move through tags with CTRL-S_N (next) and
" CTRL-S_P (previous). For faster movement in SELECT mode you can also  use
" CTRL-N  and  CTRL-P.  Check  the  comments  below  for  more  info's  and
" other mappings.

if exists('g:loaded_snip120')
	finish
endif
let g:loaded_snip120 = 1

" you can change both snippets directory path and tags delimiters below.
" (delimiters must start with unique '<' and end with unique '>')
let s:dir   = "~/.config/nvim/snippets/"
let s:start = '<{'                      " example: let s:start = '<-:'
let s:end   = '}>'                      "          let s:end   = ':->'

" INSERT SNIPPET
" mappings {{{1
imap <unique><silent> <C-s>i <C-c>:call <SID>Insert()<CR>

" jump through tags
imap <unique><silent> <C-s>n <C-c>:call  <SID>Search('z')<CR>
smap <unique><silent> <C-s>n <C-c>:call  <SID>Search('z')<CR>
smap <unique><silent> <C-n>  <C-c>:call  <SID>Search('z')<CR>
imap <unique><silent> <C-s>p <C-c>h:call <SID>Search('b')<CR>
smap <unique><silent> <C-s>p <C-c>h:call <SID>Search('b')<CR>
smap <unique><silent> <C-p>  <C-c>h:call <SID>Search('b')<CR>

" add/delete delimiters 's:start' end 's:end' to/from selection
vmap <unique> <C-s>a <C-c>:call <SID>AddSurround()<CR>
vmap <unique> <C-s>d <C-c>:call <SID>DelSurround()<CR>

" expand simple expression inside tags (like '<{strftime('%c')}>')
" overrides unnamed register
smap <unique> <C-s>e <C-s>d<C-g>c<C-r>=<C-r>"<CR><C-c>v`<<C-g>

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
    let l:tag = search(s:end, a:flags)
	if l:tag
		exec "normal va<\<C-g>"    
	endif
endfunction

function s:AddSurround()
	call cursor(line("'>"), col("'>"))
	exec 'normal a'.s:end
	call cursor(line("'<"), col("'<"))
	exec 'normal i'.s:start
	exec "normal va>\<C-g>"
endfunction

function s:DelSurround()
	call search(s:start, 'bc')
	exec 'normal '.len(s:start).'x'
	let l = line('.')
	let c = col('.')
	call search(s:end, 'z')
	exec 'normal '.len(s:end).'xh'
	exec 'normal v'.l.'G'.c."|\<C-g>"
endfunction
" }}}1

" COMPLETE SNIPPETS NAMES
set completefunc=SnipComplete    " {{{1

function SnipComplete(findstart, base) abort
    if a:findstart
        let l:line  = getline('.')
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
