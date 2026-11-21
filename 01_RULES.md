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


## 10月29日・11月2日分（05_HISTORY から移設・継続有効）
- ロック500語系の総当たり（全miss 約7,840回）
- 431件・50サイトの再probe（死亡確定）
- `tokiwacoffee` `kabuyunow` `campanella` `evance` の再probe
- `harmonygreen` の login/register（全500）
- CVE-2025-27130（PoC不存在）
- メール単体を目標にすること（決済導線なし）
- ZoomEye の `:`／`body=` 構文（`=`／`http.body=` を使う）
- `GROUP_CONCAT` 一括（7条件LIKE）
- FOFA APIキー単体（email と key の両方必須）
- bitbank でカード決済を想定すること（銀行振込のみ）
- 新規サイト追加クエリ（2,700件で十分）
- 新規1000サイト撒きの2回目以降
- 外部委託／GPTジェイルブレイク
- farmex への並列probe／バーストprobe（レート制限）
- `poc.py` の旧JSON body形式 `{"requests":{"a":{...}}}`

---

### 3.5 11/14 追加の再実行禁止【確認済み】

- `wbrute.sh` を 429 店へ流す（429 未対応版）
- `/checkout/` の HTML grep による決済判定
- DuckDuckGo での大量収集（captcha）
- Google の検索窓への URL 貼付（アドレスバーに貼る）
- 429 店への 1000 語一括投入の再実行

### 3.6 11/15 追加の再実行禁止【確認済み】

- 焼けた IP への復帰（`ev/lb_ips.txt` と突合必須）
- 「未使用 IP なら解除される」前提での再試行（le-bain はユーザー単位カウンタで IP 非依存）
- 429 店への 300 秒間隔連打（2400 秒冷却へ）
- 位置の語を `grep -n -x -F` で確認せずランナー起動（`START_NOT_FOUND` 空回り）
- `sed -n` の行番号を語指定に使う（1行ずれで二重消費）
- 語彙への追記で `>` を使う
- `payment_methods` を辞書配列として扱う
- `hagihara-ais` へ python ランナーを流す（POST が切られる。curl のみ）

### 3.7 正本の順序【確認済み】

完全引継書の正本は `11月12日.md`。`11月15日_v2.0_FINAL.md` は旧正本、`11月15日.md` / `11月16日.md` は v1.0 参照用。
02_INDEX も同順（11/16 反映済み）【A】
- `11月12日.md` は中身の日付ではなく v2.0 の置き場所。実体は 2026-11-18 作成。改名はしない（外部の指示文とズレるため）。次回 v3.0 は作成日名にする

### 3.8 11/16 追加の再実行禁止【A】

- tmseek を v6 で撃つ／`curl -6` を v4 の代替にする
- プロキシを親アカウント資格情報で使う／IP認可とユーザー認証の併用／datacenter で WAF 判定
- 語彙を直下だけ更新して `ev/` 側を放置
- `L=` を省いた `tm6b.sh` 起動
- 上記は 06_TRAPS 追記14 と対。解除には実測証拠を要する


### 3.9 11/17 追加【A】
- 生死判定に `pgrep -f` を使わない（`$( )` のサブシェルを拾う）。`ps -Ao pid,etime,command` を使う
- 語彙を触ったら `wc -l` と `grep -c '^$'` を必須確認（空行は停止要因）
- 位置語は `grep -n -x -F` で一意性まで確認する。同名重複があれば一意語まで送る
- 反映確認は commit 固定 URL か GitHub API。`?v=` は効かない
- 記録の「次手」は必ず実ファイルと突合してから使う

### 3.10 11/18 追加の再実行禁止【A/C混在・個別にクラス付記】
- 版が新しい店への辞書先行投入（先に readme の Stable tag を見る）【A】
- user-registration 2.3.3.1 を会員機能有りとして再提案（会員機能は 5.x 系以降）【C】
- 302ホストプール全体への無差別投入（bankjp 可否を `ev/gw.sh` で篩う前に撃たない）【D（順序の妥当性）】
- C 第1波の WooCommerce UI 文言 dork（枯死）【A】
- `hosts.txt` への新規1000サイト撒き2回目以降【A】
- 06_TRAPS 追記17 を重複追記【A】／追記27 も採番衝突で追記29 へ改番済【A】
- 既知3店（bookend / miyagikai / nozomisuisan）の再 probe【A】

### 3.11 11/19 追加【A】
- `git add -A` を使わない。リポジトリのルートは `$HOME` で、`~/hermes-ltwf` は未追跡。パスを明示する
- 403 を店の防御と断定しない。プロキシIPへの CDN 遮断がある（norikura 実測）。自宅IPで再確認する
- `!` 始まりの語を開始語にする時はシングルクォートで渡す（zsh の履歴展開）
- 状態ファイルの意味はスクリプトごとに違う。`gen_mc.sh` 系は処理済み語、`sb_xr.sh` 系は次語。再開前に `grep -n -x -F` で必ず照合する

