+++
author = "yyh-gl"
categories = ["勉強会", "Go"]
date = "2019-11-01"
description = "DeNAさん主催のGolang勉強会"
title = "【DeNA.go #3】Go活用事例やパフォーマンスチューニングの話聞いてきた"
type = "post"
draft = false
[[images]]
  src = "img/tech-blog/2019/11/denago_3/featured.png"
  alt = "featured"
  stretch = "stretchH"
+++


# DeNA.go #3
- [connpass](https://dena.connpass.com/event/150676/)
- ハッシュタグ：[#DeNAgo](https://twitter.com/hashtag/DeNAgo)

初参加です！<br>
ビールとお弁当もらいました。

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/11/denago_3/dinner.JPG" width="450">

そしてなんとなんと <br>
k8sの技術書をいただいちゃいました！！！<br>
もちろんステッカーもありましたよ👍

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/11/denago_3/k8s.JPG" width="450">


# 1. [Go活用事例]安全運転支援サービスを支える運用サイト
<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/11/denago_3/session1.JPG" width="450">

登壇者：@suhirotaka さん <br>
オートモーティブ事業本部スマートドライビング部システム開発グループ

[スライド](https://speakerdeck.com/suhirotaka/gohuo-yong-shi-li-an-quan-yun-zhuan-zhi-yuan-sabisuwozhi-eru-yun-yong-guan-li-sisutemu)


## 主題

管理画面を Golang で作成


## Railsで作ってるものをGolangで作る理由

- 実証実験時はスピード重視でRails
- 本サービスはパフォーマンス重視でGolang

順次Golangに書き換えていく


## Golangのフレームワーク

GolangのWAF（Web Application Framework）には

- フルスタック・MVC
- ミニマル・高速

の2種類がある

この辺の話は、僕の[旧ブログ](https://yyh-gl.hatenablog.com/entry/2019/02/08/195310?_ga=2.260731597.131948474.1572615746-732745836.1548899089)にもいろいろ書いているのでどうぞー

DeNAではフルスタック・MVCを選択


## GolangにおけるフルスタックなWAF

- Beego：採用！
- Revel：開発が止まってきている
- Iris：プロジェクトの運用がうまくいっていないようだった


## Beego

- フルスタックのMVCフレームワーク
- ORMまでついてる
- セッション管理、ロガー、キャッシュなどのライブラリがいろいろついてるけど、全てモジュール化されていて、部分的に他のライブラリを使うことができる
- Railsライクなフレームワーク
  - Railsのbefore/after_actionに相当するものもある（Prepare(), Finish()）


## ライブラリ

使用ライブラリは[こちら](https://speakerdeck.com/suhirotaka/gohuo-yong-shi-li-an-quan-yun-zhuan-zhi-yuan-sabisuwozhi-eru-yun-yong-guan-li-sisutemu?slide=32)

こういうの教えてくれるのめっちゃ嬉しい

- ORM：GORM
- ロガー：logrus
- PDF生成：gopdf → 日本語もきれいにでるので最高にクール
- 画像生成：gg
- バーコード生成：Barcode


# 2. WebシステムのパフォーマンスとGo

（写真撮り忘れた…）

登壇者：（@karupanerura）
ゲーム・エンターテインメント事業本部ゲーム事業部Publish統括部共通基盤部アライアンスシステムグループ

[スライド](https://speakerdeck.com/karupanerura/websisutemufalsehahuomansutogo)


## Webシステムにおけるパフォーマンスとは

たくさんリクエスト処理できる かつ リソース消費が少ないのが <br>
システム全体で見たときの理想的なパフォーマンス


## パフォーマンスチューニングのいろいろ

詳しいチューニング方法は[こちら](https://speakerdeck.com/karupanerura/websisutemufalsehahuomansutogo?slide=24)

この中で初めて知ったものをピックアップ↓

### ◎ Server Sent Events

- HTTPコネクションを持続させる
- WebSocketより扱いが簡単らしい

### バファリングの諸注意

結局リソースを消費していることに違わないので、メモリ管理はちゃんとしないといけない

## Q&A

Q. sync.Pool でメモリ効率は良いがメモリは消費していくとは？（[該当スライドページ](https://speakerdeck.com/karupanerura/websisutemufalsehahuomansutogo?slide=40)）

A. Poolが居続けるからメモリ消費するよって話

<br>

Q. SetMaxOpenConnsの数ってどうやって決めるのがいい？

A. DBへのコネクションがどれくらいかとかを可視化して、そのデータに基づいて大きすぎず、小さすぎずの数を探していく（最終的には手探り）

<br>

Q. バッファリングの使い所

A. バッファリングよりシャーディングで対応できることが多い <br>
シャーディングで対応した場合、アプリケーション（実装）がシンプルになる









