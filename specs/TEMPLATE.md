# <infra-change-name>

## メタ情報

- Issue: #<number> / draft-YYYYMMDD
- ステータス: Draft
- 作成日: YYYY-MM-DD
- 更新日: YYYY-MM-DD

## 設計フェーズ状況

状態は `未着手 / 進行中 / 完了 / レビュー済 / 保留` のいずれか。保留の場合は理由を備考に残す。

| #   | フェーズ                 | 状態   | 最終更新 | 備考 |
| --- | ------------------------ | ------ | -------- | ---- |
| 1   | 起票                     | 未着手 |          |      |
| 2   | 下書き                   | 未着手 |          |      |
| 3   | 上位文書突合             | 未着手 |          |      |
| 4   | 論点整理                 | 未着手 |          |      |
| 5   | 論点解決                 | 未着手 |          |      |
| 6   | Resource / Contract 設計 | 未着手 |          |      |
| 7   | Terraform / State 設計   | 未着手 |          |      |
| 8   | Security / Runtime 設計  | 未着手 |          |      |
| 9   | Test / Metrics 設計      | 未着手 |          |      |
| 10  | 実装分割                 | 未着手 |          |      |
| 11  | レビュー済               | 未着手 |          |      |

## 上位ドキュメント確認

- PRD 更新要否: 要 / 不要
- Design Docs 更新要否: 要 / 不要
- ADR 起票要否: 要 / 不要

## 関連資料

- `PRD.md`:
- `design/DesignDoc.md`:
- 関連 issue / ticket:
- app repo 側の関連資料:

## 背景

- なぜこの infra spec が必要か
- どの Cloudflare resource / environment / app contract に影響するか
- Terraform 管理対象か、既存 dashboard 設定の import / 移行か

## スコープ

### やること

-

### やらないこと

-

## 要件の解釈

### 実現したい運用価値

-

### 成功条件

-

### 操作主体 / 利用主体

-

## 論点一覧

| #   | 論点 | 決定候補 | 決定 |
| --- | ---- | -------- | ---- |
| 1   |      |          | 未決 |

## 解決済みの論点

-

## 未確定事項

-

## 実装対象

| 対象               | 実装有無 | 主な責務                                                |
| ------------------ | :------: | ------------------------------------------------------- |
| `terraform`        |  ◯ / -   | module、resource、variable、provider、state 参照        |
| `cloudflare-pages` |  ◯ / -   | Pages project、preview、production、custom domain       |
| `workers`          |  ◯ / -   | Workers、route、runtime binding、edge logic             |
| `dns`              |  ◯ / -   | DNS record、TLS、redirect、cache rule                   |
| `secrets`          |  ◯ / -   | secret 名、environment variable、binding、rotation 方針 |
| `ci-cd`            |  ◯ / -   | plan / apply job、権限、approval、artifact              |
| `observability`    |  ◯ / -   | analytics、logs、alert、drift detection                 |
| `docs`             |  ◯ / -   | contract、runbook、ADR、spec 更新                       |

## Resource / Contract 仕様

### Cloudflare Resource

-

### App Repo Contract

-

### Environment

-

### Preview / Production 差分

-

## Terraform / State 設計

### Terraform 構成

-

### State / Provider / Module

-

### Plan / Apply

-

## Security / Runtime 設計

### Secret / Binding

-

### Runtime Boundary

-

### 権限 / Approval

-

## Error / Rollback 設計

### エラーケース

| #   | ケース | 検知方法 | リカバリ |
| --- | ------ | -------- | -------- |
| 1   |        |          |          |

### Rollback

-

### Drift Detection

-

## テスト / 評価方針

### テスト観点

-

### 計測指標

-

### 検証コマンド

-

## 実装分割

### 実装タスク案

| Phase | 対象 | 概要 | 依存 |
| ----- | ---- | ---- | ---- |
| P1    |      |      |      |

### prompts 生成方針

- `terraform` / `cloudflare-pages` / `workers` / `dns` / `secrets` / `ci-cd` / `docs` のどこで分けるか
- 並列実装できる境界

## 既存資料からの変更点

| 対象 | 変更内容 | 理由 |
| ---- | -------- | ---- |
|      |          |      |

## 変更履歴

| 日付 | 変更者 | 変更内容 |
| ---- | ------ | -------- |
|      |        |          |

## 備考
