# Recommended CLI Tools

Modern command-line tools that enhance productivity across all platforms (Windows, macOS, Linux).

## Currently Installed (Base)

| Tool | Description | Replaces |
|------|-------------|----------|
| [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`) | Ultra-fast regex search | `grep` |
| [fd](https://github.com/sharkdp/fd) | Simple, fast file finder | `find` |
| [bat](https://github.com/sharkdp/bat) | Syntax-highlighted `cat` | `cat` |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder for anything | - |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart `cd` with frecency | `cd` |
| [delta](https://github.com/dandavella/delta) | Better git diff viewer | `diff` |

## Additional Tools

### File / Data Processing

| Tool | Description | Replaces |
|------|-------------|----------|
| [jq](https://github.com/jqlang/jq) | JSON processor and filter | - |
| [yq](https://github.com/mikefarah/yq) | YAML/TOML/XML processor (jq-like syntax) | - |
| [sd](https://github.com/chmln/sd) | Intuitive find & replace | `sed` |

### Directory / Disk

| Tool | Description | Replaces |
|------|-------------|----------|
| [broot](https://github.com/Canop/broot) | Interactive tree explorer with fuzzy search | `tree` + `cd` |

### System Monitoring

| Tool | Description | Replaces |
|------|-------------|----------|
| [bottom](https://github.com/ClementTsang/bottom) (`btm`) | Graphical system monitor | `top` / `htop` |
| [procs](https://github.com/dalance/procs) | Modern process viewer with color/search | `ps` |

### Shell / History

| Tool | Description | Replaces |
|------|-------------|----------|
| [atuin](https://github.com/atuinsh/atuin) | Shell history in SQLite, fuzzy search, sync | `history` / `Ctrl+R` |

### Task Runner

| Tool | Description | Replaces |
|------|-------------|----------|
| [just](https://github.com/casey/just) | Cross-platform task runner | `make` |

## Installation by OS

### Windows (Scoop)

All tools are available via Scoop:

```powershell
scoop install jq yq sd bottom procs just broot atuin
```

### macOS (Homebrew)

All tools are available via Homebrew:

```bash
brew install jq yq sd bottom procs just broot atuin
```

### Linux

**Arch Linux** - All available in official repos:

```bash
sudo pacman -S jq yq sd bottom procs just broot atuin
```

**Ubuntu/Debian, RHEL/Fedora** - `jq` is in repos; others are installed via `cargo binstall` (prebuilt binaries) with fallback to `cargo install`:

```bash
# jq
sudo apt install jq  # or sudo dnf install jq

# Others (requires cargo, installed via rustup)
cargo binstall sd broot bottom procs atuin just yq
```

### Termux (Android)

```bash
pkg install jq yq
# Others: cargo install sd broot bottom procs atuin just
```

## Migrating Data from Legacy Tools

### atuin (Shell History)

Import existing shell history into atuin:

```bash
atuin import bash        # from ~/.bash_history
atuin import zsh         # from zsh history
atuin import fish        # from fish history
atuin import powershell  # from PowerShell history
```

### zoxide (Directory Jump)

Import jump data from legacy tools:

```bash
zoxide import --from=z ~/.z              # from z
zoxide import --from=autojump /path/to/db  # from autojump
```

## Notes on `just` for Cross-Platform Use

`just` is a significant improvement over `Makefile` for cross-platform projects:

**Advantages over Make:**
- No tab-sensitivity issues
- No `.PHONY` needed
- Natural argument passing to recipes
- Built-in OS detection (`os()`, `os_family()`, `arch()`)
- Per-recipe shell selection
- `[windows]`, `[linux]`, `[macos]` attributes for OS-specific recipes

**Cross-platform pattern:**

```just
# Set default shell per OS
set windows-shell := ["powershell.exe", "-NoLogo", "-Command"]
set shell := ["bash", "-cu"]

# OS-independent recipes work as-is
test:
    cargo test

# OS-specific recipes with attributes
[windows]
setup:
    scoop install jq yq

[linux]
setup:
    sudo apt install jq

# Conditional logic within recipes
info:
    @echo "OS: {{os()}}, Arch: {{arch()}}"
```

**Limitations:**
- Shell commands still differ per OS (e.g., `rm` vs `Remove-Item`)
- Not a full abstraction layer over OS differences
- Best suited for projects using cross-platform toolchains (cargo, npm, go, etc.)
