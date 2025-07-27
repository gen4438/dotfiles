# Chezmoi Dotfiles Management Makefile
# This provides convenient shortcuts for common chezmoi operations

.PHONY: help
## Show available commands
help:
	@echo "Chezmoi Dotfiles Management"
	@echo ""
	@echo "Primary commands (use chezmoi directly):"
	@echo "  chezmoi init --apply          Initialize and apply dotfiles"
	@echo "  chezmoi update               Update from remote and apply changes"
	@echo "  chezmoi diff                 Show pending changes"
	@echo "  chezmoi apply                Apply local changes"
	@echo "  chezmoi doctor               Diagnose potential issues"
	@echo ""
	@echo "Convenience commands (via Makefile):"
	@awk '/^[a-zA-Z_0-9%:\\-]+:/ { \
	  helpMessage = match(lastLine, /^## (.*)/); \
	  if (helpMessage) { \
	    helpCommand = $$1; \
	    helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
	    gsub("\\\\", "", helpCommand); \
	    gsub(":+$$", "", helpCommand); \
	    printf "  %-28s %s\n", helpCommand, helpMessage; \
	  } \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

.PHONY: status
## Show chezmoi status and git status
status:
	@echo "=== Chezmoi Status ==="
	@chezmoi status || true
	@echo ""
	@echo "=== Git Status ==="
	@cd $$(chezmoi source-path) && git status

.PHONY: update
## Update everything (dotfiles, tools, completions, nvim)
update:
	@echo "🔄 Updating everything..."
	chezmoi update
	@echo "✅ Update complete!"

.PHONY: update-tools
## Update development tools (pyenv, nvm, fzf, etc.)
update-tools:
	@echo "🔧 Updating development tools..."
	@bash ~/.chezmoiscripts/run_onchange_30-update-development-tools.sh
	@echo "✅ Tools updated!"

.PHONY: update-nvim
## Update Neovim plugins and packages
update-nvim:
	@echo "📝 Updating Neovim..."
	@nvim --headless "+Lazy! sync" "+TSUpdateSync" "+CocUpdateSync" +qa
	@bash ~/.chezmoiscripts/run_onchange_35-update-neovim-environment.sh
	@echo "✅ Neovim updated!"

.PHONY: update-completions
## Update shell completions for various tools  
update-completions:
	@echo "🔧 Shell completions are managed through the respective shell configuration files"
	@echo "✅ Run 'exec $$SHELL' to reload completions"

.PHONY: external-update
## Update external tools managed by chezmoi
external-update:
	@echo "Updating external tools..."
	@chezmoi apply --refresh-externals

.PHONY: tools-status
## Show status of development tools
tools-status:
	@echo "=== Development Tools Status ==="
	@echo "Git: $$(git --version 2>/dev/null || echo 'Not installed')"
	@echo "Python: $$(python3 --version 2>/dev/null || echo 'Not installed')"
	@echo "Node.js: $$(node --version 2>/dev/null || echo 'Not installed')"
	@echo "Neovim: $$(nvim --version 2>/dev/null | head -1 || echo 'Not installed')"
	@echo "fzf: $$(fzf --version 2>/dev/null || echo 'Not installed')"
	@echo "ripgrep: $$(rg --version 2>/dev/null | head -1 || echo 'Not installed')"
	@echo "direnv: $$(direnv --version 2>/dev/null || echo 'Not installed')"

.PHONY: edit-source
## Open chezmoi source directory in editor
edit-source:
	@$${EDITOR:-vim} $$(chezmoi source-path)

.PHONY: backup
## Create backup of current dotfiles before major changes
backup:
	@BACKUP_DIR="$$HOME/.dotfiles_backup/$$(date '+%Y%m%d-%H%M%S')" && \
	mkdir -p "$$BACKUP_DIR" && \
	echo "Creating backup in $$BACKUP_DIR..." && \
	chezmoi archive --output="$$BACKUP_DIR/chezmoi-backup.tar.gz" && \
	echo "✅ Backup created: $$BACKUP_DIR/chezmoi-backup.tar.gz"

.PHONY: doctor
## Run chezmoi doctor and show system information
doctor:
	@echo "=== Chezmoi Doctor ==="
	@chezmoi doctor
	@echo ""
	@echo "=== System Information ==="
	@echo "OS: $$(uname -s)"
	@echo "Architecture: $$(uname -m)"
	@echo "Shell: $$SHELL"
	@echo "Home: $$HOME"
	@echo "Chezmoi config: $$(chezmoi doctor 2>/dev/null | grep 'config file' || echo 'Default')"