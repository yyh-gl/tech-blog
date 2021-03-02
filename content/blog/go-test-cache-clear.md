+++
author = "yyh-gl"
categories = ["Go"]
tags = ["Tech"]
date = "2020-04-30T00:00:00Z"
description = "知っておくと便利"
title = "go test におけるキャッシュの消し方"
type = "post"
draft = false
[[images]]
  src = "img/tech-blog/2020/04/go-test-cache-clear/featured.webp"
  alt = "featured"
  stretch = "stretchH"
+++


# go test のキャッシュを消すのは簡単
`$ go clean -testcache`

以上です！

```zsh
$ go test ./...
ok  	github.com/oxequa/realize	(cached)
ok  	github.com/oxequa/realize/realize	(cached)
```

このように `(cached)` となっていたものが、、、

```zsh
$ go clean -testcache
$ go test ./...
ok  	github.com/oxequa/realize	0.086s
ok  	github.com/oxequa/realize/realize	0.389s
```

このように、実行時間が表示されており、キャッシュが消えていることが分かりますね。

<br>

ちなみに、キャッシュを無視する方法はもうひとつあり、<br>
以下のように `-count=1` をつけてやればOKです。

```zsh
$ go test ./... -count=1
ok  	github.com/oxequa/realize	0.076s
ok  	github.com/oxequa/realize/realize	0.384s
```

<br>

ここからは上記コマンドが一体なにをしてくれたのか、<br>
もう少し詳細に話していきます。


# go clean とは

[こちら](https://golang.org/pkg/cmd/go/internal/clean/)にドキュメントがあります。

> Clean removes object files from package source directories.

`go clean` は上記のとおりファイルを消してくれるわけですね。

`-testcache` オプションをつけると、<br>
テストに関するキャッシュファイルのみを消してくれます。

では、次にキャッシュファイルがどこにあるのか見ていきます。

# キャッシュはどこに保存されている？

環境変数 `GOCACHE` で指定されている場所に保存されます。

参考：[公式ドキュメント](https://golang.org/cmd/go/#hdr-Build_and_test_caching)


# count オプションについて

最後に`$ go test ./... -count=1` によって、<br>
キャッシュを無効化できた理由についてです。

この話は[公式ドキュメント](https://golang.org/pkg/cmd/go/internal/test/)にて、<br>
「本来意図した使い方ではないが、そういう使い方もできる」<br>
ぐらいのニュアンスで紹介されています（以下参照）

> The idiomatic way to disable test caching explicitly is to use -count=1.

<br>

そもそも、countオプションはその名前のとおり、
キャッシュ無効化のためのものではないです。

countオプションはテストを指定回数実行し、<br>
そのベンチマークを取るためのオプションです（以下参照）

> -count n
>
>      Run each test and benchmark n times (default 1).
>      If -cpu is set, run n times for each GOMAXPROCS value.
>      Examples are always run once.

ベンチマークを取るのにあたってキャッシュは不要であるため、<br>
countオプションがつくとキャッシュが無効化されます。

このルールを応用して、`-count=1`とすることで、<br>
テスト自体は1回しか実行されず、かつ、キャッシュも無効化して、<br>
テストを走らせることができるわけです。

<br>

なるほど
