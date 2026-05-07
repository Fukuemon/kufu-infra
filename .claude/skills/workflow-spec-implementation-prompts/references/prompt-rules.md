# Prompt Rules

## 目的

spec から生成する prompt の粒度、責務境界、自己完結性を揃える。

## ルール

- 1 prompt 1 責務を守る
- 明示された path 以外の探索を前提にしない
- 依存関係を phase で表現する
- terraform / cloudflare-pages / workers / dns / secrets / ci-cd / docs を無理に 1 本へ混ぜない
- 未確定事項が残るなら prompt を出さず、spec 側へ戻る
- prompt から別 repo の追加探索を要求しない
- secret 実値、provider credential、Terraform state 内容を prompt に含めない
- 実装に必要な仕様は spec から抜粋して埋め込む

## 命名

`P{phase}_{seq}_{target}_{scope}.md`

例:

- `P1_01_terraform_pages_project.md`
- `P1_02_dns_production_domain.md`
- `P2_01_secrets_turnstile_binding.md`

## Kufu Infra でよく使う target

- `terraform`
- `cloudflare-pages`
- `workers`
- `dns`
- `secrets`
- `ci-cd`
- `observability`
- `docs`
