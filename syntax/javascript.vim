" Vim syntax file
" Language:	JavaScript
" Maintainer:	Zoë C. Ma <zoe@zoe-translat.es>
" Updaters:	Claudio Fleiner <claudio@fleiner.com>,
"               Scott Shattuck (ss) <ss@technicalpursuit.com>
" Changes:	- Update regular expression literal skip patterns.
"               - Highlight delimiters (slashs) around regular expression
"                 literal.
"               - Adjust keywords and globals for modern ES.
"               - Mark use of future reserved words as errors.
"               - Mark syntax errors in number literals.
"               - Mark obsolete features as errors (0-initial octal literals,
"                 octal literal in strings).
"               - Mark trailing whitespace after line-continuation in strings
"                 as errors.
"               - Highlight 'use strict'.
"               - Highlight NodeJS shebang line (and other kinds of shebang
"                 lines as errors).
"               - Highlight ESLint configuration directives embedded in
"                 comments.
"               - Do not highlight keywords when they appear as properties.
"               - Highlight certain special properties such as 'prototype'.
"               - Highlight ALL_CAPS names as globals.


" based on the stock JavaScript syntax
" http://www.fleiner.com/vim/syntax/javascript.vim
" with modern ES features, focused on the balance of feature and simplicity
" tuning parameters:
" unlet javaScript_fold

if !exists("main_syntax")
    if version < 600
       syntax clear
    elseif exists("b:current_syntax")
	finish
    endif
   let main_syntax = 'javascript'
endif

let s:cpo_save = &cpo
set cpo&vim


syn keyword	javaScriptCommentTodo	TODO FIXME XXX TBD NOTE contained
syn match	javaScriptLineComment	"\/\/.*" contains=@Spell,javaScriptCommentTodo,javaScriptESLInlineDirective
syn match	javaScriptCommentSkip	"^[ \t]*\*\($\|[ \t]\+\)"
syn region	javaScriptComment	start="/\*"  end="\*/" contains=@Spell,javaScriptCommentTodo,@javaScriptESLint keepend

