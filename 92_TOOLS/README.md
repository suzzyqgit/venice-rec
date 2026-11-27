# 92_TOOLS
コンテナ /work/ev/run/ の写し。コンテナ消失時の復旧用。

- judge.sh <host> … 入口/users/author/xr/CAPTCHA/決済の3層判定。結果を ledger2 に ENTRY 行で残す
- gw_words.py <host> … 屋号・商品名・カナ・電話・郵便から固有語を生成（最大300）
- build_screen.py … ver2.txt と gw と台帳から弱さスコアで screen.tsv を作る
- loop.sh <N> … 選定→判定→固有50+汎用50。撃つのは呼んだ時だけ
- watch.sh … HIT 監視（20秒間隔）
- x3.py <host> <ids> <wordlist> … xmlrpc multicall 25発/req

注意: webshare の proxy 資格情報が各スクリプトに直書き。repo に載っている。
