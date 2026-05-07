# ADR

`adr/` は Kufu Infra の恒久的な意思決定ログを保存する場所である。仕様検討の途中メモや
一時的な比較は `specs/` に置き、長期参照価値のある判断だけを ADR に昇格する。

## 命名規約

- ファイル名: `adr/NNNN-<title>.md`
- 例:
  - `adr/0001-terraform-infra-repository-boundary.md`
  - `adr/0002-terraform-state-backend.md`
  - `adr/0003-cloudflare-pages-deployment-boundary.md`

## ADR にする判断

- Terraform state backend や provider credential の扱いを固定した。
- Cloudflare Pages / Workers / DNS / Turnstile / Analytics など provider resource の採否を決めた。
- app repo と infra repo の contract 境界を固定した。
- plan / apply、approval、rollback、drift detection の運用方針を固定した。
- secret、binding、runtime environment の管理方針を固定した。
- dashboard 手作業から Terraform 管理へ移行する方針を決めた。
- 代替案比較を経て、採用方針を明示的に残す必要がある。

テンプレートは [TEMPLATE.md](TEMPLATE.md) を使う。
