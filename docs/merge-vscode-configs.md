# Merging VSCode Configurations Across Platforms

## keybindings.json

```bash
"dot_config/Code/User/keybindings.json"
"AppData/Roaming/Code/User/keybindings.json"
"Library/Application Support/Code/User/keybindings.json"
```

## settings.json

```bash
"dot_config/Code/User/settings.json"
"AppData/Roaming/Code/User/settings.json"
"Library/Application Support/Code/User/settings.json"
```

## rsync

```bash
# Linux -> MacOS
rsync -av "dot_config/Code/User/" "Library/Application Support/Code/User/"

# MacOS -> Linux
rsync -av "Library/Application Support/Code/User/" "dot_config/Code/User/"

# Windows -> MacOS
rsync -av "AppData/Roaming/Code/User/" "Library/Application Support/Code/User/"

# MacOS -> Windows
rsync -av "Library/Application Support/Code/User/" "AppData/Roaming/Code/User/"
```
