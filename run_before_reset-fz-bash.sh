#!/bin/bash
# Reset fz.bash before external repository updates to prevent git conflicts

FZ_DIR="$HOME/bin/fz"
FZ_BASH_FILE="$FZ_DIR/fz.bash"

if [[ -d "$FZ_DIR/.git" ]] && [[ -f "$FZ_BASH_FILE" ]]; then
    echo "Resetting fz.bash before external updates..."
    cd "$FZ_DIR"
    
    # Check if fz.bash is tracked by git
    if git ls-files --error-unmatch fz.bash >/dev/null 2>&1; then
        echo "Resetting tracked fz.bash to prevent conflicts..."
        git checkout -- fz.bash 2>/dev/null || true
    else
        echo "Removing untracked fz.bash..."
        rm -f "$FZ_BASH_FILE"
    fi
    
    cd - >/dev/null
fi