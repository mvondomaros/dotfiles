" Use the vimrc submodule while keeping the dependency under XDG_CONFIG_HOME.
let s:config_home = empty($XDG_CONFIG_HOME) ? expand('~/.config') : $XDG_CONFIG_HOME
let s:vim_runtime = s:config_home . '/vim'
execute 'set runtimepath+=' . fnameescape(s:vim_runtime)
execute 'source ' . fnameescape(s:vim_runtime . '/vimrcs/basic.vim')
execute 'source ' . fnameescape(s:vim_runtime . '/vimrcs/filetypes.vim')
execute 'source ' . fnameescape(s:vim_runtime . '/vimrcs/plugins_config.vim')
execute 'source ' . fnameescape(s:vim_runtime . '/vimrcs/extended.vim')

if filereadable(s:vim_runtime . '/my_configs.vim')
  execute 'source ' . fnameescape(s:vim_runtime . '/my_configs.vim')
endif
