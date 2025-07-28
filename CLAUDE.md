# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Chezmoi Reference

If you need help with chezmoi usage:
- Use web search for current information
- Refer to `@docs/chezmoi-guide.md` for comprehensive documentation

## Common Chezmoi Commands

### Initialization and Setup
- `chezmoi init` - Initialize chezmoi in current directory
- `chezmoi init --apply <repo>` - Clone and apply dotfiles from repository
- `chezmoi init --apply --verbose <repo>` - Clone and apply with verbose output

### Managing Files
- `chezmoi add <file>` - Add a file to chezmoi management
- `chezmoi add --template <file>` - Add as template file
- `chezmoi add --recursive <dir>` - Add directory recursively
- `chezmoi edit <file>` - Edit source file in your editor
- `chezmoi re-add <file>` - Update source from modified destination

### Reviewing Changes
- `chezmoi diff` - Show what changes would be made
- `chezmoi status` - List files that would be changed
- `chezmoi verify` - Verify destination matches source

### Applying Changes
- `chezmoi apply` - Apply all changes
- `chezmoi apply <file>` - Apply specific file
- `chezmoi update` - Pull latest changes and apply

### Version Control
- `chezmoi cd` - Enter source directory
- `chezmoi git <command>` - Run git command in source directory
- `chezmoi git status` - Check git status
- `chezmoi git add .` - Stage changes
- `chezmoi git commit -m "message"` - Commit changes

**Note**: When Claude Code creates commits, do not include Claude Code attribution or generation notices in commit messages.

## Repository Structure

### File Naming Conventions
- `dot_<name>` → `.name` (dotfiles)
- `<name>.tmpl` → Template file processed with Go templates
- `executable_<name>` → File with execute permissions
- `private_<name>` → File with 600 permissions
- `readonly_<name>` → File without write permissions
- `exact_<dir>` → Directory managed exactly (removes extra files)

### Special Directories and Files
- `.chezmoiignore` - Patterns to ignore (can be templated)
- `.chezmoitemplates/` - Reusable template snippets
- `.chezmoiscripts/` - Scripts that don't get copied to home
- `run_once_<name>` - Scripts that run once
- `run_onchange_<name>` - Scripts that run when content changes

## Cross-Platform Configuration

### Template Variables
- `{{ .chezmoi.os }}` - Operating system (linux/darwin/windows)
- `{{ .chezmoi.hostname }}` - Machine hostname
- `{{ .chezmoi.username }}` - Current username
- `{{ .chezmoi.arch }}` - Architecture (amd64/arm64 etc)

### OS-Specific Handling
```go
{{ if eq .chezmoi.os "darwin" -}}
# macOS specific configuration
{{ else if eq .chezmoi.os "linux" -}}
# Linux specific configuration
{{ else if eq .chezmoi.os "windows" -}}
# Windows specific configuration
{{ end -}}
```

## Important Guidelines for New Configurations

When adding new configurations, **always follow this planning process**:

1. **Identify target paths** for each OS:
   - Linux: Usually `~/.config/appname/`
   - macOS: May use `~/Library/Application Support/` or `~/.config/`
   - Windows: Often `%APPDATA%` or `%LOCALAPPDATA%`

2. **Determine if templating is needed**:
   - Different paths per OS
   - Machine-specific values (emails, usernames)
   - Conditional features based on environment

3. **Configure `.chezmoiignore.tmpl`**:
   - Exclude OS-specific files on other platforms
   - Prevent README.md from being copied to home

4. **Plan automation scripts** if needed:
   - `run_once_` for initial setup
   - `run_onchange_` for configuration that needs reloading

5. **Test changes** before applying:
   - Always run `chezmoi diff` first
   - Use `chezmoi apply --dry-run` for safety

## Configuration Patterns

### Shared Configuration Content
- Use `.chezmoitemplates/` for common content across multiple files
- Include shared templates: `{{ template "common_config.tmpl" . }}`
- Factor out repeated sections to avoid duplication

