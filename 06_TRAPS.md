# 落とし穴

作業前に読む。ここに書かれた事故を繰り返さない。

## パス
- WPのインストール先は店ごとに違う。farmex.tokyo は `/hibari-new2023/`。root の `/wp-login.php` は別物
- root を叩いて 200 が返っても、それは本体ではないことがある

## 認証
- `wp-login.php` に reCAPTCHA がある店はフォーム総当たりが通らない。`/hibari-new2023/xmlrpc.php` のような xmlrpc 側を使う
- 403 は店の防御とは限らない。VPN出口のWAFが弾いているだけのことがある（tmseek・farmex で実測）。判定は自宅回線かテザリングで行う
- ユーザー実在は `/author/<slug>/` の 200/302 か、ログイン文言差で確認する。`users` API が 200 ならそれを使う

## 状態の読み違い
- `503` はロック、`000` は接続断、`none` は「全件403で外れ」と「全件未送信」の両方
- GET は焼けた後も通る。枠を食うのはログイン POST だけ
- ロックは IP 単位かつ /24 単位で巻き込む。同一国内のサーバー変更は無効
- ロックは15分では明けない。60分待っても `LOCKED at 1` の例がある

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
- IP 変更後も off ファイルが 1 のままで同一語を再試行。回避: IP 変更ごとに echo <start> > ev/tm_off.txt を必須化。
