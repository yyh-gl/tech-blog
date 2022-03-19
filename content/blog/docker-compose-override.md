<!-- textlint-disable -->

+++
title = "複数のdocker-compose.ymlを使って、設定の追加や上書きをやってみる"
author = "yyh-gl"
categories = ["Docker", "Docker Compose"]
tags = ["Tech"]
date = 2022-03-18T15:55:40Z
description = "知識として知っているだけで実際に使ったことはない←"
type = "post"
draft = false
[[images]]
  src = "img/tech-blog/2022/03/docker-compose-override/featured.webp"
  alt = "featured"
  stretch = "stretchH"
+++

<!-- textlint-enable -->

# 要約

Docker Composeの設定ファイルは複数指定できて、設定の追加や上書きができる。

<br>
<br>

早速詳細に見ていきましょう↓

# `docker-compose.yml`は複数指定可能

`docker compose up`実行時に`-f`オプションを使うことで、
参照する`docker-compose.yml`ファイル（設定ファイル）を指定できることは、ご存知の方も多いと思います。<br>
しかし、複数の設定ファイルを指定できることはあまり知られていないと思います（勝手な決めつけ）。

[Docker-docs-ja](https://docs.docker.jp/index.html)では、以下のページで説明がされています。

[『ファイル間、プロジェクト間での Compose 設定の共有 』](https://docs.docker.jp/compose/extends.html)


# 実際の動きを見てみる

以下のような`docker-compose.yml`を用意します。

`docker-compose.yml`
```docker-compose
version: '3'
services:
  web:
    image: "nginx:latest"
```

`docker compose -f docker-compose.yml up`でコンテナを起動した後に、
ブラウザを開いて`http://localhost/`にアクセスしてみます。

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2022/03/docker-compose-override/result1.webp" width="600">

Webサイトにアクセスできませんでした。

ポートを公開していないので当然の結果ですね。

<br>

次に、以下のような`docker-compose.override.yml`を用意します。

`docker-compose.override.yml`
```docker-compose
version: '3'
services:
  web:
    ports:
      - "80:80"
```

そして、今度は以下のようにして、複数の設定ファイルを指定します。

`docker compose -f docker-compose.yml -f docker-compose.override.yml up`

では、`http://localhost/`にアクセスしてみます。

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2022/03/docker-compose-override/result2.webp" width="600">

今度は無事にアクセスできました。

ポート公開がうまくできているようです。<br>

<!-- textlint-disable ja-technical-writing/sentence-length -->
上記の挙動を見ることで、`docker-compose.yml`で使用イメージの指定ができており、なおかつ、
`docker-compose.override.yml`でポート公開の設定ができていることが分かります。
<!-- textlint-enable ja-technical-writing/sentence-length -->

<br>

すなわち、Docker Composeは追加で設定ファイルを指定することで、設定を追加できます。

なお、今回はサンプルを省きましたが、追加だけではなく、上書きも可能です。<br>
（後ほど出てくるサンプルを見れば、上書きの挙動も分かると思います）


# 重複した設定項目がある場合はどちらが優先される？

前章の最後に、「追加だけではなく、上書きも可能です」と書きました。

本章では、複数の設定ファイルを指定したさいに、
例えば、同じ環境変数名に対して異なる値を設定していた場合どちらの設定が優先されるのかを解説します。

<br>

はじめに、ドキュメントを読んでみます。

[『設定の追加と上書き』](https://docs.docker.jp/compose/extends.html#adding-and-overriding-configuration)の章に、

> 設定オプションが元々のサービスとローカルのサービスの両方にて定義されていた場合は、
> 元のサービスの値はローカルの値によって<b>置き換えられる</b>か、あるいは<b>拡張されます</b>。

とありますが、元のサービスってどっち？となります。<br>
なので、実際に動作を見てみます。

以下のファイルを用意します。

`main.go`
```go
package main

import (
	"fmt"
	"os"
)

func main() {
	fmt.Println(os.Getenv("ENV"))
}
```

`docker-compose.yml`
```docker-compose
version: '3'
services:
  app:
    image: "golang:latest"
    working_dir: /app
    volumes:
      - .:/app
    environment:
      - ENV=local
    command: "go run /app/main.go"
```

`docker-compose.override.yml`
```docker-compose
version: '3'
services:
  app:
    environment:
      - ENV=prod
```

`docker compose up`するとGoのコードが動いて、環境変数`ENV`の内容が表示されるようになっています。

<br>

まずは、`docker compose -f docker-compose.yml -f docker-compose.override.yml up`してみます。

結果は以下のとおりです。

```shell
[+] Running 1/1
 ⠿ Container test-app-1  Recreated                                                                                                                      0.1s
Attaching to test-app-1
test-app-1  | prod
test-app-1 exited with code 0
```

4行目で`prod`と表示されていますね。<br>
これは`docker-compose.override.yml`で設定した内容です。

よって、ドキュメントの言葉に当てはめると、

元々のサービス = `docker-compose.yml`で定義したサービス<br>
ローカルのサービス = `docker-compose.override.yml`で定義したサービス

となるので、`docker-compose.yml`の内容が`docker-compose.override.yml`の内容で上書きされていることになります。

<br>

では、次はファイルの指定順を逆にしてみます。

`docker compose -f docker-compose.override.yml -f docker-compose.yml up`

結果は以下のとおりです。

```shell
[+] Running 1/1
 ⠿ Container test-app-1  Recreated                                                                                                                      0.1s
Attaching to test-app-1
test-app-1  | local
test-app-1 exited with code 0
```

`local`と表示されました。<br>
`docker-compose.override.yml`の内容が`docker-compose.yml`の内容で上書きされたということですね。

<br>

以上、2つの検証から分かったことをまとめると、以下のとおりです。

- 元々のサービスの値はローカルのサービスの値によって上書きされる
  - 元々のサービス = 先に指定した設定ファイルの内容
  - ローカルのサービス = 後から指定した設定ファイルの内容


# ユースケース

本機能のユースケースに関しては、ドキュメントに詳しく記載があるので、そちらをご覧ください。<br>
[『利用例』](https://docs.docker.jp/compose/extends.html#id4)の項です。

ちなみに今回の機能に関して、現状、僕はdocker-composeをローカルでしか使っていないのに加えて、
OSによる差分で困るといったこともなかったので使ったことはありません。


# まとめ

Docker Composeの設定ファイルは複数指定することで、設定の追加や上書きが可能です。

重複している設定内容については、先に指定した設定ファイルの内容が後に指定した設定ファイルの内容で上書きされます。
