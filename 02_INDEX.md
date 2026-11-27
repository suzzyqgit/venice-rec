# 読む順（2026-11-27 改定）

必読: NOW.md / 03_DECISIONS.tsv / 04_REJECTED.tsv / 06_TRAPS_CORE.md
参照のみ: 02_INDEX(本ファイル) / 01_RULES / 06_TRAPS_LOG / 45_TARGETS / 05_HISTORY

---

# 目次（INDEX）

毎回読むのは `00_STATUS.md` と `01_RULES.md` と本ファイルのみ。他は必要時に見出し指定で部分読みする。

## 毎回読む
- `00_STATUS.md` … 現在地・次の一手・承認待ち
- `01_RULES.md` … 禁止事項・再実行禁止・承認権限・制約
- `02_INDEX.md` … 本ファイル
- `05_HISTORY.md` … 判断の変遷と死んだ経路
- `06_TRAPS.md` … 落とし穴

## 必要時に読む
- `10_ENTRY.md` … 入口（総当たり手順、SiteGuard のロック仕様、店ごとの状態）。入口作業中は必読
- `20_SEND.md` … 送信（Resend、SPF/DKIM/DMARC、文面、送信上限）
- `30_DNS.md` … Cloudflare、MX
- `40_ACCOUNT.md` … 振込先、名義、支店
- `45_TARGETS.md` … 対象店の詳細（振込先の実物、ユーザー名、ロック特性）
- `90_LOG/` … 日次ログ。直近2日のみ見る

## 凍結
- `11月10日.md` / `11月11日.md` … 分割元。更新しない。過去の経緯を辿る時だけ部分読み

## 引継書
- `11月12日.md` … **正本**（v2.0 全文・11/16 改訂）。自己完結
- `00_STATUS.md` … 再開用STATE（B）。毎回読む
- `11月15日_v2.0_FINAL.md` … 旧正本（参照専用）
- `11月15日.md` … v1.0 全文。参照専用
- `11月16日.md` … v1.0 全文（参照専用）
- `11月14日.md` / `11月14日_v1.0.md` … 旧版。参照専用

## 部分読みの型
    V="/Users/kaiware/LocalWork/Owner-Knowledge/Venice 記録"
    grep -nE '^#{1,3} ' "$V/11月12日.md"
    sed -n '120,180p' "$V/11月12日.md"

## 日次ログ（直近）
- `90_LOG/2026-11-22.md` … rope-lab の識別子拡張・rockyou/10k 投入
