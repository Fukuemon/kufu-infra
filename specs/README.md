# Specs

`specs/` は issue / infra 変更単位で要求、設計、Terraform plan、rollback、検証観点を整理する
作業領域である。上位方針の正本は `PRD.md` と `design/DesignDoc.md` に残し、恒久的な意思決定は
`adr/` に昇格する。

## 命名規約

- ディレクトリ名: `specs/<issue-number>-<short-slug>/`
- 例:
  - `specs/1-cloudflare-pages-foundation/`
  - `specs/2-dns-production-domain/`
- `short-slug` は英小文字、数字、ハイフンを使う。
- issue 未採番の一時ドラフトだけ `specs/draft-<yyyymmdd>-<short-slug>/` を許容する。
- 一時ドラフトは issue 採番後に正式なディレクトリ名へ寄せる。

## 配置ルール

- 1 issue につき 1 ディレクトリを基本とする。
- 各 spec の入口は `index.md` とする。
- 実装タスクへ分割する場合は `prompts/` を同ディレクトリ配下に置く。
- 追加資料が必要な場合だけ図、plan 要約、runbook 補助文書を同ディレクトリ配下へ置く。

## 必須確認

新しい spec を作る時は、少なくとも次を確認する。

- PRD 更新要否
- Design Docs 更新要否
- ADR 起票要否
- Terraform plan / apply への影響
- Terraform state / provider / module への影響
- Cloudflare resource の create / update / destroy / replacement の有無
- DNS / custom domain / TLS / cache への影響
- secret / environment variable / binding への影響
- preview / production 差分
- app repo との infra contract 更新要否
- rollback / drift detection / observability の要否

## 推奨フロー

1. `PRD.md` で infra の What / Why / Who / 成功条件を確認する。
2. `design/DesignDoc.md` で Cloudflare、Terraform、environment、secret、cross-repo contract の境界を確認する。
3. `workflow-spec-draft` を使って 1 issue ごとに 1 spec を起こし、対象 resource と論点を `index.md` に閉じ込める。
4. `workflow-spec-lifecycle` を使って Terraform / Cloudflare / security / rollback / contract 観点を埋める。
5. 実装可能になったら `workflow-spec-implementation-prompts` を使って `prompts/` 配下へ
   `terraform` / `cloudflare-pages` / `workers` / `dns` / `secrets` / `ci-cd` / `docs` 単位で分割する。

## Kufu Infra での spec 分割指針

Phase 1 では、次の粒度で spec を切るのを基本とする。

- `cloudflare-pages-foundation`
- `dns-production-domain`
- `terraform-state-backend`
- `secrets-and-bindings`
- `workers-runtime-boundary`
- `preview-production-contract`
- `plan-apply-workflow`
- `drift-detection`
- `observability-foundation`

1 spec で複数 resource をまたぐ実装が発生してもよいが、論点は 1 つの infra 変更テーマに閉じる。

テンプレートは [TEMPLATE.md](TEMPLATE.md) を使う。

## 関連 Skills

- `workflow-spec-draft`: spec の初回作成
- `workflow-spec-lifecycle`: spec の phase 管理と review gate
- `workflow-spec-implementation-prompts`: prompt 分割と自己完結化
