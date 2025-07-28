# Neovim Configuration

This is a comprehensive Neovim configuration managed by [chezmoi](https://chezmoi.io), featuring modern plugin management with [Lazy.nvim](https://github.com/folke/lazy.nvim) and extensive AI integration.

## Overview

This configuration provides a full-featured development environment with:
- Modern plugin management using Lazy.nvim
- AI-powered coding assistance (ChatGPT, Copilot, CodeCompanion)
- Advanced file management (Neo-tree, Oil)
- Rich syntax highlighting and language support
- Japanese language support
- Extensive customization and theming options

## File Structure

### Core Configuration Files

```
dot_config/nvim/
├── init.lua                     # Main entry point
├── lua/
│   ├── config/                  # Core configuration modules
│   │   ├── base.lua            # Basic Vim settings
│   │   ├── options.lua         # Editor options and behavior
│   │   ├── keymaps.lua         # Key bindings and mappings
│   │   ├── autocmds.lua        # Auto commands
│   │   ├── commands.lua        # Custom user commands
│   │   ├── filetypes.lua       # File type detection and settings
│   │   ├── gui.lua             # GUI-specific settings
│   │   ├── lazy.lua            # Lazy.nvim plugin manager setup
│   │   ├── colorscheme_pre.lua # Pre-colorscheme setup
│   │   ├── colorscheme_post.lua# Post-colorscheme customizations
│   │   └── custom.lua          # User-specific customizations
│   └── plugins/                # Plugin configurations
│       ├── aerial.lua          # Code outline and navigation
│       ├── chatgpt.lua         # ChatGPT integration
│       ├── codecompanion.nvim.lua # AI coding companion
│       ├── colorschemes.lua    # Color themes
│       ├── completion.lua      # Auto-completion setup
│       ├── copilot.lua         # GitHub Copilot
│       ├── filer.lua           # File managers (Neo-tree, Oil)
│       ├── fzf.lua             # Fuzzy finder
│       ├── git.lua             # Git integration
│       ├── markdown.lua        # Markdown editing tools
│       ├── telescope.lua       # Telescope fuzzy finder
│       ├── treesitter.lua      # Syntax highlighting
│       └── [many more...]      # Additional plugin configs
├── UltiSnips/                  # Code snippets
├── coc-settings.json           # CoC settings
└── misc/                       # Miscellaneous files
```

### Loading Order

The configuration loads in this order (from `init.lua`):

1. `config.base` - Basic Vim functionality
2. `config.custom` - User customizations
3. `config.autocmds` - Auto commands
4. `config.options` - Editor options
5. `config.keymaps` - Key mappings
6. `config.commands` - Custom commands
7. `config.filetypes` - File type settings
8. `config.colorscheme_pre` - Pre-theme setup
9. `config.gui` - GUI settings (if applicable)
10. `config.lazy` - Plugin manager and all plugins
11. `config.colorscheme_post` - Theme overrides

## Key Features

### AI Integration

This configuration includes multiple AI-powered tools:

- **ChatGPT** (`lua/plugins/chatgpt.lua`) - Direct ChatGPT integration
- **GitHub Copilot** (`lua/plugins/copilot.lua`) - AI pair programming
- **CodeCompanion** (`lua/plugins/codecompanion.nvim.lua`) - AI coding assistant
- **Parrot** (`lua/plugins/parrot.lua`) - Another AI integration option

### File Management

- **Neo-tree** - Modern file explorer with Git integration
- **Oil.nvim** - Directory editor that treats directories like files
- **Telescope** - Powerful fuzzy finder for files, buffers, and more

### Key Bindings Highlights

**Leader Key**: `,` (comma)

**File Operations**:
- `<C-e><C-e>` - Toggle Neo-tree
- `<C-e><C-f>` - Reveal current file in Neo-tree
- `;ff` - Fuzzy find files

**Window Management**:
- `ss` - Horizontal split
- `sv` - Vertical split
- `sj/sk/sl/sh` - Navigate between splits
- `sq` - Close buffer

**Terminal**:
- `<leader>sh` - Open terminal
- `<Esc><Esc>` - Exit terminal mode

**Japanese Input Support**:
- `い` → `i` (insert mode)
- `あ` → `a` (append mode)

**Utility**:
- `<space>=` - Calculate math expression on current line
- `yn/yp/yr/yd` - Copy filename/path/relative path/directory

### Color Themes

**Active Theme**: Catppuccin (Mocha flavor)

**Available Themes** (lazy-loaded):
- Gruvbox
- Tokyo Night
- Molokai
- Monokai variants
- Nightfox
- Nord
- Material
- Solarized
- And many more...

To change themes: `:colorscheme <theme_name>`

### Language Support

- **Treesitter** - Advanced syntax highlighting
- **LSP Integration** - Language server protocol support
- **File Type Detection** - Custom detection for various file types
- **Markdown** - Enhanced editing with Aerial outline navigation

## Customization

### Adding Plugins

Add new plugins to the appropriate file in `lua/plugins/` or create a new file:

```lua
return {
  {
    "author/plugin-name",
    config = function()
      -- Plugin configuration
    end,
  },
}
```

### Custom Settings

Modify `lua/config/custom.lua` for personal customizations that won't be overwritten.

### Key Bindings

Add custom keybindings to `lua/config/keymaps.lua` or create buffer-local mappings in plugin configs.

### Theme Customization

Color scheme customizations go in `lua/config/colorscheme_post.lua`.

## Special Features

### Aerial.nvim Markdown Integration

The Aerial plugin has been extensively customized for Markdown editing:
- `>>` / `<<` - Increase/decrease header levels
- `u` / `<C-r>` - Undo/redo in source buffer from outline
- Visual mode header level changes

### File Type Specific Settings

- **Python**: 4-space tabs, 88 character line width
- **Markdown**: Enhanced bullet point handling, tab/shift-tab for list indentation
- **CSV/TSV**: Optimized for large files (disables syntax for 5000+ lines)
- **JSON**: Support for comments (cjson)

### Security Considerations

This configuration is designed for public sharing:
- No hardcoded personal information
- Sensitive data handled through environment variables
- Generic defaults suitable for public repositories

## Installation

This configuration is managed by chezmoi. To use:

```bash
# If you're using this as part of a chezmoi dotfiles repo
chezmoi apply

# Or manually copy the nvim directory to your config location
```

## Dependencies

- Neovim 0.8+
- Git
- A Nerd Font for icons
- Node.js (for some plugins)
- Ripgrep (for telescope)
- Python 3 (for some plugins)

## Troubleshooting

- Run `:checkhealth` to diagnose issues
- Use `:Lazy sync` to update plugins
- Check `:messages` for error details
- Ensure all external dependencies are installed

## Contributing

This configuration is part of a public dotfiles repository. Feel free to fork and customize for your needs.