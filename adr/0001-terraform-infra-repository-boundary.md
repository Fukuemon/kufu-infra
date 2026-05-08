# ADR-0001: Terraform の infra code は kufu-infra で管理する

## 状態

承認

## 決定日

2026-05-08

## 背景

- Kufu apps の公開基盤は Cloudflare Pages、Workers、DNS、custom domain、secret、binding などの
  resource に依存する。
- これらの変更は本番影響が大きく、app code や product docs とは異なる review 観点と権限管理が必要である。
- `kufu-apps` は app の PRD、Design Docs、実装を正本として持つ。
- `kufu-infra` は Cloudflare resource、Terraform state、plan / apply、secret boundary、
  infra contract を正本として持つ必要がある。
- Terraform provider credential、state、apply 権限を app 開発導線から分離したい。

## 決定

- Cloudflare の infra code は Terraform で管理する。
- Terraform の正本は `$(ghq root)/github.com/Fukuemon/kufu-infra` に置く。
- `kufu-apps` には Terraform 本体、state 設定、apply workflow を置かない。
- `kufu-apps` には app 側が依存する infra contract だけを残す。
- `kufu-infra` には Cloudflare resource の実体、Terraform module / environment、plan /
  apply、rollback、secret boundary を残す。
- app 変更に伴って infra 変更が必要な場合は、app repo と infra repo の issue / spec / ADR を
  相互参照できる状態にする。

## 代替案

### 1. Terraform を kufu-apps に同居させる

#### Pros

- app と infra の変更を 1 つの PR で整合させやすい。
- app 側の変更と必要な Pages / Workers / binding 更新を同時にレビューしやすい。

#### Cons

- UI / app 変更と本番 infra 変更が同じ差分面に並び、レビュー観点が混ざる。
- Terraform apply 権限や Cloudflare credential が app 開発導線に近づく。
- DNS、secret、Workers route など本番影響の大きい変更が通常の app 開発 PR に埋もれやすい。
- AI や開発者が repo 全体を見たときに、どこまで触ってよいかの境界が曖昧になりやすい。

### 2. Terraform を使わず Cloudflare Dashboard で運用する

#### Pros

- 初期セットアップは速い。
- 小さな設定変更なら管理コストが低い。

#### Cons

- 変更履歴、review、再現性、環境差分管理が弱い。
- secret や binding を含む運用ルールが属人化しやすい。
- preview / production の差分や rollback 手順を安定して残しにくい。
- dashboard 手作業と Terraform 管理対象の drift を検知しにくい。

## 影響

### 良い影響

- app repo と infra repo の責務境界が明確になる。
- Terraform state、provider credential、apply 権限を app 開発フローから分離できる。
- Cloudflare 固有の本番変更を専用 review で扱いやすくなる。
- app が増えても、共有 infra を `kufu-infra` で一貫して管理できる。

### 悪い影響 / トレードオフ

- app 変更と infra 変更が別 repo に分かれるため、変更追跡の運用ルールが必要になる。
- 1 つの機能変更で 2 つの PR が必要になる場合がある。
- infra contract の同期漏れが起きると、app 側ドキュメントと実体の乖離が起こりうる。

## 実装・運用への反映

- 対象 repo: `$(ghq root)/github.com/Fukuemon/kufu-infra`
- app repo: `$(ghq root)/github.com/Fukuemon/kufu-apps`
- spec 更新要否: 要。infra 変更が絡む spec では、対象 resource、plan、rollback、contract 更新要否を明記する。
- AI 向け設定更新要否: 要。Cloudflare + Terraform 前提と apps / infra repo 境界を AI ルールへ反映する。

## 関連ドキュメント

- `PRD.md`: Kufu Infra の要求
- `design/DesignDoc.md`: Cloudflare + Terraform の infra 設計
- `specs/...`: infra 変更が必要な個別 spec
- app repo: `$(ghq root)/github.com/Fukuemon/kufu-apps`
- infra repo: `$(ghq root)/github.com/Fukuemon/kufu-infra`
