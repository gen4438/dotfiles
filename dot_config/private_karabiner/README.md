# Karabiner-Elements 設定ドキュメント

Windows/Linux 的な操作感を macOS で実現するための設定。

## ターミナル系アプリ

以下の4アプリは「ターミナル系」として特別扱いされ、多くのルールで Cmd/Ctrl の入れ替え等が適用される。

- `com.apple.Terminal`
- `com.googlecode.iterm2`
- `com.microsoft.VSCode`
- `com.google.antigravity`

---

## 第1層: デバイスレベル (simple_modifications)

complex_modifications より先に処理される。物理キーの配置を論理キーに変換する。

### HHKB (vendor: 11240, product: 6) / Realforce (vendor: 1204, product: 4621)

PC キーボード向け。左 Cmd/Ctrl を入れ替え + IME キー変換。

| 物理キー                  | 論理キー              |
| ------------------------- | --------------------- |
| left_command (Win キー)   | left_control          |
| left_control              | left_command          |
| japanese_pc_nfer (無変換) | japanese_eisuu (英数) |
| japanese_pc_xfer (変換)   | japanese_kana (かな)  |

### Apple KB (vendor: 1452, product: 641) / 汎用 (全キーボード共通)

左手の修飾キーを4つローテーション。

| 物理キー     | 論理キー     |
| ------------ | ------------ |
| caps_lock    | left_command |
| left_command | left_option  |
| left_option  | left_control |
| left_control | caps_lock    |

---

## 第2層: Complex Modifications (ルール一覧)

ルールは**上から順に評価**され、**最初にマッチした manipulator が勝つ**。
修飾キー自体の変換と、キー+修飾子の変換は別イベントとして処理される点が重要。

### Finder 操作

| ルール                                         | 内容                                      |
| ---------------------------------------------- | ----------------------------------------- |
| Use Return as Open and Use Fn+Return as Rename | Finder で Return=開く、Fn+Return=リネーム |
| Use F2 as Rename                               | Finder で F2=リネーム (Windows 風)        |
| Use Return as Open                             | Finder で Return+任意修飾=開く            |

### アプリ切り替え (数字キー)

物理的に「同じキー操作」でアプリを切り替えるため、ターミナル系と非ターミナル系で修飾キーを分けている。
ターミナル系では Cmd/Ctrl が入れ替わるため、物理 Cmd が command として認識される非ターミナルでは ctrl-N、
物理 Cmd が control になるターミナルでは command-N (=swap 前の ctrl) をトリガーにしている。

| 物理キー | 非ターミナル | ターミナル | 動作                 |
| -------- | ------------ | ---------- | -------------------- |
| Cmd+1    | ctrl-1       | command-1  | Google Chrome を開く |
| Cmd+2    | ctrl-2       | command-2  | Finder を開く        |
| Cmd+3    | ctrl-3       | command-3  | iTerm2 を開く        |

### デスクトップ切り替え保護

| ルール                                                   | 内容                                                                                |
| -------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| Ensure command + options + arrow keys to switch desktops | Cmd+Ctrl+矢印をそのままパススルー。後続の swap ルールで壊されないためのガードルール |

### Tab 切り替え

3段階の変換で Tab 修飾子をローテーション。

**基本ルール (全アプリ):**

| 物理キー         | 出力          | 用途                        |
| ---------------- | ------------- | --------------------------- |
| Cmd+Tab          | Ctrl+Tab      | アプリ内タブ切り替え        |
| Option+Tab       | Cmd+Tab       | macOS アプリ切り替え        |
| Option+Shift+Tab | Cmd+Shift+Tab | macOS アプリ切り替え (逆順) |
| Ctrl+Tab         | Option+Tab    | ウィンドウ切り替え          |

**ターミナル系の補正 (基本ルールより先に評価):**

ターミナル系では Cmd/Ctrl swap により修飾子がずれるため、事前に補正して非ターミナルと同じ物理キー体験を維持する。

| swap 後の修飾子     | 補正出力              | 結果                                    |
| ------------------- | --------------------- | --------------------------------------- |
| Ctrl+Tab (物理 Cmd) | Ctrl+Tab (パススルー) | タブ切り替え (非ターミナルと同じ)       |
| Cmd+Tab (物理 Ctrl) | Option+Tab            | ウィンドウ切り替え (非ターミナルと同じ) |

### JIS キーボード

