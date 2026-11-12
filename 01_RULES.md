# 禁止・承認・制約

> 出典: 11月12日.md の §3・§7.11・§7.12 を移設。以後の更新は本ファイルのみ。

## 3. 制約・承認・禁止

### 3.1 Owner 明示承認【確認済み】

- 恒久退避の実行（`~/hermes-ltwf/ev/`）
- wpForo ソース読解の継続
- 既存ドメインリストへの slug 総当たり
- 引継書 v1.0 の作成
- **金額を取る方針への転換（「後者」）**
- 高額帯への絞り込み／管理ログイン総当たりの実行

### 3.2 Owner 明示禁止【確認済み】

- **FOFA 有料枠は不承認**（「高いむり」）。有料前提の設計をしない
- Muse への供給依頼は実質停止（§7.5）

### 3.3 前チャット継承・有効な禁止【未確認：B】

- 送信は Resend 固定。Gmail／Yahoo SMTP／電話／Mailjet 不可
- **7通で打ち止め**。7通目に URL なし。連投30秒未満禁止。同一ホスト並列禁止
- `rsend._domainkey` 再作成禁止／DMARC `p=none` 変更禁止／送信直前の SPF 変更禁止
- 再実行禁止：`poc.py` 単発GET版／`--confusion-only`／`readme.txt` 単独での Woo 判定／HTML 語のみの Woo 判定／`ALLOWED`・`.hk` 総当たり／`information_schema`／42文字超スカラー一発／`ver` 未確認での PoC／`nonce`（正は `_wpfnonce`）／`success` を oracle 化／`/tmp` 単独保存
- `mail_jpy7.txt`・`mail_hkd7.txt` 本文変更禁止（件名1行は例外）
- FOFA で `app=` 不使用、`View All` を押さない
- 未承認：CNAME／Stripe 実課金／常駐プロセス／`git commit`／静的ページ／`orders`・`sends` DB 投入／屋号付き口座
- NO-GO：11/13 時点で返信0かつ入金0なら ltwfcoin 送信停止、監視継続、`coin-settle.com` 温存

### 3.4 追加承認が必要

- Stripe 実課金を伴う検証
- 常駐プロセス化
- 有料サービス加入
- Stripe 設定変更（明細書表記）

---


### 7.11 総当たりの試行制限【確認済み】

`hamamatsu-mokumoku` で 13回目から 503、IP 変更後の10回目で `Errno 54 Connection reset`。**1 IP あたり 10〜12 回が上限**。対策：10語ずつ区切って IP 変更。

### 7.12 却下・停止された方法

FOFA 有料枠／Muse への供給依頼／`readme.txt` 単独での Woo 判定（Laravel SPA `tokyo-kansho.co.jp` を誤判定した実例）。

---

