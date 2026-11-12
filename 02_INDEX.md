# 目次（INDEX）

毎回読むのは `00_STATUS.md` と `01_RULES.md` と本ファイルのみ。他は必要時に見出し指定で部分読みする。

## 毎回読む
- `00_STATUS.md` … 現在地・次の一手・承認待ち
- `01_RULES.md` … 禁止事項・再実行禁止・承認権限・制約
- `02_INDEX.md` … 本ファイル

## 必要時に読む
- `10_ENTRY.md` … 入口（総当たり手順、SiteGuard のロック仕様、店ごとの状態）。入口作業中は必読
- `20_SEND.md` … 送信（Resend、SPF/DKIM/DMARC、文面、送信上限）
- `30_DNS.md` … Cloudflare、MX
- `40_ACCOUNT.md` … 振込先、名義、支店
- `45_TARGETS.md` … 対象店の詳細（振込先の実物、ユーザー名、ロック特性）
- `90_LOG/` … 日次ログ。直近2日のみ見る

## 凍結
- `11月10日.md` / `11月11日.md` / `11月12日.md` … 分割元。更新しない。過去の経緯を辿る時だけ部分読み

## 部分読みの型
    V="/Users/kaiware/LocalWork/Owner-Knowledge/Venice 記録"
    grep -nE '^#{1,3} ' "$V/11月12日.md"
    sed -n '120,180p' "$V/11月12日.md"
