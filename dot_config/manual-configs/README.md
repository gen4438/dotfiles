# Manual Configurations

This directory contains configurations, scripts, and resources that are not automatically managed by chezmoi but are useful for system setup and customization.

## Directory Structure

- **windows/** - Windows-specific configurations and tools
- **macos/** - macOS-specific configurations and tools  
- **linux/** - Linux-specific configurations and tools
- **misc/** - Cross-platform or general-purpose resources

Each OS directory contains:
- `configs/` - Configuration files to be manually applied
- `scripts/` - Utility scripts and automation tools
- `snippets/` - Code snippets and configuration examples

## Usage

1. Browse the appropriate OS directory
2. Read the OS-specific README for detailed instructions
3. Manually apply configurations as needed
4. Run scripts with appropriate permissions

## Note

Files in this directory are NOT automatically applied by chezmoi. They serve as:
- Reference configurations
- Manual setup tools
- Backup copies of complex settings
- Platform-specific utilities