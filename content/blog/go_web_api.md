+++
author = "yyh-gl"
categories = ["Golang", "Web API", "アーキテクチャ", "DDD"]
date = "2019-06-14"
description = "2019/10/30 に内容を一部更新しました"
featured = "go_web_api/featured.png"
featuredalt = "画像がどこかへ逝ってしまったようだ…"
featuredpath = "date"
linktitle = ""
title = "【Golang + レイヤードアーキテクチャ】DDD を意識して Web API を実装してみる"
type = "post"

+++

<br>

---
# 更新（2019年10月30日）
---

初回投稿から3ヶ月経ちました。<br>
この3ヶ月で新しく得た知見を基に、内容を一部アップデートしました。

<br>

---
# 今回やること
---

[過去記事](http://localhost:1313/tech-blog/blog/go_project_template/)で Golang のディレクトリ構成についていろいろ調べた結果、<br>
[こちらの資料](https://www.slideshare.net/pospome/go-80591000) がとても分かりやすかったので、<br>
今回はこちらを参考に Golang で Web API を作っていきたいと思います。

<br>

加えて、本プロジェクトでは、DDD と レイヤードアーキテクチャ を取り入れます。<br>
（内容はほぼレイヤードアーキテクチャになってしまいましたが…）

DDD については、「DDD を Golang とレイヤードアーキテクチャでやるなら、こんな感じかな？」という個人の見解レベルです。<br>
パッケージ構成の参考になれば幸いです。<br>
（ですので、ドメインモデルは重度のドメイン貧血症に陥っていますｗ）

釣りタイトルみたいになっちゃっててすみません🧝‍♀️

<br>

## 環境

- MacOS Mojave 10.14.6
- Golang 1.12.5

なお、今回は、Gin や Mux などといったフレームワークは使わず、<br>
httprouter のみで薄く作っていこうと思います。

Mux を使った実装は [僕の前のブログで紹介している](https://yyh-gl.hatenablog.com/entry/2019/02/08/195310) のでよければどうぞ。

<br>
・

・

・

では、早速本題に入っていきましょう。

---
# 採用アーキテクチャ：レイヤードアーキテクチャ
---

[参考記事内](https://www.slideshare.net/pospome/go-80591000) で紹介されているのは <u>レイヤードアーキテクチャ</u> をベースに <br>
いろいろカスタマイズされたものらしいです。

クリーンアーキテクチャに似たアーキテクチャだとか。

---

ユースケース層という呼び方はクリーンアーキテクチャ由来ですね。

DDD の文脈だと アプリケーション層 と呼ばれますが、<br>
アプリケーションって意味が広くて分かりづらいので、<br>
本プロジェクトでは ユースケース という単語を使用します。

---

とりあえず、今回はスライドページ19で紹介されているディレクトリ構成に従って、 <br>
<u>DDD を意識して</u> Web API を実装していこうと思います。

（意識だけして、実践できずに終わりましたが😇）

<br>

レイヤードアーキテクチャ における各層の依存関係 について説明します。

依存関係の図は下記のとおりです。

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/06/go_web_api/architecture.png" width="600">

矢印は依存の方向を示しています。<br>
例えば、上図だと Handler層 は UseCase層 の処理を利用することを意味します。

<br>

一般的なレイヤードアーキテクチャだと、上から下に一方向に依存します。<br>
しかし、今回は、Infra層が Domain層に依存しています。<br>
このあたりがクリーンアーキテクチャに似ています。

さきほどの図を視点を変えて見てみます。（下記の図）<br>
今回採用したアーキテクチャ は、クリーンアーキテクチャ と同様に、<br>
依存が中心方向に <u>のみ</u> 存在することがわかります。

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/06/go_web_api/dependency_direction1.png" width="600">

<u>すべての依存が中心に向かっているこの状態が理想です</u>。

（Handler層と Infra層が一緒の層みたいになっていますが、全くの別物です。うまく分離して描けず、こうなりました。ご注意を）


---

依存関係について、もう少し述べておくと、<br>
基本的に依存はひとつ下の層までに抑えておくべきのようです。

ただし、簡略化のために2つ下の層まで依存している例もあるので、<br>
そこはチームとして同意が取れていれば良いのではないでしょうか。

---

<br>

ここで、ユーザから APIリクエスト があった場合を考えてみます。

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/06/go_web_api/dependency_direction2.png" width="600">


ユーザからのリクエストは Handler で受け取られ、 UseCase を使って処理が行われます。<br>
さらに、UseCase は Domain を使って処理を行います。<br>
ここまでは処理が中心に進んでいる、つまり依存は中心に向かって発生しています。

しかし、たいていのサービスって DB を使用しますよね。<br>
つまり、ユースケースからドメインを介して、Infra を利用することになります。

UseCase → Domain → Infra

…依存が外側を向いてしまいました。<br>
これは許されていません。ではどうするか。

<u>[依存性逆転の法則](https://medium.com/eureka-engineering/go-dependency-inversion-principle-8ffaf7854a55)</u> を使います。

<br>

<u>依存性逆転の法則 とは、 interfaceを利用して、依存の方向を逆にすること</u> です。

もう少し詳しく説明します。<br>
まず、 ① Domain層 において、 DB とのやりとりを interface で定義しておきます。<br>
interface （後ほどコード内にて BookRepository として出てきます） 自体は実装を持たないので、<br>
どこにも依存していません。

次に、 ② Infra層 から Domain層 に定義した interface （後ほどコード内にて BookPersistence として出てきます） を実装します。

<br>

①, ② の2ステップを踏むことで、まず Domain は interface に対して 処理をお願いするだけでよくなります。
先ほども言ったとおり interface は 実装を持たないので依存関係はありません。

interface 自体は実装を持ちませんが、<br>
Infra が interface の実装を行っているので、ちゃんとDBアクセスして処理を行うことができます。

ここで、 Infra は interface を実装しているので、依存が interface 、すなわち Domain に向いています。 

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/06/go_web_api/dependency_direction3.png" width="600">

依存性が逆転し、すべての依存関係が中心に向かうようになりましたね。

<br>

ここはとっつきづらいところなので、まだいまいち理解できないかもしれません。

以降、実際のコードを紹介していくので、コードに落とし込みながら考えてみてください。

---
# 完成物
---

完成物に関しては [こちら](https://github.com/yyh-gl/go-api-server-by-ddd) に置いておきます。

<br>

## API 一覧

書籍管理システム の API を想定

- 書籍一覧 取得
- 書籍詳細 取得
- 書籍 追加
- 書籍 貸出
- 書籍 返却

<br>

ディレクトリ構成はこんな感じです。

```tree
api-server-with-go-kit-and-ddd
├── cmd
│   └── api
│       └── main.go  // サーバ起動したり、依存注入、ルーティングを行う
├── domain
│   └── blog.go
├── go.mod
├── go.sum
├── handler
│   └── rest // RESTful API 用のハンドラー
│       └── blog.go
├── infra
│   └── blog.go
└── usecase
    └── blog.go
```


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

// Book : Book を表すドメインモデル
// !! 重度のドメイン貧血症です !!
type Book struct {
	Id       int64
	Title    string
	Author   string
	IssuedAt time.Time
}
```

冒頭でも述べたとおり、みごとなドメイン貧血症っぷりです。

ちゃんと 値オブジェクトを使ったりして、ごりごり DDD していきたいですが、今回は…省きます🙇‍♂️

<br>

次に、`/domain/repository/book.go` を作っていきます。
 
今回、 <u>リポジトリでやることを簡単に言うと、 DB や KVS などで行う CRUD処理 の定義です。</u><br>
ただし、<u>Domain層には技術的関心事を持ち込まない</u> というルールがあるため、<br>
ここでは interface を定義するだけです。

実装は、後述する infra で行います。<br>
（<u>Infra層 は技術的関心事を扱う層です</u>）

リポジトリについてちゃんと知りたい方は、<br>
[こちら](https://blog.fukuchiharuki.me/entry/use-repository-and-dao-according-to-the-purpose)が参考になると思います。

<br>

`/domain/repository/book.go`

```go
package repository

import (
	"context"

	"github.com/yyh-gl/go-api-server-by-ddd/domain/model"
)

// BookRepository : Book における Repository のインターフェース
//  -> 依存性逆転の法則により infra 層は domain 層（本インターフェース）に依存
type BookRepository interface {
	GetAll(context.Context) ([]*model.Book, error)
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

さきほど述べたとおり、<u>Infra層 は技術的関心事を扱う層です。</u>

ここでさっき定義した repository の処理を実装します。

`/infra/persistence/book.go`

```go
package persistence

// repository という名前にしたいが domain 配下の repository とパッケージ名が被ってしまうため persistence で代替

import (
	"context"
	"time"

	"github.com/yyh-gl/go-api-server-by-ddd/domain/model"
	"github.com/yyh-gl/go-api-server-by-ddd/domain/repository"
)

type bookPersistence struct{}

// NewBookPersistence : Book データに関する Persistence を生成
func NewBookPersistence() repository.BookRepository {
	return &bookPersistence{}
}

// GetAll : DB から Book データを全件取得（BookRepository インターフェースの GetAll() を実装したもの）
//  -> 本来は DB からデータを取得するが、簡略化のために省略（モックデータを返却）
func (bp bookPersistence) GetAll(context.Context) ([]*model.Book, error) {
	book1 := model.Book{}
	book1.Id = 1
	book1.Title = "DDDが分かる本"
	book1.Author = "たろうくん"
	book1.IssuedAt = time.Now().Add(-24 * time.Hour)

	book2 := model.Book{}
	book2.Id = 2
	book2.Title = "レイヤードアーキテクチャが分かる本"
	book2.Author = "はなこさん"
	book2.IssuedAt = time.Now().Add(-24 * 7 * time.Hour)

	return []*model.Book{&book1, &book2}, nil
}
```

なお、 実際には DB にアクセスし、データを持ってくるようにします。<br>
ここでは一旦モックデータを返すようにしておきます。

また、Persistence という単語がいきなり出てきましたが、これは Repository と同義です。<br>
実際に `NewBookPersistence()` の中身を見ると Repository のインターフェースを返していると思います。<br>
（`NewBookPersistence()`の詳細は後述）

本当は Repositoryという名前を使いたかったのですが、<br>
Domain層と Infra層 でパッケージ名が被ってしまうため、やむなくこうしています。

<br>

先ほどと同様に 依存関係 を確認します。

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/06/go_web_api/dependency_infra.png" width="600">

Infra層 は Domain層 で作った `/domain/repository/book.go` のインターフェース（BookRepository）を実装しています。<br>

<br>

ここで、Golang に慣れていない方は、どこでインターフェースと関連づけてるの？<br>
という疑問が生まれると思います。

答えは、 `NewBookPersistence()` です。<br>
この関数の戻り値は インターフェース です。<br>
したがって、17行目でreturnする bookPersistence がインターフェースを満たしていないとエラーとなります。<br>
このようにして インターフェースを満たしているか否かを判別します。

`NewBookPersistence()` をどこで使うかは後述します。

<br>

では、依存関係を見ていきます。<br>
上述したとおり、Infra層 は Domain層 のインターフェースを満たすように作られているので、Domain層に依存しています。<br>
Golang には implements とかないので分かりづらいですね。<br>
でも、確かに依存しています。


<br>

## UseCase 層

<u>UseCase層 では、システムのユースケースを満たす処理の流れを実装します。</u>

今回は単純な処理しかしないので、この層の存在価値が少し分かりづらくなってしまいます。

複雑なビジネスロジックがあるときは、この層の存在が効いてくると思います。

<br>

コードは以下のとおりです。

`/usecase/book.go`

```go
package usecase

import (
	"context"

	"github.com/yyh-gl/go-api-server-by-ddd/domain/model"
	"github.com/yyh-gl/go-api-server-by-ddd/domain/repository"
)

// BookUseCase : Book における UseCase のインターフェース
type BookUseCase interface {
	GetAll(context.Context) ([]*model.Book, error)
}

type bookUseCase struct {
	bookRepository repository.BookRepository
}

// NewBookUseCase : Book データに関する UseCase を生成
func NewBookUseCase(br repository.BookRepository) BookUseCase {
	return &bookUseCase{
		bookRepository: br,
	}
}

// GetAll : Book データを全件取得するためのユースケース
//  -> 本システムではあまりユースケース層の恩恵を受けれないが、もう少し大きなシステムになってくると、
//    「ドメインモデルの調節者」としての役割が見えてくる
func (bu bookUseCase) GetAll(ctx context.Context) (books []*model.Book, err error) {
	// Persistence（Repository）を呼出
	books, err = bu.bookRepository.GetAll(ctx)
	if err != nil {
		return nil, err
	}
	return books, nil
}
```

<br>

UseCase層 の依存関係も見てみましょう。

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/06/go_web_api/dependency_usecase.png" width="600">

UseCase層 は `/domain/repository` を呼び出しています。<br>
したがって、 UseCase層 は Domain層 に依存しています。

<br>

[参考にしている資料](https://www.slideshare.net/pospome/go-80591000) では、<br>
UseCase層 をさらに input と output で切っていますが、複雑になりすぎると思い、省略しました。

<br>

## Handler 層

次に Handler層 です。

<u>本プロジェクトにおける、Handler層 の役目は、HTTPリクエストを受け取り、UseCase を使って処理を行い、結果を返す</u> ことです。

ただし、本来の Handler層は HTTPリクエストに限った話ではありません。

外部にあるものがなんであれ、その差異を吸収して、ユースケースに伝えるのが役目です。

したがって、本プロジェクトでは `/handler/rest` というふうにディレクトリを切っています。<br>
（RESTful API であることを明確にしてみました）<br>
CLIを追加するなら `/handler/cli` というふうにディレクトリを切るのが良さそう。

<br>

本プロジェクトのコード的には以下のようになります。

`/handler/blog.go`

```go
package rest

// Handler 層を変えるだけで、例えば CLI にも簡単に対応可能

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/julienschmidt/httprouter"
	"github.com/yyh-gl/go-api-server-by-ddd/usecase"
)

// BookHandler : Book における Handler のインターフェース
type BookHandler interface {
	Index(http.ResponseWriter, *http.Request, httprouter.Params)
}

type bookHandler struct {
	bookUseCase usecase.BookUseCase
}

// NewBookUseCase : Book データに関する Handler を生成
func NewBookHandler(bu usecase.BookUseCase) BookHandler {
	return &bookHandler{
		bookUseCase: bu,
	}
}

// BookIndex : GET /books -> Book データ一覧を返す
func (bh bookHandler) Index(w http.ResponseWriter, r *http.Request, pr httprouter.Params) {
	// request : 本 API のリクエストパラメータ
	//  -> こんな感じでリクエストも受け取れますが、今回は使いません
	type request struct {
		Begin uint `query:"begin"`
		Limit uint `query:"limit"`
	}

	// bookField : response 内で使用する Book を表す構造体
	//  -> ドメインモデルの Book に HTTP の関心事である JSON タグを付与したくないために Handler 層で用意
	//     簡略化のために JSON タグを付与したドメインモデルを流用するプロジェクトもしばしば見かける
	type bookField struct {
		Id       int64     `json:"id"`
		Title    string    `json:"title"`
		Author   string    `json:"author"`
		IssuedAt time.Time `json:"issued_at"`
	}

	// response : 本 API のレスポンス
	type response struct {
		Books []bookField `json:"books"`
	}

	ctx := r.Context()

	// ユースケースの呼出
	books, err := bh.bookUseCase.GetAll(ctx)
	if err != nil {
		// TODO: エラーハンドリングをきちんとする
		http.Error(w, "Internal Server Error", 500)
		return
	}

	// 取得したドメインモデルを response に変換
	res := new(response)
	for _, book := range books {
		var bf bookField
		bf = bookField(*book)
		res.Books = append(res.Books, bf)
	}

	// クライアントにレスポンスを返却
	w.Header().Set("Content-Type", "application/json")
	if err = json.NewEncoder(w).Encode(res); err != nil {
		// TODO: エラーハンドリングをきちんとする
		http.Error(w, "Internal Server Error", 500)
		return
	}
}
```
<br>

依存関係は以下のとおりです。

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/06/go_web_api/dependency_handler.png" width="600">

57行目で UseCase を使用するので、UseCase層に依存しています。


<br>

## main.go

ここまでで、書籍に関する Handler, UseCase, Repository が用意できました。<br>
最後にこれらの用意したものを `main.go` にて依存関係を注入してやることで、利用可能な状態にします。<br>
（注入とか言ってますが DI とかやってません🙏）

このとき利用するのが、各層に用意されている `NewXxx()` という関数です。

`NewXxx()` で生成した Handler や UseCase, Repository を使って、必要なメソッドを実行できるようにします。

`/cmd/api/main.go`

```go
package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/julienschmidt/httprouter"
	handler "github.com/yyh-gl/go-api-server-by-ddd/handler/rest"
	"github.com/yyh-gl/go-api-server-by-ddd/infra/persistence"
	"github.com/yyh-gl/go-api-server-by-ddd/usecase"
)

func main() {
	// 依存関係を注入（DI まではいきませんが一応注入っぽいことをしてる）
	// DI ライブラリを使えば、もっとスマートになるはず
	bookPersistence := persistence.NewBookPersistence()
	bookUseCase := usecase.NewBookUseCase(bookPersistence)
	bookHandler := handler.NewBookHandler(bookUseCase)

	// ルーティングの設定
	router := httprouter.New()
	router.GET("/api/v1/books", bookHandler.Index)

	// サーバ起動
	fmt.Println("========================")
	fmt.Println("Server Start >> http://localhost:3000")
	fmt.Println("========================")
	log.Fatal(http.ListenAndServe(":3000", router))
}
```

注目していただきたのが、17行目から19行目の処理です。<br>
ここで、各層の `NewXxx()` の処理を使って依存関係を定義しています。

DI ライブラリを使うことで、よりスマートに書けると思いますが、<br>
愚直にやるならこんな感じです。


---
# テスト
---

ここまでの実装で 書籍一覧 取得リクエスト を送れるようになりました。

```bash
$ go run cmd/api/main.go
$ curl -X GET  http://localhost:3000/api/v1/books
```

上記コマンドを実行すると、<br>
2つの書籍データが返ってくるはずです。

```json
{
  "books": [
    {
      "id": 1,
      "title": "DDDが分かる本",
      "author": "たろうくん",
      "issued_at": "2019-10-29T02:22:09.264835+09:00"
    },
    {
      "id": 2,
      "title": "レイヤードアーキテクチャが分かる本",
      "author": "はなこさん",
      "issued_at": "2019-10-23T02:22:09.264841+09:00"
    }
  ]
}
```

<br>

エンドポイントが一個しかなかったり、DB 接続してなかったりと、未完成なところが多いですが、<br>
DDD や レイヤードアーキテクチャ が絡んできて、結構重い内容になってきたので、一旦ここで切ろうと思います。<br>
後日、続編記事を出したいと思います。

---
# まとめ
---

[前々回の記事](https://yyh-gl.github.io/tech-blog/blog/go_project_template/) でディレクトリ構成を考え、
今回ようやく実装してみました。

ディレクトリ構成が DDD を意識していることもあり、<br>
DDD や レイヤードアーキテクチャ の話がメインっぽくなりましたが、<br>
DDD も勉強中だったので、僕的にはちょうど良い勉強になりました。

今後は、エヴァンス本で「どうドメインモデルに落とし込んでいくのか」ってところを勉強していこうと思います。
