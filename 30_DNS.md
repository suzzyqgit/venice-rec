# DNS

> 出典: 11月10日.md の DNS 節（360-371）。更新は本ファイルのみ。

## DNS（Cloudflare）
| 種別 | 名前 | 用途 | 備考 |
|---|---|---|---|
| MX | send | Resend の返送路 | |
| TXT | send | SPF | |
| TXT | rsend._domainkey | DKIM | 名前は `rsend`。`resend` ではない |
| TXT | _dmarc | DMARC | |
| MX | （ルート） | Email Routing | Cloudflare 自動 |
| TXT | （ルート） | Email Routing 検証 | Cloudflare 自動 |

Email Routing のオンボーディング時に DNS レコードはロック済み。

