# shellcheck shell=sh
# Shared selector for explicit provisioning; private role files stay out of Git.
dotfiles_read_role() {
    selected_role=${DOTFILES_ROLE:-}
    role_file=${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/local/role
    if [ -z "$selected_role" ]; then
        if [ -f "$role_file" ]; then
            IFS= read -r selected_role < "$role_file" || :
        else
            selected_role=workstation
        fi
    fi
    case $selected_role in
        workstation|server) printf '%s\n' "$selected_role" ;;
        *) printf 'Invalid dotfiles role: %s (expected workstation or server).\n' "$selected_role" >&2; return 1 ;;
    esac
}
