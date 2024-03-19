+++
author = "yyh-gl"
categories = ["Go"]
tags = ["Tech"]
date = 2020-10-03T09:00:00+09:00
description = "忘れがちじゃないですか？？"
title = "【Go】Switch文のfallthroughに関するまとめ"
type = "post"
draft = false
[[images]]
  src = "img/2020/10/go-switch-fallthrough/featured.webp"
  alt = "featured"
  stretch = "stretchH"
+++

# fallthrough とは

GoではSwitch文でfallthroughという[キーワード](https://golang.org/ref/spec#Keywords)が使用可能です。

機能としては、処理を次の節（caseやdefault）に進めます。（[参考](https://github.com/golang/go/wiki/Switch#fall-through)）<br>
言葉で説明するよりも、サンプルコードを見てもらった方がイメージしやすいと思います。

```go
package main

import "fmt"

func main() {
	num := 1
	switch num {
	case 1:
		fmt.Print("I ")
		fallthrough
	case 2:
		fmt.Print("am ")
		fallthrough
	case 3:
		fmt.Println("yyh-gl.")
		// fallthrough // 次の節がなければコンパイルエラー
	}
}

// 実行結果：
// I am yyh-gl.
```

[Playground](https://play.golang.org/p/FBJKDxbVw5n)

[defaultにも飛べるという例](https://play.golang.org/p/VmfdVwngNGi)

<br>

`fallthrough`は、Go言語のORMライブラリとして有名な『GORM』でも使用されています。([使用箇所](https://github.com/go-gorm/gorm/blob/26dd4c980a62d47c990a05da9e5566bff3b2b00c/finisher_api.go#L94))<br>

