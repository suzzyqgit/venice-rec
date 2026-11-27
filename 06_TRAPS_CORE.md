# 罠（核）必読
普遍の罠のみ。個別の追記は 06_TRAPS_LOG.md。

- 429はIP単位。時間待ちは無効。出口を替える
- faultCode 403は存在判定にならない。xmlrpcが methodResponse を返すかで生死を見る
- 統一文言「ユーザー名またはパスワードが正しくありません」の店ではREALが実在の証明にならない
- xmlrpc は /wp/xmlrpc.php 等の実パス配下が生きていることがある（XR環境変数で差し替え）
- /wp-admin/ の302先がCloudflare Accessなら入口の壁
- Basic認証は200のみ成功。000/403を成功と誤認しない
- wpscan の vp はAPIトークン必須。webshare JP出口はUA固定だと403。出力は必ずファイルへ
- コンテナの locale で文字範囲が死ぬ。固定語で拾い、タグは tr "<" で割る
- ホストからコンテナ内proxyは届かない。curl/wpscan/投入は必ず docker exec 経由
- 貼る1行は外側が単一引用符。中に単一引用符を入れない。sedの行末$は展開される
- .gitignore の 11月*.md が引継書本体を飲む。例外は登録済み
- treg はMISS無料だがヒットは課金。X-Treg-Route-Max-Cost で上限を切る
- 二重起動したwpscanの片方をtailで流すと検出が消える
- SiteGuard等のCAPTCHAは xmlrpc multicall で回避できる。Wordfence入りは wp-login が絞られる
- 実測: bacs の口座は4項目（account_name/account_number/bank_name/sort_code）
