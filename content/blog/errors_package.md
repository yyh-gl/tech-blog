+++
author = "yyh-gl"
categories = ["Golang"]
date = "2020-03-03"
description = "今回は Is()，As()，Unwrap() についてお届け"
featured = "errors_package/featured.png"
featuredalt = "画像がどこかへ逝ってしまったようだ…"
featuredpath = "date"
linktitle = ""
title = "【Golang】errorsパッケージの中身覗いてみた"
type = "post"

+++


<br>

---
# errorsパッケージに興味持った
---

バージョン1.13からerrorsパッケージに `Is()` `As()` `Unwarp()` といった関数が追加されました。<br>
（もう1.14もリリースされているのに今さらですね😇）

今回はこれら3つの関数について、内部実装を追いかけていきます。

と、その前に、errorsパッケージの概要と関連パッケージについて軽く説明しておきます。


<br>

---
# errorsパッケージと関連パッケージ
---

## errorsパッケージ

名前の通り、エラー関連の処理がまとまっているパッケージですね。<br>
Goの標準パッケージです。<br>
→ [GoDoc](https://golang.org/pkg/errors/)

バージョン1.13にて、先述の `Unwrap()` `Is()` `As()` という関数たちが追加されました。<br>

errorを扱うパッケージとして、もうひとつ有名なパッケージがあります。<br>
xerrorsパッケージです。 

<br>

## xerrorsパッケージ

[xerrors](https://godoc.org/golang.org/x/xerrors) とは、
[Goのサブリポジトリ](https://godoc.org/-/subrepo)で開発が進められているパッケージです。<br>
（準標準パッケージといった感じでしょうか）

[xerrorsのGoDoc](https://godoc.org/golang.org/x/xerrors)に下記の記述がある通り、

> These functions were incorporated into the standard library's errors package in Go 1.13: - Is - As - Unwrap

もともとは本パッケージに `Unwrap()` `Is()` `As()` が実装されていましたが、<br>
バージョン1.13にて標準パッケージに取り込まれました。


<br>

さて、軽くerror関連のパッケージについて触れたところで、<br>
早速、`Unwrap()` `Is()` `As()` の内部実装を見ていきたいと思います。

<br>

---
# [Unwrap()](https://golang.org/pkg/errors/#Unwrap)
---

ラップされたエラーから中身のエラーを取り出す関数です。

処理としては下記のようになっています。

```go
func Unwrap(err error) error {
	u, ok := err.(interface {
		Unwrap() error
	})
	if !ok {
		return nil
	}
	return u.Unwrap()
}
```
https://golang.org/src/errors/wrap.go?s=372:400#L14

ぱっと見だと、ん？っとなってしまうかもしれませんが、<br>
下記のように処理を分解してやると、特別難しいことは何もしていないことがわかります。

```go
func Unwrap(err error) error {
    // ラップされたエラーのインターフェース
    type wrapErrInterface interface {
        Unwrap() error
    }

    // 型アサーションにより、ラップされたエラーのインターフェースを満たしているかチェック
	u, ok := err.(wrapErrInterface)
	if !ok {
		return nil
	}
	return u.Unwrap()
}
```

やっていることとしては、7行目で <br>
型アサーションを用いてラップされたエラーのインターフェースを満たしているかチェックし、<br>
満たしていなければ（ok == false）、nilを返す。<br>
満たしていれば（ok == true）、実装されている `Unwrap()` を処理するわけです。

ここで注意ですが、<br>
12行目の `Unwrap()` は今まで話に出てきていた `errors.Unwrap()` とは全く別物です。

では、12行目の `Unwrap()` はどこにあるのか。
答えはerrorをラップする処理のところにあります。

<br>

## errorをラップする関数

errorをラップする関数である `fmt.Errorf()` の中身を見てみましょう。

```go
func Errorf(format string, a ...interface{}) error {
	p := newPrinter()
	p.wrapErrs = true
	p.doPrintf(format, a)
	s := string(p.buf)
	var err error
	if p.wrappedErr == nil {
		err = errors.New(s)
	} else {
		err = &wrapError{s, p.wrappedErr}
	}
	p.free()
	return err
}
```
https://golang.org/src/fmt/errors.go?s=624:674#L17

10行目で、`wrapError` なる構造体を返していますね。
宣言箇所に飛んでみましょう。

```go
type wrapError struct {
	msg string
	err error
}

func (e *wrapError) Error() string {
	return e.msg
}

func (e *wrapError) Unwrap() error {
	return e.err
}
```
https://golang.org/src/fmt/errors.go#L32

`Unwrap()` がありましたね。<br>
wrapError構造体は内部フィールドに `err` を持っており、<br>
ここにラップしたエラーを入れるわけです。<br>
実際、さきほどの `Errorf()` の10行目でセットしてますよね。

<br>

`errors.Unwrap()` はこうして実装されていたわけですね〜

どんどん行きましょう。

<br>

---
# Is()
---

次は `Is()` を見ていきます。

処理はこんな感じです。

```go

```


---







<img src="http://localhost:1313/tech-blog/img/tech-blog/2020/03/-/-" width="600">
<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2020/03/-/-" width="600">
