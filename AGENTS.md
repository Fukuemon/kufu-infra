# Kufu Infra Agent Operating Contract

## Repository Reference Rules

- 本プロジェクトは `ghq` を利用してリポジトリを管理する
- リポジトリの path を記載する場合は `$(ghq root)/<repository-path>/...` の形式を優先する
- Kufu 関連のアプリケーション repo は `$(ghq root)/github.com/Fukuemon/kufu-apps` に配置する
- Kufu 関連の infra repo は `$(ghq root)/github.com/Fukuemon/kufu-infra` に配置する
- 兄弟リポジトリの path 定義は本ルールを正本とし、spec / ADR / skill では必要箇所のみ参照する

## Repository Map

```sh
$(ghq root)/github.com/Fukuemon/
├── kufu-apps/
└── kufu-infra/
```

## Repository Overview

本リポジトリは、Kufu apps が依存する Cloudflare 基盤を Terraform で管理する infra repository である。

- Cloudflare Pages / preview / production
- Cloudflare Workers / routes / bindings
- DNS / custom domain / TLS / cache
- secrets / environment variables / provider credentials boundary
- Terraform module / state / plan / apply workflow
- app repo から参照する infra contract

を管理する。

app の PRD、Design Docs、UI、routing、content、frontend package の正本は
`$(ghq root)/github.com/Fukuemon/kufu-apps` に置く。本リポジトリでは app 実装の詳細を正本化しない。

### Repository Structure

```bash
<repo-root>/
├── design/          # infra Design Docs
├── specs/           # issue / infra 変更単位の spec
├── adr/             # 長期参照する infra decision
├── hooks/           # AI / git / validation hooks
├── .rulesync/       # AI provider 向け設定の正本
├── PRD.md           # Kufu Infra PRD
└── rulesync.jsonc
```

Terraform code を追加する場合は、`design/DesignDoc.md` と対象 spec で directory boundary を決めてから作成する。

### Module Responsibilities

| モジュール | 用途 |
| ---------- | ---- |
| design     | Cloudflare、Terraform、environment、secret、contract の全体設計 |
| specs      | Terraform / Cloudflare 変更単位の要求、論点、plan、rollback、検証観点 |
| adr        | state backend、provider、運用方針など長期参照する意思決定 |
| hooks      | AI / git / validation の guardrail |
| .rulesync  | AGENTS.md / CLAUDE.md / .codex / .claude / .cursor / .agents の生成元 |

## Architecture Policy

- Phase 1 の provider は Cloudflare を標準とする
- Infra as Code は Terraform を標準とする
- Terraform state、provider credential、secret 実値を repository に保存しない
- Cloudflare Dashboard の手作業は例外扱いとし、後続で Terraform import または ADR 化する
- app repo には infra contract の参照だけを残し、Terraform 本体と apply 導線は持ち込まない
- preview / production の差分を明示し、branch / domain / secret / binding の境界を文書化する
- 本番影響のある変更では `terraform plan`、rollback、drift detection、review gate を必ず確認する
- AI フレンドリーな構造を保つため、ドキュメント、命名、責務分離、停止条件を明文化する

## Infra Boundary Rules

### Cloudflare

- Pages project、preview deployment、production deployment、custom domain は Terraform 管理対象とする
- Workers、routes、KV / D1 / R2 / Queues、Pages Functions binding は必要になった時点で spec / ADR を作る
- DNS、TLS、cache、redirect、compression は Cloudflare の標準機能を優先する
- Turnstile、Web Analytics、bot protection、rate limiting は app 要件が具体化した時点で infra spec に切る
- Cloudflare resource を dashboard で手作業変更した場合は、理由、作業者、日時、Terraform import 要否を記録する

### Terraform

- Terraform code は Cloudflare provider を主軸にする
- module は resource 責務ごとに分ける
- environment 差分は variable、environment directory、workspace などで説明可能にする
- `terraform plan` を review gate とし、`terraform apply` は明示された operator または CI job のみが実行する
- destroy、replacement、DNS、secret、state migration が plan に含まれる場合は明示 review を必須にする
- `terraform fmt`、`terraform validate`、plan 確認を標準検証に含める

### Secret / Runtime Boundary