| ルール                  | 内容                                                    |
| ----------------------- | ------------------------------------------------------- |
| underscore to backslash | `_` キー (international1) → `\` (international3+Option) |

### 絵文字メニュー

物理的に同じキーで絵文字メニューを開けるようにしている。

| アプリ       | 物理キー | 出力                    |
| ------------ | -------- | ----------------------- |
| ターミナル系 | Cmd+.    | Cmd+Ctrl+Space (絵文字) |
| 非ターミナル | Ctrl+.   | Cmd+Ctrl+Space (絵文字) |

### Cmd/Ctrl 入れ替え (修飾キー自体)

#### リモートデスクトップ用

| ルール                                | 内容                                                        |
| ------------------------------------- | ----------------------------------------------------------- |
| Swap command and control in some apps | Microsoft RDC, Ericom で左右とも Cmd ↔ Ctrl を完全入れ替え |

#### ターミナル系用

| ルール                                      | 内容                                                                            |
| ------------------------------------------- | ------------------------------------------------------------------------------- |
| Swap left-ctrl and command only in Terminal | left_command ↔ left_control を双方向入れ替え                                   |
| right-command to ctrl only in Terminal      | right_command → right_control (片方向。right_ctrl キーが存在しないため逆は不要) |

#### ターミナル系の例外

| ルール                                                     | 内容                                       |
| ---------------------------------------------------------- | ------------------------------------------ |
| Exceptions for Swap left-ctrl and command only in Terminal | Cmd+Escape → Ctrl+Escape (swap の打ち消し) |

### ターミナル系のコピペ・新規ウィンドウ (Linux 風)

swap 後の修飾子で macOS のコピペ操作を実現する。

| 物理キー    | from (swap 後) | 出力  | 用途                                  |
| ----------- | -------------- | ----- | ------------------------------------- |
| Cmd+Shift+C | Ctrl+Shift+C   | Cmd+C | コピー                                |
| Cmd+Shift+V | Ctrl+Shift+V   | Cmd+V | ペースト (Terminal/iTerm2 のみ)       |
| Cmd+Shift+N | Ctrl+Shift+N   | Cmd+N | 新規ウィンドウ (Terminal/iTerm2 のみ) |

### ターミナル起動

| ルール                                  | 内容                                              |
| --------------------------------------- | ------------------------------------------------- |
| Open a terminal window with Ctrl-RAlt-T | Cmd+Option+T で iTerm2 をホームディレクトリで開く |

### 矢印キー修飾子の入れ替え

#### 非ターミナル: Cmd+矢印 ↔ Option+矢印

Windows 風のカーソル移動を実現。

| 物理キー   | 出力       | 用途                        |
| ---------- | ---------- | --------------------------- |
| Cmd+←/→    | Option+←/→ | 単語単位で移動              |
| Cmd+↑/↓    | Option+↑/↓ | 段落単位で移動              |
| Option+←/→ | Cmd+←/→    | 行頭/行末へ移動             |
| Option+↑/↓ | Cmd+↑/↓    | ドキュメント先頭/末尾へ移動 |

#### VSCode: 矢印交換スキップ (パススルー)

VSCode は GUI エディタとして Cmd/Ctrl の両方をネイティブに正しく扱うため、
Cmd/Ctrl swap だけで十分であり、矢印交換ルールは不要。
ターミナル用の矢印交換ルールより先にパススルーを挿入して交換をバイパスしている。

| 物理キー   | swap 後    | VSCode の動作          |
| ---------- | ---------- | ---------------------- |
| Cmd+←/→    | Ctrl+←/→   | 単語単位で移動         |
| Cmd+↑/↓    | Ctrl+↑/↓   | スクロール             |
| Ctrl+←/→   | Cmd+←/→    | 行頭/行末へ移動        |
| Ctrl+↑/↓   | Cmd+↑/↓    | ファイル先頭/末尾      |

#### ターミナル (Terminal/iTerm2/antigravity): Cmd+矢印 ↔ Ctrl+矢印

ターミナルエミュレータでは swap 後の修飾子を再交換して正しい動作を実現する。
(swap が Cmd→Ctrl にし、交換が Ctrl→Cmd に戻すことで、結果的にターミナルに Cmd+矢印が届く)

| from (swap 後)       | 出力      | 用途                      |
| -------------------- | --------- | ------------------------- |
| Cmd+矢印 (物理 Ctrl) | Ctrl+矢印 | ターミナルの行頭/行末移動 |
| Ctrl+矢印 (物理 Cmd) | Cmd+矢印  | ターミナルの単語移動      |

### Home/End キー (Windows 風)

#### 非ターミナル

| 物理キー | 出力  | 用途               |
| -------- | ----- | ------------------ |
| Home     | Cmd+← | 行頭へ移動         |
| End      | Cmd+→ | 行末へ移動         |
| Cmd+Home | Cmd+↑ | ドキュメント先頭へ |
| Cmd+End  | Cmd+↓ | ドキュメント末尾へ |

※ Shift 同時押しで選択範囲を拡張

#### ターミナル

| 物理キー | from (swap 後)  | 出力                                    | 用途               |
| -------- | --------------- | --------------------------------------- | ------------------ |
| Home     | home (そのまま) | 行頭へ移動 (ルール不要、ネイティブ動作) |
| End      | end (そのまま)  | 行末へ移動 (ルール不要、ネイティブ動作) |
| Cmd+Home | Ctrl+Home       | Cmd+↑                                   | ドキュメント先頭へ |
| Cmd+End  | Ctrl+End        | Cmd+↓                                   | ドキュメント末尾へ |

※ Shift 同時押しで選択範囲を拡張

---

## 処理フローの仕組み

Karabiner-Elements では、修飾キーのキーダウンと通常キーのキーダウンは**別イベント**として処理される。

### 非ターミナルでの例: Cmd+←

1. Cmd キーダウン → swap ルール対象外 → **command** のまま
2. ← キーダウン → 「Cmd+矢印 ↔ Opt+矢印」ルールにマッチ → **Option+←** を送信
3. macOS が Option+← を受信 → **単語単位で左に移動**

### ターミナルでの例: 物理 Cmd+←

1. Cmd キーダウン → swap ルールで **control** に変換
2. ← キーダウン → 修飾子は control → 「Ctrl+矢印 → Cmd+矢印」ルールにマッチ → **Cmd+←** を送信
3. ターミナルアプリが Cmd+← を受信 → **行頭に移動** (ターミナルの標準動作)

### 重要なポイント

- `to` の出力は他のルールで**再処理されない** (直接 OS/アプリに送信される)
- ルールは上から順に評価され、**最初にマッチした manipulator のみ**が実行される
- ターミナル系の補正ルールは、対応する汎用ルールより**先に配置**する必要がある
