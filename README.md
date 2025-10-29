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
# scoopのインストール
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

# Install chezmoi using scoop
scoop install chezmoi

# Alternatively, using winget
winget install chezmoi
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
- Set up development tools (fzf, pyenv, nvm, etc.) - *Note: Limited on Termux*
- Apply all configuration files
- Update shell completions (Linux/macOS/Windows only)

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

### Updating Tools and Dependencies

The repository uses two complementary update mechanisms:

#### 1. Automatic Updates via chezmoi
- **External tools** (fzf, pyenv, nvm, etc.) are managed by `.chezmoiexternal.toml`
- Updates happen automatically every 7 days when running `chezmoi apply`
- Force immediate update: `chezmoi apply --refresh-externals`

#### 2. Manual Tool Updates

##### Using Makefile (Linux/macOS/Windows)
Navigate to the chezmoi source directory and use the included Makefile:

**Note**: On Windows, you need `make` installed. Options include:
- Git for Windows (Git Bash) - use `make` or `mingw32-make`
- MSYS2/MinGW - includes make package
- WSL - full Linux compatibility
- Chocolatey: `choco install make`

```bash
# Enter chezmoi source directory
chezmoi cd

# Update everything (chezmoi apply)
make update

# Update only development tools (pyenv, nvm, fzf, tmux plugins)
make update-tools

# Update all Neovim plugins (lazy, mason, coc, treesitter)
make update-neovim

# Update Neovim plugins individually
make update-neovim-lazy        # Lazy.nvim plugins
make update-neovim-mason       # Mason LSP servers
make update-neovim-coc         # coc.nvim extensions
make update-neovim-treesitter  # Tree-sitter parsers

# Update Neovim Python/Node.js environment
make update-neovim-env

# Run Neovim health check
make neovim-health

# Update all Neovim components (plugins + environment)
make update-neovim-all
```

##### Windows (using PowerShell - alternative)
Navigate to the chezmoi source directory and use the PowerShell script:

```powershell
# Enter chezmoi source directory
chezmoi cd

# Update all Neovim components (plugins + environment)
.\Update-Neovim.ps1 all

# Update only plugins
.\Update-Neovim.ps1 plugins

# Update individually
.\Update-Neovim.ps1 lazy        # Lazy.nvim plugins
.\Update-Neovim.ps1 mason       # Mason LSP servers
.\Update-Neovim.ps1 coc         # coc.nvim extensions
.\Update-Neovim.ps1 treesitter  # Tree-sitter parsers
.\Update-Neovim.ps1 env         # Python/Node.js environment
.\Update-Neovim.ps1 health      # Run health check
```

**Important**: While `chezmoi apply` updates the tool repositories, it doesn't:
- Install new Python/Node.js versions
- Update pip/npm packages
- Update Neovim plugins
- Update tmux plugins

Use the manual update commands periodically to keep everything current.

**Note**: On Termux (Android), update scripts are automatically skipped. Use Termux's package manager (`pkg update && pkg upgrade`) for system updates.

**Note**: When a new Python version is installed, the Neovim Python virtual environment (`neovim3`) is automatically recreated with the latest Python version to ensure compatibility and security.

## What Gets Installed

### Packages (OS-specific)
- **Linux**: build-essential, ripgrep, fd-find, bat, git-delta, direnv, neovim, gh, etckeeper
  - Ubuntu/Debian: Uses apt with PPA for latest versions
  - RHEL/Fedora: Uses dnf with EPEL repository
  - Arch/Manjaro: Uses pacman with AUR support
- **macOS**: Core utils, modern CLI tools, development environment via Homebrew
- **Windows**: Git, Python, Node.js, VSCode, PowerToys via winget
- **Termux**: Mobile development environment with adapted packages (development tool scripts are automatically skipped due to filesystem limitations)

### Development Tools (automatically managed)
- **fzf**: Fuzzy finder for command line
- **pyenv**: Python version manager
- **nvm**: Node.js version manager  
- **tmux**: Terminal multiplexer with plugin manager
- **z**: Smart directory navigation

*Note: On Termux (Android), development tool setup scripts are automatically skipped due to filesystem and permission limitations. These tools can be manually installed using Termux's package manager.*

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

This repository includes a cross-platform Makefile with shortcuts for common operations.

**Requirements**: `make` must be installed. On Windows, use Git Bash, MSYS2, WSL, or install via Chocolatey.

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
- `manual-configs/` - Manual configurations and encrypted personal files

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

## Encryption

This repository uses Age encryption to protect personal configuration files containing sensitive information. The encryption configuration is automatically included in the chezmoi configuration template.

### Setup Encryption

Age encryption is automatically configured during the initial setup. During the setup process, you'll be prompted to configure:
- Age identity file path (default: `~/.config/chezmoi/key.txt`)
- Age recipient (your public key)

The encryption settings are managed through `.chezmoi.toml.tmpl` template variables to ensure consistency across environments.

### Manual Encryption Setup

If you need to set up encryption manually or update your keys:

```bash
# Generate Age key pair
mkdir -p ~/.config/chezmoi
age-keygen -o ~/.config/chezmoi/key.txt
chmod 600 ~/.config/chezmoi/key.txt

# Get your public key
age-keygen -y ~/.config/chezmoi/key.txt

# Update encryption settings by removing cached values and re-running chezmoi
chezmoi state delete-bucket --bucket=templateData
chezmoi apply

# This will re-prompt for all template variables including Age settings
```


### Encrypted Files

Personal configuration files are stored encrypted:
- Location: `manual-configs/` directory
- Format: Files with `.age` extension
- Examples: dconf settings, personal keymaps, etc.

### Working with Encrypted Files

#### Using chezmoi encryption (for dotfiles)

```bash
# Add encrypted file to chezmoi
chezmoi add --encrypt ~/.ssh/id_rsa

# Edit encrypted file
chezmoi edit ~/.ssh/id_rsa

# View decrypted content
chezmoi cat ~/.ssh/id_rsa

# Apply encrypted files
chezmoi apply
```

#### Manual encryption (for manual-configs)

For files in `manual-configs/` directory that are not managed by chezmoi:

```bash
# Decrypt and view file
age -d -i ~/.config/chezmoi/key.txt encrypt_{FILENAME}.ini.age

# Create new encrypted file
FILENAME="your-config-file"
age -r $(age-keygen -y ~/.config/chezmoi/key.txt) -o encrypt_${FILENAME}.ini.age ${FILENAME}.ini
rm ${FILENAME}.ini  # Remove plaintext

# Backup your private key (IMPORTANT!)
cp ~/.config/chezmoi/key.txt /secure/backup/location/
```

### Security Notes

- **Never commit the private key** (`~/.config/chezmoi/key.txt`) to the repository
- **Backup your private key** to multiple secure locations
- **Lost keys mean permanently encrypted files** - recovery is impossible
- The `age` package is automatically installed during setup

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