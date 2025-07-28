# Homebrew completions - add to FPATH only
# compinit is handled centrally in .zshrc for better performance
if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi
