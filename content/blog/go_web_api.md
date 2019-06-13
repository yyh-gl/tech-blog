+++
author = "yyh-gl"
categories = ["Golang", "Web API", "アーキテクチャ", "DDD"]
date = "2019-06-13"
description = ""
featured = "go_web_api/featured.png"
featuredalt = "画像がどこかへ逝ってしまったようだ…"
featuredpath = "date"
linktitle = ""
title = "【Golang】DDD を意識して Web API を構築してみる"
type = "posta"

+++

<img src="http://localhost:1313/tech-blog/img/tech-blog/2019/06/-/-" width="600">
<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/06/-/-" width="600">

<br>

---
# 今回やること
---

前回の記事で Golang のディレクトリ構成についていろいろ調べた結果、<br>
[こちら](https://www.slideshare.net/pospome/go-80591000)の記事が参考になりそうだったので、<br>
今回はそちらを参考に Golang で Web API を作っていきたいと思います。

<br>

## 採用アーキテクチャ

記事内で紹介されているのは <u>レイヤアーキテクチャ</u> をベースに <br>
いろいろカスタマイズされたものらしいです。

クリーンアーキテクチャに似たアーキテクチャだとか。

とりあえず、今回はスライドページ19で紹介されているディレクトリ構成に従って、<br>
<u>DDD を意識して</u> Web API を実装していこうと思います。

<br>

依存関係の図だけ載せておきます。

<img src="http://localhost:1313/tech-blog/img/tech-blog/2019/06/go_web_api/architecture.png" width="600">

矢印は依存の方向を示しています。<br>
例えば、上図だと Handler層 は Usecase層 の処理を利用することを意味します。


<br>

## 環境

- MacOS Mojave 10.14.4
- Golang 1.12
- Docker for Mac Version 2.0.0.3

<br>

なお、今回は、Gin や Mux などといったフレームワークは使わず、<br>
API周りに関して追加するパッケージは、 httprouter のみでやっていこうと思います。

Mux を使った実装は [僕の前のブログで紹介している](https://yyh-gl.hatenablog.com/entry/2019/02/08/195310) のでよければどうぞ。


---
# 完成物
---

完成物に関しては [こちら](https://github.com/yyh-gl/go-api-server-by-ddd) に置いておきます。

以降の説明で指定するブランチ（数字）に切り替えてもらえれば、<br>
そのときの状態になるようにしておきます。

<br>

## API 一覧

書籍管理システム の API を想定

- 書籍一覧 取得
- 書籍詳細 取得
- 書籍 追加
- 書籍 貸出
- 書籍 返却


---
# ディレクトリ構成（ブランチ：1）
---

ディレクトリ構成はこんな感じです。

```
api-server-with-go-kit-and-ddd
├── cmd
│   └── api
│       └── main.go  // サーバ起動するやつ
├── domain
├── go.mod
├── go.sum
├── handler
├── infra
│   └── router.go  // ルーティングの設定
└── usecase
```

`go run cmd/api/main.go` で最低限動作する状態にしてあります。

`http://localhost:3000` にアクセスしてもらえば、 Welcome と表示されるはずです。


---
# 書籍一覧を取得するAPIを作る
---

## Domain 層

まずは、`/domain/model` に書籍モデルを作っていきます。

<u>Domain層 はシステムが扱う業務領域に関するコードを置くところです。</u>

よって、「書籍」 がどういうものなのかモデルという形で定義します。

`/domain/model/book.go`

```go
package model

import "time"

type Book struct {
	Id       int64      `json:"id"`
	Title    string     `json:"title"`
	Author   string     `json:"author"`
	IssuedAt  time.Time `json:"issued_at"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}
```

次に、`/domain/repository/book.go` を作っていきます。
 
<u>リポジトリは DB や KVS との CRUD処理 を記述する場所です。</u>

ただし、<u>ドメイン層には技術的関心事を持ち込まない</u> というルールがあるため、<br>
ここでは interface を定義するだけです。

実装は infra で行います。<br>
<u>Infra層 は技術的関心事を扱う層です。</u>

`/domain/repository/book_repository.go`

```go
package repository

import "github.com/yyh-gl/go-api-server-by-ddd/domain/model"

type BookRepository interface {
	GetAll() ([]*model.Book, error)
}
```

今は 全ての書籍を取得する関数 `GetAll()` のみ定義します。


<br>

ここで、はじめに示した 依存関係の図 を思い出してください。

今定義した Domain層 は他の層のコードを一切利用していません。<br>
つまり、<u>下図の赤枠の中で依存関係が完結しています</u>。

<img src="http://localhost:1313/tech-blog/img/tech-blog/2019/06/go_web_api/dependency_domain.png" width="600">


<br>

## Infra 層

さきほども言いましたが、<u>Infra層 は技術的関心事を扱う層です。</u>

ここでさっき定義した repository の処理を実装します。

`/infra/persistence/book_persistence.go`

```go
package persistence

import (
	"time"

	"github.com/yyh-gl/go-api-server-by-ddd/domain/model"
)

type BookPersistence struct {}

func (book BookPersistence) GetAll() ([]*model.Book, error) {
	book1 := model.Book{}
	book1.Id = 1
	book1.Title = "Test1"
	book1.Author = "Tester1"
	book1.IssuedAt = time.Now()
	book1.CreatedAt = time.Now()
	book1.UpdatedAt = time.Now()

	book2 := model.Book{}
	book2.Id = 2
	book2.Title = "Test2"
	book2.Author = "Tester2"
	book2.IssuedAt = time.Now()
	book2.CreatedAt = time.Now()
	book2.UpdatedAt = time.Now()

	return []*model.Book{ &book1, &book2 }, nil
}
```

なお、 実際には DB にアクセスし、データを持ってくるようにします。<br>
DB には後ほど接続できるようにするので、ここではモックデータを返すようにしておきます。

<br>

先ほどと同様に 依存関係 を確認します。

<img src="http://localhost:1313/tech-blog/img/tech-blog/2019/06/go_web_api/dependency_infra.png" width="600">

このコードだけでは分からないのですが、<br>
Infra層 は Domain層 で作った `/domain/repository/book_repository.go` を実装しています。

すなわち、 Infra層 は Domain層 に依存しています。<br>
Golang には implements とかないので分かりづらいですね。<br>
でも、確かに依存しています。


<br>

## Usecase 層

<u>Usecase層 では、システムのユースケースを満たす処理の流れを実装します。</u>

今回は単純な処理しかしないので、この層の存在価値が少し分かりづらくなってしまいます。

複雑なビジネスロジックがあるときは、この層の存在が効いてくると思います。

<br>

コードは以下のとおりです。

`/usecase/book_usecase.go`

```go
package usecase

import (
	"github.com/yyh-gl/go-api-server-by-ddd/domain/model"
	"github.com/yyh-gl/go-api-server-by-ddd/domain/repository"
	"github.com/yyh-gl/go-api-server-by-ddd/infra/persistence"
)

type BookUsecase struct {}

type IBookUsecase interface {
	GetAll() ([]*model.Book, error)
}

func (bookUsecase BookUsecase) GetAll() ([]*model.Book, error) {
	var books []*model.Book
	var err error

	books, err = repository.BookRepository(persistence.BookPersistence{}).GetAll()
	if err != nil {
		return nil, err
	}

	return books, nil
}
```

<br>

Usecase層 の依存関係も見てみましょう。

<img src="http://localhost:1313/tech-blog/img/tech-blog/2019/06/go_web_api/dependency_usecase.png" width="600">

Usecase層 は `/domain/repository` のコードを使用しています。<br>
したがって、 Usecase層 は Domain層 に依存しています。

<br>

また、ここで先ほど言っていた Infra層 が Domain層 に依存していることが明確になります。

というのも、<br>
`books, err = repository.BookRepository(persistence.BookPersistence{}).GetAll()`<br>
この部分ですね。

ここが <u>Golang 風の implements</u> になるわけです。<br>
やってることはキャストみたいなもんだと理解しています。<br>
`Interface で定義した形に変換できない構造体は、実装すべきものを実装していない証拠` ってことですよね。

