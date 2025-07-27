# Linux Manual Configurations

Linux-specific configurations and tools that require manual setup.

## Directories

### configs/
Configuration files that need to be manually applied:
- Application configurations
- System service configs
- Custom configuration files

### scripts/
Linux scripts and automation tools:
- Shell scripts for system setup
- Installation scripts
- Maintenance utilities

### snippets/
Code examples and configuration snippets:
- Command-line examples
- Configuration templates
- Useful aliases and functions

### systemd/
systemd service and timer files:
- Custom services (.service)
- Timer units (.timer)
- User services

### desktop/
Desktop environment files:
- Application launchers (.desktop)
- Custom menu entries
- Desktop icons

## Usage Examples

```bash
# Install systemd service
sudo cp service.service /etc/systemd/system/
sudo systemctl enable service.service
sudo systemctl start service.service

# Install desktop file
cp application.desktop ~/.local/share/applications/
update-desktop-database ~/.local/share/applications/

# Apply configuration
cp config.conf ~/.config/application/

# Make script executable
chmod +x script.sh
```

## Distribution-Specific Notes

### Ubuntu/Debian
- Use `apt` package manager
- Configuration paths: `/etc/` and `~/.config/`

### Fedora/RHEL
- Use `dnf` package manager  
- SELinux considerations

### Arch Linux
- Use `pacman` package manager
- AUR packages may be needed