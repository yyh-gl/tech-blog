+++
author = "yyh-gl"
categories = ["Golang", "勉強会"]
date = "2019-06-15"
description = ""
featured = "mercari_go/featured.png"
featuredalt = "画像がどこかへ逝ってしまったようだ…"
featuredpath = "date"
linktitle = ""
title = "【mercari.go #8】メルカリの Golang に関する勉強会メモ"
type = "post"

+++


<br>

---
# mercari.go #8 
---

- connpass： [リンク](https://mercari.connpass.com/event/132114/?utm_campaign=event_message_to_selected_participant&utm_source=notifications&utm_medium=email&utm_content=title_link)
- ハッシュタグ： [`#mercarigo`](https://twitter.com/search?q=%23mercarigo&src=typd&lang=ja)

- 独自ルール： [懇親会のGルール](https://twitter.com/zaki_hmkc/status/1139481689300713472) <br>
   懇親会のときに登壇者を囲んでもいいけど、自分たち以外にもう一人入ってこれるスペースを常に開けておこうねっていうルール。とてもよい！

- 雰囲気

<img src="http://localhost:1313/tech-blog/img/tech-blog/2019/06/mercari_go/goods.JPG" height="300">

ビール以外にもおいしそうなご飯もありましたが、写真を撮るの忘れ…
   
<br>

以降、自分用のメモを書き連ねます。<br>
詳細はスライドの方をご覧ください。

<br>


---
# 1. Goで学ぶKnative
---

登壇者： @toshi0607 さん

スライド： https://speakerdeck.com/toshi0607/learning-knative-with-go

<br>

## [Knative](https://cloud.google.com/knative/?hl=ja)

- Knative ＝ 最新のサーバーレス ワークロードをビルド、デプロイ、管理できる Kubernetes ベースのプラットフォーム。
  - AWS の Lmabda に近いことを k8s 上でできると解釈

- 登壇者含め、会場内で Knative を本番に導入している人はなし。<br>まだ時期尚早っぽい。

- k8s のリソースを抽象化し、独自のPaaS/FaaSを構築するためのパーツを提供。

- k8s 上にのっかる。

- Knative の構成
  - [Serving](https://speakerdeck.com/toshi0607/learning-knative-with-go?slide=8)
  - [Build](https://speakerdeck.com/toshi0607/learning-knative-with-go?slide=13)
  - [Eventing](https://speakerdeck.com/toshi0607/learning-knative-with-go?slide=15)

- 現状、一部、Istio に依存してしまっているので、Istioの導入が必要不可欠。

- 登壇者は 機能実装に一層集中するための基盤 として注目している。

- yml ファイルで定義した内容に基づいて コード生成


<br>

## 感想

終盤、 Knative の内部処理を コードリーディング していたのですが、<br>
見入ってしまいメモを忘れていました。。。

Knative 初めて聞いたのですが、おもしろそうだなという感想。

k8s の勉強しないとな。


<br>

---
# 2. Gotham GoとGopherCon EUに参加してきました
---

登壇者： @tenntenn

スライド： https://docs.google.com/presentation/d/1u6E0btAS_uJP8F62Ly2GdZScJYbLK-Ub9QnnMGm0IRY/edit

<br>

- 技術をアウトプットするところに人は集まる

- メルペイ エキスパートチーム では <u>50%以上の時間</u> をコミュニティへの貢献に充てている

- 海外カンファレンスに参加する理由
  - 最新の技術を知る
  - 世界各地のエンジニアとの交流

<br>

## Gotham Go

- ニューヨークで毎年開かれている Go カンファレンス
- 1トラック
- 200名くらいが参加する（そんなに大規模ではない）
- ハンズオンがあった
  - パックマン（ゲーム）作った（[github](https://github.com/danicat/pacgo)）
  - 絵文字で動くらしい
  - step by step で初心者におすすめ
- <u>自作楽器</u> を Go から操作する
- スライスをプール（再利用）する方法
  - leachsync を使う方法が良さそうという結論
- セッションのレベルは 日本の Go Conference と同等
  - ただし、 現地に Goチーム がいるので登壇者が豪華
- 突然ビンゴ大会が始まったりする

<br>

## GopherCon EU

- ヨーロッパで毎年開催されている
  - ヨーロッパ中から Gopher が集まる
- 参加者は200名くらい
- 2トラックで大きめ
- ダイバーシティスカラーシップがあり、費用の補助が出る（一部）
- リーダビリティに関するセッション
  - width が大きいスパゲッティコード と dipth が大きい行き過ぎた抽象化 どちらもそれぞれいやなことがある。この間ぐらいがいいよねーって話。
- GoTrace： Go Routine を可視化するライブラリ → [参考記事リンク](https://divan.dev/posts/visual_programming_go/)
  - <u>IDE でコードを読むなんて、 洞窟でたいまつをもって壁画に書かれた文字を読むようなもの。</u> 可視化しましょう！
- <u>現在使用では、 map に range を使うとキーがランダムに並ぶ</u> ので、それを使ってLT大会の発表順を決めた 


<br>

## 感想

- メルペイ エキスパートチーム では <u>50%以上の時間</u> をコミュニティへの貢献に充てている

これすごくないですか？

多くのつよつよエンジニアが集まるのも納得です。

<br>

海外のカンファレンスのノリがおもしろそうでした。

発表にかける気合がすごい笑

ぜひ、一度行ってみたいです。

<br>

---
# 3. Go + WebAssemblyを活用する
---

登壇者： @__syumai

- メルペイのバックエンドエンジニア
- Go Playground にタブを追加する chrome拡張を作った人

スライド： https://speakerdeck.com/syumai/using-go-and-webassembly/

<br>

## Go WebAssembly（wasm ワズム）

- experimental の機能
- 1.11 以上で使用可能
- GOOS=js GOARCH=wasm でビルドすると `.wasm` ファイルが生成され、JavaScript から使用できる
  - ≒ JavaScript から Golang を使用できるようになる
- クリックの動作を Golang で実装したりした
- select{} 使わないと main 関数が終了して JavaScriptから呼べなくなる（[参考](https://twitter.com/shumon_84/status/1139502364673466368)）
- つらみ
  - GOOS=js GOARCH=wasm でしかビルドできないので、テストができない
     - （解決策）テストしたい部分は別パッケージにエクスポートする。Goで実装するやつは main.go だけに依存するようにしたらいい。
  - DOM操作をGoでやった（JavaScript ならしゅっと書けるのに…）
     - （解決策）ビジネスロジック部分だけを Golang で実装するようにしないとつらい
     - DOM操作は素直に JavaScript にお任せした方がいい


<br>

## 感想

JavaScript から Golang で実装した機能を使えるとか、夢しかないですね。楽しそう。<br>
（黒魔術の匂いがする）

<br>

---
# 4. E2E Testing with 'main' function
---

登壇者： @yuki.ito

<br>

- サンプルリポジトリ： https://github.com/110y/go-e2e-example
- 普通にテストしようとすると `main` 関数 がカバレッジに含まれないから、含まれるように努力する話
  1. e2e で TestMain を起動し、go test . でトップレベルのコードをgoroutineで起動
  1. Mainで起動されたサーバに対して TestMainから接続してリクエストを投げる
  1. TestMainで生成したクライアントから個々のテストを実行する。
  1. mainのカバレッジも取れる。



<br>

## 感想

こういう工夫して問題解決する話大好きです。

その手があったか。とただただ説明を聞き入ってました。


---
# 全体まとめ
---

メルカリ社の技術力の高さがとても分かる勉強会でした。

中の人たちが積極的に外に出てキャッチアップをしている姿見習っていきたいと思います。

また参加したいなー
