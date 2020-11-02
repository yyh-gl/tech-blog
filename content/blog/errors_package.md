+++
author = "yyh-gl"
categories = ["Go"]
date = "2020-03-09"
description = "今回は Unwrap()，Is()，As() についてお届け"
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

v1.13からerrorsパッケージに `Unwrap()` `Is()` `As()` といった関数が追加されました。<br>
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

v1.13にて、先述の `Unwrap()` `Is()` `As()` という関数たちが追加されました。<br>

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
v1.13にて標準パッケージに取り込まれました。


<br>

さて、軽くerror関連のパッケージについて触れたところで、<br>
早速、`Unwrap()` `Is()` `As()` の内部実装を見ていきたいと思います。<br>
なお、Goのコードはv1.14.0を参照しています。

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
# [Is()](https://golang.org/pkg/errors/#Is)
---

次は `Is()` を見ていきます。

本関数は2つのエラーが同じエラーかどうかを判定します。<br>
また、比較元（第一引数）のエラーがラップしたエラーだったとしても、<br>
最後までUnwrapして比較してくれます。

処理はこんな感じです。

```go
func Is(err, target error) bool {
    if target == nil {
		return err == target
	}

	isComparable := reflectlite.TypeOf(target).Comparable()
	for {
		if isComparable && err == target {
			return true
		}
		if x, ok := err.(interface{ Is(error) bool }); ok && x.Is(target) {
			return true
		}
		
		if err = Unwrap(err); err == nil {
			return false
		}
	}
}
```

要となる処理は7〜20行明のfor文内の処理です。

まずは、8,9行目にて単純にエラー同士の比較をしています。<br>
ここで一致すれば `return true` ですね。

次に11行目でerrが `Is(error) bool` という関数を持っているかどうか、<br>
型アサーションによって確認しています。

本処理がなにをしているかというと、<br>
<u>独自の同値判定処理がないか確認し、ある場合はその同値判定処理を使用して判定を行う</u><br>
ということをしてくれています。

`Is(error) bool` の実装例が[公式のドキュメント](https://golang.org/pkg/errors/#Is)にあります。<br>
↓↓↓

```go
func (m MyError) Is(target error) bool { return target == os.ErrExist }
```

独自のエラー型を定義するときに役立ちそうですね。

では、最後に15行目からの処理です。<br>
ここはerrをUnwrapする処理ですね。<br>
（このUnwrap()は前章で説明した関数です）

つまり、<br>
`isComparable && err == target`<br>
および<br>
`x, ok := err.(interface{ Is(error) bool }); ok && x.Is(target)`<br>
の両条件に該当しなかった場合は、errの中にあるエラーを抜き取り、<br>
そのエラーに対して、forループの最初から処理していくということになります。

この最後のUnwrap()により、<br>
本章冒頭に述べた

> また、比較元（第一引数）のエラーがラップしたエラーだったとしても、<br>
  最後までUnwrapして比較してくれます。

というのを実現しているわけですね。

<br>

---
# [As()](https://golang.org/pkg/errors/#As)
---

最後に `As()` です。<br>
本関数はラップされたエラーから指定のエラーを抽出します。<br>
抽出できるエラーがない場合は戻り値としてfalseが返されます。

それでは内部実装を見ていきます。

```go
func As(err error, target interface{}) bool {
	if target == nil {
		panic("errors: target cannot be nil")
	}
	val := reflectlite.ValueOf(target)
	typ := val.Type()
	if typ.Kind() != reflectlite.Ptr || val.IsNil() {
		panic("errors: target must be a non-nil pointer")
	}
	if e := typ.Elem(); e.Kind() != reflectlite.Interface && !e.Implements(errorType) {
		panic("errors: *target must be interface or implement error")
	}
	targetType := typ.Elem()
	for err != nil {
		if reflectlite.TypeOf(err).AssignableTo(targetType) {
			val.Elem().Set(reflectlite.ValueOf(err))
			return true
		}
		if x, ok := err.(interface{ As(interface{}) bool }); ok && x.As(target) {
			return true
		}
		err = Unwrap(err)
	}
	return false
}

var errorType = reflectlite.TypeOf((*error)(nil)).Elem()
```

for文と `errors.Unwrap()` を使って <br>
ラップされたエラーの中身を取り出していくあたりは `Is()` と同じですね。

また、19行目で独自定義の `As()` を使用できるところも `Is()` と同じです。

特徴的なのは、5〜18行目の部分になります。

まず、5，6行目でreflectliteを使って第2引数のエラー（target）の構造を読み取っています。<br>

> reflectliteはreflectパッケージの軽量版で、<br>
> runtimeおよびunsafe以外での使用は基本的に禁止されています。 >> [参考](https://golang.org/pkg/internal/reflectlite/#Overview)

そして、targetがポインタである、かつ、nilでないことを確認します。<br>
抽出したエラーはtargetに格納するので、targetはポインタである必要があります。<br>
よって、ポインタかどうか確認しているのだと考えています。

加えて、10行目で、interfaceである、かつ、errorType（＝error）を実装できているかをチェックします。

以上で、targetがerrorを格納できる箱であるかどうかを判定しています。

<br>

続きの13行目以降で、<br>
errがtargetに格納できる値かどうかを判定し、できるならば格納しています。（15，16行目）

格納できない場合は、独自実装の `As()` 探して、実行していますね。

err が target に格納できず、独自実装の `As()` もない場合は、<br>
err を `Unwrap()` して再度同じ処理を行います。

そして、格納できるエラーがなかった場合は false を返すわけですね。

<br>

---
# まとめ
---

errorsパッケージの実装を覗いてみましたが、いかがだったでしょうか？<br>
普段使ってる標準パッケージの内部実装を追いかけるのは楽しいですね〜

今回はerrorsパッケージの中身を見ましたが、reflectliteパッケージが結構使われていましたね。

reflectliteの動きが分からない部分もあったので、<br>
次はreflectliteの中身も見たいなという気持ちになっています。

（reflectliteを少し覗いたのですが、Goの型のデータ構造？的な話が入ってきており、ビビってます😇）

reflectliteを一緒に読みたいって方おられたら[TwitterでDM](https://twitter.com/yyh_gl)ください！<br>
ぜひオンラインでコードリーディング会しましょう

<br>

---
# 参考文献
---

- [errorsパッケージの公式ドキュメント](https://golang.org/pkg/errors/)
- [Go 1.13 のエラー・ハンドリング](https://text.baldanders.info/golang/error-handling-in-go-1_3/)
- [Golang: How to handle Errors in v1.13](https://medium.com/@felipedutratine/golang-how-to-handle-errors-in-v1-13-fda7f035d027)
- [reflectliteパッケージの公式ドキュメント](https://golang.org/pkg/internal/reflectlite/)
