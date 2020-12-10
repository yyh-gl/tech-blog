<!-- textlint-disable -->

+++
title = "The Go Programming Language Specificationで知った「こんなことできるだ」を紹介"
author = "yyh-gl"
categories = ["Go"]
tags = ["Tech"]
date = 2020-12-08T00:00:00+09:00
description = "Go 5 Advent Calendar 2020 8日目"
type = "post"
draft = false
[[images]]
  src = "img/tech-blog/2020/12/uncredible-codes-from-go-spec/featured.webp"
  alt = "featured"
  stretch = "stretchH"
+++

<!-- textlint-enable -->


本記事は『[Go 5 Advent Calendar 2020 8日目](https://qiita.com/advent-calendar/2020/go5)』の記事です。


# Go Language Specification輪読会

現在、[Go Language Specification輪読会](https://gospecreading.connpass.com/)という、
[Goの言語仕様](https://golang.org/ref/spec)を読んでいく会に参加しています。

今回は、そんな輪読会で「こんなことできるんだ」と驚いたコードを紹介します。<br>
（振り返ると結構たくさんあったので、今回はその中から5個選んで紹介します）

**ちなみに、だいたいのコードは現場で使うと怒られそうです😇** <br>
（いや、まず間違いなく怒られる）


# 1. Comments

```go
package main

import (
  "fmt"
)

func main() {
  var/*comment*/a = 1
  fmt.Println(a)
}
```
https://play.golang.org/p/9Dun0LiT5N5

まずはこちら。<br>
変な位置にコメントが挿入されています。<br>
コメント部分を消すと`vara = 1`となるのでエラーになりそうです。

しかし、実行してみると、すんなりと変数`a`を表示してくれます。

## 解説

[Spec](https://golang.org/ref/spec#Comments)を参照すると以下の一文があります。

> A general comment containing no newlines acts like a space.
> 
> 改行を含まないgeneral commentはスペースのように作用する。

（general commentとは`/**/`で囲われたコメントのことを指します）

よって、先程のコードは以下と同じということです。

```go
package main

import (
  "fmt"
)

func main() {
  var a = 1
  fmt.Println(a)
}
```

こうして変換してみると、エラーでないことは明白ですね。

ちなみに、「改行を含まない」ことが条件なので、以下のコードはエラーとなります。

```go
package main

import (
  "fmt"
)

func main() {
  var a/*comment*/= 1 // こっちはOKだけど
  var b/*com
  ment*/= 1 // こっちはNG
  fmt.Println(a)
  fmt.Println(b)
}
```
https://play.golang.org/p/_IFGaJ4VK4w


# 2. Identifiers

続いてはこちらです。

```go
package main

import "fmt"

func main() {
	false := true
	if false {
		fmt.Println("false is true")
	}
}
```
https://play.golang.org/p/kzf4fwRxyAJ

これはGoクイズでもよく出てくるので、ご存じの方も多いかと思います。

## 解説

ここで重要になってくる単語として以下の2つがあります。

- Identifier
- Keyword

Identifierについて、[Spec](https://golang.org/ref/spec#Identifiers)を参照すると、

> Identifiers name program entities such as variables and types.
>
> 識別子は、変数や型などのプログラムエンティティの名前を付けます。

とあります。<br>
Identifierは、ただ単に名前を付けるためのものなんですね。

加えて、以下の一文から、事前に宣言されているIdentifierがあると分かります。

> Some identifiers are predeclared.
> 
> いくつかの識別子は事前に宣言されています。

今回取り上げた`false`はこの事前宣言されたIdentifierに該当します。<br>
（事前宣言されているIdentifier一覧は[こちら](https://golang.org/ref/spec#Predeclared_identifiers)）

<br>

次に、Keywordについて見ていきます。

[Spec](https://golang.org/ref/spec#Keywords)を参照すると、

> The following keywords are reserved and may not be used as identifiers.
> 
> 以下のキーワードは予約されており、識別子として使用することはできません。

とあります。<br>
よって、下記のとおり`default`をIdentifierとして使用できません。<br>
（`default`はKeywordです）

```go
package main

import "fmt"

func main() {
	default := true
	fmt.Println(default)
}
```
https://play.golang.org/p/Cxuolg_b7Xx

<br>

`false`の話に戻しますが、`false`はIdentifierであり、Keywordではありません。<br>
したがって、最初に示したコードのとおり、別の対象に対して`false`と名付けることが可能です。


# 3. Slice types

次はSlice関連です。

```go
package main

import "fmt"

func main() {
	a := [5]int{0, 1, 2, 3, 4}
	b := a[1:3]
	fmt.Println(b)
	fmt.Println(b[0:4])
}
```
https://play.golang.org/p/inbRV8SWfNO

一度実行してみてください。<br>
`fmt.Println(b[0:4])`の出力結果に違和感がないでしょうか。

`b`＝`a[1:3]`＝`{1, 2}`のはずです。<br>
実際、`fmt.Println(b)`の出力結果はそうなっています。<br>
よって、`b[0:4]`は取れないはずです。

しかし、実行してみると`b[0:4]`が取れています。

## 解説

[Spec](https://golang.org/ref/spec#Slice_types)を見ると、

> A slice is a descriptor for a contiguous segment of an underlying array and provides access to a numbered sequence of elements from that array.
> 
> スライスは、underlying arrayの連続したセグメントの記述子であり、そのunderlying arrayの要素の番号付きシーケンスへのアクセスを提供します。

とあります。

つまり、Sliceの後ろにはArrayがいて、SliceはそのArrayに対してよしなにアクセスすることで、<br>
あたかもSliceであるかのように見せています。

よって、

```go
b := a[1:3]
```

こうしたときに`b`の後ろには`[5]int{0, 1, 2, 3, 4}`がいることになります。

実際にアクセスできるのは`{1, 2, 3, 4}`だけなので、<br>
厳密には背後に`{1, 2, 3, 4}`という要素を持った配列がいるように思えるでしょう。

ここまでくると、最初のコードで`b[0:4]`の範囲にアクセスできたのも納得ですね。


# 4. Method declarations

続いてはこちらです。

```go
package main

type S int

func(S) _() {}
func(S) _() {}

func _() {}
func _() {}

func main() {}
```
https://play.golang.org/p/sHq9NZvlPsL

同じ関数名が乱立しています。

もうなんとなく察してる方もおられると思いますが、<br>
これはブランク（`_`）が使用されているために成り立っています。

## 解説

[Spec](https://golang.org/ref/spec#Method_declarations)に以下の一文があります。

> For a base type, the non-blank names of methods bound to it must be unique.
> 
> Base typeにバインドされているブランクではないメソッド名は一意である必要があります。

言い換えると、関数名がブランクである場合は、ユニークでなくても良いということになります。


# 5. Composite literals

最後はこちらです。

```go
package main

import "fmt"

var arr = [3]int{2: 2}
var slice = []int{3: 3}

func main() {
	fmt.Println(arr)
	fmt.Println(slice)
}
```
https://play.golang.org/p/7vfUjbDEeCZ

5, 6行目の中括弧の中を見ると、一瞬、mapかなと思った人がいるかもしれません。<br>
しかし、これはArrayとSliceの初期化です。

## 解説

ArrayとSliceでもキー（インデックス）指定で初期化できます。

[Spec](https://golang.org/ref/spec#Composite_literals)には、
ArrayとSliceに対して以下の一文が記載されています。

> An element with a key uses the key as its index. The key must be a non-negative constant representable by a value of type int; and if it is typed it must be of integer type.
> 
> キーを持つ要素は、そのキーをインデックスとして使用します。キーは int 型の値で表すことができる非負の定数でなければならず、型付けされている場合は整数型でなければなりません。

まぁ、あまり見ることはないコードでしょう🙈


# まとめ

Goの言語仕様をちゃんと勉強し始めたことで、<br>
**こういう仕様だから、こうやって処理されていたのか**というのが理解できてきました。

個人的には、ここを理解してくると、<br>
なぜCompilerやLinterが怒っていたのかが分かるようになってきて、<br>
言語仕様を読むのがさらにおもしろくなりました。

<br>

今回の内容は、個人的に「おおお、、、」っとなったものを中心に取り上げたのですが、<br>
実務では使えないであろうコードばかりになってしまいました😇

しかし、実際に役に立つ発見も多くあるので、ぜひ一緒に言語仕様を読み進められればなと思っています！

<br>

▶▶▶ [Go Language Specification輪読会](https://gospecreading.connpass.com/)


# 明日は、、、

[Go 5 Advent Calendar 2020](https://qiita.com/advent-calendar/2020/go5)の明日の枠はまだ空いていますね〜🎅
