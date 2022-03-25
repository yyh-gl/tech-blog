+++
author = "yyh-gl"
categories = ["Go"]
tags = ["Tech"]
date = 2020-06-14T09:00:00+09:00
description = "Goでは全てが値渡し"
title = "Goの参照渡しについて調べてみた"
type = "post"
draft = false
[[images]]
  src = "img/tech-blog/2020/06/go-always-passing-by-value/featured.webp"
  alt = "featured"
  stretch = "stretchH"
+++


# Goにおける参照渡し＝ポインタの値渡し
<u>Goでは関数にパラメータを渡すとき、全て値渡しで実現されています。</u><br>
（C派生の言語はすべてそうらしいです）

じゃあ、参照渡しって何？ってなりますよね。

<u>参照渡し＝ポインタの値渡し</u>です。<br>
つまり、ポインタそのものを渡しているわけではなく、ポインタのコピーを渡しています。<br>

<br>

値渡しと参照渡しの差は、内部の値をコピーするかどうかです。<br>
こちらについては後ほど例を交えて説明します。

<br>

今回の内容はGo公式ドキュメントの[『Pointers and Allocation』](https://golang.org/doc/faq#Pointers)の章に <br>
詳細な記載があります。

本記事では、[『Pointers and Allocation』](https://golang.org/doc/faq#Pointers)から要点を抜粋して紹介します。


# 値渡しと参照渡しの違いは内部値のコピー有無
まずは、先述した

> 値渡しと参照渡しの差は、内部の値をコピーするかどうかです。

について詳しく見ていきます。

公式ドキュメント[『When are function parameters passed by value?』](https://golang.org/doc/faq#pass_by_value)の節に以下の記述があります。

> For instance, passing an int value to a function makes a copy of the int, and passing a pointer value makes a copy of the pointer, but not the data it points to.
>
> たとえば、int値を関数に渡すとintのコピーが作成され、ポインター値を渡すとポインターのコピーが作成されますが、ポインターが指すデータは作成されません。

つまり、

- 値渡し：値のコピーが作成される
- 参照渡し：ポインタのコピーは作成されるが、ポインタが指すデータ（値）のコピーは作成しない

といった差があります。

図にすると以下のとおりです。<br>
同じ色の箱はアドレスが同じだと考えてください。<br>
（図が下手なところはほっといてあげてください🙇‍♂️）

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2020/06/go-always-passing-by-value/passing-by-value.png" width="600">

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2020/06/go-always-passing-by-value/passing-by-reference.png" width="600">

大きな差がありますね。

この差により、例えば、多くのフィールドを持つ構造体を関数の引数やレシーバとして渡す場合、<br>
値渡しでは全フィールドのコピーが行われてしまうため <br>
パフォーマンス的に良くないといった違いが生まれてきます。

<br>

無駄なコピーを行わないために全て参照渡しにしとけばいいか、<br>
というとそれはまた別で考慮すべき点が出てきます。

「値渡し または 参照渡しのどちらを使用するか」については多くの議論がなされています。

- [Go公式ドキュメント『Should I define methods on values or pointers?』](https://golang.org/doc/faq#methods_on_values_or_pointers)
- [Yury Pitsishin『Pass by pointer vs pass by value in Go』](https://goinbigdata.com/golang-pass-by-pointer-vs-pass-by-value/)
- [pospomeのプログラミング日記『golang の 引数、戻り値、レシーバをポインタにすべきか、値にすべきかの判断基準について迷っている』](https://www.pospome.work/entry/2017/08/12/195032)
- [THE Finatext Tech Blog『Go言語（golang）における値渡しとポインタ渡しのパフォーマンス影響について』](https://medium.com/finatext/go%E8%A8%80%E8%AA%9E-golang-%E3%81%AB%E3%81%8A%E3%81%91%E3%82%8B%E5%80%A4%E6%B8%A1%E3%81%97%E3%81%A8%E3%83%9D%E3%82%A4%E3%83%B3%E3%82%BF%E6%B8%A1%E3%81%97%E3%81%AE%E3%83%91%E3%83%95%E3%82%A9%E3%83%BC%E3%83%9E%E3%83%B3%E3%82%B9%E5%BD%B1%E9%9F%BF%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6-70aa3605adc5)


# コードで確認
では、最後にここまでの内容をコードで確認して終わります。

[playground](https://play.golang.org/p/Zo9Op3ryKyW)

上記のplaygroundを実行すると、以下のように出力されました。<br>
（アドレス部分は実行ごとに異なります）

```
main()における構造体のアドレス：            0xc00010a040
main()におけるnameのアドレス：             0xc00010a040
PassByReference()における構造体のアドレス： 0xc000102020
PassByReference()におけるnameのアドレス：  0xc00010a040
PassByValue()における構造体のアドレス：     0xc00010a050
PassByValue()におけるnameのアドレス：      0xc00010a050
```

`PassByReference()`がレシーバを参照渡しで受け取る関数で <br>
`PassByValue()`がレシーバを値渡しで受け取る関数です。

`main()`と`PassByReference()`を比較すると、両者の構造体のアドレスが異なっています。<br>
`Human`構造体がもつ`name`フィールドについては同じアドレスを指しています。<br>
つまり、レシーバのポインタはコピーしたものを参照していますが、<br>
フィールドの値はコピーではなく、`main()`で定義したものが使用されています。<br>
先述の内容と一致しますね。

一方で、`main()`と`PassByValue()`を比較すると、<br>
両者の構造体のアドレスおよびフィールドのアドレスがすべて異なります。<br>
すなわち、レシーバのポインタおよびフィールドのすべての値に関して、コピーしたものを参照しています。

こちらも先述の内容と一致します。

納得！

<br>

ちなみに、なぜすべて値渡しで実現しているかについては、<br>
先程紹介した下記の記事で触れられています。

[Yury Pitsishin『Pass by pointer vs pass by value in Go』](https://goinbigdata.com/golang-pass-by-pointer-vs-pass-by-value/)<br>
→「Passing by value often is cheaper」の章
