+++
author = "yyh-gl"
categories = ["Web API", "セキュリティ"]
date = "2019-06-19"
description = ""
title = "【OAuth 2.0 / OIDC】アクセストークンとIDトークンの違い ＋ OIDC誕生の歴史"
type = "post"
draft = false
[[images]]
  src = "img/tech-blog/2019/06/id_token_and_access_token/featured.png"
  alt = "featured"
  stretch = "stretchH"
+++


<br>

---
# はじめに
---

Web API のセキュリティ周りについて調べていると、<br>
「OAuth 2.0」や「OpenID Connect」という単語をよく見かけると思います。

さらに調べると、「アクセストークン」と「IDトークン」という単語に出会いました。

<br>

しかし、この2つのトークンの違いについて、<br>
いまいち理解ができていなかったので、今回は両者の違いを調べてみました。

加えて、トークンについて調べる中で、<br>
OpenID Connectが生まれた経緯も知ることができたのでメモしておきます。

<br>

---
# 2つのトークンの違い
---

アクセストークン と IDトークン、両者は役割が大きく異なります。

- アクセストークン：認可（リソースへのアクセスコントロール＝あるリソースへの権限（readやwriteなど）を持っているかどうか確認すること）
- IDトークン：認証（その人が誰かを確認すること）

名前のままでした。

認可に使うためのいろいろな情報が詰まっているのがアクセストークンで、
認証に使うためのいろいろな情報が詰まっているのがIDトークンです。

<br>

---
# OpenID Connectが生まれた経緯
---

OAuth 2.0およびOpenID Connectについて調べていると、<br>
「OpenID Connect は OAuth 2.0 を拡張した仕様」であるという記述を見かけました。

どうしてOpenID Connectが必要になったのか、<br>
この辺の経緯について述べていきます。

<br>

---
# OAuth 2.0 は 認可 の仕組み
---

まずは、OAuth 2.0について見ていきます。

<br>

<u>OAuth 2.0 は 認可 の仕組みであり、 認証 の仕組みではない</u><br>
のですが、実際にはOAuth 2.0を認証用途で使っているシステムは多く存在します。 

OAuth 2.0 で認証を行うことの問題点については、<br>
[こちら](https://www.sakimura.org/2012/02/1487/) の記事に詳しく書いてあります。

上記記事より、OAuth 2.0 による認証の問題点は、<br>
<u>クライアント（アプリケーション）側でトークンの正当性を確かめる術がない</u> ことであるとわかります。

なお、ここでいう「正当性」に関して補足しておくと、<br>
「正当なトークン」とは、クライントが受け取ったトークンがそのクライアントのために用意されたものであることを意味します。

つまり、クライアント側でトークンの正当性を確かめる術がない＝クライアントが自身のためのトークンであることを検証する術がないという意味です。<br>
（トークンの改ざん検知うんぬんの話ではありませんのでご注意ください）

>「OAuth 2.0 による認証の問題点」という言葉を使っていますが、先述のとおりOAuth 2.0は認可のための仕組みなので、厳密には「認証の問題」なんて存在しません。
> 説明しやすくするためにこういった言葉を使っています。

<br>

---
# クライアント側でトークンの正当性を確かめたい
---

<u>OAuth 2.0 による認証の問題は OpenID Connect に則ることで解決できます。</u>

では、どうして OpenID Connect を使うと安全に認証できるようになるのでしょうか。<br>
キーとなるのは IDトークン に含まれる <u>audクレーム</u> です。

<br>

---
# audクレーム
---

audクレーム は IDトークン に含まれるデータのひとつです。<br>
（「クレーム」はJSONにおける「キー」とほぼ同義だと思ってください）

では、この audクレーム がどういった情報を持っているかと言うと、<br>
<u>そのトークンがどのクライアントのために発行されたものか</u> という情報です。

<br>

したがって、audクレームを使用することで、<br>
クライアントは自身のためのトークンかどうか調べることが可能です。

この「クライアント側で audクレーム のチェックを行う」ことは仕様として決められています。</u>（[参考](https://tools.ietf.org/html/rfc7519#section-4.1.3)）

<br>

このような仕組み（ルール）があるから、<br>
OpenID ConnectでOAuth 2.0 による認証の問題を解決できるわけですね。なるほど

<br>

---
# まとめ
---

- アクセストークンは認可、IDトークンは認証に使うもの
- 認証がしたいなら OpenID Connect を使いましょう

<br>

今回の内容は、自分が調べたことをだいぶざっくりメモした程度のものです。<br>
下記に参考記事を載せておくので、詳細はそちらを御覧ください。

<br>

---
# 参考
---

- [OAuth 2.0 仕様](https://tools.ietf.org/html/rfc6749)
- [OpenID Connect 仕様](https://openid-foundation-japan.github.io/openid-connect-core-1_0.ja.html)
- [OAuth 2.0 + OpenID Connect のフルスクラッチ実装者が知見を語る（@TakahikoKawasaki さん）](https://qiita.com/TakahikoKawasaki/items/f2a0d25a4f05790b3baa)
- [IDトークンが分かれば OpenID Connect が分かる（@TakahikoKawasaki さん）](https://qiita.com/TakahikoKawasaki/items/8f0e422c7edd2d220e06)
- [OAuth 2.0/OpenID Connectの2つのトークンの使いみち（@wadahiro さん）](https://qiita.com/wadahiro/items/ad36c7932c6627149873)
- [単なる OAuth 2.0 を認証に使うと、車が通れるほどのどでかいセキュリティー・ホールができる（Nat Sakimura さん）](https://www.sakimura.org/2012/02/1487/)
