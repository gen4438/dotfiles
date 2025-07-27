# macOS Manual Configurations

macOS-specific configurations and tools that require manual setup.

## Directories

### configs/
Configuration files that need to be manually applied:
- Application preferences
- System configuration files
- Plist files for manual import

### scripts/
macOS scripts and automation tools:
- Shell scripts for system configuration
- AppleScript files (.scpt)
- Setup automation scripts

### snippets/
Code examples and configuration snippets:
- Terminal commands
- AppleScript examples
- Configuration templates

### preferences/
macOS preference files (.plist):
- System preferences
- Application settings
- Custom configurations

### automator/
Automator workflows and services:
- Quick Actions
- Workflows (.workflow)
- Services for context menus

## Usage Examples

```bash
# Apply system preferences
defaults write com.apple.dock key value

# Import plist file
cp preference.plist ~/Library/Preferences/

# Make script executable
chmod +x script.sh

# Install Automator workflow
open workflow.workflow
```

## Common Commands

```bash
# List system preferences domains
defaults domains

# Read current preferences
defaults read com.apple.dock

# Reset preferences
defaults delete com.apple.dock
```