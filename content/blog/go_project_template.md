+++
author = "yyh-gl"
categories = ["Golang", "Web API"]
date = "2019-06-11"
description = ""
featured = "go_project_template/featured.png"
featuredalt = "画像がどこかへ逝ってしまったようだ…"
featuredpath = "date"
linktitle = ""
title = "【Golang + Web API + go-kit】実際に手を動かしながらGolangプロジェクトのディレクトリ構成について考えてみた"
type = "posta"

+++

<img src="http://localhost:1313/tech-blog/img/tech-blog/2019/06/-/-" width="600">
<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/06/-/-" width="600">

<br>

---
# Golangのディレクトリ構成で迷う
---

Golang + go-kit でAPIサーバ作ろうと思ったときに、<br>
ディレクトリ構成どうすりゃいいんだ？ってなりました。

Golang でプロジェクト作るとき、ディレクトリ構成で迷いませんか？<br>
Rails や Laravel などは自動生成してくれるから迷いません。<br>

<br>

Golangにディレクトリ構成から自動生成してくれるやつってないですよね…？

ざっくり調べた感じ個人の人が作ったジェネレータは何個か見つかりましたが、<br>
みんながこれを使う！<br>
っていうデファクト・スタンダード的なライブラリは見つけられませんでした。<br>
（あったらすみません）

<br>

今回は、Golang + go-kit でAPIサーバを作りながら、<br>
どうやってディレクトリを切っていこうか考えようと思います。


---
# 一応、ディレクトリ構成のデファクト・スタンダードはある
---

Golangにもディレクトリ構成のデファクト・スタンダードはあるようです。

[golang-standards/project-layout](https://github.com/golang-standards/project-layout)

ただし、これも公式に認められた構成ではないようです。

それでも、8000弱のスターがついているので、<br>
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
│   └── go-project-template
├── configs
├── deployments
├── init
├── internal
├── pkg
├── scripts
├── test
└── vendor
```

ひとつずつ見ていきます。

（↓ 大文字になっちゃって見づらいと思います。すみません…そのうち直します ↓）

---
# /api
---

`/api` ディレクトリに以下のものが入ります。

- OpenAPI や Swagger などの定義ファイル

- リクエストやレスポンスのJSONスキーマ定義ファイル <br>
  リクエストはこういうので、レスポンスはこういう形っていうのを決めるやつですね

- protocol definition files <br>
  プロトコルを決めるってなんでしょう…？
  

---
# /build
---

`/build` はさらに `/build/package` と `/build/ci` に分けられる。
 
`/build/package` には、クラウド（AMI）やコンテナ関連（Dockerfile など），OSパッケージ（deb, rpm, pkg）が入ります。
ビルドするための設定ファイルを入れておくって感じですね。
 
`/build/ci` には、名前のとおりCI関連の設定を入れます。


---
# /cmd
---

`/cmd` がプロジェクトのメインとなるディレクトリです。

APIサーバで言えば、サーバを起動するやつがここに入ります。<br>
（`main.go` や `server.go` などで表されるやつですね）


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

`/init` は、systemd，upstart，sysv などの「System init」と <br>
runit，supervisord などの「process manager/supervisor」の設定を置きます。

僕には systemd しか分からなかったので、ほぼ原文まま載せておきます。。。

<br>

とにかく、ここにはサーバPC起動時に自動でアプリケーションを起動するための設定を入れておくってことですよね。


---
# /internal
---



---
# /pkg
---

---
# /scripts
---

---
# /test
---
---
# /vendor
---



---
# 参考
---

[『Goにはディレクトリ構成のスタンダードがあるらしい。』 @sueken](https://qiita.com/sueken/items/87093e5941bfbc09bea8)
