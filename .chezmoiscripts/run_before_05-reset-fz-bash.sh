#!/bin/bash
# Reset fz.bash before external repository updates to prevent git conflicts

FZ_DIR="$HOME/bin/fz"
FZ_BASH_FILE="$FZ_DIR/fz.bash"

if [[ -d "$FZ_DIR/.git" ]] && [[ -e "$FZ_BASH_FILE" ]]; then
    echo "Resetting fz.bash before external updates..."
    cd "$FZ_DIR"
    
    # Always remove fz.bash (symlink or file) to prevent conflicts
    echo "Removing fz.bash to prevent git conflicts..."
    rm -f "$FZ_BASH_FILE"
    
    # If it was tracked, reset to clean state
    if git ls-files --error-unmatch fz.bash >/dev/null 2>&1; then
        git checkout -- fz.bash 2>/dev/null || true
        # Remove it again after git restores it
        rm -f "$FZ_BASH_FILE"
    fi
    
    cd - >/dev/null
fi