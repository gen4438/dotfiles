---
name: agy
description: Run tasks or research via Gemini (Antigravity CLI) as a subagent. 大量のログ解析・リサーチ・定型コード生成など泥臭い作業を `agy` に委譲し、Claude のコンテキストとコストを節約する。Web 検索は agy-search、設計の壁打ちは agy-discuss を使う。
---

## Agy Subagent — タスク委譲

ユーザーから与えられたタスク（または Claude が委譲すると判断した作業）を `agy`（Gemini）に
サブエージェントとして実行させる。

## 厳守ルール

1. **必ず隔離 cwd（`~/.cache/agy-sub`）から起動する。** agy の会話は起動時の cwd に紐付き、
   リポジトリや trusted workspace 内で起動すると他セッションの会話に合流したり、
   ツール操作（ファイル書き込み含む）が無確認で自動承認される（実害事故あり。[[agy-is-agentic-no-continue]] 参照）。
2. **`--continue` / `-c` / `--conversation` / `--dangerously-skip-permissions` を絶対に使わない。**
3. agy は隔離 cwd で動くため**リポジトリを読めない全盲**。必要な文脈（コード断片・エラー・制約）は
   プロンプトに**そのまま貼り込む**。連続して `--print` を呼んでも会話は引き継がれない
   （v1.1.26 / 2026-09-05 検証済み）ため、**毎回自己完結したプロンプト**を渡す。
   ファイル編集が必要な成果物は agy にテキスト（コード・パッチ）で出力させ、適用はこちら（Claude）が行う。
4. Bash ツールは `timeout: 330000` 程度を指定するか、長いタスクは `run_in_background: true` で実行する
   （`agy --print` は応答後にプロセスが終了しないことがあるため `timeout` コマンドで必ず囲う）。

## 実行テンプレート

委譲するタスクと貼り込むべき文脈を組み合わせて PROMPT を組み立て、以下を実行する
（クォート衝突を避けるため、プロンプトが複雑な場合は heredoc でファイルに書いてから渡してよい）。

```bash
PROMPT="（ここにタスク＋必要な文脈。出力形式も指定する）"
WORKDIR="$HOME/.cache/agy-sub"
mkdir -p "$WORKDIR"
OUTPUT_FILE="$(mktemp "${TMPDIR:-/tmp}/agy_sub.XXXXXX")"

(
  cd "$WORKDIR" || exit 1
  timeout 300 agy --print "$PROMPT" --model gemini-3.8-flash-medium
) > "$OUTPUT_FILE" 2>&1
EXIT_CODE=$?

if [ "$EXIT_CODE" -ne 0 ]; then
  echo "Error: agy failed (exit $EXIT_CODE)"
  tail -n 20 "$OUTPUT_FILE"
  exit "$EXIT_CODE"
fi

echo "agy output saved to: $OUTPUT_FILE ($(wc -l < "$OUTPUT_FILE") lines)"
echo "--- head ---"
head -n 40 "$OUTPUT_FILE"
```

- モデルは用途で選ぶ: 大量・軽量作業は `gemini-3.8-flash-low`、標準は `gemini-3.8-flash-medium`、
  難しい推論は `gemini-3.1-pro-high`（一覧は `agy models`）。
- 出力が 40 行を超えた場合、全文を読み込まず `OUTPUT_FILE` を必要箇所だけ Read する（コンテキスト保護）。
- 5 分を超えそうなタスクは `--print-timeout 10m` を追加し、外側の `timeout` も合わせて延長する。
- 実行後、作業中リポジトリがあれば `git status` で汚れていないことを確認する。

## 関連スキルとの使い分け

- **Web 検索だけ**が目的なら `agy-search`
- **設計判断の壁打ち・セカンドオピニオン**なら `agy-discuss`
- 本スキルは**作業の委譲**（リサーチ・ログ解析・要約・コード/テストの下書き生成など）に使う
