+++
author = "yyh-gl"
categories = ["Golang", "勉強会"]
date = "2019-10-07"
description = "めちゃくちゃためになった"
featured = "mercarigo_11/featured.png"
featuredalt = "画像がどこかへ逝ってしまったようだ…"
featuredpath = "date"
linktitle = ""
title = "【mercari.go #11】エラーハンドリング ＋ single flight ＋ ISUCON ベンチマーカー【Golang】"
type = "post"

+++


<br>

---
# mercari.go #11 
---

- connpass： [リンク](https://mercari.connpass.com/event/148913/)
- ハッシュタグ： [`#mercarigo`](https://twitter.com/search?q=%23mercarigo&src=typd&lang=ja)

今回もお弁当とドリンクがありました！ありがたや


---
# 1. About error handling in Go
---

登壇者：jd さん（@JehandadKamal）

[資料](https://about.sourcegraph.com/go/gophercon-2019-handling-go-errors)（正式に共有されたものでないので、発表の内容が少し異なります）

<br>

## Errors are values

”[Errors are values](https://blog.golang.org/errors-are-values)” という考え方。


<br>

## Golangでよくあるエラー処理パターン
- エラーをラップしてより詳細な情報を付与する
- 専用構造体を作る
- スタックトレースを構成する

<br>

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

<br>

## 上記のような構造体を作る理由

error を比較するときは、基本的に文字列の比較になるため取り回しが悪い
<br>
→ ”NotFound” という文字列を比較するとかとか

Domain Error Struct を作れば Kind での比較などが可能になる。

加えて、操作内容やエラー種別とか情報を付与できる。


<br>

### これ大事！
Remember ”Error is your domain”

<br> 

### エラーの分割方法
https://twitter.com/fukubaka0825/status/1181162651008659461

<br>

---
# 2. singleflight
---

登壇者：@nsega さん

[スライド](https://speakerdeck.com/nsega/introduction-to-singleflight)

<br>

## singleflight

- 同じ処理が複数回実行される場合に、一回だけ実行して、その結果を使い回すというもの。
<br>
→ キャッシュに似ていますが、違いは後述します。

- BFF レイヤーで活躍
<br>
→ マイクロサービスにおいて、複数のAPIにリクエストを投げて、レスポンスを集約するようなときに有効。

- [ここ](https://godoc.org/golang.org/x/sync/singleflight)にある3つの関数さえ押さえればOK。

<br>

## singleflight のユースケース

初見だと、キャッシュとなにが違うのか分かりづらいと思います。
<br>
ここらへんを見ると singleflight のユースケースがわかってくると思います。

- [singleflight で解決できること1](https://christina04.hatenablog.com/entry/go-singleflight)
- [singleflight で解決できること2](https://qiita.com/methane/items/27ccaee5b989fb5fca72)

<br>


## Q&A

Q. goroutine で使うのはどうでしょう？

A.<br>

singleflight は扱いが難しいので、呼び出し元がわからなくなると、デバッグが余計難しくなる。
<br>
よって、goroutine ではあまり使わない方が良さそう。
<br>
→ 呼び出し元は明確な方が追跡しやすくていいと思う。


<br>

---
# 3. ISUCON9予選のベンチマーカーについて（TBD）
---

登壇者：カタツイさん（@catatsuy）

[資料](https://gist.github.com/catatsuy/74cd66e9ff69d7da0ff3311e9dcd81fa)

上記資料が全てです！

ISUCON の裏側、つまりベンチマーカーを作った話です。

こんなことを考えて作られているんだと知ることができ、
<br>
めちゃくちゃおもしろかったし、勉強になりました！

ぜひ、上記資料読んでみてください！
