+++
author = "yyh-gl"
categories = ["Golang"]
date = "2020-03-10"
description = "errorに関するちょっとしたメモ"
featured = "error_questions/featured.png"
featuredalt = "画像がどこかへ逝ってしまったようだ…"
featuredpath = "date"
linktitle = ""
title = "【Golang】errorの同値性と表示について調べた"
type = "post"

+++


<br>

---
# errorについて疑問があった
---

Goのコードを書いてて、ふと気になったことがあったので調べてみました。

<br>

---
# errorの同値性
---

1つ目の疑問は、下記コードで e1 と e2 がイコールではないことです。 <br>
（同値性なんて仰々しく言ってすみません。たったこれだけの疑問ですｗ）

```go
func main() {
	e1 := errors.New("error1")
	e2 := errors.New("error1")
	e3 := e1

	fmt.Println(e1 == e2) // false
	fmt.Println(e1 == e3) // true
}
```
[Playground](https://play.golang.org/p/hwjeo1L6TS1)

<br>

---
# 結論（errorの同値性）
---

errors.New() が返しているのがポインタでした。

つまり、さきほどのコードの6行目はポインタの値を比較しているので、そりゃfalseになりますね。

<br>

---
# errorの表示
---

2つ目の疑問は、下記コードで e1 を表示すると、<br>
errors.New()の戻り値である構造体の値ではなく、エラー文言が表示されることです。

```go
package main                                                                                         

import (
	"fmt"
	"errors"
)                                                                                      

func main() {
	e1 := errors.New("error1")

	fmt.Println(e1) // error1
}
```
[Playground](https://play.golang.org/p/z8CQyypo4zX)

errors.New()が返しているのは構造体なので、<br>
下記コードのように構造体の内容が表示されないのはなんでだ？ってなったわけです。<br>

```go
package main

import "fmt"

func Hoge() interface{} {
	type hoge struct {
		s string
	}
	return &hoge{s: "hoge"}
}

func main() {
	h := Hoge()

	fmt.Println(h) // &{hoge}
}
```

[Playground](https://play.golang.org/p/_MeqQS420HV)

<br>

まぁ、だいたい予想はついています。<br>
errorってGoの中に組み込まれているやつなので、特別な処理が入っているんでしょう（[参考](https://golang.org/ref/spec#Errors)）<br>
問題はその処理がどこにあるのかってことですね。

<br>

ってことで、該当箇所を探します。

・<br>
・<br>
・<br>

ありました。<br>
[ここ](https://github.com/golang/go/blob/master/src/fmt/print.go#L624)ですね。

```go
p.fmtString(v.Error(), verb)
```

Error() で取り出した値を表示しているようですね。

ということは、、、

```go
package main

import (
	"fmt"
)

type CustomError struct {
	s string
}

func (e CustomError) Error() string {
	return e.s + " この文章が表示されるはず"
}

func NewCustomError(s string) error {
	return &CustomError{s: s}
}

func main() {
	ce1 := NewCustomError("custom error 1")
	fmt.Println(ce1) // custom error 1 この文章が表示されるはず
}
```
[Playground](https://play.golang.org/p/yYPkFMkYCzf)

たしかに、Error() 関数に変更を入れると、表示される内容も変わりましたね。

<br>

---
# 結論（errorの表示）
---

errorに関しては、特別な処理が入っていて、Error()で取得した文字列を表示している。
