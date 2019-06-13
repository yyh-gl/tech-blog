+++
author = "yyh-gl"
categories = ["Web API", "Golang", "Docker"]
date = "2019-06-12"
description = ""
featured = "go_web_api_go-kit/featured.png"
featuredalt = "画像がどこかへ逝ってしまったようだ…"
featuredpath = "date"
linktitle = ""
title = "【Go kit + Docker】GolangでAPIサーバを構築"
type = "onHold"

+++

<img src="http://localhost:1313/tech-blog/img/tech-blog/2019/06/-/-" width="600">
<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/06/-/-" width="600">

<br>

---
# Go kit
---
 
 <img src="http://localhost:1313/tech-blog/img/tech-blog/2019/06/go_web_api_go-kit/go-kit.png" width="600">
 
 今回使用する [Go kit](https://gokit.io) はマイクロサービスを開発するためのフレームワークです。
 
 同カテゴリのフレームワークでは、最もスター数が多かったので、今回は Go kit を使用することにしました。
 
 （参考：[『Go言語Webフレームワークランキング』 @loftkun](https://qiita.com/loftkun/items/1a9951d1864bebdc51e1)）


---
# 動作環境
---

- MacOS Mojave 10.14.4
- Golang 1.12
- Docker for Mac Version 2.0.0.3


---
# 作るもの
---

- 書籍管理システム の API
  - 書籍一覧 取得
  - 書籍詳細 取得
  - 書籍 追加
  - 書籍 貸出
  - 書籍 返却
  - 著者一覧 取得
  - 著者詳細 取得
  - 著者 追加

上記のような処理を行うAPIサーバを実装します。


---
# パッケージ管理
---

パッケージ管理には Golang 1.11 から導入された [Go Modules](https://qiita.com/propella/items/e49bccc88f3cc2407745) を使用します。

プロジェクトのルートディレクトリで

```bash
$ export GO111MODULE=on
$ go mod init go-api-project-template
```

`go.mod` がルートディレクトリに生成されると思います。<br>
`go.mod` はビルドに使用されるので `/build/package` に入れておきましょう。

<br>

と、思ったのですが、 [Golang公式ブログ](https://blog.golang.org/using-go-modules) に

> The go.mod file only appears in the root of the module. 

このように書いてありました。<br>

「モジュールのルートにしか置けない」と…<br>
モジュールのルートって、今回はプロジェクトのルートという解釈でよかったですかね。

<br>

それでも、なんとか `go.mod` を `/build/package` に移そうといろいろしたのですがうまくいかず…

結局、諦めて、ルートディレクトリに置きました。<br>
（`go.mod` を移動させる方法があれば教えてください）

<br>

[こちら](https://github.com/golang-standards/project-layout/issues/22#issuecomment-472141814) を見ると、<br>
ルートディレクトリで `go mod init` してる人がいるっぽいですね。<br>
（つまり、ルートディレクトリに `go.mod` を置いている）

---
# main.go
---

では、アプリケーションを起動させるメインのプログラムを作っていきましょう。

以下のような `main.go` を作成します。

```go

```


---
# Docker環境の構築
---

今はソロ開発ですが、今後チーム開発になる予定（ないです）なので、<br>
だれでもすぐに開発に入れるように Docker で環境構築します。

<br>

以下のような image を用意しました。
（長くなるので説明はコメントのみです）

```dockerfile
FROM golang:1.12-alpine3.9 AS build

WORKDIR /go/src/go-api-project-template

RUN GO111MODULE=on go mod vendor \
    && go build -o build/api-server ./cmd/api-server

COPY . .

FROM alpine:3.8 AS app

COPY --from=build /go/src/go-api-project-template/build/api-server /usr/local/bin/api-server

EXPOSE 8080

CMD ["api-server"]
```

Dockerfile もビルドに使用されるので `/build/package` に置きましょう。