- secret 実値、API token、provider credential、Terraform state は repository に保存しない
- repository に残すのは secret 名、用途、environment、参照主体、rotation 方針だけにする
- preview と production で secret 実値を共有しない
- client bundle に露出してよい値と Cloudflare runtime secret を分ける
- Workers や Pages Functions が第三者 API を中継する場合、binding と secret の所有は infra repo で管理する

### Cross-Repo Contract

- `kufu-apps` は product / app implementation の正本を持つ
- `kufu-infra` は Cloudflare resource / Terraform implementation / infra operations の正本を持つ
- app が infra へ要求するものは contract として表現する
  - Pages project 名
  - preview / production domain
  - required secret 名
  - Workers / Pages Functions binding 名
  - environment variable 名
  - deploy trigger / branch 前提
- app 側変更で infra 差分が必要な場合は、app 側 issue / spec / ADR と infra 側 issue / spec / ADR を相互参照する

## Toolchain Rules

### Terraform

Terraform code が追加された後は、対象 directory で次を標準確認とする。

```sh
terraform fmt -check
terraform validate
terraform plan
```

`terraform apply` は明示依頼がある場合だけ実行する。plan 未確認、destroy / replacement 未確認、
secret 影響未確認の状態で apply しない。

### GitHub / CI

- plan / apply を CI 化する場合は、approval、secret、artifact、log retention、state lock を spec で決める
- production apply は protected branch / environment approval を前提にする
- provider token は GitHub Secrets または Cloudflare 管理の secret store に置き、repository に保存しない

## AI Configuration Workflow

- AI 関連の設定を更新する際は、必ず `.rulesync/` 配下を正本として更新する
- `AGENTS.md`、`CLAUDE.md`、`.codex/`、`.claude/`、`.cursor/` を直接の正本として編集しない
- `.rulesync/` 更新後は次のコマンドで各プロバイダー向け設定へ同期する

```sh
npx rulesync@latest generate
```

- 生成後は `git diff` で `.rulesync/` と生成先の差分が意図どおりであることを確認する
- `npx rulesync@latest generate` が失敗した場合は、生成先を手作業で合わせず、失敗理由を解消して再実行する

## Git Workflow Guardrails

- main / develop は保護ブランチ
- 作業は必ず feature ブランチで行う

```bash
feature/<issue-number>
```

例:

```bash
feature/1
feature/2
```

## Naming Conventions

### Terraform / Cloudflare

- resource 名は provider 種別、environment、用途が分かる命名にする
- secret 名は実値を含めず、用途と environment を表す
- Pages project、Workers、DNS record、binding 名は app repo から参照できる contract として文書化する

### Specs

- directory: `specs/<issue-number>-<short-slug>/`
- draft: `specs/draft-<yyyymmdd>-<short-slug>/`
- prompt: `P{phase}_{seq}_{target}_{scope}.md`

## Security Rules

- secret、token、API key、provider credential、Terraform state を repo に保存しない
- plan output に sensitive value が露出しないようにする
- DNS、custom domain、Workers route、production secret、state migration は本番影響が大きいため spec と review を必須にする
- Cloudflare Dashboard で手作業変更した場合は Terraform drift を確認する
- app repo へ共有するのは contract 名であり、秘匿値ではない

## Forbidden Patterns

- app の product requirements や UI Design Docs を infra repo の正本にすること
- Terraform state や secret 実値を repository に保存すること
- plan 未確認で production apply すること
- dashboard 手作業を正本として放置すること
- app repo に Terraform apply 導線や provider credential を持ち込むこと
- apps 側の実装詳細を推測して infra resource を作ること

## Output Format Rules

コード調査結果は以下形式で記載:

```sh
- {説明}
  - `<path>:<line-range>`
```

- リポジトリ path を文書に記載する場合は、可能な限り `$(ghq root)/<repository-path>/...` を使う

## Philosophy

このリポジトリは以下を重視する:

- 再現性
- 本番安全性
- secret boundary
- cross-repo traceability
- Terraform-first operations

## Decision Priority

迷った場合は以下の優先順位で判断:

1. 本番安全性
2. secret / state の保護
3. Terraform による再現性
4. app repo との contract 一貫性
5. 開発体験
