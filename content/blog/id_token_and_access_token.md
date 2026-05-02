+++
author = "yyh-gl"
categories = ["Web API", "セキュリティ"]
tags = ["Tech"]
date = 2019-06-19T09:00:00+09:00
description = ""
title = "【OAuth 2.0 / OIDC】アクセストークンとIDトークンの違い ＋ OIDC誕生の歴史"
type = "post"
draft = false
[[images]]
src = "img/2019/06/id_token_and_access_token/featured.webp"
alt = "featured"
stretch = "stretchH"
+++

# はじめに

Web API のセキュリティ周りについて調べていると、<br>
「OAuth 2.0」や「OpenID Connect」という単語をよく見かけると思います。

さらに調べると、「アクセストークン」と「IDトークン」という単語に出会いました。

しかし、この2つのトークンの違いについて、<br>
いまいち理解ができていなかったので、今回は両者の違いを調べてみました。

加えて、トークンについて調べる中で、<br>
OpenID Connectが生まれた経緯も知ることができたのでメモしておきます。

# 2つのトークンの違い

アクセストークン と IDトークン、両者は役割が大きく異なります。

- アクセストークン：認可（リソースへのアクセスコントロール＝あるリソースに対する権限（readやwriteなど）を持っているかどうか確認すること）
- IDトークン：認証（その人が誰かを確認すること）

名前のままでした。

認可に使うためのいろいろな情報が詰まっているのがアクセストークンで、
認証に使うためのいろいろな情報が詰まっているのがIDトークンです。

なお、アクセストークンはクライアントにとって通常 **中身を解釈する必要のない（opaque）** 文字列です。<br>
クライアントは中身を解釈せず、リソースサーバーへのリクエストに添えるだけで、
トークンの内容を検証・解釈するのはリソースサーバー側です。<br>
（参考: https://datatracker.ietf.org/doc/html/rfc6749#section-1.4）

# OpenID Connectが生まれた経緯

OAuth 2.0およびOpenID Connectについて調べていると、<br>
「OpenID Connect は OAuth 2.0 を拡張した仕様」であるという記述を見かけました。

どうしてOpenID Connectが必要になったのか、<br>
この辺の経緯について述べていきます。

# OAuth 2.0 は 認可 の仕組み

まずは、OAuth 2.0について見ていきます。

<u>OAuth 2.0 は 認可 の仕組みであり、 認証 の仕組みではない</u><br>
のですが、実際にはOAuth 2.0を認証用途で使っているシステムは多く存在します。

OAuth 2.0 で認証することの問題点については、<br>
[こちら](https://www.sakimura.org/2012/02/1487/) の記事に詳しく書いてあります。

上記記事より、OAuth 2.0 による認証の問題点は、<br>
<u>クライアント（アプリケーション）側でトークンの正当性を確かめる術がない</u> ことであるとわかります。

なお、ここでいう「正当性」に関して補足しておくと、<br>
「正当なトークン」とは、クライアントが受け取ったトークンはそのクライアントのために用意されたものであることを意味します。

つまり、クライアント側でトークンの正当性を確かめる術がない＝クライアントは自身のためのトークンであることを検証する術がないという意味です。<br>
（トークンの改ざん検知うんぬんの話ではありませんのでご注意ください）

> 「OAuth 2.0 による認証の問題点」という言葉を使っていますが、先述のとおりOAuth 2.0は認可のための仕組みなので、厳密には「認証の問題」なんて存在しません。
> 説明しやすくするためにこういった言葉を使っています。

# クライアント側でトークンの正当性を確かめたい

<u>OAuth 2.0 による認証の問題は OpenID Connect に則ることで解決できます。</u>

では、どうして OpenID Connect を使うと安全に認証できるようになるのでしょうか。<br>
キーとなる重要な要素のひとつがIDトークンに含まれる<u>audクレーム</u>です。

# audクレーム

audクレーム は IDトークン に含まれるデータのひとつです。<br>
（「クレーム」はJSONにおける「キー」とほぼ同義です）

では、このaudクレーム（IDトークンにおける `aud`）がどういった情報を持っているかと言うと、<br>
<u>そのIDトークンがどのクライアントのために発行されたものか</u> という情報です。

したがって、audクレームを使用することで、<br>
クライアントは自身のためのトークンかどうか調べることができます。

この「クライアント側でaudクレームのチェックを行う」ことは仕様として決められています。
（参考: [OIDC Core - ID Token Validation](https://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation) / [RFC 7519 Section 4.1.3](https://tools.ietf.org/html/rfc7519#section-4.1.3)）

ただし、`aud`はあくまでも検証すべきクレームの1つです。

OpenID Connect の安全性は `aud` だけでなく、`iss`（Issuer）、`exp`（有効期限）、`iat`（発行日時）、
必要に応じて`nonce`（リプレイ攻撃対策）や`azp`も検証します。<br>
そして、**署名検証**（JWKSによる公開鍵での改ざん検知）を含む
**IDトークン検証ルール全体**によって安全性が担保されます。

このような仕組み（ルール）があるから、<br>
OpenID ConnectでOAuth 2.0 による認証の問題を解決できるわけですね。なるほど

# まとめ

- アクセストークンは、リソースサーバーへのアクセス時に提示するトークン（クライアントは中身を解釈しない）
- IDトークンは、認証結果をクライアントに伝えるための署名付きトークン
- 認証をしたい場合はOAuth 2.0をそのまま流用せず、OpenID ConnectのIDトークン検証ルールに従いましょう

今回の内容は、自分が調べたことをだいぶざっくりメモした程度のものです。<br>
下記に参考記事を載せておくので、詳細はそちらを御覧ください。

# 参考

- [OAuth 2.0 仕様](https://tools.ietf.org/html/rfc6749)
- [OpenID Connect 仕様](https://openid-foundation-japan.github.io/openid-connect-core-1_0.ja.html)
- [OAuth 2.0 + OpenID Connect のフルスクラッチ実装者が知見を語る（@TakahikoKawasaki さん）](https://qiita.com/TakahikoKawasaki/items/f2a0d25a4f05790b3baa)
- [IDトークンが分かれば OpenID Connect が分かる（@TakahikoKawasaki さん）](https://qiita.com/TakahikoKawasaki/items/8f0e422c7edd2d220e06)
- [OAuth 2.0/OpenID Connectの2つのトークンの使いみち（@wadahiro さん）](https://qiita.com/wadahiro/items/ad36c7932c6627149873)
- [単なる OAuth 2.0 を認証に使うと、車が通れるほどのどでかいセキュリティー・ホールができる（Nat Sakimura さん）](https://www.sakimura.org/2012/02/1487/)
