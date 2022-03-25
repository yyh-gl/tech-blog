+++
author = "yyh-gl"
categories = ["Advent Calendar", "テスト", "Lint", "Go"]
tags = ["Tech"]
date = 2019-12-09T09:00:00+09:00
description = "DMM Advent Calendar 2019 9日目"
title = "GolangCI-Lintの設定ファイルを理解する"
type = "post"
draft = false
[[images]]
  src = "img/tech-blog/2019/12/golangci-lint-custom-settings/featured.webp"
  alt = "featured"
  stretch = "stretchH"
+++


# DMM Advent Calendar 2019

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/12/react_typescript_sample/qiita_advent_calendar_2019.png" width="700">

本記事は [DMM Advent Calendar 2019](https://qiita.com/advent-calendar/2019/dmm) の 9日目 の記事です。

<br>

私は現在、DMM.com の CDS というチームに所属し、<br>
主に[ユーザレビュー基盤](https://inside.dmm.com/archive/category/%E3%83%A6%E3%83%BC%E3%82%B6%E3%83%BC%E3%83%AC%E3%83%93%E3%83%A5%E3%83%BC)のバックエンドを開発しています。

<br> 

今回は、Go用Linterである GolangCI-Lint を軽く紹介した後に、<br>
GolangCI-Lint のハマリポイントとその解決策である設定周りの話をします。


# Linter 導入していますか？

突然ですが、みなさんの開発環境には Linter が導入されているでしょうか？

私の所属するチームでは、<br>
<u>コーディング規約違反</u> および <u>コンパイラでは見つけられないエラー</u> を検知するために、<br>
ローカルと CI において Linter を回すようにしています。


# GoにおけるLinter

Goの場合、Linterがデフォルトで用意されているうえに、<br>
ライブラリとして公開されているものも多く存在します。

なかでも有名なものに以下のようなものがあります。

- govet：GoデフォルトのLinter
- errcheck：ちゃんとエラーハンドリングしているかチェックしてくれる
- unused：未使用の定義をチェックしてくれる
- goimports：未使用のimportを消してくれたり、フォーマット修正してくれる
- gosimple：コードをシンプルにしてくれる

<br>

しかしながら、多すぎるがゆえに <u>どれを選択すればいいのか分からなくなりがちです</u>。<br>
加えて、導入する Linter が増えれば、その分だけ <u>導入・管理コストが増加</u> します。

この問題を解決してくれるツールが <b>GolangCI-Lint</b> です。


# GolangCI-Lint

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/12/golangci-lint-custom-settings/golangci-lint-logo.png" width="200">

勉強会でもよく耳にするようになってきている＋多くの紹介記事があるので、<br>
ここで詳しく説明する必要もないかもしれませんが、いちおう少しだけ触れておきます。

<br>

[GolangCI-Lint](https://github.com/golangci/golangci-lint)とは、
GoのLinterを一元管理するためのツールです。<br>
開発者は GolangCI-Lint を導入するだけで様々な Linter を実行することができます。

したがって、Linter の導入・管理コストが一気に下がりますし、<br>
運用していく過程で不要だと感じた Linter は、簡単に無効化することもできるので、<br>
気軽に Linter を試用することができます。

対応 Linter は[こちら](https://github.com/golangci/golangci-lint#supported-linters)に一覧が載っています。

似たようなツールに [gometalinter](https://github.com/alecthomas/gometalinter) というのがあったのですが、<br>
[こちらの議論](https://github.com/alecthomas/gometalinter/issues/590)の結果、なくなることが決定しました。<br>
<b>今後の主流は GolangCI-Lint です</b>。


<br>

（…ロゴいいですよね👍）



# 使ってみる

## 導入

[こちら](https://github.com/golangci/golangci-lint#install)に導入方法が書いてあります。

Binary のインストール方法を紹介しておくと、下記のようになります。

```zsh
# $(go env GOPATH)/bin ディレクトリ配下にインストールする方法
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.21.0

# ./bin ディレクトリ配下にインストールする方法
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s v1.21.0

# alpine linux 用のインストール方法
wget -O- -nv https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s v1.21.0
```

もちろん `go get` でもインストールできますし、<br>
他にも brew や Docker イメージとしても提供されています。

[IDEやエディタ上で実行する方法も紹介](https://github.com/golangci/golangci-lint#editor-integration)されており、サポートが手厚いです。

弊チームでは、ローカル用コンテナイメージのビルド時に `go get` してインストールしています。

## 実行

`$ golangci-lint run` コマンドで実行できます。<br>
テストファイルにも Lint をかけたい場合は、`--tests` オプションを付与します。

何も設定しない状態では、[こちら](https://github.com/golangci/golangci-lint#enabled-by-default-linters)に記載のある Linter が実行されます。

では、実際に動かしてみます。

```zsh
$ docker-compose exec -T app golangci-lint run --tests ./...
handler/rest/blog.go:82:27: Error return value of `(*encoding/json.Encoder).Encode` is not checked (errcheck)
	json.NewEncoder(w).Encode(res)
	                         ^
domain/model/task/task.go:9:2: structtag: struct field tag `json:"title","hoge"` not compatible with reflect.StructTag.Get: key:"value" pairs not separated by spaces (govet)
	Title         string      `json:"title","hoge"`
	^
```

エラーが出ました。<br>
2行目と5行目の最後に括弧書きでエラーを発見した Linter の名前が書いてあります。<br>
（厳密には Lint で出力された内容はエラーではありませんが、CIがこけるという意味で「エラー」と呼ぶことにします）<br>
今回の場合だと、errcheck と govet がエラーを発見したようですね。


# GolangCI-Lint には検知できないエラーがある…？🧐

では、ここから本記事の主題に入っていきたいと思います。<br>
実際に GolangCI-Lint を導入しようとしてハマったポイントです。

といっても、GolangCI-Lint の README はとても詳細に書かれているので、<br>
なにかあっても README を見ればすぐ解決できます👍


・<br>
・<br>
・<br>

そんなこんなでいきなりですが、同じソースコードに対して、<br>
GolangCI-Lint を使わずに golint を単体で走らせてみます。 

```zsh
$ golint ./...
domain/model/task/task.go:7:1: comment on exported type Task should be of the form "Task ..." (with optional leading article)
```

！？<br>
さきほどの GolangCI-Lint にはなかったエラーが出力されました。

なんとなく分かってきた方もおられると思いますが、<br>
GolangCI-Lint はデフォルト設定だと、いくつかのエラーを無視するようになっています。

例えば、今回の例だと、コメントの記述形式についてのエラーですが、<br>
そこまで厳密に守らなくてもいい内容ですね。（僕は守りたい派ですが。。。）<br>
したがって、GolangCI-Lint が気を利かせて無視するようにしてくれています。

## デフォルトで無視されるルール

デフォルト設定だと無視されるルールは <br>
[こちら](https://github.com/golangci/golangci-lint#command-line-options)の`--exclude-use-default`オプションの説明のところに記載があります。<br>
抜粋してくると以下のとおりです。<br>

||Linter名|無視されるエラー（Linterが出力する内容）|
|---|---|---|
|1|errcheck|`Error return value of .((os\.)?std(out\|err)\..*\|.*Close\|.*Flush\|os\.Remove(All)?\|.*printf?\|os\.(Un)?Setenv). is not checked`|
|2|golint|`(comment on exported (method\|function\|type\|const)\|should have( a package)? comment\|comment should be of the form)`|
|3|golint|test系パッケージにおける `func name will be used as test\.Test.* by other packages, and that stutters; consider calling this`|
|4|govet|`(possible misuse of unsafe.Pointer\|should have signature)`|
|5|staticcheck|`ineffective break statement. Did you mean to break out of the outer loop`|
|6|gosec|`Use of unsafe calls should be audited`|
|7|gosec|`Subprocess launch(ed with variable\|ing should be audited)`|
|8|gosec|errcheckと重複するエラーチェック `G104`|
|9|gosec|`(Expect directory permissions to be 0750 or less\|Expect file permissions to be 0600 or less)`|
|10|gosec|`Potential file inclusion via variable`|

<br>

さきほど例に挙げていた、golint のコメント記述形式に関するエラーは、表中2番のエラーです。<br>
だから、GolangCI-Lint では検知されなかったんですね。

このルール、人によっては「これ無視しちゃだめだろ」と思われるものもあると思いますが、<br>
投稿日時点ではこのようなルールがデフォルトで無視されるようになっています。


# 設定ファイル .golangci.yml

気を利かせてくれているのは分かりますが、無視しないで欲しいときもありますよね。<br>
逆にこのエラーは無視してほしいっていうニーズもあると思います。

そこで登場するのが <b>.golangci.yml</b> です。<br>
`.golangci.yml` により、GolangCI-Lint の細かな設定が可能になります。<br>

CLIのオプションでも指定できますが、チームで共有するなら設定ファイルの方がいいでしょう。<br>
また、後述しますが、CLIのオプションでは指定できない設定もあるので注意が必要です。

## [設定方法](https://github.com/golangci/golangci-lint#config-file)

設定ファイルとして `.golangci.yml` を紹介しましたが、他にも下記の拡張子が使用できます。

- `.golangci.toml`
- `.golangci.json`

今回は`.golangci.yml`を使用します。

設定ファイルのサンプルが[GitHub上に公開](https://github.com/golangci/golangci-lint/blob/master/.golangci.example.yml)されています。

使えるオプションはCLIと同じです。<br>
ただし、CLI では、Linter ごとの設定（`linters-settings`）ができないため、<br>
Linter ごとに細かく設定をしたい場合は設定ファイルを書く必要があります。

## 設置場所

次に、`.golangci.yml`をどこに置くのかという話ですが、<br>
<u>PC のルートディレクトリからプロジェクトのルートディレクトリ内のどこか</u> であればOKです。

例えば、$GOPATH が `/go` で、プロジェクトルートが `/go/src/github.com/yyh-gl/hoge-project` だった場合、<br>
以下のディレクトリ内を見に行ってくれます。

- `./`
- `/go/src/github.com/yyh-gl/hoge-project`
- `/go/src/github.com/yyh-gl`
- `/go/src/github.com`
- `/go/src`
- `/go`
- `/`

上にいくほど優先順位が高いです。（PCのルートディレクトリが一番低い）<br>
基本的には各プロジェクトのルートに置いておけばいいでしょう。

実際に読み込まれている設定ファイルは`-v`オプションで確認可能です。

```zsh
$ golangci-lint run --tests -v ./...
level=info msg="[config_reader] Config search paths: [./ /go/src/github.com/yyh-gl/hoge-project /go/src/github.com/yyh-gl /go/src/github.com /go/src /go /]"
level=info msg="[config_reader] Used config file .golangci.yml" ← ここ

<省略>
```

<br>

では、実際に設定ファイルを変更し、<br>
さきほどの golint が検知していたコメント記述形式に関するエラーを、<br>
GolangCI-Lint でも検知できるようにしてみます。


# "デフォルトで無視されるルール"を無視する

golint が検知していたコメント記述形式に関するエラーを検知するには、<br>
"デフォルトで無視されるルール"を無視する必要があります。

設定自体はすごく簡単です。

```yaml
# .golangci.yml

issues:
  exclude-use-default: false
```

以上です。

テストしてみましょう。

```zsh
$ docker-compose exec -T app golangci-lint run --tests ./...
handler/rest/blog.go:82:27: Error return value of `(*encoding/json.Encoder).Encode` is not checked (errcheck)
	json.NewEncoder(w).Encode(res)
	                         ^
domain/model/task/task.go:7:1: comment on exported type Task should be of the form "Task ..." (with optional leading article) (golint)
// Taskhoge : タスクを表現するドメインモデル
^
domain/model/task/task.go:9:2: structtag: struct field tag `json:"title","hoge"` not compatible with reflect.StructTag.Get: key:"value" pairs not separated by spaces (govet)
	Title         string      `json:"title","hoge"`
	^
```

golint のエラーが増えましたね👍

このように簡単に GolangCI-Lint の設定を変更することができます。


# 細かな設定も可能

さきほど少し触れましたが、各 Linter ごとの細かな設定も可能です。

## linters-settings

各 Linter ごとの設定は `linters-settings` によって定義できます。

```yaml
# .golangci.yml

linters-settings:
  errcheck:
    check-type-assertions: false
    check-blank: false
    ignore: fmt:.*,io/ioutil:^Read.*
    exclude: /path/to/file.txt
  govet:
    check-shadowing: true
    settings:
      printf:
        funcs:
          - (github.com/golangci/golangci-lint/pkg/logutils.Log).Infof
          - (github.com/golangci/golangci-lint/pkg/logutils.Log).Warnf
          - (github.com/golangci/golangci-lint/pkg/logutils.Log).Errorf
          - (github.com/golangci/golangci-lint/pkg/logutils.Log).Fatalf
    enable:
      - atomicalign
    enable-all: false
    disable:
      - shadow
    disable-all: false
  golint:
    min-confidence: 0.8
 ```

例えば、golint の min-confidence は Lint の厳しさを設定するもので、<br>
数値が低いほど厳しいルールが適用されます。<br>
（ちなみに、デフォルトは 0.8で、1.1 にすると何も検知しなくなります😇）

## 他の設定たち

GolangCI-Lint で使用できる設定を探したい場合は、<br>
設定ファイルのサンプルを参考にすればOKです。

このファイルの中に利用可能な全ての設定とデフォルト値が記載されています👍 最高ですね

- [設定ファイルのサンプル](https://github.com/golangci/golangci-lint/blob/master/.golangci.example.yml)


# まとめ

GolangCI-Lint により、様々な Linter が一元管理でき、<br>
Linter の導入・管理コストがとても低くなったと感じています。<br>
また、いろいろな Linter を気軽に試せるようになりました。

ちょっとしたコーディング規約違反を毎回人力で指摘している方や<br>
コンパイラでは発見できないエラーを潰すのに疲弊している方などは、<br>
ぜひ、GolangCI-Lint の導入を検討しみてはいかかでしょうか？

最高の DX です🎁

<br>

DMM Advent Calendar 2019、明日は [mimickn](https://qiita.com/mimickn) さんです！
