" Ayu Light colorscheme for the classic Vim configuration.
hi clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'ayu_light'
set background=light

hi Normal       guifg=#5C6166 guibg=#F8F9FA cterm=NONE gui=NONE ctermfg=241 ctermbg=231
hi Comment      guifg=#ABADB1 guibg=NONE cterm=NONE gui=NONE ctermfg=145
hi Constant     guifg=#A37ACC guibg=NONE cterm=NONE gui=NONE ctermfg=140
hi String       guifg=#86B300 guibg=NONE cterm=NONE gui=NONE ctermfg=106
hi Character    guifg=#86B300 guibg=NONE cterm=NONE gui=NONE ctermfg=106
hi Number       guifg=#A37ACC guibg=NONE cterm=NONE gui=NONE ctermfg=140
hi Boolean      guifg=#A37ACC guibg=NONE cterm=NONE gui=NONE ctermfg=140
hi Identifier   guifg=#399EE6 guibg=NONE cterm=NONE gui=NONE ctermfg=74
hi Function     guifg=#F2AE49 guibg=NONE cterm=NONE gui=NONE ctermfg=215
hi Statement    guifg=#FA8D3E guibg=NONE cterm=NONE gui=NONE ctermfg=209
hi Conditional  guifg=#FA8D3E guibg=NONE cterm=NONE gui=NONE ctermfg=209
hi Repeat       guifg=#FA8D3E guibg=NONE cterm=NONE gui=NONE ctermfg=209
hi Operator     guifg=#ED9366 guibg=NONE cterm=NONE gui=NONE ctermfg=209
hi Keyword      guifg=#FA8D3E guibg=NONE cterm=NONE gui=NONE ctermfg=209
hi Exception    guifg=#FA8D3E guibg=NONE cterm=NONE gui=NONE ctermfg=209
hi PreProc      guifg=#E6BA7E guibg=NONE cterm=NONE gui=NONE ctermfg=180
hi Type         guifg=#399EE6 guibg=NONE cterm=NONE gui=NONE ctermfg=74
hi Special      guifg=#E6BA7E guibg=NONE cterm=NONE gui=NONE ctermfg=180
hi Underlined   guifg=#399EE6 guibg=NONE cterm=underline gui=underline ctermfg=74
hi Error        guifg=#F8F9FA guibg=#E65050 cterm=NONE gui=NONE ctermfg=231 ctermbg=167
hi Todo         guifg=#F07171 guibg=NONE cterm=NONE gui=NONE ctermfg=203

hi CursorLine   guibg=#F3F4F5 gui=NONE ctermbg=255
hi CursorColumn guibg=#F3F4F5 gui=NONE ctermbg=255
hi ColorColumn  guibg=#F3F4F5 gui=NONE ctermbg=255
hi LineNr       guifg=#CCCFD3 guibg=NONE cterm=NONE gui=NONE ctermfg=252
hi CursorLineNr guifg=#FFAA33 guibg=#F3F4F5 cterm=bold gui=bold ctermfg=215 ctermbg=255
hi Visual       guifg=NONE guibg=#D3E1F5 cterm=NONE gui=NONE ctermbg=189
hi Search       guifg=#F8F9FA guibg=#A37ACC cterm=NONE gui=NONE ctermfg=231 ctermbg=140
hi IncSearch    guifg=#F8F9FA guibg=#FFAA33 cterm=NONE gui=NONE ctermfg=231 ctermbg=215
hi Pmenu        guifg=#5C6166 guibg=#D3E1F5 cterm=NONE gui=NONE ctermfg=241 ctermbg=189
hi PmenuSel     guifg=#F8F9FA guibg=#399EE6 cterm=NONE gui=NONE ctermfg=231 ctermbg=74
hi StatusLine   guifg=#5C6166 guibg=#F3F4F5 cterm=NONE gui=NONE ctermfg=241 ctermbg=255
hi StatusLineNC guifg=#8A9199 guibg=#F3F4F5 cterm=NONE gui=NONE ctermfg=246 ctermbg=255
hi VertSplit    guifg=#CCCFD3 guibg=NONE cterm=NONE gui=NONE ctermfg=252
hi SignColumn   guifg=#5C6166 guibg=NONE cterm=NONE gui=NONE ctermfg=241
hi Folded       guifg=#8A9199 guibg=#F3F4F5 cterm=NONE gui=NONE ctermfg=246 ctermbg=255
hi Directory    guifg=#399EE6 guibg=NONE cterm=NONE gui=NONE ctermfg=74
hi DiffAdd      guifg=#86B300 guibg=#F3F4F5 cterm=NONE gui=NONE ctermfg=106 ctermbg=255
hi DiffChange   guifg=#399EE6 guibg=#F3F4F5 cterm=NONE gui=NONE ctermfg=74 ctermbg=255
hi DiffDelete   guifg=#F07171 guibg=#F3F4F5 cterm=NONE gui=NONE ctermfg=203 ctermbg=255
hi DiffText     guifg=#5C6166 guibg=#D3E1F5 cterm=NONE gui=NONE ctermfg=241 ctermbg=189
hi ErrorMsg     guifg=#E65050 guibg=NONE cterm=NONE gui=NONE ctermfg=167
hi WarningMsg   guifg=#E65050 guibg=NONE cterm=NONE gui=NONE ctermfg=167
hi MatchParen   guifg=#5C6166 guibg=#F8F9FA cterm=underline gui=underline ctermfg=241 ctermbg=231
hi NonText      guifg=#CCCFD3 guibg=NONE cterm=NONE gui=NONE ctermfg=252
hi SpecialKey   guifg=#CCCFD3 guibg=NONE cterm=NONE gui=NONE ctermfg=252
hi TabLine      guifg=#5C6166 guibg=#F3F4F5 cterm=NONE gui=NONE ctermfg=241 ctermbg=255
hi TabLineSel   guifg=#F8F9FA guibg=#399EE6 cterm=bold gui=bold ctermfg=231 ctermbg=74
hi Title        guifg=#FA8D3E guibg=NONE cterm=bold gui=bold ctermfg=209

hi GitGutterAdd          guifg=#86B300 guibg=NONE cterm=NONE gui=NONE ctermfg=106
hi GitGutterChange       guifg=#399EE6 guibg=NONE cterm=NONE gui=NONE ctermfg=74
hi GitGutterDelete       guifg=#F07171 guibg=NONE cterm=NONE gui=NONE ctermfg=203
hi GitGutterChangeDelete guifg=#F2AE49 guibg=NONE cterm=NONE gui=NONE ctermfg=215
