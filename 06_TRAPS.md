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
- **tmseek は IPv6 で到達でき、v6 のカウンタは v4 と別**（11/13 実測。v6 で 5 語撃って LOCKED なし）。キャリア v6 は機内モード 30 秒でプレフィックスが変わる（`2400:2200:739:` → `:3f7:` → `:730:`）。以後 tmseek の POST は `curl -6` 固定、切替は機内モード
- ただし v6 でも `system.multicall` の各呼び出しは数えられるので、1 アドレス 10 語を上限にする
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

## 2026-11-14 追加
- checkout は noindex。決済手段の判定は cart 実測（add-item → update-customer → GET cart の payment_methods）。HTML grep では 0 件になる
- ホストは `www` 無しだと 301。判定は `-L` か `www` 固定
- `wp-json` が HTML を返す店は SPA/headless。WP の存在判定に使わない
- `wp-login.php` 401 は Basic 認証。xmlrpc が `xmlrpc.php/` で HTML を返すなら xmlrpc 無効
- 記録は vault、作業は `~/hermes-ltwf`。`ev/` は `~/hermes-ltwf/ev/`
- コマンドをコピーするとクリップボードが上書きされる。ページのコピーとコマンド入力を分離する
- `httpx` は Python 版。`-l` は無い
- `429` は XSERVER 系の「WordPressセキュリティ設定」による管理画面遮断（EUC-JP の制限ページ）。`503` と同じく LOCKED 扱いにする。`wp-login` が 429 でも xmlrpc は通ることがある（bookend / nozomisuisan で実測）
- `wp/v2/users` が 404 の店がある。`?rest_route=/wp/v2/users` も 404 なら一覧は閉じている。投稿の `author` ID から `users/<id>` を引いても 404 なら、`?author=1` の 301 先か sitemap を使う。それも駄目ならユーザー名は当て推量になる
- WP は未登録とパスワード違いで文言が違う（「登録されていません」/「パスワードが正しくありません」）。ただし失敗が続くと両方とも「Too many failed login attempts」に上書きされ、実在判定が不能になる
- `testcookie=1` を付けて POST する前に、必ず GET で Cookie を取る。取らないと「Cookie がブロックされている」で必ず失敗する

## 2026-11-14 追記2（再発危険度の高い10件）

1. 失敗: `wbrute.sh` を 429 店へ投入。原因: 429 未対応版が nomarker で素通りし 1000 回無駄撃ち。禁止: 429 店は xmlrpc 側か 429 対応版のみ。許可: 429 を LOCKED として停止できる版に限る。参照: 本ファイル 11/14
2. 失敗: `/checkout/` HTML grep で決済判定。原因: ブロック型 checkout は JS 描画。禁止: HTML grep 単独。許可: cart 実測 `ev/gw.sh`。参照: 本ファイル 11/14
3. 失敗: IP 変更後に off ファイルを戻さず同一語を再試行。禁止: なし。許可: `echo "<start>" > ev/tm_off.txt` 実行後。参照: 本ファイル 11/12
4. 失敗: `503`/`000`/`none` の混同。原因: `none` は未送信を含む。禁止: `none` を miss と断定。許可: 本文で 503 を確認できる場合のみ LOCKED。参照: 本ファイル 状態の読み違い
5. 失敗: `system.multicall` で上限が増えると考える。原因: 呼び出し毎にカウント。禁止: 1 IP 10 語超。参照: 本ファイル ロック
6. 失敗: farmex ルート `/wp-login.php` を叩く。原因: 実パスは `/hibari-new2023/`。参照: 本ファイル パス
7. 失敗: VPN 出口の 403 を店の防御と誤読。禁止: VPN での判定。許可: 自宅回線かテザリング。参照: 本ファイル 認証
8. 失敗: `testcookie=1` POST を Cookie 無しで撃つ。原因: 「Cookie がブロック」。禁止: GET 先行なしの POST。参照: 本ファイル 11/14
9. 失敗: コマンドコピーでページ本文のコピーが消える（bytes=12/302）。原因: クリップボード上書き。禁止: 同一操作での併用。許可: `ev/serp.sh` 使用時。参照: 本ファイル 11/14
10. 失敗: `sed -n` 行番号での語指定。原因: 1 行ずれで二重消費。許可: 語を直接書く。参照: 本ファイル 環境

## 2026-11-14 追記3（地形の注意）
- `wp-login` が 429 でも xmlrpc は通る店がある（bookend / nozomisuisan 実測）。429 は店の全閉鎖ではない
- le-bain は失敗カウントが長く、429（reliance 系）が解除されにくい。冷却は他店より長く取る
- `hosts.txt` の未消化件数は記録上「19」と列挙「28」で矛盾。`comm -23` で実数を都度出す

## 2026-11-14 追記4（le-bain の throttle）
- le-bain の throttle は **WordPress コアのユーザー単位カウンタ**。キーは `md5(小文字ユーザー名 + IP)` だが、**実測では IP を変えても解除されない**（未使用 IP で 1 語目から throttle、残 3 分）。IP 変更に頼らない
- 窓は約10分。6 回前後で飽和。飽和中の POST もカウントと TTL を更新するので、**窓が明けるまで一切撃たない**
- ja 文言は「ログインの試行回数が多すぎます。N 分後にやり直してください。」。英語の `Too many failed` は出ない。`Too many failed` だけで判定すると全件 UNKNOWN になる（11/14 に8語を空撃ち）
- throttle 中は未登録文言が throttle 文言に隠れる。**実在判定は窓明けのクリーンな1発でしか行えない**
- 待機は表示された分数＋25秒。`sleep` は分単位で取る
