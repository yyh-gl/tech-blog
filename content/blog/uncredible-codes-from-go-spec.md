<!-- textlint-disable -->
+++
title = "The Go Programming Language Specificationで知った「こんなことできるだ」を紹介"
author = ["yyh-gl"]
categories = ["Go"]
tags = ["Tech"]
date = 2020-12-06T20:43:42+09:00
description = "Go 5 Advent Calendar 2020 13日目"
type = "post"
draft = true
[[images]]
  src = "img/tech-blog/2020/12/uncredible-codes-from-go-spec/featured.webp"
  alt = "featured"
  stretch = "stretchH"
+++
<!-- textlint-enable -->

本記事は『[Go 5 Advent Calendar 2020 13日目](https://qiita.com/advent-calendar/2020/go5)』の記事です。


# Go Language Specification輪読会

現在、[Go Language Specification輪読会](https://gospecreading.connpass.com/)という、<br>
Goの言語仕様を読んでいく会に参加しています。

今回は、そんな輪読会で知った「こんなことできるんだ！？」となったコードを解説付きで紹介していきます。<br>
（挙げだすときりがないので、5個ほど選んで紹介します）

**ちなみに、現場では使えないコードです😇**


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
> 改行を含まない一般的なコメントはスペースのように作用する。

（一般的なコメントとは`/**/`で囲われたコメントのことを指します）

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
すなわち、名前を付けているだけです。

加えて、以下の一文から、事前に宣言されているIdentifierがあることも分かります。

> Some identifiers are predeclared.
> 
> いくつかの識別子は事前に宣言されています。

今回取り上げた`false`はこの事前宣言されたIdentifierです。<br>
（事前宣言されているIdentifier一覧は[こちら](https://golang.org/ref/spec#Predeclared_identifiers)）

事前に宣言されているだけで、以下のコードの`hoge`となんら変わりはありません。

```go
package main

import "fmt"

func main() {
	hoge := true
	if hoge {
		fmt.Println("false is true")
	}
}
```

次に、Keywordについて見ていきます。

[Spec](https://golang.org/ref/spec#Keywords)を参照すると、

> The following keywords are reserved and may not be used as identifiers.
> 
> 以下のキーワードは予約されており、識別子として使用することはできません。

とあります。<br>
よって、下記のとおり変更できません。

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

では、`false`の話に戻しますが、先述のとおり、`false`はIdentifierです。<br>
したがって、開発者は自由に変更できるため、最初に示したコードが成り立つわけです。


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

上記のコードですが、`fmt.Println(b[0:4])`の出力結果に違和感がないでしょうか。

`b`は`a[1:3]`＝`{1, 2}`のはずです。<br>
実際、`fmt.Println(b)`の表示はそうなっています。<br>
よって、`b[0:4]`は取れないはずです。

しかし、実行してみると`b[0:4]`が取れています。

## 解説

[Spec](https://golang.org/ref/spec#Slice_types)を見ると、

> A slice is a descriptor for a contiguous segment of an underlying array and provides access to a numbered sequence of elements from that array.
> 
> スライスは、基底となる配列の連続したセグメントの記述子であり、その配列の要素の番号付きシーケンスへのアクセスを提供します。

とあります。

つまり、Sliceの後ろにはArrayがいて、SliceはそのArrayに対してよしなにアクセスすることで、<br>
あたかもSliceであるかのように見せています。

よって、

```go
b := a[1:3]
```

こうしたときに`b`の後ろには`[5]int{0, 1, 2, 3, 4}`がいることになります。<br>
（ただし、実際にアクセスできるのは`{1, 2, 3, 4}`のみ）

したがって、`b[0:4]`の範囲にもアクセスできたというわけです。


## 4. Method declarations

https://play.golang.org/p/RqPf_QBoETy

https://play.golang.org/p/BTWgu0DwLiG

## 5. Composite literals

https://play.golang.org/p/ln0GCYwQZ5g



https://golang.org/ref/spec#Keywords

https://docs.google.com/document/d/1RfZkLngAu9NmZcl9wBjzktXDQZjJAYFloIvuKWGIljk/edit#
