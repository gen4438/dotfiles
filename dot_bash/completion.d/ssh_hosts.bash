# mosh: complete the same way as ssh (host names from ~/.ssh/config incl. Include, known_hosts)
# bash-completion lazy-loads ssh's completion on first <Tab>, so load it now and reuse its spec.
if ! complete -p ssh &>/dev/null; then
    if declare -F _comp_load &>/dev/null; then
        _comp_load ssh
    elif declare -F _completion_loader &>/dev/null; then
        _completion_loader ssh
    fi
fi
if _ssh_comp_spec=$(complete -p ssh 2>/dev/null); then
    eval "${_ssh_comp_spec% ssh} mosh"
fi
unset _ssh_comp_spec
