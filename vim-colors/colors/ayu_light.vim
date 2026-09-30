" Ayu Light colorscheme for the classic Vim configuration.
hi clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'ayu_light'
set background=light

hi Normal       guifg=#5C6773 guibg=#FAFAFA cterm=NONE gui=NONE
hi Comment      guifg=#ABB0B6 guibg=NONE cterm=NONE gui=NONE
hi Constant     guifg=#A37ACC guibg=NONE cterm=NONE gui=NONE
hi String       guifg=#86B300 guibg=NONE cterm=NONE gui=NONE
hi Character    guifg=#86B300 guibg=NONE cterm=NONE gui=NONE
hi Number       guifg=#A37ACC guibg=NONE cterm=NONE gui=NONE
hi Boolean      guifg=#A37ACC guibg=NONE cterm=NONE gui=NONE
hi Identifier   guifg=#36A3D9 guibg=NONE cterm=NONE gui=NONE
hi Function     guifg=#F29718 guibg=NONE cterm=NONE gui=NONE
hi Statement    guifg=#FF7733 guibg=NONE cterm=NONE gui=NONE
hi Conditional  guifg=#FF7733 guibg=NONE cterm=NONE gui=NONE
hi Repeat       guifg=#FF7733 guibg=NONE cterm=NONE gui=NONE
hi Operator     guifg=#E7C547 guibg=NONE cterm=NONE gui=NONE
hi Keyword      guifg=#FF7733 guibg=NONE cterm=NONE gui=NONE
hi Exception    guifg=#FF7733 guibg=NONE cterm=NONE gui=NONE
hi PreProc      guifg=#E6B673 guibg=NONE cterm=NONE gui=NONE
hi Type         guifg=#36A3D9 guibg=NONE cterm=NONE gui=NONE
hi Special      guifg=#E6B673 guibg=NONE cterm=NONE gui=NONE
hi Underlined   guifg=#36A3D9 guibg=NONE cterm=underline gui=underline
hi Error        guifg=#FAFAFA guibg=#FF3333 cterm=NONE gui=NONE
hi Todo         guifg=#F07178 guibg=NONE cterm=NONE gui=NONE

hi CursorLine   guibg=#F3F3F3 ctermbg=NONE gui=NONE
hi CursorColumn guibg=#F3F3F3 ctermbg=NONE gui=NONE
hi ColorColumn  guibg=#F3F3F3 ctermbg=NONE gui=NONE
hi LineNr       guifg=#D9D8D7 guibg=NONE cterm=NONE gui=NONE
hi CursorLineNr guifg=#FF6A00 guibg=#F3F3F3 cterm=bold gui=bold
hi Visual       guifg=NONE guibg=#F0EEE4 cterm=NONE gui=NONE
hi Search       guifg=#FAFAFA guibg=#A37ACC cterm=NONE gui=NONE
hi IncSearch    guifg=#FAFAFA guibg=#FF6A00 cterm=NONE gui=NONE
hi Pmenu        guifg=#5C6773 guibg=#F0EEE4 cterm=NONE gui=NONE
hi PmenuSel     guifg=#FAFAFA guibg=#41A6D9 cterm=NONE gui=NONE
hi StatusLine   guifg=#5C6773 guibg=#FFFFFF cterm=NONE gui=NONE
hi StatusLineNC guifg=#828C99 guibg=#FFFFFF cterm=NONE gui=NONE
hi VertSplit    guifg=#D9D8D7 guibg=NONE cterm=NONE gui=NONE
hi SignColumn   guifg=#5C6773 guibg=NONE cterm=NONE gui=NONE
hi Folded       guifg=#828C99 guibg=#FFFFFF cterm=NONE gui=NONE
hi Directory    guifg=#36A3D9 guibg=NONE cterm=NONE gui=NONE
hi DiffAdd      guifg=#86B300 guibg=#FFFFFF cterm=NONE gui=NONE
hi DiffChange   guifg=#36A3D9 guibg=#FFFFFF cterm=NONE gui=NONE
hi DiffDelete   guifg=#F07178 guibg=#FFFFFF cterm=NONE gui=NONE
hi DiffText     guifg=#5C6773 guibg=#F0EEE4 cterm=NONE gui=NONE
hi ErrorMsg     guifg=#FF3333 guibg=NONE cterm=NONE gui=NONE
hi WarningMsg   guifg=#FF3333 guibg=NONE cterm=NONE gui=NONE
hi MatchParen   guifg=#5C6773 guibg=#FAFAFA cterm=underline gui=underline
hi NonText      guifg=#D9D8D7 guibg=NONE cterm=NONE gui=NONE
hi SpecialKey   guifg=#D9D8D7 guibg=NONE cterm=NONE gui=NONE
hi TabLine      guifg=#5C6773 guibg=#FFFFFF cterm=NONE gui=NONE
hi TabLineSel   guifg=#FAFAFA guibg=#41A6D9 cterm=bold gui=bold
hi Title        guifg=#FF7733 guibg=NONE cterm=bold gui=bold

hi GitGutterAdd          guifg=#86B300 guibg=NONE cterm=NONE gui=NONE
hi GitGutterChange       guifg=#36A3D9 guibg=NONE cterm=NONE gui=NONE
hi GitGutterDelete       guifg=#F07178 guibg=NONE cterm=NONE gui=NONE
hi GitGutterChangeDelete guifg=#F29718 guibg=NONE cterm=NONE gui=NONE
