# Completions for dots, the single entry point of this checkout.
set -l commands update outdated install link status role host targets adopt help
set -l targets tools editor agents vscode packages appstore os all
set -l tools pixi lazygit rg fd atuin btop eza nvim starship ruff ty rsync shfmt shellcheck stylua tinymist typst tree-sitter websocat codex claude bash-language-server fish-lsp
complete -c dots -f
complete -c dots -n "not __fish_seen_subcommand_from $commands" -a update -d 'Pull, relink, update targets'
complete -c dots -n "not __fish_seen_subcommand_from $commands" -a outdated -d 'List incoming commits and updates'
complete -c dots -n "not __fish_seen_subcommand_from $commands" -a install -d 'Link and install missing targets'
complete -c dots -n "not __fish_seen_subcommand_from $commands" -a link -d 'Reapply configuration links'
complete -c dots -n "not __fish_seen_subcommand_from $commands" -a status -d 'Role, host, targets, checkout'
complete -c dots -n "not __fish_seen_subcommand_from $commands" -a role -d 'Show or set the role'
complete -c dots -n "not __fish_seen_subcommand_from $commands" -a host -d 'Show or set the host layer'
complete -c dots -n "not __fish_seen_subcommand_from $commands" -a targets -d 'Show or set default targets'
complete -c dots -n "not __fish_seen_subcommand_from $commands" -a adopt -d 'Adopt user-installed tools (Linux)'
complete -c dots -n "not __fish_seen_subcommand_from $commands" -a help -d 'Show help'
complete -c dots -n "__fish_seen_subcommand_from update outdated install" -a "$targets $tools"
complete -c dots -n "__fish_seen_subcommand_from targets" -a "$targets default"
complete -c dots -n "__fish_seen_subcommand_from role" -a 'workstation server'
complete -c dots -n "__fish_seen_subcommand_from host" -a "default (path basename $__fish_config_dir/../dotfiles/hosts/*)"
complete -c dots -n "__fish_seen_subcommand_from adopt" -a "$tools all"
complete -c dots -n "__fish_seen_subcommand_from update install link" -l backup -d 'Preserve and replace conflicting files'
complete -c dots -n "__fish_seen_subcommand_from update" -l no-pull -d 'Apply the current checkout'
complete -c dots -n "__fish_seen_subcommand_from adopt" -l check -d 'Preview only'
