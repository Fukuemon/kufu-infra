# Kufu Infra PRD

この文書は `kufu-infra` の要求を整理する PRD である。Kufu の product requirements や
app 実装方針は `$(ghq root)/github.com/Fukuemon/kufu-apps` を正本とし、この repo では
Cloudflare と Terraform を中心にした infra の要求、運用境界、成功条件を扱う。

## 概要

`kufu-infra` は Kufu apps が依存する公開基盤を再現可能に管理するための infra repository である。
Phase 1 では Cloudflare Pages、Workers、DNS、custom domain、secret、binding、preview /
production 環境を Terraform で管理できる状態にする。

app 側に必要な Design Docs、PRD、UI、routing、content の正本は `kufu-apps` に置く。
`kufu-infra` は app から見える infra contract と、実際の Cloudflare resource 管理、plan /
apply、state、secret boundary、rollback 方針を正本として管理する。

## Infra 原則

- Terraform を infra code の正本にする
  - Cloudflare resource の追加、変更、削除は review 可能な差分として扱う。
- Cloudflare を Phase 1 の公開基盤にする
  - Pages、Workers、DNS、TLS、CDN、secret、binding は Cloudflare の標準機能を優先する。
- app repo と infra repo の責務を分ける
  - app repo には product / implementation の正本を置き、infra repo には運用可能な contract と実体を置く。
- secret と provider credential を app 実装導線から分離する
  - client bundle や app repository に秘匿値を含めない。
- preview と production の差分を明示する
  - branch / environment ごとの Pages deployment、domain、binding、secret の差分を追跡できるようにする。
- AI が本番 infra を不用意に変更しない構造にする
  - spec、ADR、workflow、plan / apply gate を明文化し、変更範囲と停止条件を明確にする。

## 背景

### Problem Statement

- `kufu-infra` は `kufu-apps` の内容をコピーして作成されたため、app monorepo 前提の
  PRD、Design Docs、spec、skills が残っている。
- Cloudflare resource は本番影響が大きく、app 実装と同じ判断軸で変更すると review 漏れや
  secret 露出のリスクがある。
- app 側の要件変更に伴う infra 差分を、Terraform plan、ADR、spec として追跡できる必要がある。
- AI agent が infra repo を扱う際に、LP / UI / React ではなく Cloudflare / Terraform /
  environment / secret boundary を優先して判断できる必要がある。

### なぜ今やるか

- infra repo の初期化直後に apps 由来の前提を除去し、以後の spec と skill の入力品質を保つため。
- Cloudflare Pages preview / production、DNS、secret、Workers binding を後から ad hoc に
  管理しないよう、最初に repo contract を固定するため。
- Terraform state、provider credential、apply 権限を app 開発フローと分離するため。

## ペルソナ

### ターゲットユーザー

- Cloudflare 基盤を設計、レビュー、apply する infra maintainer
- Kufu apps の deploy や domain / secret / binding を必要とする app developer
- Terraform plan や ADR を確認して本番影響を review する reviewer
- AI agent に infra spec、Terraform 変更、運用 docs 更新を依頼する開発者

### ユーザーストーリー

- infra maintainer として、Cloudflare resource を Terraform plan で確認してから apply したい。
  そうすれば本番影響を review 可能な形で管理できる。
- app developer として、app が必要とする domain、Pages project、Workers binding、secret 名を
  contract として確認したい。そうすれば app 側の変更と infra 側の変更を分けて依頼できる。
- reviewer として、preview と production の差分、rollback 方針、secret 影響を確認したい。
  そうすれば deploy 前に運用リスクを判断できる。
- AI agent として、対象 resource、state、secret boundary、検証コマンドを明確に把握したい。
  そうすれば app 実装の文脈に引きずられず infra 変更を扱える。

## 期待されるアウトカム

### 定量アウトカム

