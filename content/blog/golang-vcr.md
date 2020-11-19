+++
author = "yyh-gl"
categories = ["Go", "テスト", "Advent Calendar"]
date = "2019-12-08T00:00:00Z"
description = "Go3 Advent Calendar 2019 8日目"
title = "【Golang+VCR】外部APIとの通信を保存してテストに使用する話"
type = "post"
draft = false
[[images]]
  src = "img/tech-blog/2019/12/golang-vcr/featured.png"
  alt = "featured"
  stretch = "stretchH"
+++


# Go3 Advent Calendar 2019

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/12/react_typescript_sample/qiita_advent_calendar_2019.png" width="700">

本記事は [Go3 Advent Calendar 2019](https://qiita.com/advent-calendar/2019/go3) の 8日目 の記事です。

ではでは、早速本題に入っていきます。


# モック使ってますか？

みなさんモックコードは書いていますか？

テストコードを書いているなら、ほぼ必ず登場するあのモックです。<br>
DB処理や関数のモックなどいろいろありますよね。

そんなモックコードですが、作ったり管理するのめんどくさいなぁとか思ってないですか？<br>
モックだからといって雑なコードになっていませんか？

<br>

今回は、外部API通信のモック化にフォーカスし、<br>
モックコードの作成・管理コストを軽減する <br>
<u>VCR ライブラリ</u> を紹介します。


# VCR ライブラリ とは？

VCR（Video Cassette Recorder）とは、<u>通信を保存し、再生するライブラリ</u>です。<br>

つまり、APIリクエストの初回通信の内容を保存し、<br>
次回以降その保存内容（レスポンス）を使いまわしてくれるというものです。

言い換えれば、外部APIのモックを自動生成してくれるということですね！

## VCR ライブラリ in Golang World

Golang 用の VCR ライブラリは[いろいろあります](https://github.com/search?l=Go&q=vcr&type=Repositories)。<br>
スター数が多いのは以下のものです。

- [go-vcr](https://github.com/dnaeon/go-vcr)
- [vcr-go](https://github.com/ComboStrikeHQ/vcr-go)
- [govcr](https://github.com/seborama/govcr)
- [rpcreplay](https://github.com/googleapis/google-cloud-go/tree/master/rpcreplay)

go-vcr および vcr-go，govcr の開発は盛んではないようです。

rpcreplay は [google-cloud-go](https://github.com/googleapis/google-cloud-go)に包含されるパッケージであり、安心して使えそうです。<br>
ただし、gRPC 用なので、その点は注意が必要です。<br>
[GoDocはこちら](https://godoc.org/cloud.google.com/go/rpcreplay)です。

<br>

今回は REST API を使って説明していくので、go-vcr を使用します。<br>

go-vcr は、vcr-go と govcr よりスター数が多いです。<br>
Ruby 製の [vcr](https://github.com/vcr/vcr) というライブラリがもとになっているようです。


# サンプルを見ていく

では、コードを交えて紹介していきたいと思います。<br>
今回は下記のような簡単なサンプルを用意しました。

（最終的なサンプルコードは[こちら](https://github.com/yyh-gl/go-vcr-sample)にあります。）

Qiitaのユーザ情報取得APIを呼び出し、<br>
レスポンス内容（ID と Location のみ）を表示するだけの簡単なプログラムです。

```go
// /main.go

package main

import (
	"fmt"

	"github.com/yyh-gl/go-vcr-sample/qiita"
)

func main() {
	user := qiita.FetchUser("yyh-gl")
	fmt.Println("============ RESULT ============")
	fmt.Printf("%+v\n", user)
	fmt.Println("============ RESULT ============")
}
```

```go
// /qiita/qiita.go

package qiita

import (
	"encoding/json"
	"io/ioutil"
	"net/http"
)

type User struct {
	ID       string
	Location string
}

func FetchUser(id string) (user *User) {
	req, _ := http.NewRequest("GET", "https://qiita.com/api/v2/users/"+id, nil)

	client := new(http.Client)
	resp, _ := client.Do(req)
	defer resp.Body.Close()

	body, _ := ioutil.ReadAll(resp.Body)
	_ = json.Unmarshal(body, &user)
	return user
}
```

実行してみると、、、

```zsh
$ go run main.go
============ RESULT ============
&{ID:yyh-gl Location:Tokyo, Japan}
============ RESULT ============
```

ちゃんと ID と Location が表示できていますね。

# テストしたい

今回のサンプルは簡単なコードですがテストを書くことにします。

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/12/golang-vcr/test-lion.jpeg" width="600">

・<br>
・<br>
・<br>

```go
// /qiita/qiita_test.go

package qiita_test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/yyh-gl/go-vcr-sample/qiita"
)

func Test_FetchUser(t *testing.T) {
	tests := []struct {
		testCase     string
		id           string
		wantLocation string
	}{
		{
			testCase:     "Qiitaからyyh-glのユーザ情報を取得できていること",
			id:           "yyh-gl",
			wantLocation: "Tokyo, Japan",
		},
	}

	for _, tt := range tests {
		t.Run(tt.testCase, func(t *testing.T) {
			user := qiita.FetchUser(tt.id)
			assert.Equal(t, tt.wantLocation, user.Location)
		})
	}
}
```

書きました。

```zsh
$ go test ./...
?   	github.com/yyh-gl/go-vcr-sample	[no test files]
ok  	github.com/yyh-gl/go-vcr-sample/qiita	0.313s
```

ちゃんとテストが通りますね。

しかし、このままではテストのたびに <br>
Qiita API にリクエストが飛んでしまうので良くないですね。

ここで、本日の主役 go-vcr を導入していきましょう。


# go-vcr のセットアップ

VCR ライブラリは通信内容を保存します。<br>
つまり、通信を傍受する必要があります。

go-vcr では、http.Client の Transport を go-vcr で用意されたものに差し替えることで、<br>
通信の傍受を可能にします。

したがって、まずは独自の http.Client を差し込めるように、<br>
サンプルのコードを修正していきます。

## Qiita API 用の HTTP クライアントを作る

まず、`qiita.go` に HTTP クライアント生成関数を作ります。

```go
// /qiita/qiita.go

package qiita

import (
	"encoding/json"
	"io/ioutil"
	"net/http"
)

// ここ
type Client struct {
	*http.Client
}

// ここ
func NewClient(c *http.Client) Client {
	return Client{c}
}

type User struct {
	ID       string
	Location string
}

// ここ
func (c Client) FetchUser(id string) (user *User) {
	req, _ := http.NewRequest("GET", "https://qiita.com/api/v2/users/"+id, nil)

	resp, _ := c.Do(req) // ここ
	defer resp.Body.Close()

	body, _ := ioutil.ReadAll(resp.Body)
	_ = json.Unmarshal(body, &user)
	return user
}
```

<br>

`main.go` と `qiita_test.go` も直します。

```go
// /main.go

package main

import (
	"fmt"
	"net/http"

	"github.com/yyh-gl/go-vcr-sample/qiita"
)

func main() {
	// ここ
	qiitaClient := qiita.NewClient(http.DefaultClient)
	user := qiitaClient.FetchUser("yyh-gl")
	fmt.Println("============ RESULT ============")
	fmt.Printf("%+v\n", user)
	fmt.Println("============ RESULT ============")
}
```

```go
// /qiita/qiita_test.go

package qiita_test

import (
	"net/http"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/yyh-gl/go-vcr-sample/qiita"
)

func Test_FetchUser(t *testing.T) {
	tests := []struct {
		testCase     string
		id           string
		wantLocation string
	}{
		{
			testCase:     "Qiitaからyyh-glのユーザ情報を取得できていること",
			id:           "yyh-gl",
			wantLocation: "Tokyo, Japan",
		},
	}

    // ここ
	qiitaClient := qiita.NewClient(http.DefaultClient)

	for _, tt := range tests {
		t.Run(tt.testCase, func(t *testing.T) {
			user := qiitaClient.FetchUser(tt.id)
			assert.Equal(t, tt.wantLocation, user.Location)
		})
	}
}
```

この状態でテストを実行すると、、、

```zsh
$ go test ./...
?   	github.com/yyh-gl/go-vcr-sample	[no test files]
ok  	github.com/yyh-gl/go-vcr-sample/qiita	0.293s
```

ちゃんと通りますね。

さて、これで `NewClient()` に渡す引数（http.Client）しだいで、<br>
使用する HTTP クライアント変更できるようになりました。


## go-vcr 導入

ここから go-vcr を導入して、外部APIとの通信を保存・再生していくのですが、<br>
<u>めちゃくちゃ簡単</u>です。

今回はテストにおいて、外部APIとの通信部分をモック化したいので、<br>
`qiita_test.go` を直していきます。

```go
// /qiita_test.go

package qiita_test

import (
	"net/http"
	"testing"

	"github.com/dnaeon/go-vcr/recorder"
	"github.com/stretchr/testify/assert"
	"github.com/yyh-gl/go-vcr-sample/qiita"
)

func Test_FetchUser(t *testing.T) {
	tests := []struct {
		testCase     string
		id           string
		wantLocation string
	}{
		{
			testCase:     "Qiitaからyyh-glのユーザ情報を取得できていること",
			id:           "yyh-gl",
			wantLocation: "Tokyo, Japan",
		},
	}

    // ここ
	// go-vcr のレコーダを生成
	// 通信内容は ../fixtures/qiita に保存される
	r, _ := recorder.New("../fixtures/qiita")
	defer r.Stop()

	customHTTPClient := &http.Client{
		Transport: r, // ここ 重要！
	}
	qiitaClient := qiita.NewClient(customHTTPClient)

	for _, tt := range tests {
		t.Run(tt.testCase, func(t *testing.T) {
			user := qiitaClient.FetchUser(tt.id)
			assert.Equal(t, tt.wantLocation, user.Location)
		})
	}
}
```

以上で終了です。

この状態で `$ go test ./...` してみると、

```zsh
$ go test ./...
?   	github.com/yyh-gl/go-vcr-sample	[no test files]
ok  	github.com/yyh-gl/go-vcr-sample/qiita	0.472s
```

普通にテストが通りますね。

では、この状態で、ネットワーク（WiFi）を切って、再度テストしてみます。

```zsh
$ go test ./...
?   	github.com/yyh-gl/go-vcr-sample	[no test files]
ok  	github.com/yyh-gl/go-vcr-sample/qiita	0.014s
```

成功しました。<br>
"保存された通信内容"を見ているので、ネットワークに繋がっていなくても、テストが通ります。<br>
（"保存された通信内容"がどこにあるかは後で説明します）<br>
つまり、<u>モック化できてしまっているのです！</u>

しかも、実行時間が短くなっていますね！これはでかい。

では、"保存された通信内容"を消して、再度テストしてみましょう。

```zsh
$ go test ./...
?   	github.com/yyh-gl/go-vcr-sample	[no test files]
panic: runtime error: invalid memory address or nil pointer dereference [recovered]
	panic: runtime error: invalid memory address or nil pointer dereference
[signal SIGSEGV: segmentation violation code=0x1 addr=0x40 pc=0x12aef8d]

goroutine 21 [running]:
testing.tRunner.func1(0xc0000fe200)
	/Users/yyh-gl/.anyenv/envs/goenv/versions/1.13.4/src/testing/testing.go:874 +0x3a3
panic(0x1343900, 0x1642f80)
	/Users/yyh-gl/.anyenv/envs/goenv/versions/1.13.4/src/runtime/panic.go:679 +0x1b2
github.com/yyh-gl/go-vcr-sample/qiita.Client.FetchUser(0xc00008b2c0, 0x13a96ac, 0x6, 0x104fe28)
	/Users/yyh-gl/workspaces/Go/src/github.com/yyh-gl/go-vcr-sample/qiita/qiita.go:26 +0x10d
github.com/yyh-gl/go-vcr-sample/qiita_test.Test_FetchUser.func1(0xc0000fe200)
	/Users/yyh-gl/workspaces/Go/src/github.com/yyh-gl/go-vcr-sample/qiita/qiita_test.go:37 +0x49
testing.tRunner(0xc0000fe200, 0xc0000a0540)
	/Users/yyh-gl/.anyenv/envs/goenv/versions/1.13.4/src/testing/testing.go:909 +0xc9
created by testing.(*T).Run
	/Users/yyh-gl/.anyenv/envs/goenv/versions/1.13.4/src/testing/testing.go:960 +0x350
FAIL	github.com/yyh-gl/go-vcr-sample/qiita	0.020s
FAIL
```

エラーになりましたね。<br>
ちゃんとエラーハンドリングしていないので、nil参照のエラーになっていますが、<br>
これはネットワークに繋がっていない（＋"保存された通信内容"がない）ために、<br>
外部APIへのリクエストが失敗し、発生したエラーです。

# "保存された通信内容"

では、さきほど go test を初めて実行したときに何が起こっていたのかを説明します。

プロジェクト内を見てみると、

```zsh
$ tree go-vcr-sample
go-vcr-sample
├── fixtures
│   └── qiita.yaml
├── go.mod
├── go.sum
├── main.go
└── qiita
    ├── qiita.go
    └── qiita_test.go
```

`fixtures` ディレクトリができています。

中身を見てみると、

```zsh
$ ls fixtures
qiita.yaml
```

`qiita.yaml` ができています。<br>

```yaml
# /fixtures/qiita.yaml

---
version: 1
interactions:
- request:
    body: ""
    form: {}
    headers: {}
    url: https://qiita.com/api/v2/users/yyh-gl
    method: GET
  response:
    body: "{\"description\":\"東京でエンジニアしてます／CLI名刺 $ npx yyh-gl／メインは個人ブログです\U0001F4DD\",\"facebook_id\":\"\",\"followees_count\":19,\"followers_count\":18,\"github_login_name\":\"yyh-gl\",\"id\":\"yyh-gl\",\"items_count\":11,\"linkedin_id\":\"\",\"location\":\"Tokyo,
      Japan\",\"name\":\"\",\"organization\":\"\",\"permanent_id\":119088,\"profile_image_url\":\"https://qiita-image-store.s3.amazonaws.com/0/119088/profile-images/1535528464\",\"team_only\":false,\"twitter_screen_name\":null,\"website_url\":\"https://yyh-gl.github.io/tech-blog/\"}"
    headers:
      Cache-Control:
      - max-age=0, private, must-revalidate
      Content-Type:
      - application/json; charset=utf-8
      Date:
      - Sat, 07 Dec 2019 07:27:05 GMT
      Etag:
      - W/"a6adaa36bf27d2045a25659539dcdae5"
      Rate-Limit:
      - "60"
      Rate-Remaining:
      - "56"
      Rate-Reset:
      - "1575706459"
      Referrer-Policy:
      - strict-origin-when-cross-origin
      Server:
      - nginx
      Strict-Transport-Security:
      - max-age=2592000
      Vary:
      - Origin
      X-Content-Type-Options:
      - nosniff
      X-Download-Options:
      - noopen
      X-Frame-Options:
      - SAMEORIGIN
      X-Permitted-Cross-Domain-Policies:
      - none
      X-Request-Id:
      - f0ca74f0-4aae-4d0f-b6f9-ec08b0407b56
      X-Runtime:
      - "0.082646"
      X-Xss-Protection:
      - 1; mode=block
    status: 200 OK
    code: 200
    duration: ""
```

リクエストおよびレスポンスの内容が全て保存されています。

<br>

このように、go-vcr では、通信内容を傍受して、yaml 形式で保存します。<br>
（内容自体も、Web エンジニアならよく見かける単語ばかりなので読みやすいですね）

そして、この yaml ファイルがあるときは、外部APIに対してリクエストを飛ばさずに、<br>
yaml ファイルの内容からレスポンスを返します。


# リクエスト済みかどうかの判断方法

ここで、go-vcr がどのようにして、<br>
リクエストを送ったことがあるかどうかを判定しているのか説明していきます。

答えは[こちら](https://github.com/dnaeon/go-vcr/blob/9384691f0462689770c3e930cd8aff05c7075a5b/cassette/cassette.go#L103-L107)のコードにあります。

```go
// DefaultMatcher is used when a custom matcher is not defined
// and compares only the method and URL.
func DefaultMatcher(r *http.Request, i Request) bool {
	return r.Method == i.Method && r.URL.String() == i.URL
}
```

> compares only the method and URL.

デフォルトだと、HTTP メソッドとリクエストURL しか見てないんですね。

しかし、この判定処理において、<br>
HTTP メソッドとリクエストURL以外も見るようにしたかったり、<br>
逆にこのURLへのリクエストだけは保存したくないといったニーズもあると思います。<br>
そこで 登場するのが <u>Custom Request Matching</u> です。

## Custom Request Matching

[README.md](https://github.com/dnaeon/go-vcr#custom-request-matching) にもあるとおり、<br>
Matcher を作ってあげるだけで、簡単にオリジナルの判定処理を実装可能です。

さきほどの README.md にあるサンプルを拝借して、<br>
僕のコード書き換えてみると以下のとおりになります。

```go
// /qiita/qiita_test.go

package qiita_test

import (
	"bytes"
	"io/ioutil"
	"net/http"
	"testing"

	"github.com/dnaeon/go-vcr/cassette"

	"github.com/dnaeon/go-vcr/recorder"
	"github.com/stretchr/testify/assert"
	"github.com/yyh-gl/go-vcr-sample/qiita"
)

func Test_FetchUser(t *testing.T) {
	tests := []struct {
		testCase     string
		id           string
		wantLocation string
	}{
		{
			testCase:     "Qiitaからyyh-glのユーザ情報を取得できていること",
			id:           "yyh-gl",
			wantLocation: "Tokyo, Japan",
		},
	}

	// go-vcr のレコーダを生成
	// 通信内容は ../fixtures/qiita に保存される
	r, _ := recorder.New("../fixtures/qiita")
	defer r.Stop()

    // ここ
	r.SetMatcher(func(r *http.Request, i cassette.Request) bool {
		if r.Body == nil {
			return cassette.DefaultMatcher(r, i)
		}
		var b bytes.Buffer
		if _, err := b.ReadFrom(r.Body); err != nil {
			return false
		}
		r.Body = ioutil.NopCloser(&b)
		return cassette.DefaultMatcher(r, i) && (b.String() == "" || b.String() == i.Body)
	})

	customHTTPClient := &http.Client{
		Transport: r,
	}
	qiitaClient := qiita.NewClient(customHTTPClient)

	for _, tt := range tests {
		t.Run(tt.testCase, func(t *testing.T) {
			user := qiitaClient.FetchUser(tt.id)
			assert.Equal(t, tt.wantLocation, user.Location)
		})
	}
}
```

`SetMatcher()` 内の処理によって、判定ロジックを変更します。<br>
この例だと、HTTP メソッドとリクエストURL に加えて、リクエストBody の内容も見るようになっています。

このように、`SetMatcher()` を定義してやるだけです。<br>
後はいつもどおり、http.Client の Transport に渡してやるだけなので簡単ですね👍


# 保存内容を修正する必要が出たときはどうする？

yaml ファイルを消すだけです。

例えば、外部APIの仕様が変わり、モックを更新する必要が出てきた場合は、<br>
yaml ファイルを消してやるだけで、次のAPIリクエストの内容を保存 => つまり、モックを更新できます。

もちろん yaml ファイルを直接変更することもできます。

モックの管理が楽になりますね👍


# まとめ

go-vcr を利用することで、外部API通信のモック化および管理が簡単にできるようになりました。<br>
しかも、モックの内容は、実際にリクエストして得た内容なので、<br>
仕様が漏れることもないでしょう。

また、今回は説明しませんでしたが、<br>
go-vcr には [Protecting Sensitive Data](https://github.com/dnaeon/go-vcr#protecting-sensitive-data) という機能もあり、<br>
指定したデータを保存しないようにするといったこともできます。

カスタマイズ性が高く、とてもおすすめのライブラリです。

もしモックの作成・管理で悩んでいる方がおられたら、<br>
ぜひ一度検討してみてください！

<br>

Go3 Advent Calendar 2019、明日は [EbiEbiEvidence](https://qiita.com/EbiEbiEvidence) さんです🛫
