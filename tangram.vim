" tangram.vim - <https://github.com/jpaulogg/vim-tangram.git>

" Licence: public domain
" Last Change: 2021/01/14  

" Vim plugin for assemble code snippets, just like solving a tangram puzzle!

if exists('g:loaded_tangram')
	finish
endif
let g:loaded_tangram = 1

" USAGE {{{1
" First create a directory for saving your snippets files.
" These are the defaults paths for neovim and vim:
if has('nvim')
	let s:dir = $HOME."/.config/nvim/snippets/"
else
	let s:dir = $HOME.".vim/snippets/"
endif

" You can also define delimiters for snippets tags. They must start with
" unique '<' and end with unique '>'.   Example:
let s:start = '<{'                    " let s:start = '<-:'
let s:end   = '}>'                    " let s:end   = ':->'

" Create snippet files with the '.snip' extension.  Put  them  in  the  defined
" directory or in sub-directories by file type. When editing a  'r'  file,  you
" will have access to all snippets in  the  main  directory  and  in  the  'r/'
" sub-directory. That way, typing 'for' and pressing <C-s>i will first  attempt
" to insert r/for.snip file in the current line, and if it fails it will try to
" insert for.snip from  the  main  directory.  Typing  python/for  will  insert
" for.snip from python sub-directory.

" Snippets tags accept empty, default and expressions values. You can also put
" tags inside other tags (the plugin will select first the deepest tag).

" Example:
" pacotes <- c('<{data.table}>', '<{ggplot2}>', '<{...}>')
"
" for (p in pacotes) {
" 	if (!require(p, character.only = TRUE, quietly = TRUE)) {
" 		install.packages(p)
" 		library(p, character.only = TRUE)
" 	}
" }

" In insert mode <C-x><C-u> completes snippets  keyword ;  <C-s>i  insert  the
" snippet in the current line; <C-s>n and <C-s>p move through the snippet tags.

" In select mode, move with <C-n> and <C-p> (<C-s>n and <C-s>p still work); add
" or remove delimiters from current selection with <C-s>a and  <C-s>d;  expands
" simple expressions inside delimiters (like '<{strftime('%c')}>') with <C-s>e.

" MAPPINGS {{{1
imap <unique><silent> <C-s>i <C-c>:call <SID>Insert()<CR>

" jump through tags
imap <unique><silent> <C-s>n <C-c>:call  <SID>Search('z')<CR>
smap <unique><silent> <C-s>n <C-c>:call  <SID>Search('z')<CR>
smap <unique><silent> <C-n>  <C-c>:call  <SID>Search('z')<CR>
imap <unique><silent> <C-s>p <C-c>b:call <SID>Search('b')<CR>
smap <unique><silent> <C-s>p <C-c>b:call <SID>Search('b')<CR>
smap <unique><silent> <C-p>  <C-c>b:call <SID>Search('b')<CR>

" add/delete delimiters 's:start' end 's:end' to/from selection
vmap <unique> <C-s>a <C-c>:call <SID>AddSurround()<CR>
vmap <unique> <C-s>d <C-c>:call <SID>DelSurround()<CR>

" expand simple expression inside tags (like '<{strftime('%c')}>')
" overrides unnamed register
smap <unique> <C-s>e <C-s>d<C-g>c<C-r>=<C-r>"<CR><C-c>v`<<C-g>

" FUNCTIONS {{{1
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

" COMPLETE FUNCTION {{{1
set completefunc=SnipComplete

function SnipComplete(findstart, base)
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
			let l:input  = split(glob(s:dir."/*")) + split(glob(s:dir.&ft."/*"))
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
