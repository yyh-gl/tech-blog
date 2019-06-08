+++
author = "yyh-gl"
categories = ["Web API", "Vue.js", "HTML", "CSS"]
date = "2019-06-08"
description = "いいね機能つけました"
featured = "good_api/featured.png"
featuredalt = "画像がどこかへ逝ってしまったようだ…"
featuredpath = "date"
linktitle = ""
title = "【Web API（Rails） + Vue.js】ブログのいいねボタン自作してみた"
type = "posta"

+++

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/05/-/-" width="600">

<br>

---
# いいねボタンがないブログ
---

本ブログ、いいねボタンが <u>ありませんでした</u>。

だから、作っちゃいました。っていう記事です。


---
# 構成
---

<img src="http://localhost:1313/tech-blog/img/tech-blog/2019/06/good_api/architecture.png" width="600">

<br>

上図のように

記事ページからAPIサーバにリクエストを送り、 いいねの数を取得・加算します。

記事ページからAPIサーバへのリクエスト部分（クライアント）には Vue + axios を使用。

APIサーバは Rails で実装しました。 

（以前から Slackのスラッシュコマンド用に使用していたAPIサーバを流用しました）

---
# APIサーバ
---

Rails で APIサーバを建てる方法に関しては、

以前に Qiita で [入門記事](https://qiita.com/yyh-gl/items/30bd91c2b33fdfbe49b5) 書いたのでそちらをご覧ください。

（少し古い記事ですが、そんなに問題はないはずです）


<br>

## CORSの設定

今回追加でやったのは CORS の設定です。

CORS を説明するとなると、 CSRF の説明やらなんやらで、とても長くなり、本題からかなり脱線するので

今回は [こちらのサイト](http://watanabe-tsuyoshi.hatenablog.com/entry/2015/03/04/123649) をご紹介するだけにしておきます。

僕的に一番分かりやすかったです。

・

・

・


では、本題の CORS の設定についてですが、

Rails における CORS の設定はとても簡単です。

1. Gemfile に `rack-cors` を追加

    Rails で生成した Gemfile にデフォルトで入っていますが、コメントアウトされています。
  
    コメントを解除してあげましょう。
    
    ```
    # Gemfile
    
    …省略
    
    # Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
    gem 'rack-cors'
    
    …省略
    ```
1. `cors.rb` を編集

    こちらも元から存在するファイルです。
    
    中身に関しては、コメントを解除してあげるだけでOKです。
    
    ```ruby
    # <Rails Root Directory>/config/initializers/cors.rb   
 
    Rails.application.config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins 'https://yyh-gl.github.io'
    
        resource '*',
          headers: :any,
          methods: [:get, :post, :options]
      end
    end
    ```
    
    `origins` で指定した場所からのアクセスに関しては、同一生成元ポリシーを少し無視して
    
    アクセスを許可します。
   
    ワイルドカードによる指定もできます。
    
    今回は、僕のブログからのアクセスのみを許可します。
    
    <br>
    
    `resource` によってアクセスを許可するリソースを指定できます。
    
    `resource` で許可したリソースに対して、
    
    `headers` および `methods` で指定したヘッダおよびメソッドのみを受け付けます。
    
    <br>
    
    [こちら](https://github.com/cyu/rack-cors#rack-configuration) を見ていただければ、より詳しい設定方法が分かると思います。
    
    今回実装するAPIは GET と POST しか使わないので 
    
    `methods: [:get, :post, :options]` となっています。
    
    <br>
    
    `options` は <u>プリフライトリクエスト</u> と言って、
    
    事前にサーバに対してリクエストを送信しても大丈夫か問い合わせるさいに使用します（[参考](https://developer.mozilla.org/ja/docs/Web/HTTP/CORS#Preflighted_requests)）。
    
    忘れずに追加しましょう。

<br>


以上で、Rails における CORS の設定は完了です。


---
# クライアントの実装
---

次は、記事ページからリクエストを送る部分です。

Vue の SFC を使いたかったのですが、勉強不足で実現できず、このような実装になりました。

詳しい人ぜひ教えてください。

```html
<html>
      <div id="GoodCounter">
        <good-counter></good-counter>
      </div>
</html>

<script src="/tech-blog/js/axios.min.js"></script>
<script src="/tech-blog/js/vue.min.js"></script>
<script src="/tech-blog/js/vue_app.js"></script>
```

中の処理を説明すると、

IDが `GoodCounter` の `div`要素の部分に Vue コンポーネント（後述）を入れ込んでいます。

`script`タグは、上から axios, Vue, Vue コンポーネント を読み込んでいます。


> axios が npm 経由のインストール方法しか見つけられなかったの CDN 経由なのですが、ローカルに落とすことってできるんでしょうか？）


















