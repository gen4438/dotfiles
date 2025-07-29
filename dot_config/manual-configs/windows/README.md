# Windows Manual Configurations

Windows-specific configurations and tools that require manual setup.

## Directories

### configs/
Configuration files that need to be manually placed or imported:
- Application settings
- System configuration files
- Import/export configurations

### scripts/
Windows scripts and automation tools:
- Batch files (.bat, .cmd)
- PowerShell scripts (.ps1)
- System setup scripts

### snippets/
Code examples and configuration snippets:
- PowerShell one-liners
- Registry modification examples
- Configuration templates

### registry/
Windows Registry files (.reg):
- System tweaks
- Application preferences
- Performance optimizations

**⚠️ Warning**: Always backup your registry before applying .reg files!

### powershell/
PowerShell-specific resources:
- Profile scripts
- Module configurations
- Custom functions

## Usage Examples

```powershell
# Apply registry file
regedit /s filename.reg

# Run PowerShell script
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\script.ps1

# Import configuration
Copy-Item config.json $env:APPDATA\ApplicationName\
```