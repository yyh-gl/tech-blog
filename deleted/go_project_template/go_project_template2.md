いろいろ内容間違ってたから削除

+++
author = "yyh-gl"
categories = ["Golang", "考察"]
date = "2019-06-11"
description = ""
featured = "go_project_template/featured.png"
featuredalt = "画像がどこかへ逝ってしまったようだ…"
featuredpath = "date"
linktitle = ""
title = "Golangプロジェクトのディレクトリ構成について考えてみた"
type = "post"

+++


<br>

---
# 追記 20/06/06
# いろいろ間違ってたねーーーーー
---

いろいろ内容間違ってたから削除


Goについていろいろと学び、触れていく中で、<br>
本記事で取り上げる [golang-standards/project-layout（Standard Go Project Layout）](https://github.com/golang-standards/project-layout)の内容は <br>
APIサーバといったアプリケーションを作る上ではちょっとやりすぎな部分があると感じています。<br>
（一方で、ツール系のプロジェクトでは、Standard Go Project Layout に則っているものが多い気がします）

この辺の話は、最近、フューチャー社さんの技術ブログでとても参考になる記事が上がっていたので、<br>
そちらを読むことをおすすめします！（[リンク](https://future-architect.github.io/articles/20200528/)）


僕自身、現在はオニオンアーキテクチャを採用しており、<br>
本記事とは全く異なるディレクトリ構成を取っています。<br>
そちらについては今度記事にしたいと思います。

<br>

---
# 追記 19/06/13
# 社内同期と議論した内容のメモ
---

以降ディレクトリ構成について、いろいろ書いているんですが、<br>
社内で何人かの同期と話した結果、<br>
下記記事内の `第5ケース: DDDライクなライトなパッケージ構成` が一番人気でした。<br>

＞＞ [記事リンク](https://medium.com/@timakin/go%E3%81%AE%E3%83%91%E3%83%83%E3%82%B1%E3%83%BC%E3%82%B8%E6%A7%8B%E6%88%90%E3%81%AE%E5%A4%B1%E6%95%97%E9%81%8D%E6%AD%B4%E3%81%A8%E7%8F%BE%E7%8A%B6%E7%A2%BA%E8%AA%8D-fc6a4369337)

社内でも第5ケースの構成に近いものが多く使われている印象です。<br> <br>

他にもpospomeさんのブログ↓を参考にしました。

- [Goのサーバサイド実装におけるレイヤ設計とレイヤ内実装について考える](https://www.slideshare.net/pospome/go-80591000)

僕自身で書いた記事もあるので参考なれば幸いです。 -> [参考記事](https://yyh-gl.github.io/tech-blog/blog/go_web_api/)

<br>

本記事で取り上げる [golang-standards/project-layout（Standard Go Project Layout）](https://github.com/golang-standards/project-layout)以外にも <br>
いろいろな構成があることを踏まえつつ、本記事を読んでいただけると幸いです。


・

・

・



---
# ディレクトリ構成で迷う
---

GoでAPIサーバ作ろうと思ったときに、<br>
ディレクトリ構成どうすりゃいいんだ？ってなりました。

Go でプロジェクト作るとき、ディレクトリ構成で迷いませんか？<br>
Rails や Laravel などは自動生成してくれるから迷いません。<br>

<br>

Goにディレクトリ構成から自動生成してくれるやつってないですよね…？

ざっくり調べた感じ個人の人が作ったジェネレータは何個か見つかりましたが、<br>
Goのディレクトリ構成といえこれ！<br>
っていうデファクト・スタンダード的なライブラリは見つけられませんでした。

<br>

そこで、今回はどのようにディレクトリを切っていけばいいのか考えようと思います。


---
# 一応、ディレクトリ構成のデファクト・スタンダードはある
---

Goにもディレクトリ構成のデファクト・スタンダードはあるようです。

[golang-standards/project-layout（Standard Go Project Layout）](https://github.com/golang-standards/project-layout)

ただし、これは公式に認められた構成ではないようです。

それでも、2019年6月11日時点で8000弱のスターがついているので、<br>
長いものには巻かれる精神でこのディレクトリ構成をベースにします。


---
# [golang-standards/project-layout](https://github.com/golang-standards/project-layout) を読み解く
---

まずは、[golang-standards/project-layout](https://github.com/golang-standards/project-layout) がどういう構成なのか見ていきます。

なお、今回は「APIサーバを作る」ことを目的としたディレクトリ構成を考えます。

<br>

[golang-standards/project-layout](https://github.com/golang-standards/project-layout) を参考にすると下記のとおりになるでしょうか。

```
go-project-template
├── api
├── build
│   ├── ci
│   └── package
├── cmd
│   ├── app1
│   │   └── main.go
│   └── app2
│       └── main.go
├── configs
├── deployments
├── init
├── internal
│   ├── app1
│   └── app2
├── pkg
├── scripts
├── test
└── vendor
```

ここで注意すべきは、今回作成する `go-project-template` というプロジェクトは <br>
<u>`$GOPATH/src/` 配下に設置します。</u>

それがGoのお作法らしいです。

<br>

では、作成したディレクトリについて、ひとつずつ見ていきます。

---
# /cmd
---

`/cmd` がプロジェクトのメインとなるディレクトリです。

APIサーバで言えば、サーバを起動するやつがここに入ります。<br>
（`main.go` や `server.go` などで表されるやつですね。 以降、例では `main.go` を使います。）

<br>

ここで、[golang-standards/project-layout](https://github.com/golang-standards/project-layout) の本文に

> The directory name for each application should match the name of the executable you want to have (e.g., /cmd/myapp).

上記の文章があるのですが、「The directory name for each application」… each とあります。

複数のアプリケーションが混在することを想定しているかのような書き方ですが、<br>
おそらく、マイクロサービスを組み合わせてひとつのサービスを作り上げることを想定しているのでしょう。

したがって、今回作成した `go-project-template` というプロジェクト内には <br>
いくつかのアプリケーションが混在するという想定で話が進みます。


<br>

## 注意1

このときcmd配下に設置するディレクトリ名はアプリケーション名と合わすようにしましょう。<br>
（本文には 「実行可能ファイルと一致させる」 と書かれています）

したがって、今回の場合は下記のようになっているわけです。

```
go-project-template
├── cmd
│   ├── app1
│   │   └── main.go
│   └── app2
│       └── main.go
```

<br>

## app1 と app2

app1 と app2 って例えばどんなのがあるでしょうか。

僕が新卒研修で経験したものだと、

APIサーバ本体 と DBのマイグレーション用システム で分けてありました。

他に思いついたのだと Swagger を切り出す とかでしょうか。


<br>

## 注意2

`/cmd` に配置する `main.go` の中にあまり多くの機能を書き込まないことです。

後述の `/pkg` や `/internal` からインポートする形で機能を実装します。


---
# /internal
---

`/internal` はアプリケーションごとの専用ライブラリを格納します。

よって、下記のようにディレクトリを切り、

```
go-project-template
├── internal
│   ├── app1
│   └── app2
``` 

`/app1` の中に app1 が使用するコードを、<br>
`/app2` の中に app2 が使用するコードをそれぞれ格納します。

ビジネスロジックはここに入ることになるでしょう。


---
# /pkg
---

`/pkg` は外部のアプリケーションが使ってもよいパッケージを入れておくところです。<br>
したがって、ここには app1 も app2 も両方が使用するコードが入ることになります。


---
# /build
---

`/build` はさらに `/build/package` と `/build/ci` に分けられる。
 
`/build/package` には、クラウド（AMI）やコンテナ関連（Dockerfile など），OSパッケージ（deb, rpm, pkg）が入ります。
ビルドするための設定ファイルを入れておくって感じですね。
 
`/build/ci` には、名前のとおりCI関連の設定を入れます。


---
# /configs
---

`/configs` は他の言語のフレームワークにもだいたいあるのでイメージがつきやすいのではないでしょうか。

アプリケーションに関する設定ファイルを入れる場所ですね。

---
# /deployments
---

`/deployments` はデプロイに関するものを入れるところなので、<br>
IaaS や PaaS，コンテナオーケストレーションシステム にデプロイするための設定ファイルを置きます。

具体的には、docker-compose や kubernetes/helm，terraform などですね。


---
# /init
--- 

`/init` には、下記2種類のものが入ります。

- systemd，upstart，sysv などの「System init」
- runit，supervisord などの「process manager/supervisor」の設定

僕には systemd しか分からなかったので、ほぼ原文まま載せておきます。

<br>

とにかく、ここにはサーバPC起動時に <br>
自動でアプリケーションを起動するための設定を入れておくってことですよね。


---
# /api
---

`/api` ディレクトリに以下のものが入ります。

- OpenAPI や Swagger などの定義ファイル

- リクエストやレスポンスのJSONスキーマ定義ファイル <br>
  リクエストはこういうので、レスポンスはこういう形っていうのを決めるやつですね

- protocol definition files <br>
  プロトコルを決めるファイル郡ってなんでしょう…？

<br>

Webサーバを作るときは `/web` を使います。詳細は [こちら](https://github.com/golang-standards/project-layout/tree/master/web) をどうぞ。

---
# /scripts
---

`/scripts` には、ビルドやインストール，解析などを行うスクリプトを入れておきます。

[golang-standards/project-layout](https://github.com/golang-standards/project-layout) にどういったものを入れるのか例があったので載せておきます。

- https://github.com/kubernetes/helm/tree/master/scripts
- https://github.com/cockroachdb/cockroach/tree/master/scripts
- https://github.com/hashicorp/terraform/tree/master/scripts

---
# /test
---

`/test` は テストのためのディレクトリですね。

`/test` 配下の構造に関しては、「あなたの自由に」と書かれています。


---
# /vendor
---

`/vendor`はアプリケーションが依存関係（ライブラリ郡）を格納する場所です。

<br>

---
# まとめ
---

以上で各ディレクトリに関する説明は終わりです。

今回紹介したディレクトリ構成はかなりマイクロサービスを意識した構成だと感じました。<br>
1つのプロジェクト内に複数のアプリケーションが置かれることを想定していますしね。

<br>

ひとつ疑問に思ったのは、「リポジトリ管理をどのようにするのか」です。<br>
ひとつのリポジトリに突っ込むには粒度が大きすぎると感じました。<br>
だからといって、submoduleに切ったら管理が大変そうですよね。（そうでもないか…）

<br>

実際のプロジェクトでどういうディレクトリ構成が取られているのか、<br>
今後いろいろ経験して、自分なりのベストプラクティスを出していきたいです。

<br>

長々と説明してきましたが、このディレクトリ構成って使われているんでしょうか。

社内とかOSSで見かけるプロジェクトで、<br>
今回紹介した [golang-standards/project-layout](https://github.com/golang-standards/project-layout)  の構成使ってるところ見たことないんですが…。


---
# 参考
---

[『Goにはディレクトリ構成のスタンダードがあるらしい。』 @sueken](https://qiita.com/sueken/items/87093e5941bfbc09bea8)