" ESLint in-comment config minilanguage
syn match	javaScriptESLInlineDirective	"\<eslint-disable-\%(next-\)\?line\>.*$" contained
" Eslint global enable/disable
syn match	javaScriptESLBlockDirective	"\<eslint-\%(en\|dis\)able\>.*\>" contained
" Severity directive or options
syn match	javaScriptESLBlockDirective	+\<eslint\%(\s\+\a\+\%(-\a\+\)\?:\s\+\%(\%(\("\|'\)\%(off\|warn\|error\)\1\|[0-2]\)\|\[.\+\]\),\?\)\+\ze\_s*\%(--\)*+ contained
" Multiline
syn match	javaScriptESLBlockDirective	"\<eslint-\%(en\|dis\)able-\%(next-\)\?line\_s*\%(\a\+\%(-\a\+\)\?\|,\s+\|,\%(\s*\n\)\+\s*\)\+" contained

syn cluster	javaScriptESLint	contains=javaScriptESLBlockDirective,javaScriptESLInlineDirective

" Obsolete number and escapes
" 0-prefixed octal integer literal (not after decimal point or exponent)
syn match	javaScriptDeprecated	+\%(\.\|[eE][+-]\?\)\@2<!\<0[0-7]\+\>+
" octal escape sequences
" up to two digits
syn match	javaScriptDeprecatedEscape	+\\[0-7]\{1,2}+ contained
" three digits, up to 377
syn match 	javaScriptDeprecatedEscape	+\\[0-3][0-7]\{2}+ contained
" Wrong binary, octal, or hexadecimal literals
syn match	javaScriptError			"\<0[XxOoBb][0-9A-Za-z]\+[Nn]\?\>"
syn match	javaScriptNumber		"\<0[Xx][0-9A-Fa-f]\+[Nn]\?\>"
syn match	javaScriptNumber		"\<0[Oo][0-7]\+[Nn]\?\>"
syn match	javaScriptNumber		"\<0[Bb][01]\+[Nn]\?\>"

" Escape sequences, includig line continuation in string literal
syn match	javaScriptEscape		+\\[\n0bfnrtv'"\\]+ contained
syn match	javaScriptLineContinueError	+\\\s\+$+ contained

" Shared by RE and String: numeric escape sequences
syn match	javaScriptREStringSpecial	"\\x[0-9A-Fa-f]\{2}" contained
syn match	javaScriptREStringSpecial	"\\u[0-9A-Fa-f]\{4}" contained
syn match	javaScriptREStringSpecial	"\\u{[0-9A-Fa-f]\{4,5}}" contained

syn region	javaScriptString	start=+\z("\|'\)+ skip=+\\\\\|\\"+ end=+\z1\|$+	contains=javaScriptDeprecatedEscape,javaScriptEscape,javaScriptLineContinueError,javaScriptREStringSpecial,@htmlPreproc
syn region	javaScriptTemplateString	start=+`+ skip=+\\\\\|\\`+ end=+`+ contains=javaScriptEmbed,javaScriptEscape,javaScriptDeprecatedEscape,@htmlPreproc

" Interpolation in template strings
syn region	javaScriptEmbed		start=+${+ end=+}+ contains=@javaScriptEmbededExpr

" Regular expression literals
" Special character classes in regular expressions
syn match	javaScriptRegExpSpecial	"\\[bdDwWsStrnvf0]" contained containedin=javaScriptRegExpLiteral
" backspace
syn match	javaScriptRegExpSpecial	"\[\\b\]" contained containedin=javaScriptRegExpLiteral
" caret notation
syn match	javaScriptRegExpSpecial	"\\c[A-Z]" contained containedin=javaScriptRegExpLiteral
" Character properties
syn match 	javaScriptRegExpSpecial	"\\[pP]{.\{-1,}}" contained containedin=javaScriptRegExpLiteral

syn region	javaScriptRegExpLiteral	matchgroup=javaScriptRegExpDelimit start=+[,(\[=+]\s*\zs/\ze[^/*]+ms=e-1 start=+[,(\[=+]\?\s\+\zs/\ze[^/*]+ms=e-1 skip=+\\\\\|\(\\\|\[[^]]*\)/+ end=+/[gimuys]\{0,4\}\s*$+ end=+/[gimuys]\{0,4\}\s*[+;.,)\]}]+me=e-1 end=+/[gimuys]\{0,4\}\s\+\/+me=e-1 contains=javaScriptRegExpSpecial,javaScriptREStringSpecial oneline

" strict mode directive
syn match	javaScriptStrict	"\_s*\_^\zs'use strict'\ze;"
syn match	javaScriptStrict	'\_s*\_^\zs"use strict"\ze;'

" Expressions and statements
syn keyword	javaScriptConditional	if else switch
syn keyword	javaScriptRepeat	while do
syn keyword	javaScriptBranch	break continue
"
" for...of
syn region	javaScriptFor		start="\%(\<for\|\<for\_s\+await\)\_s\{-}(" end=+)+ transparent contains=ALLBUT,javaScriptStatement,javaScriptConditional,javaScriptException
syn keyword	javaScriptOperator	for of await contained containedin=javaScriptFor

" common operators that looks like words
syn keyword	javaScriptOperator	new delete instanceof typeof in void yield await
syn keyword	javaScriptStatement	return debugger async
syn keyword	javaScriptLabel		case default
syn keyword	javaScriptException	try catch finally throw
syn keyword	javaScriptDeprecated	escape unescape with
" unused reserved words. Marked as errors because you shouldn't use them as
" top-level names
syn keyword	javaScriptReserved	enum implements interface package private protected public

" Import and export
syn keyword	javaScriptStatement	import
syn keyword	javaScriptStatement	export
syn keyword	javaScriptStatement	as from

" These are statement components, but we're going to use 'StorageClass'
" analogously
syn keyword	javaScriptDeclaration	var let const

" special values
syn keyword	javaScriptUndefined	undefined

" not an exhaustive list
syn keyword	javaScriptGlobal	true false null Infinity NaN
syn keyword	javaScriptGlobal	Array ArrayBuffer BigInt Boolean Date Function Intl JSON Math Map Number Object Promise Proxy Reflect RegExp Set String Symbol WeakMap WeakSet
syn keyword	javaScriptGlobal	globalThis eval
syn keyword	javaScriptGlobal	isFinite isNan parseFloat parseInt
syn keyword	javaScriptGlobal	decodeURI decodeURIComponent encodeURI encodeURIComponent
syn keyword	javaScriptGlobal	setTimeout setInterval clearTimeout structuredClone
syn keyword	javaScriptGlobal	globalThis document window self top parent closed console history location localStorage name navigator opener scheduler

syn keyword	javaScriptGlobalErrors	Error AggregateError EvalError RangeError ReferenceError SyntaxError TypeError URIError

" useful APIs
syn keyword	javaScriptAPI	fetch IntersectionObserver IntersectionObserverEntry Request Response ResizeObserver ResizeObserverEntry URL URLSearchParams XMLHttpRequest 
" NodeJS API
syn keyword	javaScriptAPI	require __dirname __filename exports module
" ALL_CAPS typically globals
syn match	javaScriptAPI	"\<[A-Z][A-Z0-9_]*[A-Z0-9]\?\>"

syn match	javaScriptBadShebang	"\%^#!.*$"
syn match	javaScriptShebang	"\%^#!.*\<node\%(\s\+\|$\).*$"

syn cluster	javaScriptTop	contains=javaScriptGlobal,javaScriptGlobalErrors,javaScriptAPI

" 'special' properties
syn keyword	javaScriptSpecialProperty	apply bind call constructor prototype __proto__ contained containedin=javaScriptProperty,javaScriptKeyLike
" Not exactly identifiers or values...
syn keyword	javaScriptSpecialIdentifier	arguments this super

syn cluster	javaScriptEmbededExpr	contains=javaScriptUndefined,javaScriptString,javaScriptTemplateString,javaScriptGlobal,javaScriptAPI,javaScriptGlobalErrors,javaScriptOperator,javaScriptDeprecated,javaScriptReserved,javaScriptSpecialIdentifier

" function as initializers
syn match	javaScriptMemberFunc	"\%\(\<get\>\|\<set\>\|\<static\>\)\_s\+\i\+\s*(.*)" contains=javaScriptGetSetKeyword,javaScriptStatic contained containedin=javaScriptBlock
syn keyword	javaScriptGetSetKeyword	get set contained
syn keyword	javaScriptStatic	static contained
syn match	javaScriptStaticMember	"^\s*static\>" contains=javaScriptStatic contained containedin=javaScriptBlock transparent

syn region	javaScriptBlock	start="{" end="}" transparent
" Classes
" class definition line (may span multiple lines)
syn match	javaScriptClassDef	"\<class\>\_.\{-}\ze\_s*{" contains=ALLBUT,javaScriptStatement,javaScriptConditional,javaScriptRepeat,javaScriptException,javaScriptDeclaration,javaScriptFunctionDef
syn keyword	javaScriptClass		class contained containedin=javaScriptClassDef
syn keyword	javaScriptClassSpecial	extends contained containedin=javaScriptClassDef

" Functions
" function definition line (may span multiple lines)
syn region	javaScriptFunctionDef	start="\<function\>\*\?\%(\_s\+\i*\)\?\_.\{-}\ze\_s*{" end="\ze\_s*{" contains=ALLBUT,javaScriptStatement,javaScriptConditional,javaScriptRepeat,javaScriptException,javaScriptDeclaration,javaScriptClassDef
syn keyword	javaScriptFunction	function contained containedin=javaScriptFunctionDef

syn match	javaScriptArrow 	"=>"

syn sync match javaScriptSync	grouphere javaScriptFunctionDef "\<function\>"
syn sync match javaScriptSync	grouphere NONE "^}"

if exists("javaScript_fold")
    setlocal foldmethod=syntax
    setlocal foldtext=getline(v:foldstart)
endif

" Object initializer
syn match	javaScriptKeyLike		/\i\{-}\_s*:/ contains=ALLBUT,@javaScriptTop,javaScriptMemberInit contained containedin=javaScriptBlock

" Everything after a dot except numbers
syn match	javaScriptProperty	/\.\h\w*/ contains=javaScriptSpecialProperty

if main_syntax == "javascript"
  syn sync fromstart
  syn sync maxlines=100

  syn sync ccomment javaScriptComment
endif

" Define the default highlighting.
" Only when an item doesn't have highlighting yet
hi def link javaScriptComment		Comment
hi def link javaScriptLineComment	Comment
hi def link javaScriptCommentTodo	Todo
hi def link javaScriptESLInlineDirective	SpecialComment
hi def link javaScriptESLBlockDirective		SpecialComment

hi def link javaScriptShebang		Special
hi def link javaScriptStrict		PreProc
hi def link javaScriptEscape		SpecialChar
hi def link javaScriptREStringSpecial	javaScriptEscape
hi def link javaScriptRegExpSpecial	javaScriptEscape

hi def link javaScriptRegExpLiteral	String
hi def link javaScriptRegExpDelimit	Delimiter

hi def link javaScriptString		String
hi def link javaScriptTemplateString	String

hi def link javaScriptDeclaration	StorageClass
hi def link javaScriptConditional	Conditional
hi def link javaScriptRepeat		Repeat
hi def link javaScriptBranch		Conditional
hi def link javaScriptOperator		Operator
hi def link javaScriptStatement		Statement

hi def link javaScriptUndefined		Keyword

hi def link javaScriptSpecialIdentifier	Identifier
hi def link javaScriptSpecialProperty	Identifier
hi def link javaScriptLabel		Label
hi def link javaScriptException		Exception

hi def link javaScriptGlobal		Constant
hi def link javaScriptGlobalErrors	Special
hi def link javaScriptAPI		Constant
hi def link javaScriptFunction		Function
hi def link javaScriptGetSetKeyword	Function
hi def link javaScriptStatic		StorageClass
hi def link javaScriptClass		javaScriptFunction
hi def link javaScriptArrow		javaScriptFunction
hi def link javaScriptClassSpecial	Special

hi def link javaScriptBadShebang	Error
hi def link javaScriptError		Error
hi def link javaScriptLineContinueError	javaScriptError
hi def link javaScriptReserved		javaScriptError
hi def link javaScriptDeprecated	javaScriptError
hi def link javaScriptDeprecatedEscape	javaScriptDeprecated

hi def link javaScriptEmbed		Special
hi def link javaScriptProperty		NONE
hi def link javaScriptKeyLike		NONE

let b:current_syntax = "javascript"
if main_syntax == 'javascript'
	unlet main_syntax
endif

let &cpo = s:cpo_save
unlet s:cpo_save
" vim: ts=8
