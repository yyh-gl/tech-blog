+++
author = "yyh-gl"
categories = ["Web全般"]
tags = ["Tech"]
date = 2019-06-17T09:00:00+09:00
description = "OGP大事"
title = "【OGP】リンク先のサムネイル画像を表示できるようにした話"
type = "post"
draft = false
[[images]]
  src = "img/2019/06/ogp/featured.webp"
  alt = "featured"
  stretch = "stretchH"
+++


# Twitter のリンクにサムネイル画像が表示されない

<img src="https://tech.yyh-gl.dev/img/2019/06/ogp/before.png" width="600">

このように Twitter でブログのリンクを載せても、サムネイルが表示されない。

はてなブログをやっていたときは、何もしなくてもサムネイルが表示されていました。

トップ画像をよしなにサムネイルにしてくれるのかなぁっと思っていましたが違ったんですね…。


# どうやったらサムネイル画像が表示されるか

<!-- textlint-disable ja-technical-writing/sentence-length -->
Twitter や Facebook などの SNS でタイトルやサムネイルといったWebページの情報を表示するには、
<u>Open Graph Protocol（OGP）</u> というものを設定する必要があります。
<!-- textlint-enable ja-technical-writing/sentence-length -->

OGP を設定することで Twitter や Facebook でサムネイル付きのリンクを表示できます。

[こちらのサイト](https://digitalidentity.co.jp/blog/seo/ogp-share-setting.html) で詳細が説明されています。


# OGP の設定

今回設定する OGP 情報は以下のとおりです。

- og:title
- og:type
- og:url
- og:description
- og:image

これらの情報を head タグ内に埋め込みます。

```html
<meta property="og:title" content="【Go + レイヤードアーキテクチャ】DDDを意識してWeb APIを実装してみる">
<meta property="og:type" content="article">
<meta property="og:url" content="https://tech.yyh-gl.dev/blog/go_web_api/">
<meta property="og:description" content="hoge">
<meta property="og:image" content="https://tech.yyh-gl.dev/img/2019/06/go_web_api/featured.png">
```

ただし、僕の場合、Hugo のテーマの方で og:image 以外は設定してくれていました。<br>
したがって、今回は og:image だけを追加で設定します。

## og:image の設定

下記のような og:image の設定を `/themes/<your-theme-name>/layouts/partials/meta.html` に追加しました。

```html
<meta property="og:image" content="｛｛ .Site.BaseURL ｝｝｛｛ if .Params.featured ｝｝img｛｛ .Page.Date.Format "2006/01" | relURL ｝｝/｛｛ .Params.featured ｝｝｛｛ else ｝｝｛｛ .Site.Params.intro.ogp.src ｝｝｛｛ end ｝｝" />
```

なにやら長たらしく定義していますが、やっていることをまとめると、<br>

- featured画像（各記事ごとのサムネイル画像）が設定されていれば それを使用
- featured画像が設定されていなければ、デフォルトの OGP 用画像を使用

以上のことをしています。

## 【おまけ】toml による定数定義

og:image を定義するさいに `.Site.Params.intro.ogp.src` こんなのを使っています。<br>
これは展開されると OGP 用画像のパスになるわけですが、そのパスをどうやって定義しているかというと…

`/<your-blog-root>/confi.toml` に以下のように設定を記述すれば使えるようになります。

```toml
[params.intro]
    header                = "yyh-gl's Tech Blog"
    paragraph             = "技術系ネタ中心のブログです。サーバサイドをメインとしたフルスタックエンジニアを目指しています。"
    rssIntro              = true
    socialIntro           = true
    
    < 一部省略 >

    [params.intro.ogp]
      src = "img/main/ogp_image.png"
      alt = "yyh-gl's image for OGP"
```

9 〜 11 行目が OGP 用のデフォルト画像を設定しているところです。


# 結果

OGP が正しく設定できているかは 以下のサイトを使って確かめることが可能です。

- [Card validator（Twitter）](https://cards-dev.twitter.com/validator)
- [シェアデバッガー（Facebook）](https://developers.facebook.com/tools/debug/)

僕は Twitter にしか共有する気がなかったので、 Card validator を使用してデバッグしました。

<img src="https://tech.yyh-gl.dev/img/2019/06/ogp/debug.png" width="600">

こんな感じで確かめることができます。
 
<br>

最後に、Twitter 上でどのように表示されているか確認します。

<img src="https://tech.yyh-gl.dev/img/2019/06/ogp/after.png" width="600">

少しサイズがずれちゃっていますが、ちゃんと表示できていますね👍


# 感想

はてなブログを見に行ってみたら、 OGP 用の設定がされていました。<br>
裏で設定してくれていたんですね。

OGP という仕組みを知れてよかったです。

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">リンクのサムネイル出るようになったで🤡<a href="https://t.co/OGXRRGonKc">https://t.co/OGXRRGonKc</a></p>&mdash; ｴﾝｼﾞﾆｱのﾎｹﾞさん 🌕 (@yyh_gl) <a href="https://twitter.com/yyh_gl/status/1140245493844307969?ref_src=twsrc%5Etfw">2019年6月16日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
