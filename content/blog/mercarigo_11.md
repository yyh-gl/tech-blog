+++
author = "yyh-gl"
categories = ["Go", "勉強会"]
tags = ["Tech"]
date = "2019-10-07T00:00:00Z"
description = "めちゃくちゃためになった"
title = "【mercari.go #11】エラーハンドリング ＋ singleflight ＋ ISUCON ベンチマーカー【Golang】"
type = "post"
draft = false
[[images]]
  src = "img/tech-blog/2019/10/mercarigo_11/featured.webp"
  alt = "featured"
  stretch = "stretchH"
+++


# mercari.go #11 

- connpass： [リンク](https://mercari.connpass.com/event/148913/)
- ハッシュタグ： [`#mercarigo`](https://twitter.com/search?q=%23mercarigo&src=typd&lang=ja)

今回もお弁当とドリンクがありました！ありがたや

<br>
[追記：2019年10月12日]<br>
[Mercari Engineering Blog](https://tech.mercari.com/entry/2019/10/11/160000) にて、本イベントの記事が公開されました。<br>
発表資料が載せてあります。ありがたや🙏


# 1. About error handling in Go

登壇者：jd さん（@JehandadKamal）

[資料](https://about.sourcegraph.com/go/gophercon-2019-handling-go-errors)（正式に共有されたものでないので、発表の内容が少し異なります）

## Errors are values

”[Errors are values](https://blog.golang.org/errors-are-values)” という考え方。


## Golangでよくあるエラー処理パターン
- エラーをラップしてより詳細な情報を付与する
- 専用構造体を作る
- スタックトレースを構成する

## ”Error is your domain”

Domain Error Struct を作成する。

```go
type Error struct {
  Op        Op
  Kind      Kind
  Serverity zapcore.ErrorLevel
  Err       error
}
```

- Op：Operation → 関数名とか
- Kind：エラー種別 → NotAvailable, NotFound といったもの
- Serverity：エラーレベル
- Err：エラー内容

## 上記のような構造体を作る理由

error を比較するときは、基本的に文字列の比較になるため取り回しが悪い
<br>
→ ”NotFound” という文字列を比較するとかとか

Domain Error Struct を作れば Kind での比較などが可能になる。

加えて、操作内容やエラー種別とか情報を付与できる。


### これ大事！
Remember ”Error is your domain”

<br> 

### エラーの分割方法

[Twitterメモ](https://twitter.com/fukubaka0825/status/1181162651008659461)


# 2. singleflight

登壇者：@nsega さん

[スライド](https://speakerdeck.com/nsega/introduction-to-singleflight)

## singleflight

- 同じ処理が複数回実行される場合に、一回だけ実行して、その結果を使い回すというもの。
<br>
→ キャッシュに似ていますが、違いは後述します。

- BFF レイヤーで活躍
<br>
→ マイクロサービスにおいて、複数のAPIにリクエストを投げて、レスポンスを集約するようなときに有効。

- [ここ](https://godoc.org/golang.org/x/sync/singleflight)にある3つの関数さえ押さえればOK。

## singleflight のユースケース

初見だと、キャッシュとなにが違うのか分かりづらいと思います。
<br>
ここらへんを見ると singleflight のユースケースがわかってくると思います。

- [singleflight で解決できること1](https://christina04.hatenablog.com/entry/go-singleflight)
- [singleflight で解決できること2](https://qiita.com/methane/items/27ccaee5b989fb5fca72)

## Q&A

Q. goroutine で使うのはどうでしょう？

A.<br>

singleflight は扱いが難しいので、呼び出し元がわからなくなると、デバッグが余計難しくなる。
<br>
よって、goroutine ではあまり使わない方が良さそう。
<br>
→ 呼び出し元は明確な方が追跡しやすくていいと思う。


# 3. ISUCON9予選のベンチマーカーについて（TBD）

登壇者：カタツイさん（@catatsuy）

[資料](https://gist.github.com/catatsuy/74cd66e9ff69d7da0ff3311e9dcd81fa)

上記資料が全てです！

ISUCON の裏側、つまりベンチマーカーを作った話です。

こんなことを考えて作られているんだと知ることができ、
<br>
めちゃくちゃおもしろかったし、勉強になりました！

ぜひ、上記資料読んでみてください！
