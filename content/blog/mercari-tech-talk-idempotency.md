+++
author = "yyh-gl"
categories = ["勉強会"]
tags = ["Tech"]
date = 2019-12-20T09:00:00+09:00
description = "冪等性 is 大事"
title = "【merpay Tech Talk】マイクロサービスの冪等性に関する勉強会"
type = "post"
draft = false
[[images]]
  src = "img/2019/12/mercari-tech-talk-idempotency/featured.webp"
  alt = "featured"
  stretch = "stretchH"
+++


# Tech Talk vol.2 Backend Engineer 〜マイクロサービスの冪等性〜

- [connpass](https://mercari.connpass.com/event/157009/)
- ハッシュタグ：[#merpay_techtalk](https://twitter.com/hashtag/merpay_techtalk)
- [質問板](https://handsup.cloud/r/VEQvy2o#new-comment)


merpay社で開催された勉強会です。<br>
参加者のツイートも含めてメモを残しておきます。

かなり雑なのでコンテキストが読み取れないところもあると思いますが、<br>
なにかの参考になれば幸いです。

（[@sonatard](https://twitter.com/sonatard) さんの実況にとても助けられました。
ありがとうございました！）


# 1. 500万ユーザーを支える残高の冪等性

登壇者：（@knsh14）

<s>スライド</s>

[参考スライド](https://speakerdeck.com/kazegusuri/builderscon-tokyo-2019-open-skt)
（ベースとなる話は↑これ）


## 残高管理サービス（Balance Service）

使ってるDBはCloud Spanner

外部サービスや他のマイクロサービスには依存してない

DeleteなしでCRUのみ

かなりシンプルで冪等性を担保しやすい


## 冪等性があるAPI

最初に成功した一度だけ処理される

同じリクエストを何回繰り返しても内部的には処理されない

何度リクエストしても同じ結果が返ってくる
何度でもリトライできる

取引IDが保存されていれば既に行われた取引である

## 冪等性の担保

- 冪等性キーが同じ
  外部から指定される取引IDのこと
- 残高の種類が同じ
  ポイント/メイルペイ残高 など
- 操作する金額が同じ

## 冪等なレスポンス

- レスポンスはDBから引ける情報で組み立てる
- 取引IDから引ける情報
  - 取引後残高は返さない

[Twitterメモ](https://twitter.com/matsukaz/status/1207250011391553536)

## 冪等なAPIでのエラー

- リトライしても良いエラー：ex. タイムアウト
- リトライだめなエラー：ex. 残高不足


## 誰がどう使うのか？

- リクエストを投げる側の使い方1つで簡単に冪等性が壊れる
→ ex. 取引IDを毎回変えるとか


# 2. コード決済における冪等性と整合性

登壇者：（@susho0220）

[スライド](https://speakerdeck.com/susho/number-merpay-techtalk)

モノリスであれば、リクエスト、レスポンス内のトランザクションで整合性を保てる。

マイクロサービスでは、トランザクションが分かれるため、<br>
決済の進捗状態を保持するDBを用意し、状態を管理 <br>
→ Pending、Authorized、Captured

メルペイのコード決済では、<br>
Cloud Pub/Subを使ってAuthorizedまでを同期処理、Captureは非同期処理で行っている。<br>

同期処理の責務を最小限に抑えて、処理自体もシンプルにするのが狙い。<br>
→ リトライによる不整合の解消が重要な処理は、自動的にリトライをしてくれるPubSubで非同期にすることで、実装がシンプルになる


# 3. バッチ処理と冪等性

登壇者：（@kaznishi1246）

[スライド](https://speakerdeck.com/kaznishi/20191218-merpay-techtalk)


### バッチ処理

回復可能かどうかはとても大事

冪等性があれば回復後のリトライも安心して行える

### 何回実行されても大丈夫（冪等）なバッチ処理を作る

バッチのリトライ戦略には大別して下記2パターンがある。<br>
（メルペイではどちらもある。）

- 処理済みも含めてやり直す

全ての処理が冪等であることが求められる。

難しいことをあまり考えなくて良い。（if文減る）<br>
ただし、時間・リソースをくう

個々のステップが冪等である前提が必要。<br>
他のマイクロサービス連携してる場合は、リクエスト先の冪等性も必要

- 一度処理したものはスキップする

実装が複雑になる。（ステータスなどで条件分岐）<br>
ただし、未処理のみ対応するので所要時間が短く、軽い

「どこまで処理したか」をどこかに保持する必要がある

### 外部サービスを使用する場合はどうする？

外部サービスが冪等ならば何度リトライしても大丈夫だから無問題

ただし、外部サービスによっては、ロールバックされるものもあるので、そういう場合は検討が必要


### バッチを回す前の確認

バッチ処理が処理する材料データは揃っているか確認する <br>
（前段のバッチが終わっているか確認）<br>
→各バッチの終了状態をDBで管理している


# 4. パネルディスカッション

登壇者：@kazegusuri, @knsh14, @susho0220, @kaznishi1246

[質問板](https://handsup.cloud/r/VEQvy2o#new-comment)

会場からの質問が多く、Q&Aだけで終了しました。<br>
とても興味深い話ばかりでした。

### 冪等性キーの発行や管理はどうしてるんだろう？

Balance Service の前段にある Payment Service にて発行 <br>
→ UUID v4 で発行（基本的に被ることはないはず）


### マイクロサービス間のデータ不整合を修正するバッチはどれくらいの時間間隔で実行しているのでしょうか？

30分に1回<br>
15分とか短くしたいが、実行中の可能性も出てくるので、難しい<br>
10, 15分あける必要があるが、コンサバで30分


### 冪等性がないことにより発生した問題や障害などは過去にありましたでしょうか？（言える範囲で結構です）

- 最初から意識されていたので特になかった

- 正しくリトライされ無かった経験はある

リクエストを受けたら、別マイクロサービスの情報を使用して処理を行っていた。<br>
しかし、その別マイクロサービスからもらうデータが変わったことでエラーとなった。<br>
→解決策として、Bodyデータ（別マイクロサービスの？）もDBに保存して使いまわした

[Twitterメモ](https://twitter.com/sonatard/status/1207263596494802944?s=20)


### トランザクションを使う以外にべき等性を担保する方法って例えばどんなのがありますか

ユニーク制約を保証できるものならOK<br>
ex. ユニーク成約に引っかかるようになったらロールバックとか


### カオスエンジニアリング的なことってやってたりするんですか

Istioでfalte injection機能で取り組もうとしているが、想定した機能ではなかったのでまだ実施していない

Cloud Spannerの部分をMockにしてランダムでエラーを返すなどのテストを実行している<br>

[Twitterメモ](https://twitter.com/sonatard/status/1207264613269590016?s=20)


### 売掛決済やクレカ決済のようにauthorized->capturedに数日かかる場合はありますか？その場合にauthorizedを解放することはありますか？


### statusをどうやって管理しているのか知りたい updateしているのか、eventソーシング的に組み立てているのか

update でやってる。<br>
イベントソーシングに挑戦するほどの余裕がなかった。

ただ、updateだといつアクションが起こったのか分からなくなるから、ログを残す必要がある。


### マイクロサービス化するとチームごとに指針が違ったりすると思いますが、冪等性等外せないところを担保するためにどのような組織的工夫をしていますか。

最初はkazegusuriさんが口酸っぱく言っていたが、今はみんなが意識できている。

[Twitterメモ](https://mobile.twitter.com/sonatard/status/1207266041090297856<br>)

デザインドックを書いてレビューしてから取り組む<br>
冪等性の理解の普及をしてきた<br>
そのうえでチームに任せている

### 取引IDが重複する可能性を考慮してるの、そもそもなんで重複する可能性があるんだろ。重複はしないけど、マイクロサービスの１サービスの中では重複するかしないかは知らないから一応考慮しておくという感じなのかな

IDが絶対に被らない生成方法がある？

冪等性キーだけで冪等性を保証しようとすると、<br>
リトライ時のパラメータが変わった時に問題が起きる可能性があるので、<br>
リクエストのボディーなども見るようにしたかった<br>
(が、今は冪等性キーだけしか見ていない？<br>

[Twitterメモ](https://twitter.com/sonatard/status/1207266711117844482)


### 残高の整合性をどう担保しているのか聞いてみたい

Balance Service では増えた減ったのアクションだけ記録、<br>
別で会計サービス?とかが残高を持っていたりして、そこと照らし合わせたりはする


### authorizedになった時点でcapturedには100%遷移できるという前提でしょうか？

yes


### なぜBalance Serviceでサービスで残高などをレスポンスとして返してはいけないのかがわからなかったです

「結果いくらになった」というのは変わるからだめ


### この話の中で、バッチの実行履歴テーブルを作ってる・場合によってはワークフロー化とかもある、という話があったと思うんですが、ワークフロー化せず履歴テーブルを作る選択をしたのはどうしてでしょうか？バッチの中での各トランザクションごとに再開ポイント・スキップできるできない、みたいな話もあったと思うんですけど、各トランザクションごとに個別バッチ化してワークフロー組んだら便利だったのかなーって思うのですがどうでしょうか？

> 各トランザクションごとに個別バッチ化しワークフローを組む

という部分について、処理が複雑なところがあるので、できるか分からない。



### 取引IDだけじゃなくてコンテンツの中身までチェックする理由は？

取引IDが同じで処理内容が異なるリクエストの場合に、<br>
処理済みOKと誤って返さないようにという配慮の観点もあるとのこと。<br>
勉強になりました、良き 

[Twitterメモ](https://twitter.com/laqiiz/status/1207268316437368832)


### 取引IDを一意にするのは難しい？

そんなことはない


### 「冪等性」の重要性は十分に理解しているのですが、そもそもどういう問題を解決するためでしょうか？

不整合を修復すること。


### 冪等性キーとレスポンスは永遠に保持し続けるのか、定期的に削除したほうがいいのか気になりました

今のところ消す予定はない

一般的には消す方が多い。
→2時間とかで消すパターンが多い

メルペイは消すのがめんどくさかったから、残せばいいんじゃない？で残ってたはず


### バッチの実行間隔短くすると周回遅れが起きたり、処理中掴むのは確かにありそう。だけど、決済で、数十分の処理中はあるんだろうか？

まぁ、ないです。ｗ

5分くらいにはできるかなとは思っている。


### バッチにより不整合を解消することが起きるのか

GCPのネットワークの問題で不整合が起きていることはある


### uuid v4だとしても衝突する場合があるのですが、ユニーク性はどう担保してますか?

DBに保存しており、ユニーク制約があるので大丈夫


### 不整合を修正するバッチがこけ続けたことはないですか？

あります。

人力になるところもあるので、気付ける仕組みづくりをしている


### ここだけの話

メルペイはかなりオープンに話しているから、特に無いｗ


### バッチ処理が増えてくると、何がどのタイミングでデータにアクセスしているか管理しきれなくなる場合があると思いますが、そのあたりの課題感はありますか？システム全体の処理を把握されている方が担保しているのでしょうか？

そこまで複雑にはなっていない。<br>
ある程度マイクロサービス内で閉じた状態になっている。<br>
だから、今のところ特になにもしてないけど大丈夫


全体を把握している人はいない。<br>
なんとなく分かっている人がいる？ので、なにかあったらその人中心に動くかなぁ。


### マイクロサービス意識しすぎて、コードペイメントとインナーペイメント別けるとかやりすぎじゃない？

QRとかNFCとか決済プロバイダ側で担保すること、<br>
その裏側でのお金の動きを別けるために必要だと感じている。

インナーペイメント：クレカでいくら、残高からいくらって言えば、処理して、その結果を返すやつ

（↑まとめきれませんでした。ですが↓のツイートが参考になります）

[Twitterメモ](https://twitter.com/sonatard/status/1207273197093019648)

Code PaymentとInternal Paymentは分けすぎなのではないか？<br>
外部へのオーソリを投げるのはやり過ぎではないか？もっと簡易的にするべきではないか

Internal Paymentは決済プロバイダのような立場<br>
Code Paymentは、決済プロバイダを使うFintech企業のサービスのような立場


# 最後に

<b>「自分のマイクロサービスだけでは冪等性を守れないので、そのマイクロサービスを使う他のマイクロサービスのチームとコミュニケーション大事」</b>

[Twitterメモ](https://twitter.com/s_naga03/status/1207255206456524801?s=20)

<br>
