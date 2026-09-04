---
name: agy-search
description: Web search via the `agy` CLI. Use this skill whenever a web search is needed instead of the builtin WebSearch tool.
---

## Agy Search

`agy`（Antigravity CLI、旧 `gemini`）で Web 検索を行う。

**この skill が呼ばれたら、builtin `WebSearch` ツールではなく必ず `agy` を使う。**

```bash
mkdir -p ~/.cache/agy-sub && cd ~/.cache/agy-sub   # 隔離 cwd（リポジトリ・trusted workspace 内で起動しない）
timeout 300 agy --print "WebSearch: <query>"
```

注意:

- `--print`（alias `-p` / `--prompt`）は単発プロンプトを非対話で実行して応答を表示する。
- agy は自律エージェントであり、trusted workspace 内で起動するとツール操作（ファイル書き込み含む）が
  無確認で自動承認される。**必ず隔離 cwd から起動し、`--continue` / `-c` / `--conversation` /
  `--dangerously-skip-permissions` は使わない**。
- `agy --print` は応答後にプロセスが終了しないことがあるため、必ず `timeout` で囲む。
  時間のかかる調査は `--print-timeout 10m` を付け、外側の `timeout` も合わせて延長する。

## 関連スキルとの使い分け

- 検索を超える**深掘り調査・要約・作業の委譲**は `agy` skill
- **設計判断の壁打ち・セカンドオピニオン**は `agy-discuss` skill