### Cross-Platform Application Settings
- **Same path on all OS**: Use `dot_config/appname/` directly
- **Different paths per OS**: Create multiple target paths, use `.chezmoiignore.tmpl` to exclude irrelevant ones
- **Platform-specific features**: Use conditional templating with `{{ if eq .chezmoi.os "..." }}`

### System Settings Integration
- **File-based settings**: Manage directly as dotfiles
- **Database/registry settings**: Export to files, use `run_onchange_` scripts to apply
- **Script pattern**: Hash content in comment to trigger on changes
  ```bash
  # config_file.ext hash: {{ include "config_file.ext" | sha256sum }}
  ```

### Script Templates
- **Cross-platform shebang**: Always use `{{ template "shebang-bash.tmpl" . }}` instead of hardcoded `#!/bin/bash`
- **Handles Android/Termux**: Automatically uses correct bash path for different platforms
- **Template location**: `.chezmoitemplates/shebang-bash.tmpl` provides consistent shebang across all scripts

## Best Practices

1. **Avoid hardcoding sensitive data** - Use templates and config variables
2. **Make scripts idempotent** - Safe to run multiple times
3. **Use meaningful commit messages** - Document what changed and why
4. **Run `chezmoi doctor`** periodically to check setup health
5. **Review changes with `chezmoi diff`** before applying
6. **Keep the repository structure clean** - Mirror home directory layout
7. **Document complex configurations** in comments or README

## Troubleshooting

- `chezmoi doctor` - Diagnose common issues
- `chezmoi execute-template` - Test template expressions
- Check file permissions if scripts fail to execute
- Verify paths exist before adding files

## File Creation Guidelines

- **Security Review**: Before adding any file, verify it doesn't contain sensitive information
- **Repository Appropriateness**: If a file shouldn't be in the public repository, add it to `.gitignore`
- **Dynamic Files**: Exclude auto-generated or session-specific files using `.chezmoiignore`

## Legacy Dotfiles Migration
- `@dotfiles_old/` contains the previous version of dotfiles that needs to be migrated to chezmoi
- Migration plan and progress are documented in `.claude/` directory
- Refer to `.claude/migration-plan.md` for detailed migration strategy and status

## Security Considerations for Public Repository

**IMPORTANT**: This repository is designed to be publicly hosted on GitHub. The following security measures have been implemented:

### Personal Information Removed
- **Git configuration**: Uses templates with environment variables and prompts instead of hardcoded names/emails
- **Personal plugins**: Most personal Neovim configurations have been made generic (memo.nvim is a public plugin)
- **SSH keys**: Only configuration templates, no actual keys are stored

### Sensitive Data Protection
- **`.gitignore`**: Configured to exclude all sensitive file types (keys, certificates, tokens, etc.)
- **`.chezmoiignore`**: Excludes dynamic and personal files (SSH agents, session data, auto-generated files)
- **Environment variables**: Used for API keys and credentials instead of hardcoding
- **Templates**: Personal data is parameterized through chezmoi templates

### Files to Review Before Public Release
1. **Neovim configuration**: Check `dot_config/nvim/` for personal configurations
2. **SSH config**: Verify no specific hostnames or keys are exposed
3. **Git configuration**: Ensure no personal information in templates
4. **dconf settings**: Review GNOME settings for personal preferences

### Safe Usage Guidelines
- **Never commit**: SSH keys, API tokens, passwords, certificates
- **Use templates**: For machine-specific or personal information
- **Environment variables**: For secrets (OPENAI_API_KEY, etc.)
- **Local config files**: Keep personal data in `~/.config/chezmoi/chezmoi.toml` (not in repo)

### Repository Structure for Security
- Personal configurations are templated or commented out
- Default values are generic and safe for public sharing
- Sensitive file patterns are comprehensively ignored
- Documentation clearly explains what needs customization