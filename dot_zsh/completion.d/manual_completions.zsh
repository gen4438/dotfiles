# Manual completions for tools with path issues

# Poetry completion - disabled due to Python environment conflicts
# if command -v poetry &> /dev/null; then
#     eval "$(poetry completions zsh)"
# fi

# GitHub CLI completion  
if command -v gh &> /dev/null; then
    eval "$(gh completion -s zsh)"
fi