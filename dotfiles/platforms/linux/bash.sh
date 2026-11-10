# Modules are an interactive convenience, not a batch-job side effect.
if ! type module >/dev/null 2>&1; then
    for _module_init in /etc/profile.d/lmod.sh /etc/profile.d/modules.sh; do
        if [ -r "$_module_init" ]; then
            source "$_module_init"
            break
        fi
    done
    unset _module_init
fi
