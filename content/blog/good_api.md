+++
author = "yyh-gl"
categories = ["Web API", "Vue.js", "HTML/CSS"]
date = "2019-06-08"
description = "いいね機能つけました"
featured = "good_api/featured.png"
featuredalt = "画像がどこかへ逝ってしまったようだ…"
featuredpath = "date"
linktitle = ""
title = "【Web API（Rails） + Vue.js】ブログのいいねボタン自作してみた"
type = "post"

+++

<br>

---
# いいねボタンがないブログ
---

本ブログ、いいねボタンが <u>ありませんでした</u>。

だから、作っちゃいました。っていう記事です。


---
# 構成
---

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/06/good_api/architecture.png" width="600">

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

## DB にテーブル作成

今回、ブログ記事を管理するために、下記のテーブルを作成しました。

```
mysql> describe blog_posts;
+------------+--------------+------+-----+---------+----------------+
| Field      | Type         | Null | Key | Default | Extra          |
+------------+--------------+------+-----+---------+----------------+
| id         | bigint(20)   | NO   | PRI | NULL    | auto_increment |
| title      | varchar(255) | NO   |     | NULL    |                |
| count      | varchar(255) | NO   |     | 0       |                |
| created_at | datetime     | NO   |     | NULL    |                |
| updated_at | datetime     | NO   |     | NULL    |                |
+------------+--------------+------+-----+---------+----------------+
5 rows in set (0.00 sec)
```

`title`には、日本語のタイトル（本記事だと『【WEB API（RAILS） + VUE.JS】ブログのいいねボタン自作してみた』）ではなく、
記事ファイル（マークダウン）の名前（本記事だと『good_api』, 拡張子抜き）が入ります。


<br>

Web上の記事データと APIサーバのレコード をどうやって結びつけるか考えたとき、

ページが持っている記事の情報って、 URL に含まれる 記事ファイル名 しかないなぁ…と考え、

URL から取得した 英title と テーブルの `title` が一致するものを探すようにしました。


<br>

## CORSの設定

今回重要なのは CORS の設定です。

CORS を説明するとなると、 CSRF の説明やらなんやらで、とても長くなり、本題からかなり脱線するので

今回は [こちらのサイト](http://watanabe-tsuyoshi.hatenablog.com/entry/2015/03/04/123649) をご紹介するだけにしておきます。

僕的に一番分かりやすかったです。

・

・

・


では、本題の CORS の設定についてですが、

Rails における CORS の設定はとても簡単です。

<div>

1. Gemfile に `rack-cors` を追加

    Rails で生成した Gemfile にデフォルトで入っていますが、コメントアウトされています。
  
    コメントを解除してあげましょう。
    
    ```text
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

</div>
<br>
以上で、Rails における CORS の設定は完了です。


---
# クライアントの実装
---

次は、記事ページからリクエストを送る部分です。

まず、HTMLファイルはこんな感じです ↓

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


次に Vue コンポーネントです。

（Vue のシンタックスハイライト対応してなかったので JS で代用…）

```java
// vue_app.js

Vue.component('good-counter', {
  template: '<button v-on:click="addCount">\n' +
    '<i class="far fa-thumbs-up"></i> いいね　{{ good_count }}\n' +
    '</button>',
  data: function () {
    return {
      good_count: "-",
    }
  },
  mounted () {
    // URL から記事情報を取得
    let paths = location.pathname.split('/');
    // URL のタイトル部分のみを抽出
    // GET /posts/:title への リクエストURL を作成
    let reqUrl = '<server url>' + paths[paths.length - 2];

    axios
      .get(reqUrl)
      .then(response => this.good_count = response.data.post.count)
  },
  methods: {
    addCount: function (event) {
      // URL から記事情報を取得
      let paths = location.pathname.split('/');
      // URL のタイトル部分のみを抽出
      // POST /posts/:title/good への リクエストURL を作成
      let reqUrl = '<server url>' + paths[paths.length - 2] + '/good';

      if(event) {
        axios
          .post(reqUrl)
          .then(response => this.good_count = response.data.after)
      }
    }
  }
});

// root インスタンスを作成
new Vue({
  el: '#GoodCounter',
});
```

いろいろ書いていますが、 URL から記事タイトルを取得し、

それを基にリクエストを送っているだけです。

Vue コンポーネントのマウント時に いいねの数を GET しています。

そして、いいねボタンが押されるたびに `addCount()` が実行されて、 いいね が加算されます。

<br>

Vue の SFC を使いたかったのですが、勉強不足で実現できず、このような実装になりました。

詳しい人ぜひ教えてください。


---
# 完成！
---

できあがったものは、↓ の方にスクロールしていったら実物があるので見てみてください

<br>

だれがいいねしてくれたかは分からないですが、 誰かがしてくれた という事実を噛み締めたいと思います。

<br>

Vue は僕の会社でも使われているので、今後も積極的にキャッチアップを続けていきたいです。

フロントの知識もっとつけていきたいですねー👾

（APIサーバへのアクセスを制限しないとな…）
