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

.PHONY: update-neovim update-neovim-all update-neovim-env update-neovim-lazy update-neovim-mason update-neovim-coc update-neovim-treesitter neovim-health
## Update Neovim plugins and environment
update-neovim: update-neovim-lazy update-neovim-mason update-neovim-coc update-neovim-treesitter
	@echo "✅ All Neovim plugins updated"

## Update all Neovim components (plugins + environment)
update-neovim-all: update-neovim update-neovim-env
	@echo "✅ All Neovim components updated"

## Update Python/Node.js environment for Neovim
update-neovim-env:
	@echo "🔄 Updating Python/Node.js environment..."
	@if command -v pyenv >/dev/null 2>&1 && [ -d ~/.pyenv/versions/neovim3 ]; then \
		echo "Updating pyenv neovim3..."; \
		~/.pyenv/versions/neovim3/bin/pip install --upgrade pip pynvim neovim; \
	elif [ -d ~/.local/share/nvim-venv ]; then \
		echo "Updating venv..."; \
		~/.local/share/nvim-venv/bin/pip install --upgrade pip pynvim neovim; \
	fi
	@if command -v npm >/dev/null 2>&1; then \
		echo "Updating npm packages..."; \
		npm update -g neovim tree-sitter-cli 2>/dev/null || npm install -g neovim tree-sitter-cli 2>/dev/null || true; \
	fi
	@echo "✅ Environment updated"

## Update Lazy.nvim plugins
update-neovim-lazy:
	@echo "🔄 Updating Lazy.nvim plugins..."
	@nvim --headless "+Lazy! sync" +qa
	@echo "✅ Lazy.nvim plugins updated"

## Update Mason LSP servers
update-neovim-mason:
	@echo "🔄 Updating Mason LSP servers..."
	@nvim --headless "+MasonUpdate" +qa
	@echo "✅ Mason LSP servers updated"

## Update coc.nvim extensions
update-neovim-coc:
	@echo "🔄 Updating coc.nvim extensions..."
	@nvim --headless "+CocUpdate" +qa
	@echo "✅ coc.nvim extensions updated"

## Update treesitter parsers
update-neovim-treesitter:
	@echo "🔄 Updating treesitter parsers..."
	@nvim --headless "+TSUpdate" +qa
	@echo "✅ treesitter parsers updated"

## Run Neovim health check
neovim-health:
	@echo "🏥 Running Neovim health check..."
	@nvim --headless "+checkhealth provider" +qa 2>&1 | grep -E "(python3|node|OK|WARNING|ERROR)" || true

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