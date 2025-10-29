# Chezmoi Dotfiles Management Makefile
# This provides convenient shortcuts for common chezmoi operations
# Cross-platform support: Linux, macOS, and Windows (Git Bash/MSYS2/WSL)
#
# Windows Usage:
#   This Makefile requires 'make' to be available. On Windows, you can use:
#   - Git for Windows (Git Bash) - includes make via mingw32-make or make
#   - MSYS2/MinGW - includes make package
#   - WSL (Windows Subsystem for Linux) - full Linux compatibility
#   - Chocolatey: choco install make
#
#   Note: Run 'make help' to see all available commands

# OS Detection
ifeq ($(OS),Windows_NT)
    DETECTED_OS := Windows
    # Check if running in Git Bash/MSYS2 or native Windows
    SHELL_TYPE := $(shell echo $$SHELL)
    ifneq (,$(findstring bash,$(SHELL_TYPE)))
        IS_BASH := 1
    endif
else
    DETECTED_OS := $(shell uname -s)
    IS_BASH := 1
endif

# Platform-specific settings
ifeq ($(DETECTED_OS),Windows)
    # Windows-specific (assume Git Bash/MSYS2 for make compatibility)
    NULL_DEVICE := NUL
    PATH_SEP := ;
    # On Windows with Git Bash, use bash shell
    SHELL := bash
    MKDIR := mkdir -p
    RM := rm -f
else
    # Unix-like systems (Linux, macOS)
    NULL_DEVICE := /dev/null
    PATH_SEP := :
    MKDIR := mkdir -p
    RM := rm -f
endif

# Helper function to check command existence
ifeq ($(DETECTED_OS),Windows)
    CHECK_CMD = where $(1) >$(NULL_DEVICE) 2>&1
else
    CHECK_CMD = command -v $(1) >$(NULL_DEVICE) 2>&1
endif