| 指標                            | 定義                                                                        | 目的                         |
| ------------------------------- | --------------------------------------------------------------------------- | ---------------------------- |
| Terraform Plan Review Rate      | Cloudflare 変更が plan 差分として review された割合                         | 本番影響の可視化             |
| Drift Detection Rate            | Terraform 管理外変更を検知できた割合                                        | dashboard 手作業との差分抑制 |
| Infra Contract Coverage         | app が依存する domain / secret / binding / Pages project が文書化された割合 | cross-repo 連携の安定化      |
| Preview Environment Readiness   | branch / PR ごとの preview deploy 前提が整っている割合                      | app review の再現性          |
| Secret Boundary Violation Count | repo や client bundle に秘匿値が混入した件数                                | secret 露出防止              |

### 定性アウトカム

- Cloudflare resource の変更理由、影響範囲、rollback 方針を追いやすい。
- `kufu-apps` と `kufu-infra` の責務境界を迷わず判断できる。
- app 側の Design Docs と infra 側の Design Docs が相互参照でき、正本が重複しない。
- AI が apps 由来の UI / product 前提を参照せず、infra の関心事で作業できる。

## スコープ

### Phase 1 スコープイン

- Cloudflare Pages project と preview / production deployment 前提。
- Cloudflare Workers と Pages Functions が必要になった場合の管理境界。
- DNS、custom domain、TLS、redirect、cache、compression の管理方針。
- Cloudflare secret、environment variable、binding、Turnstile などの秘匿情報境界。
- Terraform module、environment、state、provider、plan / apply workflow。
- app repo から参照する infra contract の文書化。
- spec / ADR / AI workflow を infra 変更単位で運用できる状態にすること。

### Phase 1 スコープアウト

- app の product requirements、UI、routing、content、component 設計。
- app code、frontend package、E2E test 本体の実装。
- Cloudflare 以外の provider を主軸にした multi-cloud 設計。
- secret の実値、provider token、Terraform state の内容を repo に保存すること。
- dashboard 手作業を正本とする運用。

## Phase 1 完成条件

- `PRD.md`、`design/DesignDoc.md`、`specs/`、`adr/`、`.rulesync/skills/` が
  Cloudflare + Terraform の infra repo 前提に更新されている。
- `kufu-apps` 由来の app monorepo 固有文脈が infra docs の判断基準から除去されている。
- Terraform plan / apply、state、secret boundary、preview / production、rollback の確認観点が
  spec template と workflow に含まれている。
- apps 側の正本と infra 側の正本の境界が明記されている。
- `.rulesync/` から各 AI provider 向け設定へ同期できる。

## 要求情報まとめ

### Cloudflare 要求

- Pages は app の build artifact を配信する deployment boundary として扱う。
- Workers は API / BFF / form relay / bot protection など edge runtime が必要な場合に採用する。
- DNS、TLS、custom domain、cache、compression は Cloudflare の標準機能を優先する。
- preview と production の domain、branch、secret、binding 差分を追跡できるようにする。

### Terraform 要求

- Cloudflare resource は Terraform code と plan で review する。
- provider credential、state、secret 実値は repository に保存しない。
- environment ごとの resource 差分を module / variable / workspace などで説明可能にする。
- plan / apply の実行主体、権限、停止条件を spec または runbook に残す。

### Cross-Repo Contract 要求

- apps 側の PRD / Design Docs は `$(ghq root)/github.com/Fukuemon/kufu-apps` を正本とする。
- infra 側には app が依存する project 名、domain、secret 名、binding 名、environment 名を contract として残す。
- app 変更で infra 差分が必要な場合は、app 側 spec / ADR と infra 側 spec / ADR を相互参照する。
- infra 実体の変更は `kufu-infra` で review し、app repo に Terraform apply 導線を持ち込まない。

## 前提・依存関係

- 文書上の正式名は `Kufu Infra` とする。
- repository path は `$(ghq root)/github.com/Fukuemon/kufu-infra` とする。
- apps repository path は `$(ghq root)/github.com/Fukuemon/kufu-apps` とする。
- Phase 1 の provider は Cloudflare、infra as code は Terraform とする。
- app の product / implementation 正本は apps repo、infra 正本は infra repo に分ける。

## 関連ドキュメント

- 全体設計: [design/DesignDoc.md](design/DesignDoc.md)
- spec 運用: [specs/README.md](specs/README.md)
- ADR 運用: [adr/README.md](adr/README.md)
