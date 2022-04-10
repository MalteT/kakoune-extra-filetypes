# https://vue-loader.vuejs.org/
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufCreate .+\.vue %{
    set-option buffer filetype vuejs
}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

define-command -hidden -params 3 vuejs-detect-lang %{
    try %{
        execute-keys -draft <percent> s "^<%arg{1}\b.+?\blang=""%arg{2}""" <ret>
        require-module %arg{3}
    }
}

hook global WinSetOption filetype=vuejs %{
    require-module html
    require-module css
    require-module javascript

    vuejs-detect-lang "template" "pug" "pug"
    vuejs-detect-lang "script" "ts" "typescript"
    vuejs-detect-lang "style" "scss" "scss"
    vuejs-detect-lang "style" "stylus" "css"

    require-module vuejs

    hook window ModeChange pop:insert:.* -group vuejs-indent html-trim-indent
    hook window InsertChar .* -group vuejs-indent javascript-indent-on-char
    hook window InsertChar \n -group vuejs-indent html-indent-on-new-line

    add-highlighter window/vuejs ref vuejs
    hook -once -always window WinSetOption filetype=.* %{
        remove-highlighter window/vuejs
        remove-hooks window vuejs-indent
    }
}

provide-module vuejs %§

# Commands
# ‾‾‾‾‾‾‾‾

define-command -hidden vuejs-indent-on-char %<
    evaluate-commands -draft -itersel %<
        # align closer token to its opener when alone on a line
        try %/ execute-keys -draft <a-h> <a-k> ^\h+[\]}]$ <ret> m s \A|.\z <ret> 1<a-&> /
    >
>

define-command -hidden vuejs-indent-on-new-line %<
    evaluate-commands -draft -itersel %<
        # preserve previous line indent
        try %{ execute-keys -draft <semicolon> K <a-&> }
        # filter previous line
        try %{ execute-keys -draft k : html-trim-indent <ret> }
        # indent after lines beginning / ending with opener token
        try %_ execute-keys -draft k <a-x> s [[({] <ret> <space> <a-l> <a-K> [\])}] <ret> j <a-gt> _
        # deindent closing token(s) when after cursor
        try %_ execute-keys -draft <a-x> <a-k> ^\h*[})\]] <ret> gh / [})\]] <ret> m <a-S> 1<a-&> _
    >
>

# Highlighters
# ‾‾‾‾‾‾‾‾‾‾‾‾

add-highlighter shared/vuejs regions

add-highlighter shared/vuejs/tags region '</?\K(template|script|style)\b' '(?=>)' group
add-highlighter shared/vuejs/tags/meta regex '\b(template|script|style)\b' 1:meta
add-highlighter shared/vuejs/tags/attr regex '\b(lang)\b' 1:attribute
add-highlighter shared/vuejs/tags/string regex '("[^"]*")' 1:string

add-highlighter shared/vuejs/template_pug region '<template\b.+?\blang="pug">\K' '(?=</template>)' ref pug
add-highlighter shared/vuejs/template_html region '<template\b.*>\K' '(?=</template>)' group
add-highlighter shared/vuejs/template_html/ regex (\{\{|\}\}) 1:meta
add-highlighter shared/vuejs/template_html/regions regions
add-highlighter shared/vuejs/template_html/regions/base default-region ref html
add-highlighter shared/vuejs/template_html/regions/expansion region '\{\{' '\}\}' ref javascript
add-highlighter shared/vuejs/template_html/ regex '((\bv-|@|:)[a-zA-Z0-9_-]+)=' 1:meta

add-highlighter shared/vuejs/script_javascript region '<script\b.*?>\K' '(?=</script>)' ref javascript
add-highlighter shared/vuejs/script_typescript region '<script\b.+?\blang="ts">\K' '(?=</script>)' ref typescript

add-highlighter shared/vuejs/style_css region '<style\b.*?>\K' '(?=</style>)' ref css
add-highlighter shared/vuejs/style_scss region '<style\b.+?\blang="scss">\K' '(?=</style>)' ref scss
add-highlighter shared/vuejs/style_stylus region '<style\b.+?\blang="stylus">\K' '(?=</style>)' ref css

#add-highlighter shared/vuejs/template/meta group
#add-highlighter shared/vuejs/template/meta/base default-region group

§
