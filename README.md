# Dotfiles

My personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Quick Start

```bash
# Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"

# Clone and apply dotfiles
chezmoi init --apply https://github.com/yourusername/dotfiles.git
```

## Manual Setup

1. Initialize chezmoi:
   ```bash
   chezmoi init
   ```

2. Add your existing dotfiles:
   ```bash
   chezmoi add ~/.bashrc
   chezmoi add ~/.bash_profile
   # Add other dotfiles as needed
   ```

3. Review changes before applying:
   ```bash
   chezmoi diff
   ```

4. Apply changes:
   ```bash
   chezmoi apply
   ```

## Structure

- `dot_bash/` - Bash configuration files
  - `aliases.d/` - Command aliases
  - `completion.d/` - Shell completions
  - `functions.d/` - Custom functions
  - `keybindings.d/` - Key bindings
  - `scripts.d/` - Utility scripts
- `dot_bashrc` - Main bash configuration

## Useful Commands

```bash
# Check what files would be changed
chezmoi status

# Show differences
chezmoi diff

# Edit a file in chezmoi
chezmoi edit ~/.bashrc

# Re-add a file after modifying it outside chezmoi
chezmoi re-add ~/.bashrc

# Enter the source directory
chezmoi cd

# Update from repository
chezmoi update
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

## Contributing

Feel free to fork and customize for your own use!