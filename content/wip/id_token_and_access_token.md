+++
author = "yyh-gl"
categories = ["Web API", "セキュリティ"]
date = "2019-06-19"
description = ""
featured = "id_token_and_access_token/featured.png"
featuredalt = "画像がどこかへ逝ってしまったようだ…"
featuredpath = "date"
linktitle = ""
title = "【OAuth 2.0 / OpenID Connect】アクセストークン と IDトークン の違い"
type = "post"

+++


<br>

https://qiita.com/TakahikoKawasaki/items/f2a0d25a4f05790b3baa

---
# アクセストークン と IDトークン の違いが分からない
---

「OAuth 2.0」について調べていると、「OpenID Connect」という単語が出てきました。

その中で「アクセストークン」と「IDトークン」という単語を見つけました。

<br>

しかし、両者の違いを調べてみると、なんだかよく分からない。<br>
むしろ一緒に見えてしまう。


気になったので、調べてみました。


---
# とりあえずブラウザを開いた
---

「OAuth 2.0」や「OpenID Connect」で検索すると、たくさん記事が出てきます。

特に参考になったのが [こちらの記事](https://qiita.com/TakahikoKawasaki/items/f2a0d25a4f05790b3baa) です。




---
# はじめに
---














---
# 結論：両者の違いを表すキーワードは Client ID
---

いろいろ調べた結果、僕は以下のとおり理解しました。

- アクセストークン：
  - リソース（欲しいデータ）へのアクセスコントロールが主目的
  - 他のサービスにもAPIを公開する場合に使用
- IDトークン：
  - 認証が主目的
  - 他のサービスにAPIを公開しない（同一の1サービスにおける、クライアントとサーバ間での通信を保護する）場合に使用
  
> クライアント、サーバ、他サービスの関係性が分かりづらいと思いますが、<br>
> 下記のとおりイメージしていただければ分かりやすいと思います。<br>

> ・クライアント：Twitterアプリ <br>
> ・サーバ：Twitter APIサーバ <br>
> ・ 他サービス：Twitterアカウントを使ってログインできるサービス

<br>

両者間の最も大きな違いは <u>Client ID</u> です。<br>
これについて少し説明します。


<br>

## アクセストークン

クライアントからサーバへAPIリクエスト（APIアクセスを一例として使用します）を送るさいに、<br>
リクエスト内に client_id を入れます。

client_id とは、その名のとおり、クライアントを一意に識別するための情報です。<br>
サーバは送られてきた client_id を基に、<br>
「このクライアントにどこまでのアクセス権限が与えていいのか」判断します。

つまり、client_id により、リクエストしてきたクライアントに対するアクセス許可範囲の制御（限定）が可能です。<br>
この方法により、他サービスごとにアクセスできる


<br>

## IDトークン

クライアントからサーバへAPIリクエストを送るさいに、client_id は送りません。<br>
IDトークンでは、サーバから client_id が送られてくるので、<br>
クライアントは受け取った client_id と 自身が予め持っているID（＝ Client ID）が <br>
一致するかを確認します。

こうすることで、クライアントは、リクエスト先のサーバが自身（クライアント）と通信していいかを


<img src="http://localhost:1313/tech-blog/img/tech-blog/2019/06/-/-" width="600">
<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/06/-/-" width="600">
