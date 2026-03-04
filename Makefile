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
## Update development tools (mise, fzf, etc.)
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
	@if [ -d ~/.local/share/nvim-venv ]; then \
		echo "Updating nvim-venv..."; \
		if command -v uv >/dev/null 2>&1; then \
			uv pip install --python ~/.local/share/nvim-venv/bin/python --upgrade pynvim neovim; \
		else \
			~/.local/share/nvim-venv/bin/pip install --upgrade pip pynvim neovim; \
		fi; \
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
	@echo "🔄 Updating shell completions..."
	@mkdir -p "$$HOME/.bash/completion.d"
	@mkdir -p "$$HOME/.zsh/completion.d"
	@# Git completions (version-specific)
	@if command -v git >/dev/null 2>&1; then \
		GIT_VERSION=$$(git --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+') && \
		echo "Downloading Git bash completion..." && \
		curl -fsSL "https://raw.githubusercontent.com/git/git/v$${GIT_VERSION}/contrib/completion/git-completion.bash" \
			-o "$$HOME/.bash/completion.d/git-completion.bash" && \
		echo "✅ Git bash completion updated" || echo "❌ Failed to download Git bash completion"; \
		echo "Downloading Git prompt script..." && \
		curl -fsSL "https://raw.githubusercontent.com/git/git/v$${GIT_VERSION}/contrib/completion/git-prompt.sh" \
			-o "$$HOME/.bash/completion.d/git-prompt.sh" && \
		echo "✅ Git prompt script updated" || echo "❌ Failed to download Git prompt script"; \
	fi
	@# Docker fzf completion
	@if command -v docker >/dev/null 2>&1; then \
		echo "Downloading Docker fzf completion..." && \
		curl -fsSL "https://raw.githubusercontent.com/mnowotnik/docker-fzf-completion/master/docker-fzf.bash" \
			-o "$$HOME/.bash/completion.d/docker-fzf.bash" && \
		echo "✅ Docker fzf completion updated" || echo "❌ Failed to download Docker fzf completion"; \
	fi
	@# Yarn completion
	@echo "Downloading Yarn completion..." && \
	curl -fsSL "https://raw.githubusercontent.com/dsifford/yarn-completion/master/yarn-completion.bash" \
		-o "$$HOME/.bash/completion.d/yarn-completion.bash" && \
	echo "✅ Yarn completion updated" || echo "❌ Failed to download Yarn completion"
	@# GitHub CLI completion
	@if command -v gh >/dev/null 2>&1; then \
		gh completion -s bash > "$$HOME/.bash/completion.d/gh.bash" 2>/dev/null && \
		echo "✅ GitHub CLI bash completion updated" || echo "❌ Failed to update GitHub CLI bash completion"; \
		gh completion -s zsh > "$$HOME/.zsh/completion.d/_gh" 2>/dev/null && \
		echo "✅ GitHub CLI zsh completion updated" || echo "❌ Failed to update GitHub CLI zsh completion"; \
	fi
	@# kubectl completion
	@if command -v kubectl >/dev/null 2>&1; then \
		kubectl completion bash > "$$HOME/.bash/completion.d/kubectl.bash" 2>/dev/null && \
		echo "✅ kubectl bash completion updated" || echo "❌ Failed to update kubectl bash completion"; \
		kubectl completion zsh > "$$HOME/.zsh/completion.d/_kubectl" 2>/dev/null && \
		echo "✅ kubectl zsh completion updated" || echo "❌ Failed to update kubectl zsh completion"; \
	fi
	@# npm completion
	@if command -v npm >/dev/null 2>&1; then \
		npm completion > "$$HOME/.bash/completion.d/npm.bash" 2>/dev/null && \
		echo "✅ npm bash completion updated" || echo "❌ Failed to update npm bash completion"; \
	fi
	@# Poetry completion
	@if command -v poetry >/dev/null 2>&1; then \
		poetry completions bash > "$$HOME/.bash/completion.d/poetry.bash" 2>/dev/null && \
		echo "✅ Poetry bash completion updated" || echo "❌ Failed to update Poetry bash completion"; \
		poetry completions zsh > "$$HOME/.zsh/completion.d/_poetry" 2>/dev/null && \
		echo "✅ Poetry zsh completion updated" || echo "❌ Failed to update Poetry zsh completion"; \
	fi
	@# chezmoi completion
	@if command -v chezmoi >/dev/null 2>&1; then \
		if chezmoi completion --help >/dev/null 2>&1; then \
			chezmoi completion bash --output "$$HOME/.bash/completion.d/chezmoi.bash" && \
			echo "✅ chezmoi bash completion updated" || echo "⚠️ chezmoi bash completion failed"; \
			chezmoi completion zsh --output "$$HOME/.zsh/completion.d/_chezmoi" && \
			echo "✅ chezmoi zsh completion updated" || echo "⚠️ chezmoi zsh completion failed"; \
		else \
			echo "⚠️ chezmoi completion command not available"; \
		fi; \
	fi
	@# Set appropriate permissions
	@chmod +x "$$HOME"/.bash/completion.d/*.bash 2>/dev/null || true
	@chmod +x "$$HOME"/.zsh/completion.d/_* 2>/dev/null || true
	@echo "✅ Shell completions update completed"
	@echo "💡 Run 'exec $$SHELL' to reload completions"

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
	@echo "mise: $$(mise --version 2>/dev/null || echo 'Not installed')"
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