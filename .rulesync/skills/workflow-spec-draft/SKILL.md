---
name: workflow-spec-draft
description: Kufu Infra の spec 下書き workflow。PRD と Design Doc を起点に Cloudflare / Terraform 変更単位の spec 雛形を作る。
---

# Workflow Spec Draft

infra spec の新規下書きを作るための入口スキル。

## いつ使うか

- issue 単位の infra spec を新規作成する
- Cloudflare / Terraform 変更の要求はあるが、resource、plan、rollback、contract がまだ整理されていない

## 先に読むもの

- `$(ghq root)/github.com/Fukuemon/kufu-infra/specs/TEMPLATE.md`
- `$(ghq root)/github.com/Fukuemon/kufu-infra/PRD.md`
- `$(ghq root)/github.com/Fukuemon/kufu-infra/design/DesignDoc.md`

## 実行フロー

1. `PRD.md` と `design/DesignDoc.md` から対象 infra 変更の前提だけを抜き出す
2. issue 番号または draft slug から spec directory を決める
3. `specs/TEMPLATE.md` を元に `index.md` を作る
4. 初回 draft でも template の必須節を削らずに残す
5. 少なくとも次を埋める
   - `## メタ情報`
   - `## 設計フェーズ状況`
   - `## 上位ドキュメント確認`
   - `## 関連資料`
   - `## 背景`
   - `## スコープ`
   - `## 要件の解釈`
   - `## 論点一覧`
   - `## 未確定事項`
   - `## 実装対象`
6. `## 設計フェーズ状況` には 11 フェーズを template のまま保持する
7. `## Resource / Contract 仕様` には Kufu Infra 固有論点の節を残す
   - `### Cloudflare Resource`
   - `### App Repo Contract`
   - `### Environment`
   - `### Preview / Production 差分`
8. `## Terraform / State 設計` と `## Security / Runtime 設計` を必ず残す
9. `## スコープ` の `### やること` / `### やらないこと` を必ず埋める
10. 次に進む前に、未確定事項、plan / apply 影響、cross-repo 影響を明示する

## 停止条件

- 上位文書と矛盾する
- 対象 issue / spec directory が決まらない
- 対象 Cloudflare resource / Terraform module / docs scope が特定できない
- state / provider / secret / production 影響の有無を判断できない
- app repo contract の更新要否が不明なまま進もうとしている
- template の必須節や phase 表を保てない
