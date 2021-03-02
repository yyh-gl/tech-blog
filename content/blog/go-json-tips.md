+++
author = "yyh-gl"
categories = ["Go"]
tags = ["Tech"]
date = "2020-04-26T00:00:00Z"
description = ""
title = "【Go】jsonパッケージの知っておくと便利な機能"
type = "post"
draft = false
[[images]]
  src = "img/tech-blog/2020/04/go-json-tips/featured.webp"
  alt = "featured"
  stretch = "stretchH"
+++

# jsonパッケージ

Goを触ってる人ならだれもが一度はお世話になるであろう
パッケージ「[json](https://golang.org/pkg/encoding/json/)」

今回はそんな json パッケージについて、<br>
知っておくと便利な機能を2つ紹介します。

（比較的有名なものしかないですが🙏）


# 1. 独自の変換ロジックを実装できる

例えば、下記のコードのように、<br>
ある構造体（`Human`）のフィールドを外部公開したくない場合、<br>
jsonパッケージの `Unmarshal()`，`Marshal()` が使えません。<br>
（上記関数は外部公開されたフィールドのみ変換できる）

```go
type Human struct {
	// フィールドを外部公開したくない
	name string
	age  int
}

func main() {
	h := Human{
		name: "Taro",
		age:  21,
	}

	// 構造体 → JSON
	j, _ := json.Marshal(h)
	fmt.Println(string(j)) // {}

	// JSON → 構造体
	var uh Human
	_ = json.Unmarshal(j, &uh)
	fmt.Printf("%+v\n", uh) // {name: age:0}
}
```
[playgroud](https://play.golang.org/p/53yg13xW5T7)

<br>

実際に実行してみると、うまく変換できていないことが分かると思います。

さて、このときどうすれば正しく変換できるかというと、<br>
変換対象の構造体に以下のメソッドを生やしてやればOKです。

- `MarshalJSON() ([]byte, error)`
- `UnmarshalJSON(data []byte) error`


```go
type Human struct {
	// フィールドを外部公開したくない
	name string
	age  int
}

func (h Human) MarshalJSON() ([]byte, error) {
	type tmp struct {
		Name string `json:"name"`
		Age  int    `json:"age"`
	}

	t := tmp{
		Name: h.name,
		Age:  h.age,
	}
	return json.Marshal(t)
}

func (h *Human) UnmarshalJSON(data []byte) error {
	type tmp struct {
		Name string `json:"name"`
		Age  int    `json:"age"`
	}

	var t tmp
	_ = json.Unmarshal(data, &t)

	h.name = t.Name
	h.age = t.Age
	return nil
}

func main() {
	h := Human{
		name: "Taro",
		age:  21,
	}

	// 構造体 → JSON
	j, _ := json.Marshal(h)
	fmt.Println(string(j)) // {"name":"Taro","age":21}

	// JSON → 構造体
	var uh Human
	_ = json.Unmarshal(j, &uh)
	fmt.Printf("%+v\n", uh) // {name:Taro age:21}
}
```
[playgroud](https://play.golang.org/p/CN_svIrNRxQ)

<br>

うまく変換できましたね👍

このように、`Marshal()` と `Unmarhsal()` は <br>
対象の構造体に生えている `MarshalJSON()` と `UnmarhsalJSON()` を見に行ってくれるわけです。

## Goの内部実装を追いかけたければ…

> 対象の構造体に生えている `MarshalJSON()` と `UnmarhsalJSON()` を見に行ってくれるわけです。

先述した↑この部分がどういう仕組みになっているのかは、<br>
[json/encode.go](https://github.com/golang/go/blob/master/src/encoding/json/encode.go)
を見ればわかります。<br>
→ [494行目らへんとかとか](https://github.com/golang/go/blob/master/src/encoding/json/encode.go#L494)

## 使いみちいろいろ

今回紹介した例以外にも、<br>
下記記事のように時間形式を変更するために使用する例もあります。

- [時間形式の変更](https://dev.classmethod.jp/articles/struct-json/)


# 2. 構造体なしでも変換できる

実はJSONの変換処理は、構造体をきっちり定義してやる必要はありません。

以下に示すとおり、<br>
`interface{}` を使うと、`map[string]interface{}` に変換してくれます。

```go
func main() {
	// どんな内容か分からないJSON
	mysteriousJSON := "{\"name\": \"Taro\", \"age\": 21}"

	var i interface{}
	_ = json.Unmarshal([]byte(mysteriousJSON), &i)

	for k, v := range i.(map[string]interface{}) {
		fmt.Printf("%s: %v\n", k, v) // キー・バリューのセットを取得できる
	}
}
```
[playground](https://play.golang.org/p/HCCgagiJeQW)

<br>

後は、mapに対してよしなに処理してやればOKです。

やはり、ちゃんと構造体を作って、<br>
フィールドで型を指定してやるのが理想だと思います。

しかし、正常時と異常時でレスポンス構造が大きく変わる場合などは、<br>
一旦、map型に変換して、正常時用か異常時用かを判断するのもありかなと思います。<br>

正常時と異常時の両方に対応できるでっかい構造体を作ってもいいですが、<br>
無駄が多くなりがちですしね。

その状況に合わせて、使い分けれると良さそうですね👍<br>
みなさんどうしているのか聞いてみたいですね〜

# まとめ

知っていればどうってことない機能ですが、<br>
知らなければハマりどころになるところですよね。

Go初学者の方の参考になれば幸いです。
