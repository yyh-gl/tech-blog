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

---
# アクセストークン と IDトークン の違いが分からない
---

Web API のセキュリティ周りについて調べていると、<br>
「OAuth 2.0」や「OpenID Connect」という単語をよく見かけると思います。

さらに調べると、「アクセストークン」と「IDトークン」という単語に出会うでしょう。

<br>

しかし、この「2つのトークンの違い」について、<br>
いまいち理解ができていなかったので、今回は両者の違いを調べてみました。


---
# 2つのトークンの差異
---

いきなりですが、ほぼ結論です。

アクセストークン と IDトークン、両者の違いは以下のとおりです。

- アクセストークン：
  - 主目的：リソース（欲しいデータ）へのアクセスコントロール
  - 使用例：他のアプリケーションにもAPIを公開する場合に使用
- IDトークン：
  - 主目的：認証が主目的
  - 使用例：他のアプリケーションにAPIを公開しない（同一の1サービスにおける、フロントエンドとバックエンドの関係）場合に使用

> ★認証：その人が誰かを確認すること <br>

<br>

両者の違いの本質は <u>そのトークンが誰のためのものか判断できるか否か</u> です。

<br>

なお、誤解のないように言っておきますが、<br>
<u>OpenID Connect は OAuth 2.0 を拡張した仕様</u> です。


> ★したがって、両者は <u>本来、別々のものではなく、ふたつでひとつです。</u> <br>
> 　本来、そこに差異などないです。ひとつの仕組みなんですから。 <br>
> 　僕はそこも理解していなかったので、余計頭がこんがらがってしまいました。<br>
> 　みなさんはお間違えのないように。
> 　（遊○王みたいな関係）

---
# OAuth 2.0 は 認可 の仕組み
---

<u>OAuth 2.0 は 認可 の仕組みであり、 認証 の仕組みではない</u>。

OAuth 2.0 で認証を行うと、どういう問題があるか。

[こちら](https://www.sakimura.org/2012/02/1487/) の記事に詳しく書いてあるので、ご覧ください。

<br>

上記記事内で述べられている OAuth 2.0 による認証の問題点は、<br>
<u>クライアント側でトークンの正当性を確かめる術がない</u> ということです。


---
# クライアント側でトークンの正当性を確かめたい
---

さきほどの記事を読んでいただければ分かると思いますが、<br>
<u>認証は OpenID Connect によって行うことで問題を解決できます</u>

<br>

では、どうして OpenID Connect を使うと認証ができるようになるのでしょうか。<br>
キーとなるのは IDトークン に含まれる <u>audクレーム</u> です。


---
# audクレーム
---

audクレーム は IDトークン に含まれるデータのひとつです。<br>
（「クレーム」はJSONにおける「キー」とほぼ同義だと思ってください）

では、この audクレーム がどういった情報を持っているかと言うと、<br>
<u>そのトークンがどのアプリケーションのために発行されたものか</u> という情報です。

<br>

したがって、audクレームを使用することで、<br>
クライアントは自分のためのトークンかどうか調べることが可能です。

この「クライアント側で audクレーム のチェックを行う」ことは <br>
<u>OpenID Connect の仕様として決められています。</u> → [参考](http://openid-foundation-japan.github.io/openid-connect-core-1_0.ja.html#IDTokenValidation)


---
# まとめ
---

<u>認証がしたいなら OpenID Connect を使用しましょう。</u>

<br>

---
# 参考
---

- [OAuth 2.0 仕様](https://tools.ietf.org/html/rfc6749)
- [OpenID Connect 仕様](https://openid-foundation-japan.github.io/openid-connect-core-1_0.ja.html)
- [OAuth 2.0 + OpenID Connect のフルスクラッチ実装者が知見を語る （@TakahikoKawasaki さん）](https://qiita.com/TakahikoKawasaki/items/f2a0d25a4f05790b3baa)
- [IDトークンが分かれば OpenID Connect が分かる （@TakahikoKawasaki さん）](https://qiita.com/TakahikoKawasaki/items/8f0e422c7edd2d220e06)
- [OAuth 2.0/OpenID Connectの2つのトークンの使いみち （@wadahiro さん）](https://qiita.com/wadahiro/items/ad36c7932c6627149873)
