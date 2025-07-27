# dconf

## dconf の操作方法

### dconf 設定のエクスポート（ダンプ）

```sh
dconf dump / > rc/dconf/dconf-settings_$(date +%Y%m%d%H%M%S).ini
```

- 現在の dconf 設定全体をファイルに保存します。

---

### dconf 設定のインポート（ロード）

```sh
dconf load / < rc/dconf/dconf-settings_ファイル名.ini
```

- 保存した設定ファイルを dconf に反映します。

---

#### 注意事項

- `dconf dump`/`dconf load` の `/` はルートパス（全設定）です。特定のパスのみ操作したい場合は `/org/gnome/terminal/` などに変更できます。
- 設定を上書きするため、インポート時は内容に注意してください。
- バックアップを取ってから操作することを推奨します。

---

#### 参考コマンド

- 設定のバックアップ:  
  `dconf dump /org/gnome/terminal/ > terminal.ini`
- 設定の復元:  
  `dconf load /org/gnome/terminal/ < terminal.ini`

---

## 暗号化されたファイル

個人のdconf設定はAge暗号化で保護されています：

### ファイル形式
- `.age`拡張子：Age暗号化されたファイル
- 公開鍵確認：`age-keygen -y ~/.config/chezmoi/key.txt`

### 復号化方法

```bash
# ファイルを復号化して表示
age -d -i ~/.config/chezmoi/key.txt encrypt_dconf-settings_common.ini.age

# 復号化して設定を直接適用
age -d -i ~/.config/chezmoi/key.txt encrypt_dconf-settings_noble.ini.age | dconf load /

# 一時ファイルに復号化してから適用
age -d -i ~/.config/chezmoi/key.txt encrypt_dconf-settings_common.ini.age > /tmp/dconf-temp.ini
dconf load / < /tmp/dconf-temp.ini
rm /tmp/dconf-temp.ini
```

### 新しいdconfファイルの暗号化手順

新しくエクスポートしたdconf設定を暗号化する場合：

```bash
# 1. 日付変数を設定してdconf設定をエクスポート
DATE=$(date +%Y%m%d%H%M%S)
dconf dump / > dconf-settings_${DATE}.ini

# 2. ファイルを暗号化（公開鍵を動的に取得）
age -r $(age-keygen -y ~/.config/chezmoi/key.txt) -o encrypt_dconf-settings_${DATE}.ini.age dconf-settings_${DATE}.ini

# 3. 元の平文ファイルを削除
rm dconf-settings_${DATE}.ini
```

### セキュリティ注意事項
- Age秘密鍵（`~/.config/chezmoi/key.txt`）は厳重に管理してください
- 秘密鍵を失うと暗号化ファイルは永久に読めなくなります
- 秘密鍵は複数の安全な場所にバックアップしてください
- 新しく作成した設定ファイルは必ず暗号化してからリポジトリにコミットしてください
