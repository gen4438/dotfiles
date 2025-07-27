# Dotfiles

My personal dotfiles managed with [chezmoi](https://www.chezmoi.io/), featuring automatic package installation, external tool management, and cross-platform support.

## Features

- **Cross-platform support**: Linux (Ubuntu/Debian, RHEL/Fedora, Arch), macOS, Windows, and Termux
- **Automatic package installation**: OS-specific package managers (apt, dnf, pacman, brew, winget, pkg)
- **External tool management**: Automatic download and setup of development tools
- **Template-based configuration**: OS-specific settings using Go templates
- **Comprehensive shell setup**: Unified bash and zsh configurations
- **Modern development environment**: Neovim, Git, SSH, and development tools
- **Security-focused**: No sensitive data in the repository

## Quick Start

### Installing chezmoi

#### Ubuntu
```bash
sudo snap install chezmoi --classic
```

#### macOS
```bash
brew install chezmoi
```

#### Windows
```powershell
winget install twpayne.chezmoi
```

#### Termux
```bash
pkg install chezmoi
```

### First-time Setup

```bash
# Clone and apply dotfiles in one command
chezmoi init --apply gen4438
```

This will automatically:
- Clone the dotfiles repository
- Install OS-specific packages (build tools, ripgrep, direnv, etc.)
- Set up development tools (fzf, pyenv, nvm, etc.)
- Apply all configuration files
- Update shell completions

### Daily Usage

```bash
# Update dotfiles and tools
chezmoi update

# Check what would change before applying
chezmoi diff

# Apply local changes
chezmoi apply

# Edit configuration files
chezmoi edit ~/.bashrc
```

## What Gets Installed

### Packages (OS-specific)
- **Linux**: build-essential, ripgrep, fd-find, bat, git-delta, direnv, neovim, gh, etckeeper
  - Ubuntu/Debian: Uses apt with PPA for latest versions
  - RHEL/Fedora: Uses dnf with EPEL repository
  - Arch/Manjaro: Uses pacman with AUR support
- **macOS**: Core utils, modern CLI tools, development environment via Homebrew
- **Windows**: Git, Python, Node.js, VSCode, PowerToys via winget
- **Termux**: Mobile development environment with adapted packages

### Development Tools (automatically managed)
- **fzf**: Fuzzy finder for command line
- **pyenv**: Python version manager
- **nvm**: Node.js version manager  
- **tmux**: Terminal multiplexer with plugin manager
- **z**: Smart directory navigation

### Shell Configurations
- Unified bash/zsh setup with shared functionality
- Vi mode for command line editing
- Enhanced completions and aliases
- Development environment variables

### Cross-Platform Features
- **Neovim Configuration**: Unified config across Linux/macOS/Windows
  - Windows: Automatic junction creation (`%LOCALAPPDATA%\nvim` → `~/.config/nvim`)
  - Shared Lua configuration with 30+ plugins
  - Cross-platform snippet support
- **Windows-Specific Setup**: Automatic system configuration
  - Neovim configuration junction creation
  - Git and development environment setup

## Convenience Commands

This repository includes a Makefile with shortcuts for common operations:

```bash
make help              # Show all available commands
make status            # Show chezmoi and git status
make tools-status      # Check installed development tools
make update-completions # Update shell completions
make backup            # Create backup before major changes
make doctor            # Run system diagnostics
```

## Structure

- `dot_bash/` - Bash configuration files
  - `aliases.d/` - Command aliases
  - `completion.d/` - Shell completions
  - `functions.d/` - Custom functions
  - `keybindings.d/` - Key bindings
  - `scripts.d/` - Utility scripts
- `dot_bashrc.tmpl` - Main bash configuration (templated)
- `dot_zshrc.tmpl` - Main zsh configuration (templated)
- `dot_config/` - Application configurations
  - `nvim/` - Neovim setup with modern Lua configuration
  - `byobu/` - Terminal multiplexer configuration
  - `git/` - Git global configuration
- `.chezmoiexternal.toml` - External tool management
- `.chezmoiscripts/` - Automatic setup scripts

## Customization

### Personal Information
- Update git configuration via `chezmoi edit-config`
- Modify SSH configuration in `dot_ssh/`
- Adjust shell aliases in `.chezmoitemplates/`

### Adding Packages
- **Linux**: Edit `.chezmoiscripts/run_once_before_10-install-packages-linux.sh.tmpl`
- **macOS**: Edit `.chezmoiscripts/run_once_before_10-install-packages-darwin.sh.tmpl`  
- **Windows**: Edit `.chezmoiscripts/run_once_before_20-install-packages-windows.ps1.tmpl`
- **Termux**: Edit `.chezmoiscripts/run_once_before_10-install-packages-termux.sh.tmpl`

### Adding External Tools
Edit `.chezmoiexternal.toml` to add new tools:
```toml
["path/to/tool"]
    type = "git-repo"
    url = "https://github.com/author/tool.git"
    refreshPeriod = "168h"
```

### Adding New Configurations
1. Add new dotfiles to the chezmoi source directory
2. Use templates for OS-specific variations
3. Update `.chezmoiignore` if needed
4. Test with `chezmoi diff` before applying

## Useful Commands

```bash
# Enter the source directory
chezmoi cd

# Re-add a file after modifying it outside chezmoi
chezmoi re-add ~/.bashrc

# Force refresh external tools
chezmoi apply --refresh-externals
```

## Configuration Updates

To update configuration values (like git name/email):

```bash
chezmoi edit-config
```

Edit the `[data]` section with your new values, then apply changes:
```bash
chezmoi apply
```

## Testing

To test shell configurations after making changes:

```bash
# Quick test
./docs/run-shell-tests.sh

# Manual testing (see docs/shell-testing-guide.md for details)
bash --rcfile ~/.bashrc -i -c "echo 'Bash test: EDITOR=' \$EDITOR"
zsh -c "source ~/.zshrc && echo 'Zsh test: EDITOR=' \$EDITOR"
```

See `docs/shell-testing-guide.md` for comprehensive testing procedures.

## Troubleshooting

### Common Issues

1. **Package installation fails**:
   ```bash
   # Check system package manager
   make tools-status
   
   # Re-run package installation manually
   ~/.chezmoiscripts/run_once_before_10-install-packages-linux.sh
   ```

2. **External tools not downloading**:
   ```bash
   # Force refresh external tools
   chezmoi apply --refresh-externals
   ```

3. **Shell not loading new configs**:
   ```bash
   # Check if files are applied
   chezmoi status
   
   # Reload shell
   exec $SHELL
   ```

4. **Permission issues**:
   ```bash
   # Check chezmoi state
   chezmoi doctor
   
   # Fix permissions
   chmod +x ~/.chezmoiscripts/*.sh
   ```

5. **Windows-specific issues**:
   ```powershell
   # Check if Neovim junction was created properly
   Get-Item $env:LOCALAPPDATA\nvim | Select-Object LinkType, Target
   
   # Manually create junction if needed
   New-Item -Path "$env:LOCALAPPDATA\nvim" -ItemType Junction -Value "$env:USERPROFILE\.config\nvim"
   ```

### Getting Help

- Run `chezmoi doctor` for system diagnostics
- Check `make help` for available commands
- View logs with `chezmoi apply --verbose`
- See [chezmoi documentation](https://www.chezmoi.io/) for advanced usage

## Contributing

Feel free to fork and customize for your own use!