+++
author = "yyh-gl"
categories = ["Go", "DDD"]
tags = ["Tech"]
date = 2020-05-08T09:00:00+09:00
description = "こんな感じでやってます"
title = "【Go+DDD】エンティティと値オブジェクトの実装方法（自己流）"
type = "post"
draft = false
[[images]]
  src = "img/tech-blog/2020/05/go-ddd-entity-vo/featured.webp"
  alt = "featured"
  stretch = "stretchH"
+++


# GoでDDD
今担当しているプロジェクトでは、GoでAPIを作っています。<br>
このプロジェクトでは、DDDの考え方や設計パターンも取り入れています。

今回はDDDの設計パターンの中でもEntityとValue Object（VO）について、<br>
僕がGoでどうやって実装しているのか紹介していきます。

# 実装例
兎にも角にも、まずはコードを示します。

```go
// animal/dog/dog.go

package dog

type Dog struct {
	name Name
}

func New(name string) (*Dog, error) {
	n, err := newName(name)
	if err != nil {
		return nil, err
	}

	return &Dog{
		name: *n,
	}, nil
}
```

```go
// animal/dog/name.go

package dog

import (
	"errors"
	"unicode/utf8"
)

type Name string

func newName(v string) (*Name, error) {
	// 名前は3文字以上というビジネスロジック
	if utf8.RuneCountInString(v) < 3 {
		return nil, errors.New("名前は3文字以上！")
	}
	n := Name(v)
	return &n, nil
}
```

```go
// main.go

package main

import (
	"fmt"
	"playground/animal/dog"
)

func main() {
	// d := dog.Dog{name: "犬太郎"} できない
	d, _ := dog.New("犬太郎") // できる
	fmt.Printf("%+v\n", d)
	
	d, err := dog.New("犬")
	if err != nil {
		fmt.Println(err) // 犬の名前が「犬」は可愛そうだからできない()
	}
}
```
[playground](https://play.golang.org/p/cmNp5MlCNuc)

<br>

今回の例では、`Dog`というstructがEntityで、`Name`がVOです。

Dogのnameは必ず3文字以上にするというビジネスロジックがあります。

### ポイント1

EntityとVOでファイルを分けています。<br>
また、両者は同じディレクトリ内に置いています。

どれがEntityでどれがVOか分かりづらいと思われる方もおられるかもしれませんが、<br>
個人的には言うほど分かりづらくありません。

なぜかと言うと、EntityとVOが入っているディレクトリ（パッケージ）名と、<br>
Entityのファイル名が一致するからです。

今回の例で言えば、<br>
Dog Entityは`/animal/dog`ディレクトリ配下の`dog.go`の中にあります。<br>
ディレクトリ名とEntityのファイル名が一致しています。<br>
このルールが分かっていれば、特に問題はありません。

加えて、EntityとVOは同一のパッケージ内にあるべきだと考えています。

### ポイント2

Dog Entityのnameフィールドを小文字にすることで、<br>
`New()`（コンストラクタ的なの）を使用しないと、<br>
nameの値をセットできないようにしています。<br>
（`dog.Dog{name: "hoge"}` はできない）

また、`New()`を経由することで、<u>必ず`newName()`が使われる</u> ため、<br>
Dogのnameは <b>3文字以上にするというビジネスロジックを確実に守ることができます。</b><br>

<br>

社内の方に「`dog.Dog{}` はできちゃうね」とコメントをいただきました。<br>
この件については、（願望的なところも入ってきてしまうのですが）<br>
不用意なsetterを用意していなければ、<br>
「あれ？フィールドに値セットできない！」ってなるはずなので、<br>
そこで気づいてもらえると思っています。。。<br>
（さすがに初期化しただけの構造体を保存するようなことはないと信じてます）

### ポイント3

VO自体はexportします。<br>
VO（型）を引数として指定することもあるのでこうしています。

exportしちゃうと、`dog.Name("ねこ太郎")`とすることで、<br>
不正なnameを作れるのでは？と考える方もおられると思います。

たしかに作れます。<br>
しかしながら、保存はEntity単位で行うため、<br>
不正なnameがEntityにセットできないようになっていれば無問題であると考えています。

### ポイント4

VO→基本型への変換が必要になることは、往々にしてあると思います。

このとき必要になる、基本型への変換処理はVO自身に持たせています。<br>
（ここは特に議論の余地があると思っています）

以下のサンプルをご覧ください。

```go
// animal/dog/dog.go

package dog

type Dog struct {
	name Name
}

func New(name string) (*Dog, error) {
	n, err := newName(name)
	if err != nil {
		return nil, err
	}

	return &Dog{
		name: *n,
	}, nil
}

func (d Dog) Name() *Name {
	return &d.name
}
```

```go
// animal/dog/name.go

package dog

import (
	"errors"
	"unicode/utf8"
)

type Name string

func newName(v string) (*Name, error) {
	// 名前は3文字以上というビジネスロジック
	if utf8.RuneCountInString(v) < 3 {
		return nil, errors.New("名前は3文字以上！")
	}
	n := Name(v)
	return &n, nil
}

func (n Name) String() string {
	return string(n)
}
```

```go
// main.go

package main

import (
	"fmt"
	"playground/animal/dog"
)

func main() {
	d, _ := dog.New("犬太郎")
	fmt.Println(d.Name().String())
}
```

[playground](https://play.golang.org/p/PTOelACOUAv)

<br>

まず、Dog Entityに（不本意ながら）nameのgetter（`Name()`）を追加しました。<br>
次に、Name VOに`String()`メソッドをもたせました。

そして、呼び出し元では `d.Name().String()` とすることで、<br>
基本型（string）としてのnameを取得できます。

<br>

Dog Entityにnameのgetterを用意したことについて、<br>
DTOへの変換やレイヤ間で値を受け渡すときなどに、<br>
構造体の詰め替えが発生すると思います。<br>
このときに、Goの場合どっちみちgetterが必要になることでしょう。<br>
よって、どうせ必要になることが分かっているので用意した形になります。

<br>

ただし、このgetterは、<br>
値の詰め替えや基本型取得といった、複雑なロジックを持たない処理にのみ使用し、<br>
不用意な使い方はしないことを <br>
運用（PRレビュー）で100%カバーすること前提で許可しています。<br>


・・・<br>
確実にできないようにした方がいいんでしょうね。。。<br>
賛否両論ありますよね、、、わかります

<br>

他の方法として、Dog Entityの`Name()`を以下のようにもできます。

```go
func (d Dog) Name() string {
	return string(d.name)
}
```

ただし、ある関数の引数として、NameというVO（型）のまま渡したい場合、<br>
この方法では対応できません。<br>

<br>

引数で渡す用の値（VOのまま）を取得する処理と <br>
基本型としての値を取得する処理を別関数として用意するのが一番いいのかなと思っています。

…が、今のところ、VOにString()メソッドを持たせる方式で特に困ったことがないため、<br>
このまま進めています。


# おわりに
ざっとポイントを洗い出してみましたが、<br>
実装方法を考えていた時期とブログを書いている時期がずれているため、<br>
書き忘れているポイントがあるかもしれません。<br>
なにか思い出したタイミングで追記していきます。

<br>

最後にお願いです！

Go+DDDの事例は他の言語に比べるとまだまだ少ないと思います。<br>
よって、僕も日々、試行錯誤し、より良い実装方法を探しています。<br>
今回紹介した実装方法には、まだまだ抜けもあれば、より良い実装方法もあると考えています。

なので、みなさん、ぜひコメントください！<br>
→ [Twitter](https://twitter.com/yyh_gl)

よろしくお願いします〜

