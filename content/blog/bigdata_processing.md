+++
author = "yyh-gl"
categories = ["ビッグデータ", "解析", "書籍"]
date = "2019-06-10"
description = ""
featured = "bigdata_processing/featured.png"
featuredalt = "画像がどこかへ逝ってしまったようだ…"
featuredpath = "date"
linktitle = ""
title = "【大規模サービス技術入門】大規模データ処理に入門する"
type = "postdra"

+++

<img src="http://localhost:1313/tech-blog/img/tech-blog/2019/05/-/-" width="600">
<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/05/-/-" width="600">

<br>

---
# 大量なデータを扱う場面
---

全文検索やデータマイニングなど RDBMSで処理できない規模のデータを

処理したい場面は多く存在する。

では、RDBMSが使えない規模のデータをどう処理すればいいのか。

---
# データを抽出
---

RDBMSで扱うことができないのであれば <u>抽出</u> すればよい。

## 具体的には

バッチ処理でRDBMSからデータを抽出し、

別途インデックスサーバのようなものを作って、そこに入れていく。

インデックスサーバにはRPC（Remote Procedure Call）を使ってアクセスする方法を使えばよい。

