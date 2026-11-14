# 入口

> 出典: 11月12日.md §6.8・§7.11 を移設し、11/12 の実測を追記。更新は本ファイルのみ。

## SiteGuard のロック仕様（実測）
- ロックは送信元 IP 単位、かつ /24 単位で巻き込む
- 1 IP の寿命は 15〜21 リクエスト。`503` か `Errno 54` で現れる
- 15分では明けない。60分待っても `LOCKED at 1` のまま
- 回避は国ごと VPN を変えて /24 を離れる。同一国内のサーバー変更では /24 が変わらず無効
- GET は焼けた後も通る。試行枠を食うのはログイン POST だけ

## 判定の誤読に注意
- `none` は「全件 403 で外れ」と「全件 Errno 54 で未送信」の両方で出る。後者は語を消費していない
- `503` はサイト障害ではない。トップが 200 でもログイン系だけ 503 なら焼けている

## 店ごとの状態（11/12 時点）
| 店 | 入口 | 注文の保存先 | 状態 |
|---|---|---|---|
| `dmnj.co.jp` | wp-login 200、CAPTCHA なし、試行制限なし | Snow Monkey Forms（DB 保存） | 総当たり中。ユーザー5既知 |
| `hamamatsu-mokumoku.jp` | wp-login 200 だが SiteGuard CAPTCHA、xmlrpc 可 | CF7（メールのみ） | 撤退。ユーザー `hamamatsu`、約121語で未突破 |
| `vapelog.jp` | wp-login 403、xmlrpc 403 | WooCommerce | 入口閉 |
| `nissyoku.co.jp` | wp-login 403、xmlrpc 403 | WooCommerce | 入口閉 |
| `tmseek.jp` | wp-login 403、xmlrpc 403 | WooCommerce | 入口閉 |
| `www.targma.jp` | wp-login 401（Basic 認証） | WooCommerce | 入口閉 |
| `spacemole.co.jp` / `nishiri.co.jp` / `serapis-bed` / `kagoshimara` | 401/403 | 不明 | 未着手 |

## 手順
- xmlrpc が開いている店: `python3 bin/xbrute2.py <host> <user> <pwfile>`（1語1リクエスト、`LOCKED` で停止）
- フォームのみの店: `bash bin/wbrute.sh <host> <user> <pwfile>`（`SUCCESS` / `LOCKED` を出力）
- 夜間は `bin/night_run.sh <pwfile> <host> <user> <tag> <開始行>`。`LOCKED` で15分待ち、4回で `SKIP` 記録

## tmseek のロック（11/12 深夜・追測）
- テザリングのキャリアIPでは通った（`get=200`）が、**4語でロック**。以前の15語から低下
- 5分待っても明けない。サイト側のカウンタが累積している
- 1 IP あたり3〜4語。IP 変更では回避できないが、試行数を絞る必要がある
- 対策: `pw_tm2.txt`（店固有56語）を先に流し、汎用辞書は後回し

## 候補源の採り方（11/14 確立）
- `/checkout/` は noindex で検索に載らない。**WooCommerce 日本語版の UI 文言**（`お買い物カゴに追加` `お買い物カゴを表示` `オプションを選択` `商品を表示`）を dork にする
- Google は `&udm=14`（ウェブタブ）で通常リンクのみになる。`num=100` を併用するとページングが崩れるので、`&start=10` の細かい刻みか dork 切り替えで母数を稼ぐ
- DDG は captcha、Google は curl を弾く。収集はブラウザ + `ev/serp.sh`（pbpaste を grep して `hosts.txt` へ）
- 振込の判定は `ev/gw.sh`（cart 作成 → `update-customer` → `payment_methods` に `bacs`/`bankjp`/`postofficebank` が出るか）。プラグインのパス（`/wp-content/plugins/bankjp/readme.txt`）だけでは `bacs` を拾えない
- `hosts.txt` の未消化は `comm -23` で `gw_known.txt` と差分を取って作る
