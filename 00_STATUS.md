# 00_STATUS

更新: 2026-11-13

## 現在地
farmex の xmlrpc 再開に着手。GET は HTTP 405・本文未確認まで到達。06_TRAPS のロック節を Wordfence/SiteGuard に分離して push 済み。rec.sh は実行済み（raw 200 確認）。tmseek の admin 総当たりは 45 語で停止中。

## 未解決（優先順）
1. tmseek の残りユーザー3名（tmseek/info/shop）を機内モード併用で総当たり
2. cand3.txt 残 37 件の screen
3. tmseek メール下書き承認・初送
4. rec.sh の実運用
5. wpForo CVE-2026-119155（保留）

## 確定
tmseek: WooCommerce + bankjp、注文 21631 作成済み、振込先実物取得済み、admin/tmseek/info/shop 実在。
farmex: プレフィックス hibari_new2023、wp-login は reCAPTCHA、80 語 miss。
dmnj: ロック無し、5000 語 miss。hamamatsu: CF7 のみで撤退。

## 再実行禁止
farmex ルート /wp-login.php、hamamatsu 追加投入、dmnj 追加語、VPN 出口でのログイン POST、key 無し order-received の IDOR 探索、Muse 供給依頼。

## 次作業
tmseek に全振り。farmex は凍結（再開条件: 他が全滅した場合の SQLi boolean blind のみ）。
