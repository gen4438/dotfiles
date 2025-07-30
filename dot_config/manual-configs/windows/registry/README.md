# Windows Terminal Cursor Speed Optimization

Windows Terminalのカーソル移動速度を改善するレジストリ設定。

## レジストリファイル

- `keyboard_optimization.reg` - キーボードリピート速度最適化（メイン設定）
- `key_speed.reg` - 基本キーボード速度設定

## 適用手順

### 1. バックアップ
```powershell
PowerShell -ExecutionPolicy Bypass -File "backup_registry.ps1"
```

### 2. 設定適用
```cmd
reg import key_speed.reg
reg import keyboard_optimization.reg
```

### 3. 再起動
設定反映には再起動が必要。

## 復元方法
```powershell
PowerShell -ExecutionPolicy Bypass -File "restore_backup.ps1"
```