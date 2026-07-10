#!/bin/bash

# Interactive directory navigation functions

# Navigate to subdirectories using numbered selection
cdlist() {
    local -a dirlist
    local opt_f=false
    local i d num=0 dirnum opt
    
    # Parse options
    while getopts ":f" opt; do
        case $opt in
            f) opt_f=true ;;
            \?) echo "Invalid option: -$OPTARG" >&2; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))
    
    # Build directory list
    dirlist[0]=".."
    for d in *; do
        [[ -d "$d" ]] && dirlist[$((++num))]="$d"
    done
    
    # Display numbered list
    for i in $(seq 0 $num); do
        printf "%3d %s%s\n" $i "$($opt_f && echo -n "$PWD/")${dirlist[$i]}"
    done
    
    # Get user selection
    read -p "Select number: " dirnum
    
    if [[ -z "$dirnum" ]]; then
        echo "$FUNCNAME: Aborted." >&2
        return 1
    elif [[ "$dirnum" =~ ^[0-9]+$ ]] && [[ $dirnum -le $num ]]; then
        cd "${dirlist[$dirnum]}" || return 1
    else
        echo "$FUNCNAME: Invalid selection." >&2
        return 1
    fi
}

# zoxide の履歴のうち、カレントディレクトリ以下のディレクトリに限定して fzf で選択・移動する
# （zoxide 本体にはスコープを限定するオプションがないため、query --list を prefix で絞り込む）
zic() {
    if ! command -v zoxide >/dev/null 2>&1; then
        echo "Error: zoxide command not found" >&2
        return 1
    fi

    local dir
    dir=$(zoxide query --list | awk -v prefix="$PWD/" 'index($0, prefix) == 1' | \
        fzf --no-multi --reverse --height "${FZF_TMUX_HEIGHT:-40%}") || return

    # zoxide init のフックが cd 後にスコアを自動更新する
    cd "$dir" || return 1
}

# Fix for fz filter function (if fz is installed)
__fz_filter() {
    if ! command -v fzf >/dev/null 2>&1; then
        echo "Error: fzf command not found" >&2
        return 1
    fi
    
    local fzf
    fzf=$(__fz_fzf_prog 2>/dev/null || echo "fzf")
    
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse \
        --bind 'shift-tab:up,tab:down' $FZF_DEFAULT_OPTS" ${fzf}
}