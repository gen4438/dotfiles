# Chezmoi Dotfiles TODO & History

## Completed Tasks (2025-07-26)

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
- [x] Unify shell configurations (2025-07-26)
  - [x] Create shared shell_common.tmpl for bash/zsh
  - [x] Extract Ubuntu default settings to ubuntu_bashrc.tmpl
  - [x] Add comprehensive zsh configuration with modular structure
  - [x] Fix byobu prompt to be shell-aware (bash vs zsh formatting)
  - [x] Implement cross-shell PATH deduplication
- [x] Shell testing infrastructure (2025-07-26)
  - [x] Create automated testing suite with 19 comprehensive tests
  - [x] Add shell-testing-guide.md documentation
  - [x] Test template syntax validation
  - [x] Test bash/zsh functionality and cross-shell consistency

### Security & Repository Management
- [x] Create comprehensive .gitignore for sensitive data protection
- [x] Update .chezmoiignore with cross-platform template support
- [x] Add byobu terminal multiplexer configuration
- [x] Reorganize .gitignore structure for better clarity (2025-07-26)
  - [x] Fix .claude/settings.local.json exclusion precedence
  - [x] Improve logical flow from exclusions to inclusions to overrides

### Neovim Configuration
- [x] Add complete Neovim configuration
  - [x] Modern Lua-based setup
  - [x] 30+ modular plugin configurations
  - [x] AI integrations (Copilot, ChatGPT, CodeCompanion, Parrot)
  - [x] UltiSnips for multi-language snippet support
  - [x] memo.nvim with MEMO_DIR environment variable support

### Input Method & System Integration (2025-07-26)
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

## Pending Tasks

### Core Configurations
- [x] Add git configuration (.gitconfig) - 2025-07-26
- [x] Add SSH configuration templates - 2025-07-26
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

### Automation (2025-07-26)
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
- Unified bash and zsh configurations using shared templates (2025-07-26)
- Prioritized bash structure for cross-shell compatibility
- Implemented comprehensive shell testing for configuration validation

### Technical Debt
- [ ] Consider splitting large fzf.bash into smaller modules
- [x] Review and optimize PATH management across shells (2025-07-26)
- [ ] Evaluate need for condition-based module loading

### Future Enhancements
- [ ] Add secret management integration
- [ ] Implement automatic update mechanism
- [x] Add health check scripts (2025-07-26 - shell testing suite)
- [ ] Create interactive setup wizard
- [ ] Add shell performance profiling tools
- [ ] Implement automated cross-platform testing