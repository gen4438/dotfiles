# mosh: complete host names the same way as ssh (~/.ssh/config incl. Include, known_hosts)
if declare -F _known_hosts >/dev/null 2>&1; then
    complete -F _known_hosts mosh
fi
