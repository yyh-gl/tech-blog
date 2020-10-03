+++
author = ["yyh-gl"]
categories = ["golang"]
tags = ["golang"]
date = "2020-10-03T00:00:00Z"
description = "忘れがちじゃないですか？？"
featured = "go-switch-fallthrough/featured.png"
featuredalt = "画像がどこかへ逝ってしまったようだ…"
featuredpath = "date"
linktitle = ""
title = "【Go】Switch文のfallthroughの動作を確認した"
type = "post"

+++


<br>

---
# fallthrough とは
---

GoではSwitch文でfallthroughという[キーワード](https://golang.org/ref/spec#Keywords)が使用可能です。

機能としては、Switch文における次の節（caseやdefault）に移動するというものです。（[参考](https://github.com/golang/go/wiki/Switch#fall-through)）<br>
言葉で説明するよりも、サンプルコードを見てもらった方がイメージがつきやすいと思います。

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

`fallthrough`は、Go言語のORMライブラリとして有名な『GORM』でも使用されています。([使用箇所](https://github.com/go-gorm/gorm/blob/master/finisher_api.go#L44)))<br>

