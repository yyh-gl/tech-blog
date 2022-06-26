<!-- textlint-disable -->

+++
title = "徒然なるままに go build と build tag を見ていく"
author = "yyh-gl"
categories = ["Go", "Advent Calendar"]
tags = ["Tech"]
date = 2021-12-19T09:00:00+09:00
description = "Go #1 Advent Calendar 2021 19日目"
type = "post"
draft = false
[[images]]
  src = "img/2021/12/go-build/featured.webp"
  alt = "featured"
  stretch = "stretchH"
+++

<!-- textlint-enable -->

<br>

本記事は『[Go #1 Advent Calendar 2021 19日目](https://qiita.com/advent-calendar/2021/go)』の記事です。

<img src="https://tech.yyh-gl.dev/img/2021/12/go-build/advent_calendar_2021.webp" width="500">


# はじめに

Goには標準で便利なコマンドがたくさんあります。

有名どころで言えば、
- `generate`
- `fmt`
- `vet`

などがあります。

中でも、Goのコードをコンパイルするための`build`コマンドは、
みなさんも日頃の開発で使用しているのではないでしょうか。

`build`は特に難しいことをしなければ、とてもシンプルに使えるコマンドです。<br>
よって、直感的に「こうすればコンパイルできるんでしょー」くらいの感覚で、
ドキュメントを注視しなくても使い始められるでしょう。

しかし、`build`は深く見ていくと意外と奥が深いコマンドです。<br>
今回はそんな`build`について深ぼっていこうと思います。


# `build`コマンドとは

まずは`build`とはどういったコマンドなのか見ていきましょう。

`help`を使って調べてみます。

```shell
$ go help build

Build compiles the packages named by the import paths,
along with their dependencies, but it does not install the results.

<省略>

When compiling packages, build ignores files that end in '_test.go'.

<省略>

When compiling multiple packages or a single non-main package,
build compiles the packages but discards the resulting object,
serving only as a check that the packages can be built.

<省略>

	-tags tag,list
		a comma-separated list of build tags to consider satisfied during the
		build. For more information about build tags, see the description of
		build constraints in the documentation for the go/build package.
		(Earlier versions of Go used a space-separated list, and that form
		is deprecated but still recognized.)

<省略>
```

`build`はコンパイルするやつですよという文章から始まり、
いろいろ書かれていますが、今回は以下の4点について見てみます。

- `build`はインストールを行わない
- コンパイル時に`_test.go`ファイルは無視する
- 複数パッケージor単一の非mainパッケージのコンパイル時は結果のオブジェクトを破棄する
- build tagについて


# `build`はインストールを行わない

`build`はコンパイルだけを行い、インストールは行いません。

「え、そりゃそうでしょ」「インストール？」ってなる人も多いのではないでしょうか。<br>
当たり前と言われればそうですが、ヘルプにて丁寧に説明されています。

<br>

まず、インストールとはなにかを理解するために、`build`と`insatll`の挙動の違いを見てみましょう。<br>

なぜ、`install`と比較するかと言うと、下記のとおり`install`はコンパイルとインストールを行うコマンドだからです。

```shell
$ go help install
usage: go install [build flags] [packages]

Install compiles and installs the packages named by the import paths.
```

<br>

まずは`build`してみます。<br>
（インストール物は`GOBIN`配下に配置されます）

```shell
$ go build main.go
$ ls -l $GOBIN/
total 33832
-rwxr-xr-x  1 yyh-gl  staff  13989584  8 17 02:05 go
-rwxr-xr-x  1 yyh-gl  staff   3326080  8 17 02:05 gofmt
```

`main.go`のコンパイル&インストールしたものがないですね。

次に`install`してみます。

```shell
$ go install main.go
$ ls -l $GOBIN/
total 37488
-rwxr-xr-x  1 yyh-gl  staff  13989584  8 17 02:05 go
-rwxr-xr-x  1 yyh-gl  staff   3326080  8 17 02:05 gofmt
-rwxr-xr-x  1 yyh-gl  staff   1869456 12 17 22:30 main
```

`main.go`のコンパイル物である`main`が`GOBIN`配下に設置されています。<br>
つまり、インストールが行われています。

`build`と`install`には上記のような差があります。

<br>

両者の使い分けについては、以下の記事などを参考にすると良いのではないでしょうか。

- [go build vs go install](https://esola.co/posts/2016/go-build-vs-go-install)
- [Go best practices, six years in](https://peter.bourgon.org/go-best-practices-2016/#build-and-deploy)
  - 翻訳記事：[6年間におけるGoのベストプラクティス](https://postd.cc/go-best-practices-2016/#build-and-deploy)

<!-- textlint-disable ja-technical-writing/no-doubled-joshi -->
僕は、自プロジェクトの開発物のコンパイルには`build`を使い、ツールのインストールには`install`を使うようにしています。<br>
開発物のコンパイル結果は`GOBIN`配下より、そのプロジェクト配下に入れておいた方がなにかと便利だからです。
コンパイル物を動かす場所がローカルではない場合、そもそも`GOBIN`配下にある必要もないですしね。<br>
逆にツール系は特に理由がないかぎりは、`GOBIN`配下にあった方がPATHが通っているので使い勝手がいいですよね。
<!-- textlint-enable ja-technical-writing/no-doubled-joshi -->


# コンパイル時に`_test.go`ファイルは無視する

これは知っている人も多いと思います。<br>
システムを動かす上でテストコードは不要ですし、無視されるのも納得ですね。

実際に挙動を見てみます。<br>
`invalid_test.go`（[Go Playground](https://go.dev/play/p/aeFBAGvTQR3)）というコンパイルエラーになるテストファイルを対象に`build`を実行してみます。

```shell
$ go build invalid_test.go
<正常終了するのでなにも表示されない>
```

このように正常終了します。<br>
つまり、ビルド対象に含まれていないため、そもそもコンパイルされておらず、エラーが出ません。

同じファイルを`invalid_test2.go`という名前に変更し、もう一度`build`してみます。

```shell
$ go build invalid_test2.go
# command-line-arguments
./invalid_test2.go:4:1: syntax error: unexpected EOF, expecting name or (
```

コンパイルエラーが出ましたね。<br>
今度はビルド対象に含まれたようです。

<br>

`_test.go`という命名を基にビルド対象か否かを判定していることが分かります。


# 複数パッケージor単一の非mainパッケージのコンパイル時は結果のオブジェクトを破棄する

`help`で言うと下記の記述に関しての内容です。

```txt
When compiling multiple packages or a single non-main package,
build compiles the packages but discards the resulting object,
serving only as a check that the packages can be built.
```

実際にmainパッケージではない`not_main.go`（[Go Playground](https://go.dev/play/p/vZX_f2qMhcO)）に対して`build`を実行してみます。

```shell
$ go build not_main.go
$ ls -l
total 8
-rw-r--r--  1 yyh-gl  staff  65 12 17 23:14 not_main.go
```

このようにビルド自体は正常終了しますが、生成物がありません。

次に、`not_main.go`にエラーを仕込んでみます。<br>
（[Go Playground](https://go.dev/play/p/JrP55PnPYGI)）

```shell
$ go build not_main.go
# command-line-arguments
./not_main.go:4:2: undefined: fmt
$ ls -l
total 8
-rw-r--r--  1 yyh-gl  staff  51 12 17 23:16 not_main.go
```

エラーが出ました。<br>
もちろん生成物はありません。

> serving only as a check that the packages can be built.<br>
> ビルド可能かどうかのチェックだけを行う

ヘルプに記載のあるとおりですね。

<br>

複数パッケージに対してビルドをかけてみても、同様に生成物はありませんでした。<br>
（[Go Playground](https://go.dev/play/p/mscomS3W0d7)）

```shell
$ go build ./...
$ ls -l
total 24
drwxr-xr-x  3 yyh-gl  staff    96 12 18 18:27 foo
-rw-r--r--  1 yyh-gl  staff   204 12 18 10:39 go.mod
-rw-r--r--  1 yyh-gl  staff  1526 12 17 23:41 go.sum
drwxr-xr-x  3 yyh-gl  staff    96 12 18 18:26 hoge
-rw-r--r--  1 yyh-gl  staff   145 12 18 18:28 main.go
```

`hoge`と`foo`はディレクトリだから拡張子がないだけで実行ファイルではありません。


# build tagについて

最後にbuild tagについて見て終わろうと思います。


## build tag とは

`//go:build`

↑コードの先頭付近に記載されているこんなやつです。<br> 
[公式Doc](https://pkg.go.dev/cmd/go#hdr-Build_constraints)

ビルド対象を切り分けるのに使います。

実際に試してみます。

まずは以下のようなコードを用意します。<br>
[Go Playground](https://go.dev/play/p/7C_jC-oc6-5)

`main.go`
```go
package main

import "github.com/yyh-gl/go-playground/src"

func main() {
	src.Hoge()
}
```

`src/hoge1.go`
```go
//go:build hoge

package src

import "fmt"

func Hoge() {
	fmt.Println("hoge1: //go:build hoge")
}
```

`src/hoge2.go`
```go
//go:build !hoge

package src

import "fmt"

func Hoge() {
	fmt.Println("hoge2: //go:build !hoge")
}
```

これらのファイルに対して、
`-tags`オプションを使い、ビルド対象を指定した上で`build`を実行してみます。

```shell
$ go build -tags hoge main.go
$ ./main
hoge1: //go:build hoge
```

`//go:build hoge`を持つ`hoge1.go`の内容が実行されましたね。<br>
逆に`//go:build !hoge`を持つ`hoge2.go`は無視されました。

今回は`-tags hoge`を指定したので、build tagとして`hoge`を指定したファイルがビルド対象となりました。

<br>

<!-- textlint-disable ja-technical-writing/no-doubled-joshi -->
逆に`//go:build !hoge`は`hoge`が指定されていないときにビルド対象になることを意味するので、
今回は無視されました。（`!`が否定を意味します）
<!-- textlint-enable ja-technical-writing/no-doubled-joshi -->

`hoge2.go`をビルド対象としたい場合は以下のようにすればできます。

```shell
$ go build -tags foo main.go
$ ./main
hoge2: //go:build !hoge
```

```shell
$ go build main.go
$ ./main
hoge2: //go:build !hoge
```

特筆すべき点は`-tags`を指定しない場合もビルド対象になる点です。

<br>

AND条件やOR条件も使用できるので、できることはいろいろとありそうですね。<br>
[参考](https://pkg.go.dev/cmd/go#hdr-Build_constraints)


### build tag が使われている例

最後に build tag が実際どこで使われているのか紹介して終わります。

Googleが作成したツールで、`Wire`というDIツールがあります。<br>
[google/wire](https://github.com/google/wire)

<br>

Wireでは、依存関係を定義したGoファイル（`wire.go`）を見て、
依存関係を解決し、必要なコード郡（`wire_gen.go`）を生成します。

システムを動かすにあたって必要になるコードは`wire_gen.go`のみです。<br>
`wire.go`はコード生成時には必要ですが、システムを動かすときには必要ありません。<br>
したがって、各ファイルのbuild tagは以下のようになっています。

- `wire.go`: `wireinject` 
- `wire_gen.go`: `!wireinject`

すなわち、build tagの指定なしで`build`を実行すると、
`wire.go`は無視して`wire_gen.go`だけを見るようになっています。

ちなみに、`wireinject`タグはWireによるコード生成時にのみ指定されます。<br>
[参考コード](https://github.com/google/wire/blob/v0.5.0/internal/wire/parse.go#L358)

よって、コード生成時には、逆に`wire_gen.go`は無視して`wire.go`だけを見るようになっています。

<br>

[Wire公式チュートリアル](https://github.com/google/wire/blob/main/_tutorial/README.md#using-wire-to-generate-code)
にbuild tagに関する言及があるのであわせてご覧ください。


# さいごに

今回は、僕が普段何気なく使っていた`build`について深ぼってみました。<br>
ただ、`build`にはまだ他にもオプションがあるので、
一度調べてみると「こんなことできたんだ」という発見に繋がるかもしれません。

みなさんもぜひ一度、Goコマンドについて深ぼってみてはいかかでしょうか。
