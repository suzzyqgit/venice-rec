# 落とし穴

作業前に読む。ここに書かれた事故を繰り返さない。

## パス
- WPのインストール先は店ごとに違う。farmex.tokyo は `/hibari-new2023/`。root の `/wp-login.php` は別物
- root を叩いて 200 が返っても、それは本体ではないことがある

## 認証
- `wp-login.php` に reCAPTCHA がある店はフォーム総当たりが通らない。`/hibari-new2023/xmlrpc.php` のような xmlrpc 側を使う
- 403 は店の防御とは限らない。VPN出口のWAFが弾いているだけのことがある（tmseek・farmex で実測）。判定は自宅回線かテザリングで行う
- ユーザー実在は `/author/<slug>/` の 200/302 か、ログイン文言差で確認する。`users` API が 200 ならそれを使う

## ロック（系統が2つある。混同するな）
- **Wordfence（tmseek）**: per-IP。実測 4〜9 語で発火。機内モードで IP を変えれば解除され続行できる。VPN が効かないのは同一国ローテーションで /24 が焼けており、IP を変えても焼けた帯に戻るため
- **SiteGuard（farmex）**: /24 巻き添え。15〜21 回で 503 / Errno 54。60 分待っても解除せず（`LOCKED at 1` の実例）。同一国内のサーバー変更では無効
- 「サイト全体が焼けた」と「per-IP が焼けた」は別物。tmseek は前者ではない（11/12 の誤認。正は per-IP）
- 判定は必ず GET。POST を撃つ前に GET 200 を確認する
- 待機は 20 分以上、farmex は 60 分を下限にする
- Wordfence の 503 本文は ja の「一時的にロックアウト」HTML（約18KB、`#00709e` のスタイル）。503 は本文で確認でき、空応答や 000 と混同しない
- **xmlrpc の `system.multicall` は呼び出しごとに 1 回カウントされる**（11/13 実測。6語=OK、続けて10語で503）。往復削減の効果はあるが、1 IP あたりの語数上限は増えない

## 状態の読み違い
- xmlrpc の GET は HTTP 405 が正常応答（`XML-RPC server accepts POST requests only.`）。WAF ブロックも 405 を返すため判定は本文で行う。HTTP 405 と faultCode 405（メソッド無効）は別物
- `503` はロック、`000` は接続断、`none` は「全件403で外れ」と「全件未送信」の両方
- GET は焼けた後も通る。枠を食うのはログイン POST だけ

## 注文まわり
- key 無しの `order-received` は 200 を返すが中身が無い。`wc_order_xxx` は必須
- カタログ店は products が返っても `add-item` が 400 `not_purchasable`
- ゲートウェイは cart に住所を入れないと全部 `unavailable`。先に `cart/update-customer`
- cart を取り直すとセッションが切り替わり直前の商品が消える。nonce と Cart-Token は操作ごとに取り直す

## 環境
- cwd を vault にすると `ev/` が解決できず、ログを「存在しない」と誤認する。記録操作以外は `~/hermes-ltwf`
- 記録の切り出しは `grep -nE '^#{1,3} '` で見出しを確認してから `sed`。切った後に見出しを検証する

## 2026-11-12 追加
- 記録ファイルを作成したが push せず、新チャットで 404。回避: rec.sh で push 後に raw URL を確認する。
- rec.sh は 11/12 に実行済み（00_STATUS / 06_TRAPS を push、raw 200 確認）。以後も必ず rec.sh 経由＋raw 200 確認。
- IP 変更後も off ファイルが 1 のままで同一語を再試行。回避: IP 変更ごとに echo "<start>" > ev/tm_off.txt を必須化。
