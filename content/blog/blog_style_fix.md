+++
author = "yyh-gl"
categories = ["HTML/CSS", "Web全般"]
tags = ["Tech"]
date = "2019-06-16T00:00:00Z"
description = ""
title = "【HTML + CSS + Prism.js】ブログの見た目を整えた話"
type = "post"
draft = false
[[images]]
  src = "img/tech-blog/2019/06/blog_style_fix/featured.webp"
  alt = "featured"
  stretch = "stretchH"
+++

# シンタックスハイライト導入
このブログ、ちょっと前までコードのシンタックスハイライトが効いていませんでした。

正確には対応していない言語が（めちゃくちゃ）ありました。

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/06/blog_style_fix/syntax_highlight_before.png" width="600">

このとおり、 Golang にも対応していませんでした…。

<br>

もともと、このブログのテーマは [Hugo Themes](https://themes.gohugo.io/)（Hugo 公式 テーマショップ的なの）に <br>
あったものを使わせてもらっているのですが、さすがに対応していない言語が多すぎたので、<br>
シンタックスハイライト部分だけ個別に導入することにしました。

# Prism.js
さっそく、「HTML シンタックスハイライト」で調べてみました。

そしたら、だいたい以下の3つが出てきました。

- [Prism.js](https://prismjs.com/)
- [highlight.js](https://highlightjs.org/)
- [Google code-prettify](https://github.com/google/code-prettify)


どれにしようか迷ったのですが、見た目が一番好みだった Prism.js を使うことにしました。

## 導入

導入方法については記事がたくさんあるので、そちらをご覧ください。

- [公式ダウンロードページ](https://prismjs.com/download.html#themes=prism&languages=markup+css+clike+javascript)
- [導入 参考記事](https://mndangler.net/2017/04/syntaxhighlighter_prism-js/)
- [導入 参考記事](https://thk.kanzae.net/net/wordpress/t1171/)
- [導入 参考記事](https://niwaka-web.com/prism_js/)


## 導入後

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/06/blog_style_fix/syntax_highlight_after.png" width="600">

きれいですねー

今回導入した Prism.js のプラグインは、

- Line Highlight：行指定した箇所をハイライトする機能（上記画像内では使用していません）
- Line Numbers：行番号を表示する機能
- Show Language：右上に 言語名 を表示している機能

の3つです。


# 困ったこと
## 行番号が表示されない

行番号を表示するには、

```html
<pre class="line-numbers"><code class="language-c">
  コード
</code></pre>
```

上記コードのように、表示するコードスニペットに対して、<br>
line-numbers というクラスを付与してあげるだけでOKです。

…が、なぜか行番号が他の要素の下にいってしまい、見えなくなっていました。<br>
したがって、prism.css を修正して行番号が他の要素の上に来るようにしました。

## リスト表示の行間が異様に広い

Prism.js 導入後…

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/06/blog_style_fix/li_incorrect.png" width="600">

このようになぜか リスト表示（箇条書き）の行間が異様に広くなり、文字が折り返されずはみ出ています。

まさかと思い、prism.css を無効にすると…

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/06/blog_style_fix/li_correct.png" width="600">

直った！

ということで、なにかしらのスタイルが悪さをしている模様。

しかし、これは僕が手抜きで、

```html
<pre class="line-numbers"><code class="language-c">
  コード
</code></pre>
```

のコードを、コードスニペット部分だけじゃなく、記事全体に対して適用していたため発生していました。<br>
（手抜いて本当にごめんなさい。悪気はなかったんです。）

<br>

しかしながら、記事のコンテンツに関する HTML は Hugo が自動生成してくれるため、<br>
中身をさわることができない模様…。

どうしようと困っているときに、[こちら](https://qiita.com/peaceiris/items/8b7fdbb700f6dd355f99#%E7%BD%AE%E6%8F%9B%E6%96%B9%E6%B3%95) の記事を発見。

これで生成された HTML 内の要素を置換できます。

最終的には、 `content-single.html` を以下のとおり修正しました。

```html
<article class="post">
  ｛｛ .Render "header" ｝｝
  <section id="social-share">
    ｛｛ partial "share-buttons" . ｝｝
  </section>
  ｛｛ .Render "featured" ｝｝
  <div class="content">
    ｛｛ .Content | replaceRE "<pre>" "<pre class=\"line-numbers\">" | safeHTML ｝｝
  </div>
  <footer>
    ｛｛ .Render "stats" ｝｝
  </footer>
</article>
```

修正したのは 8行目部分です。

```html
｛｛ .Content ｝｝
```

だけだった部分を

```html
｛｛ .Content | replaceRE "<pre>" "<pre class=\"line-numbers\">" | safeHTML ｝｝
```

こうすることで、 コードスニペット部分だけに line-numbers を適用することができました。

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/06/blog_style_fix/li_after.png" width="600">

行間もシンタックスハイライト&行番号 もいい具合に表示できています。


# まとめ
Prism.js いいですね！

フロントに疎い僕でも簡単にシンタックスハイライト対応ができました。

フロントの勉強もどんどんやっていきます。
