# Environment shared by every node using this host/cluster profile.
# shellcheck shell=sh
if [ -z "${http_proxy:-}${https_proxy:-}${HTTP_PROXY:-}${HTTPS_PROXY:-}${all_proxy:-}${ALL_PROXY:-}" ] && \
    [ -r "/etc/profile.d/proxy.sh" ]; then
    # SSH commands do not read /etc/profile; use the site's proxy settings only.
    # shellcheck source=/dev/null
    . "/etc/profile.d/proxy.sh"
fi