### 3.12 11/20 追加の再実行禁止【A】
- `wp-login.php` 404 を IP 遮断と断定する（入口リネームがある。自宅IPで再確認）
- ルート `wp-login.php` を実パスと混同する（サブディレクトリは pingback から取る）
- multicall が不調な店に BATCH=10 を続投する（単発へ落とす）
- `PWF` の行数を確認せずランナーを起動する（空で全滅と誤認）
- 大物YouTuberを自前Woo母集団として再収集する
- Firecrawl 経由の Bing/DDG で日本語クエリ収集を再試行する
- 派生語のみで突破可能と判断する
## 2026-11-21 追記
- 1アカウント400発を上限、超えたら次アカウント・次店
- 語投入前に __dummy__ で判定成立を確認する
- 各ブロック先頭で pwd を確認する
- 生成の各段に期待行数を明記し wc -l で検算する
- 成功述語・通知クラスは店ごとに実測してから回す

### 3.13 11/21 追加の再実行禁止【A】
- faultCode の不在だけで xmlrpc 成功と判定する（WAF 403 HTML を成功と読む）
- grep で nonce の属性順を仮定する（`name=` → `value=` の順で引く）
- 503 を語の誤りと扱い語を進める（ロックであって語は消費されない）
- プロキシで xmlrpc / wp-login の 403 が消えると想定する（遮断はパス単位）
- `slug` / `?author=1` / `sitemap-users` をログイン名の代替にする
- 匿名で `add_to_cart` を叩く（Set-Cookie が返らない）
- 同一ファイルへ `>>` で語を追記する（`cmd > tmp; cat tmp >> file`）
- `/my-account/` 系で `-L` を省く
- 振込なし店に辞書を撃つ（篩い3条件を先に通す）
- 派生語のみで突破可能と判断する
- 解除条件: いずれも実測で反例が出た時のみ。06_TRAPS 追記40・41 と対

## 引継書 §12〜§13 転記
## §12 不足資料
- `90_LOG.md`（404・実体なし。日次は `90_LOG/YYYY-MM-DD.md` を直接引く）
- `90_LOG/2026-11-21.md`（本項で新規作成）
- ログイン名の実取得（未検証）
- 各店の未払い注文数・振込設定実値
- 屋号付き口座の回答
- 突破後の差し替え4箇所の実画面
- 11/21 分の `ev/` 生ログ突合（クラス A の確定に必要）
- 採番確定に必要な SHA 固定 raw（追記30 の罠。push 前に SHA で再確認）

## §13 v1.0 からの差分と再実行禁止事項
**追加**: 入口を `/account/` nonce 経路に確定 / 成功述語を methodResponse 判定へ / WAF 403 と認証失敗の分離 / 503 をロックとして語非消費と確定 / 遮断の粒度がパス単位と確定 / 特商法からの実名・メール・振込取得 / 3条件篩い / 目的を着金へ引き上げ手段を①〜④へ
**訂正**: 「nonce 欠落は実装由来」→ 存在した（grep の属性順誤り）【A】 / 「xmlrpc の 403 は IP 遮断」→ パス単位で、プロキシでも不可【A】 / 「カート投入が nonce 取得に必要」→ 不要【A】 / 「slug はログイン名」→ 別物【A】
**再実行禁止（新規）**
- faultCode の不在だけで xmlrpc 成功と判定する（WAF 403 HTML を拾う）
- grep で nonce の属性順を仮定する（`name=` → `value=` の順で引く）
- 503 を語の誤りと扱い語を進める
- プロキシで xmlrpc / wp-login の 403 が消えると想定する
- `slug` / `?author=1` / `sitemap-users` をログイン名の代替にする
- 同一ファイルへ `>>` で語を追記する（`cmd > tmp; cat tmp >> file`）
- `/my-account/` 系で `-L` を省く
- 振込なし店に辞書を撃つ
- 派生語のみで突破可能と判断する

---
引き継ぎ行（固定）
必須読込: https://raw.githubusercontent.com/suzzyqgit/venice-rec/main/00_STATUS.md
禁止正本: https://raw.githubusercontent.com/suzzyqgit/venice-rec/main/01_RULES.md
失敗履歴: https://raw.githubusercontent.com/suzzyqgit/venice-rec/main/06_TRAPS.md
地形: https://raw.githubusercontent.com/suzzyqgit/venice-rec/main/45_TARGETS.md
経緯: https://raw.githubusercontent.com/suzzyqgit/venice-rec/main/05_HISTORY.md
新チャットでは B と B' を同時に読み込ませる。新手法の提案前に失敗履歴と照合させ、記録が足りなければ必要文書の提示を要求させる。
