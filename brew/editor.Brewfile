# Shared code/notes tools. Workstations also provision Typst.
brew "bash-language-server"
brew "fish-lsp"
brew "shellcheck"
brew "shfmt"
brew "stylua"
brew "tree-sitter-cli"
if ENV.fetch("DOTFILES_ROLE", "workstation") == "workstation"
  eval File.read(File.join(__dir__, "typst.Brewfile"))
end
