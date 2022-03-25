<!-- textlint-disable -->

+++
author = "yyh-gl"
categories = ["Go"]
tags = ["Tech"]
date = 2020-03-09T09:00:00+09:00
description = "今回は Unwrap()，Is()，As() についてお届け"
title = "【Go】errorsパッケージの中身覗いてみた"
type = "post"
draft = false
[[images]]
  src = "img/tech-blog/2020/03/errors_package/featured.webp"
  alt = "featured"
  stretch = "stretchH"
+++

<!-- textlint-enable -->

# errorsパッケージに興味持った
v1.13からerrorsパッケージに `Unwrap()` `Is()` `As()` といった関数が追加されました。<br>
（もう1.14もリリースされているのに今さらですね😇）

今回はこれら3つの関数について、内部実装を追いかけていきます。

と、その前に、errorsパッケージの概要と関連パッケージについて軽く説明しておきます。


# errorsパッケージと関連パッケージ
## errorsパッケージ

名前の通り、エラー関連の処理がまとまっているパッケージですね。<br>
Goの標準パッケージです。<br>
→ [GoDoc](https://golang.org/pkg/errors/)

v1.13にて、先述の `Unwrap()` `Is()` `As()` という関数たちが追加されました。<br>

errorを扱うパッケージとして、もうひとつ有名なパッケージがあります。<br>
xerrorsパッケージです。 

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


# [Unwrap()](https://golang.org/pkg/errors/#Unwrap)
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

処理を順に追っていくと、
7行目で型アサーションを用いてラップされたエラーのインターフェースを満たしているかチェックし、
満たしていなければ（ok == false）nilを返します。<br>
満たしていれば（ok == true）実装されている `Unwrap()` を処理します。

ここで注意ですが、
12行目の `Unwrap()` は今まで話に出てきていた `errors.Unwrap()` とは全くの別物です。<br>
では、12行目の `Unwrap()` はどこにあるのか。<br>
答えはerrorをラップする処理のところにあります。


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

10行目で、`wrapError` という構造体を返していますね。<br>
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

`Unwrap()` がありました。

まず、`wrapError`構造体ですが、本構造体は`err`フィールドを持っており、ここにラップするエラーを格納しています。<br>
（さきほど見た `Errorf()` の内部処理では、10行目にて`wrapError`が使用されています）

`Unwrap()`は`wrapError`構造体の`err`フィールド、すなわち、ラップしていたエラーを返しているだけですね。

<br>

以上、`errors.Unwrap()` の内部実装はこんな感じでした。

どんどん行きましょう。


# [Is()](https://golang.org/pkg/errors/#Is)
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

次に11行目で、型アサーションを利用して `err`が `Is(error) bool` という関数を実装しているかチェックしています。

<!-- textlint-disable -->
このチェック処理は、
<u>独自の同値判定処理がないか確認し、ある場合はその同値判定処理を使用して判定を行う</u><br>
ために用意されています。
<!-- textlint-enable -->

`Is(error) bool` の実装例が[公式のドキュメント](https://golang.org/pkg/errors/#Is)にあります。<br>
<!-- textlint-disable -->
↓↓↓
<!-- textlint-enable -->

```go
func (m MyError) Is(target error) bool { return target == os.ErrExist }
```

独自のエラー型を定義するときに役立ちそうですね。

では、最後に15行目からの処理です。<br>
ここは`err`をUnwrapする処理ですね。<br>
（この`Unwrap()`は前章で説明した関数です）

<!-- textlint-disable -->
つまり、<br>
`isComparable && err == target`<br>
および<br>
`x, ok := err.(interface{ Is(error) bool }); ok && x.Is(target)`<br>
の両条件に該当しなかった場合は、`err`の中にあるエラーを抜き取り、<br>
そのエラーに対して、forループの最初から処理していくということになります。
<!-- textlint-enable -->

この最後の`Unwrap()`により、本章冒頭に述べた

> また、比較元（第一引数）のエラーがラップしたエラーだったとしても、<br>
  最後までUnwrapして比較してくれます。

というのを実現しているわけですね。


# [As()](https://golang.org/pkg/errors/#As)
最後に `As()` です。

本関数は、第一引数のエラーが第二引数のエラーに代入可能であれば代入し、trueを返します。<br>
代入できない場合はfalseが返されます。

第二引数はポインタ型なので、`target`に関して副作用を含む関数です。

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
ラップされたエラーの中身を取り出していくあたりは `Is()` と同じですね。<br>
加えて、19行目で独自定義の `As()` を使用できるところも `Is()` と同じです。

特徴的なのは、5〜18行目の部分になります。

まず、5，6行目でreflectliteを使って第二引数の`target`の構造を読み取っています。<br>

> reflectliteはreflectパッケージの軽量版で、<br>
> runtimeおよびunsafe以外での使用は基本的に禁止されています。 >> [参考](https://golang.org/pkg/internal/reflectlite/#Overview)

そして、`target`がポインタである、かつ、nilでないことを確認します。

本章冒頭でも述べましたが、<br>
最終的に（代入可能であれば）第一引数の`err`は第二引数の`target`に格納します。<br>
つまり、戻り値で`target`に格納したエラーを返すのではなく、`target`（ポインタ）経由でできあがったエラーを返します。<br>
したがって、ポインタであることを確認する必要があります。

<!-- textlint-disable -->
加えて、10行目で、interfaceである、かつ、errorType（＝error）を実装できているかチェックします。
<!-- textlint-enable -->

以上で、`target`が`error`を格納できる箱であるか（`error`インタフェースを満たしているか）どうかを判定しています。

<br>

続きの13行目以降で、<br>
`err`が`target`に格納できる値かどうかを判定し、できるならば格納しています。（15，16行目）

格納できない場合は、独自実装の `As()` 探して、実行していますね。

`err` が `target` に格納できず、独自実装の `As()` もない場合は、<br>
`err` を `Unwrap()` して再度同じ処理を行います。

それでも、格納できるエラーがなかった場合は false を返します。


# まとめ

errorsパッケージの実装を覗いてみましたが、いかがだったでしょうか？<br>
普段使ってる標準パッケージの内部実装を追いかけるのは楽しいですね👍

今回はerrorsパッケージの中身を見ましたが、reflectliteパッケージが結構使われていましたね。

reflectliteの動きが分からない部分もあったので、<br>
次はreflectliteの中身も見たいなという気持ちになっています。

（reflectliteを少し覗いたのですが、Goの型のデータ構造？的な話が入ってきており、かなりおもしろそう）

reflectliteを一緒に読みたいって方おられたら[TwitterでDM](https://twitter.com/yyh_gl)ください！<br>
ぜひオンラインでコードリーディング会しましょう


# 参考文献

- [errorsパッケージの公式ドキュメント](https://golang.org/pkg/errors/)
- [Go 1.13 のエラー・ハンドリング](https://text.baldanders.info/golang/error-handling-in-go-1_3/)
- [Golang: How to handle Errors in v1.13](https://medium.com/@felipedutratine/golang-how-to-handle-errors-in-v1-13-fda7f035d027)
- [reflectliteパッケージの公式ドキュメント](https://golang.org/pkg/internal/reflectlite/)
