# Chezmoi Dotfiles TODO & History

## Completed Tasks

### Initial Setup
- [x] Initialize chezmoi repository
- [x] Create comprehensive documentation
  - [x] Add README.md with setup instructions
  - [x] Add CLAUDE.md with chezmoi usage guidelines
  - [x] Add docs/chezmoi-guide.md with detailed reference
- [x] Configure .chezmoiignore for repository files

### Shell Configuration (Bash & Zsh)
- [x] Add bash configuration files
  - [x] Optimize .bashrc with PATH management improvements
  - [x] Add modular bash configuration structure
  - [x] Reorganize aliases with better categorization
  - [x] Split functions into encoding.sh, document.sh, navigation.sh
  - [x] Clean up completion.d directory
  - [x] Add keybindings documentation
  - [x] Remove unused snippets.d directory
- [x] Unify shell configurations
  - [x] Create shared shell_common.tmpl for bash/zsh
  - [x] Extract Ubuntu default settings to ubuntu_bashrc.tmpl
  - [x] Add comprehensive zsh configuration with modular structure
  - [x] Fix byobu prompt to be shell-aware (bash vs zsh formatting)
  - [x] Implement cross-shell PATH deduplication
- [x] Shell testing infrastructure
  - [x] Create automated testing suite with 19 comprehensive tests
  - [x] Add shell-testing-guide.md documentation
  - [x] Test template syntax validation
  - [x] Test bash/zsh functionality and cross-shell consistency

### Security & Repository Management
- [x] Create comprehensive .gitignore for sensitive data protection
- [x] Update .chezmoiignore with cross-platform template support
- [x] Add byobu terminal multiplexer configuration
- [x] Reorganize .gitignore structure for better clarity
  - [x] Fix .claude/settings.local.json exclusion precedence
  - [x] Improve logical flow from exclusions to inclusions to overrides

### Neovim Configuration
- [x] Add complete Neovim configuration
  - [x] Modern Lua-based setup
  - [x] 30+ modular plugin configurations
  - [x] AI integrations (Copilot, ChatGPT, CodeCompanion, Parrot)
  - [x] UltiSnips for multi-language snippet support
  - [x] memo.nvim with MEMO_DIR environment variable support

### Input Method & System Integration
- [x] Add readline configuration (.inputrc)
  - [x] Vi mode with visual indicators
  - [x] Enhanced tab completion
- [x] Add Mozc keymap configuration
- [x] Add X11 initialization files
  - [x] Fix .xinitrc typo and modernize
  - [x] Implement fcitx5/fcitx auto-detection
  - [x] Remove redundant .xinputrc
- [x] Add fcitx/fcitx5 configurations
  - [x] Use blacklist/whitelist approach in .chezmoiignore
  - [x] Remove dynamic/cache files
- [x] Add direnv configuration
  - [x] Python environment layouts (pyenv, poetry)
  - [x] Node.js environment layout (nvm)
  - [x] Remove deprecated Anaconda function
- [x] Add Karabiner-Elements configuration (macOS)
  - [x] Terminal-specific Ctrl/Cmd swapping
  - [x] Application shortcuts
  - [x] Arrow key behavior customization

## Completed Tasks

### Development Tools Update System
- [x] Create comprehensive development tools update system
  - [x] Add Neovim environment setup script (run_once_after_25-setup-neovim-environment.sh.tmpl)
  - [x] Add development tools update script (run_onchange_30-update-development-tools.sh.tmpl)
  - [x] Add Neovim environment update script (run_onchange_35-update-neovim-environment.sh.tmpl)
- [x] Implement automatic runtime version management
  - [x] Auto-update pyenv and install latest Python
  - [x] Auto-recreate neovim3 virtual environment when Python updates
  - [x] Auto-update nvm and install latest Node.js LTS
  - [x] Ensure neovim package installation/update for Node.js
- [x] Add comprehensive update commands to Makefile
  - [x] make update (update everything)
  - [x] make update-tools (development tools only)
  - [x] make update-nvim (Neovim plugins and packages)
  - [x] make update-completions (shell completions)
- [x] Document update mechanisms in README.md
- [x] Add Age encryption support for sensitive files
  - [x] Configure age identity and recipient
  - [x] Add SSH identity file configuration variable

## Pending Tasks

### Core Configurations
- [x] Add git configuration (.gitconfig)
- [x] Add SSH configuration templates
- [x] Add tmux configuration (included in byobu) - Already complete
- [x] Add shell prompt customization (basic implementation complete) - Already complete

### Cross-Platform Support
- [ ] Test on macOS
- [ ] Test on Windows (WSL)
- [ ] Add OS-specific configurations

### Development Tools
- [ ] Add language-specific configurations (Python, Node.js, Go)
- [ ] Add IDE configurations (VS Code settings)
- [ ] Add terminal emulator configurations

### Automation
- [x] Create installation scripts
  - [x] .chezmoiexternal.toml for external tool management
  - [x] OS-specific package installation scripts (Linux/macOS/Windows)
  - [x] Tool setup scripts for development environment
  - [x] Makefile with convenience commands
- [x] Add system package installation automation
  - [x] Linux: apt with Rust CLI tools (exa, zoxide, dust, teladeer)
  - [x] macOS: Homebrew with essential development tools
  - [x] Windows: winget with package list
- [x] Fix chezmoi script template syntax and permissions
- [x] Implement automatic update mechanism
- [ ] Create backup/restore scripts

### Documentation
- [ ] Add troubleshooting guide
- [ ] Create migration guide from old dotfiles
- [ ] Add contribution guidelines

## Notes

### Important Decisions
- Decided to use `~/Documents/my-notes` as default memo directory across all platforms
- Removed OS-specific templating for memo.lua as paths are consistent
- Using environment variable (MEMO_DIR) for flexibility
- Keeping Ubuntu default .bashrc structure for easier diff tracking
- Using pyenv shims removal for specific commands that work better with system versions
- Unified bash and zsh configurations using shared templates
- Prioritized bash structure for cross-shell compatibility
- Implemented comprehensive shell testing for configuration validation

### Technical Debt
- [ ] Consider splitting large fzf.bash into smaller modules
- [x] Review and optimize PATH management across shells
- [ ] Evaluate need for condition-based module loading

### Future Enhancements
- [ ] Add secret management integration
- [x] Implement automatic update mechanism
- [x] Add health check scripts (shell testing suite)
- [ ] Create interactive setup wizard
- [ ] Add shell performance profiling tools
- [ ] Implement automated cross-platform testing
- [ ] Add shell completions update automation
- [ ] Integrate with VS Code settings sync
- [ ] Add dconf settings management for GNOME