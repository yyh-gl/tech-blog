+++
author = "yyh-gl"
categories = ["Golang", "Web API", "アーキテクチャ", "DDD"]
date = "2019-06-14"
description = ""
featured = "go_web_api/featured.png"
featuredalt = "画像がどこかへ逝ってしまったようだ…"
featuredpath = "date"
linktitle = ""
title = "【Golang + レイヤアーキテクチャ】DDD を意識して Web API を実装してみる"
type = "post"

+++

<br>

---
# 今回やること
---

前回の記事で Golang のディレクトリ構成についていろいろ調べた結果、<br>
[こちらの資料](https://www.slideshare.net/pospome/go-80591000) がとても分かりやすかったので、<br>
今回はこちらを参考に Golang で Web API を作っていきたいと思います。

なお、DDD，レイヤアーキテクチャ の要素が強いため、都度説明を入れています。<br>
（ほぼレイヤアーキテクチャの勉強になっています）

<br>

## 環境

- MacOS Mojave 10.14.4
- Golang 1.12.5

なお、今回は、Gin や Mux などといったフレームワークは使わず、<br>
httprouter のみで薄く作っていこうと思います。

Mux を使った実装は [僕の前のブログで紹介している](https://yyh-gl.hatenablog.com/entry/2019/02/08/195310) のでよければどうぞ。

---
# 採用アーキテクチャ：レイヤアーキテクチャ
---

[参考記事内](https://www.slideshare.net/pospome/go-80591000) で紹介されているのは <u>レイヤアーキテクチャ</u> をベースに <br>
いろいろカスタマイズされたものらしいです。

クリーンアーキテクチャに似たアーキテクチャだとか。

とりあえず、今回はスライドページ19で紹介されているディレクトリ構成に従って、<br>
<u>DDD を意識して</u> Web API を実装していこうと思います。

<br>

レイヤアーキテクチャ における各層の依存関係 について説明を加えておきます。

依存関係の図は下記のとおりです。

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/06/go_web_api/architecture.png" width="600">

矢印は依存の方向を示しています。<br>
例えば、上図だと Handler層 は Usecase層 の処理を利用することを意味します。

レイヤアーキテクチャ に限らず、クリーンアーキテクチャ などでも同じですが、<br>
依存は中心方向に <u>のみ</u> 存在します。

この図だと、中心がどこか分かりづらいので、少し違う視点の図を下記に示します。

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/06/go_web_api/dependency_direction1.png" width="600">

すべての依存が中心に向かっています。これが理想状態です。

<br>

ここで、ユーザから APIリクエスト があった場合を考えてみます。

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/06/go_web_api/dependency_direction2.png" width="600">


ユーザからのリクエストは Handler で受け取られ、 Usecase を使って処理が行われます。<br>
さらに、Usecase は Domain を使って処理を行います。<br>
ここまでは処理が中心に進んでいる、つまり依存は中心に向かって発生しています。

しかし、たいていのサービスって DB を使用しますよね。<br>
つまり、ドメインからユースケースを介して、Infra を利用することになります。

…依存が外側を向いてしまいました。<br>
これは許されていません。ではどうするか。

<u>[依存性逆転の法則](https://medium.com/eureka-engineering/go-dependency-inversion-principle-8ffaf7854a55)</u> を使います。

<br>

<u>依存性逆転の法則 とは、 interfaceに依存させることで依存の方向を逆にすること</u> です。（個人的見解）

もう少し詳しく説明します。<br>
まず、 ① Domain層 において、 DB とのやりとりを interface で定義しておきます。<br>
interface （後ほどコード内にて repository として出てきます） 自体は実装を持たないので、<br>
どこにも依存していません。

次に、 ② Infra層 から Domain層 に定義した interface （後ほどコード内にて persistence として出てきます） を実装します。

<br>

①, ② の2ステップを踏むことで、まず Domain は interface に対して 処理をお願いするだけでよくなります。
先ほども言ったとおり interface は 実装を持たないので依存関係はありません。

interface 自体は実装を持ちませんが、<br>
Infra が interface の実装を行っているので、ちゃんとDBアクセスして処理を行うことができます。

ここで、 Infra は interface を実装しているので、依存が interface 、すなわち Domain に向いています。 

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/06/go_web_api/dependency_direction3.png" width="600">

依存性が逆転し、すべての依存関係が中心に向かうようになりましたね。

<br>

ここは難しいところなので、まだいまいち理解できないかもしれません。

以降、実際のコードを紹介していくので、コードに当てはめながら考えてみてください。

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

```tree
api-server-with-go-kit-and-ddd
├── cmd
│   └── api
│       └── main.go  // サーバ起動するやつ
├── domain
├── go.mod
├── go.sum
├── handler
│   └── router.go  // ルーティングの設定
├── infra
└── usecase
```

ブランチ `1` 上で `go run cmd/api/main.go` すると動作する状態にしてあります。

`http://localhost:3000` にアクセスしてもらえば、「Welcome!」と表示されるはずです。


---
# 書籍一覧を取得するAPIを作る（ブランチ：2）
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

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/06/go_web_api/dependency_domain.png" width="600">


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
ここでは一旦モックデータを返すようにしておきます。

<br>

先ほどと同様に 依存関係 を確認します。

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/06/go_web_api/dependency_infra.png" width="600">

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

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/06/go_web_api/dependency_usecase.png" width="600">

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

<br>

[参考にしている資料](https://www.slideshare.net/pospome/go-80591000) では、<br>
Usecase層 をさらに input と output で切っていますが、「複雑になりすぎるかな」と思い、省略しました。

<br>

## Handler 層

最後に Handler層 です。

<u>Handler層 の役目は、HTTPリクエストを受け取り、Usecase を使って処理を行い、結果を返す</u> ことです。

コード的には以下のようになります。

`/handler/book_handler.go`

```go
package handler

import (
	"encoding/json"
	"net/http"

	"github.com/julienschmidt/httprouter"
	"github.com/yyh-gl/go-api-server-by-ddd/domain/model"
	"github.com/yyh-gl/go-api-server-by-ddd/usecase"
)

func BookIndex(w http.ResponseWriter, _ *http.Request, _ httprouter.Params) {
	var books []*model.Book
	var err error
	books, err = usecase.BookUsecase{}.GetAll()
	if err != nil {
		// TODO: エラーハンドリングをきちんとする
		http.Error(w, "Internal Server Error", 500)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	if err = json.NewEncoder(w).Encode(books); err != nil {
		// TODO: エラーハンドリングをきちんとする
		http.Error(w, "Internal Server Error", 500)
		return
	}
}

```
<br>

依存関係は以下のとおりです。

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/06/go_web_api/dependency_handler.png" width="600">

Usecase を使用するので、Usecase層に依存しています。


---
# テスト
---

ここまでの実装で 書籍一覧 取得リクエスト を送れるようになりました。

`GET http://localhost:3000/books` してみましょう。

2つの書籍データが返ってくるはずです。

```json
[
    {
        "id": 1,
        "title": "Test1",
        "author": "Tester1",
        "issued_at": "2019-06-13T23:50:51.888139+09:00",
        "created_at": "2019-06-13T23:50:51.888139+09:00",
        "updated_at": "2019-06-13T23:50:51.888139+09:00"
    },
    {
        "id": 2,
        "title": "Test2",
        "author": "Tester2",
        "issued_at": "2019-06-13T23:50:51.888139+09:00",
        "created_at": "2019-06-13T23:50:51.88814+09:00",
        "updated_at": "2019-06-13T23:50:51.88814+09:00"
    }
]
```

<br>

まだ実装していないエンドポイントがあったり、DB 接続してなかったり、未完成なところが多いですが、<br>
DDD や レイヤアーキテクチャ が絡んできて、結構重い内容になってきたので <br>
一旦ここで切ろうと思います。後日、続編記事を出したいと思います。

---
# まとめ
---

[前々回の記事](https://yyh-gl.github.io/tech-blog/blog/go_project_template/) でディレクトリ構成を考え、<br>
今回ようやく実装してみました。

ディレクトリ構成が DDD を意識していることもあり、<br>
DDD や レイヤアーキテクチャ の話がメインっぽくなりましたが、<br>
DDD も勉強中だったので、僕的にはちょうど良い勉強になりました。

今後は、エヴァンス本で「どうドメインモデルに落とし込んでいくのか」ってところを勉強していこうと思います。