.PHONY: help
## Show available commands
help:
	@echo "Chezmoi Dotfiles Management (OS: $(DETECTED_OS))"
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
	@if (command -v pyenv >$(NULL_DEVICE) 2>&1 || where pyenv >$(NULL_DEVICE) 2>&1) && [ -d ~/.pyenv/versions/neovim3 ]; then \
		echo "Updating pyenv neovim3..."; \
		~/.pyenv/versions/neovim3/bin/pip install --upgrade pip pynvim neovim; \
	elif [ -d ~/.local/share/nvim-venv ]; then \
		echo "Updating venv..."; \
		~/.local/share/nvim-venv/bin/pip install --upgrade pip pynvim neovim; \
	fi
	@if command -v npm >$(NULL_DEVICE) 2>&1 || where npm >$(NULL_DEVICE) 2>&1; then \
		echo "Updating npm packages..."; \
		npm update -g neovim tree-sitter-cli 2>$(NULL_DEVICE) || npm install -g neovim tree-sitter-cli 2>$(NULL_DEVICE) || true; \
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
	@$(MKDIR) "$$HOME/.bash/completion.d"
	@$(MKDIR) "$$HOME/.zsh/completion.d"
	@# Git completions (version-specific)
	@if command -v git >$(NULL_DEVICE) 2>&1 || where git >$(NULL_DEVICE) 2>&1; then \
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
	@if command -v docker >$(NULL_DEVICE) 2>&1 || where docker >$(NULL_DEVICE) 2>&1; then \
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
	@if command -v gh >$(NULL_DEVICE) 2>&1 || where gh >$(NULL_DEVICE) 2>&1; then \
		gh completion -s bash > "$$HOME/.bash/completion.d/gh.bash" 2>$(NULL_DEVICE) && \
		echo "✅ GitHub CLI bash completion updated" || echo "❌ Failed to update GitHub CLI bash completion"; \
		gh completion -s zsh > "$$HOME/.zsh/completion.d/_gh" 2>$(NULL_DEVICE) && \
		echo "✅ GitHub CLI zsh completion updated" || echo "❌ Failed to update GitHub CLI zsh completion"; \
	fi
	@# kubectl completion
	@if command -v kubectl >$(NULL_DEVICE) 2>&1 || where kubectl >$(NULL_DEVICE) 2>&1; then \
		kubectl completion bash > "$$HOME/.bash/completion.d/kubectl.bash" 2>$(NULL_DEVICE) && \
		echo "✅ kubectl bash completion updated" || echo "❌ Failed to update kubectl bash completion"; \
		kubectl completion zsh > "$$HOME/.zsh/completion.d/_kubectl" 2>$(NULL_DEVICE) && \
		echo "✅ kubectl zsh completion updated" || echo "❌ Failed to update kubectl zsh completion"; \
	fi
	@# npm completion
	@if command -v npm >$(NULL_DEVICE) 2>&1 || where npm >$(NULL_DEVICE) 2>&1; then \
		npm completion > "$$HOME/.bash/completion.d/npm.bash" 2>$(NULL_DEVICE) && \
		echo "✅ npm bash completion updated" || echo "❌ Failed to update npm bash completion"; \
	fi
	@# Poetry completion
	@if command -v poetry >$(NULL_DEVICE) 2>&1 || where poetry >$(NULL_DEVICE) 2>&1; then \
		poetry completions bash > "$$HOME/.bash/completion.d/poetry.bash" 2>$(NULL_DEVICE) && \
		echo "✅ Poetry bash completion updated" || echo "❌ Failed to update Poetry bash completion"; \
		poetry completions zsh > "$$HOME/.zsh/completion.d/_poetry" 2>$(NULL_DEVICE) && \
		echo "✅ Poetry zsh completion updated" || echo "❌ Failed to update Poetry zsh completion"; \
	fi
	@# chezmoi completion
	@if command -v chezmoi >$(NULL_DEVICE) 2>&1 || where chezmoi >$(NULL_DEVICE) 2>&1; then \
		if chezmoi completion --help >$(NULL_DEVICE) 2>&1; then \
			chezmoi completion bash --output "$$HOME/.bash/completion.d/chezmoi.bash" && \
			echo "✅ chezmoi bash completion updated" || echo "⚠️ chezmoi bash completion failed"; \
			chezmoi completion zsh --output "$$HOME/.zsh/completion.d/_chezmoi" && \
			echo "✅ chezmoi zsh completion updated" || echo "⚠️ chezmoi zsh completion failed"; \
		else \
			echo "⚠️ chezmoi completion command not available"; \
		fi; \
	fi
	@# Set appropriate permissions
	@chmod +x "$$HOME"/.bash/completion.d/*.bash 2>$(NULL_DEVICE) || true
	@chmod +x "$$HOME"/.zsh/completion.d/_* 2>$(NULL_DEVICE) || true
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
	@echo "Git: $$(git --version 2>$(NULL_DEVICE) || echo 'Not installed')"
	@echo "Python: $$(python3 --version 2>$(NULL_DEVICE) || python --version 2>$(NULL_DEVICE) || echo 'Not installed')"
	@echo "Node.js: $$(node --version 2>$(NULL_DEVICE) || echo 'Not installed')"
	@echo "Neovim: $$(nvim --version 2>$(NULL_DEVICE) | head -1 || echo 'Not installed')"
	@echo "fzf: $$(fzf --version 2>$(NULL_DEVICE) || echo 'Not installed')"
	@echo "ripgrep: $$(rg --version 2>$(NULL_DEVICE) | head -1 || echo 'Not installed')"
	@echo "direnv: $$(direnv --version 2>$(NULL_DEVICE) || echo 'Not installed')"

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
	@echo "OS: $(DETECTED_OS)"
ifeq ($(DETECTED_OS),Windows)
	@echo "Architecture: $$(echo $$PROCESSOR_ARCHITECTURE)"
else
	@echo "Architecture: $$(uname -m)"
endif
	@echo "Shell: $$SHELL"
	@echo "Home: $$HOME"
	@echo "Chezmoi config: $$(chezmoi doctor 2>$(NULL_DEVICE) | grep 'config file' || echo 'Default')"