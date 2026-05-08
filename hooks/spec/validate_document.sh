#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/../lib/tool_use_input.sh"

FILE_PATH="$(resolve_tool_use_file_path || true)"

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

if ! echo "$FILE_PATH" | grep -qE 'specs/[^/]+/index\.md$'; then
  exit 0
fi

ERRORS=()

REQUIRED_SECTIONS=(
  "## メタ情報"
  "## 設計フェーズ状況"
  "## 上位ドキュメント確認"
  "## 関連資料"
  "## 背景"
  "## スコープ"
  "## 要件の解釈"
  "## 論点一覧"
  "## 実装対象"
  "## Resource / Contract 仕様"
  "## Terraform / State 設計"
  "## Security / Runtime 設計"
  "## Error / Rollback 設計"
  "## テスト / 評価方針"
  "## 実装分割"
  "## 既存資料からの変更点"
  "## 変更履歴"
)

has_exact_line() {
  local line="$1"
  grep -qFx "$line" "$FILE_PATH" 2>/dev/null
}

extract_level2_section() {
  local heading="$1"
  awk -v heading="$heading" '
    $0 == heading {
      in_section = 1
      next
    }
    in_section && /^## / {
      exit
    }
    in_section {
      print
    }
  ' "$FILE_PATH"
}

section_has_exact_line() {
  local heading="$1"
  local line="$2"
  extract_level2_section "$heading" | grep -qFx "$line" 2>/dev/null
}

for section in "${REQUIRED_SECTIONS[@]}"; do
  if ! has_exact_line "$section"; then
    ERRORS+=("必須セクション欠落: $section")
  fi
done

PHASE_COUNT=$(
  extract_level2_section "## 設計フェーズ状況" \
    | grep -cE '^\|[[:space:]]*[0-9]+[[:space:]]*\|' 2>/dev/null \
    || echo "0"
)
if [ "$PHASE_COUNT" -lt 11 ]; then
  ERRORS+=("設計フェーズ状況に 11 フェーズ必要ですが ${PHASE_COUNT} 件しかありません")
fi

if has_exact_line "## スコープ"; then
  if ! section_has_exact_line "## スコープ" '### やること'; then
    ERRORS+=("スコープに「やること」がありません")
  fi
  if ! section_has_exact_line "## スコープ" '### やらないこと'; then
    ERRORS+=("スコープに「やらないこと」がありません")
  fi
fi

RESOURCE_CONTRACT_TOPICS=(
  "### Cloudflare Resource"
  "### App Repo Contract"
  "### Environment"
  "### Preview / Production 差分"
)

for topic in "${RESOURCE_CONTRACT_TOPICS[@]}"; do
  if ! section_has_exact_line "## Resource / Contract 仕様" "$topic"; then
    ERRORS+=("Resource / Contract 仕様の節がありません: $topic")
  fi
done

TERRAFORM_STATE_TOPICS=(
  "### Terraform 構成"
  "### State / Provider / Module"
  "### Plan / Apply"
)

for topic in "${TERRAFORM_STATE_TOPICS[@]}"; do
  if ! section_has_exact_line "## Terraform / State 設計" "$topic"; then
    ERRORS+=("Terraform / State 設計の節がありません: $topic")
  fi
done

SECURITY_RUNTIME_TOPICS=(
  "### Secret / Binding"
  "### Runtime Boundary"
  "### 権限 / Approval"
)

for topic in "${SECURITY_RUNTIME_TOPICS[@]}"; do
  if ! section_has_exact_line "## Security / Runtime 設計" "$topic"; then
    ERRORS+=("Security / Runtime 設計の節がありません: $topic")
  fi
done

ERROR_ROLLBACK_TOPICS=(
  "### エラーケース"
  "### Rollback"
  "### Drift Detection"
)

for topic in "${ERROR_ROLLBACK_TOPICS[@]}"; do
  if ! section_has_exact_line "## Error / Rollback 設計" "$topic"; then
    ERRORS+=("Error / Rollback 設計の節がありません: $topic")
  fi
done

if has_exact_line "## テスト / 評価方針"; then
  if ! section_has_exact_line "## テスト / 評価方針" '### 検証コマンド'; then
    ERRORS+=("テスト / 評価方針に「検証コマンド」がありません")
  fi
fi

if [ ${#ERRORS[@]} -gt 0 ]; then
  echo "" >&2
  echo "============================================================" >&2
  echo "[BLOCKED] spec 文書品質ゲート不合格" >&2
  echo "ファイル: $FILE_PATH" >&2
  echo "============================================================" >&2
  for err in "${ERRORS[@]}"; do
    echo "- $err" >&2
  done
  echo "specs/TEMPLATE.md に沿って補完してください。" >&2
  echo "============================================================" >&2
  exit 2
fi

exit 0
