# Spec Phase Guide

Kufu Infra の spec は次のフェーズで進める。

| フェーズ | 作業 | 完了条件 | 次アクション |
| --- | --- | --- | --- |
| 1. 起票確認 | issue、背景、上位文書を確認する | 要求の起点が明確 | `workflow-spec-draft` で下書き |
| 2. 下書き | `specs/TEMPLATE.md` を埋める | 背景、スコープ、論点、実装対象がある | draft review |
| 3. 上位文書突合 | `PRD.md` / `design/DesignDoc.md` / 関連 ADR と整合確認 | 矛盾がない | 論点整理 |
| 4. 論点整理 | 未確定事項を列挙し優先度を付ける | 重要論点が見える | 論点解決 |
| 5. 論点解決 | Cloudflare resource、Terraform scope、secret、environment、rollback を決める | 未確定事項が実装阻害にならない | resource / contract 設計 |
| 6. Resource / Contract 設計 | Cloudflare resource と app repo contract の境界を決める | resource、contract、environment が明確 | Terraform / state 設計 |
| 7. Terraform / State 設計 | module、provider、state、plan / apply の流れを決める | Terraform 実装責務と state 影響が明確 | security / runtime 設計 |
| 8. Security / Runtime 設計 | secret、binding、permission、runtime boundary、rollback を決める | security と本番影響の懸念が書ける | test / metrics 設計 |
| 9. Test / Metrics 設計 | 検証方法と観測指標を定義する | 完了判定が検証可能 | 実装分割 |
| 10. 実装分割 | prompt に落とせる単位へ切る | 各 prompt が 1 責務になる | `workflow-spec-implementation-prompts` |
| 11. レビュー済 | review gate の指摘を反映し、spec をレビュー完了状態にする | 指摘の反映方針が確定し、次工程へ渡せる | 実装または handoff |

## review gate

- フェーズ 2 完了後: draft として読み手が背景、スコープ、論点を追えるか確認する
- フェーズ 5 完了後: 重要論点が未解決のまま残っていないか確認する
- フェーズ 8 完了後: secret / state / production 影響と rollback が曖昧でないか確認する
- フェーズ 10 完了後: prompt が自己完結かつ実装可能か確認する
- フェーズ 11 完了後: review 指摘への対応方針が確定し、実装へ進める状態か確認する

## Kufu Infra で毎回確認する論点

- 対象 Cloudflare resource は何か
- Terraform 管理対象か、既存 dashboard 設定の import / 移行か
- state、provider、module、variable に影響があるか
- preview と production の差分は何か
- DNS、custom domain、TLS、cache、Workers route に本番影響があるか
- secret、environment variable、binding、provider credential に影響があるか
- app repo contract の更新が必要か
- plan に destroy / replacement / sensitive output が出る可能性があるか
- rollback と drift detection の方法は何か
- 検証コマンドと完了条件は何か

## フェーズを止めるべき条件

- 対象 resource / module / docs scope が特定できない
- 変更が `PRD.md` で扱うべきか `design/DesignDoc.md` で扱うべきか逆転している
- state / secret / production 影響が不明なまま実装へ進もうとしている
- app repo contract の更新要否を確認できない
