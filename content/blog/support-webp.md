+++
title = "ブログの画像をWebPに変えた話とSafariで表示されない件について"
author = "yyh-gl"
categories = ["Web全般"]
tags = ["Tech"]
date = 2020-11-26T13:50:31+09:00
description = "Safariはv14からじゃないと表示できない😇"
type = "post"
draft = false
[[images]]
  src = "img/tech-blog/2020/11/support-webp/featured.webp"
  alt = "featured"
  stretch = "stretchH"
+++

# 画像の形式をWebPに変えた

本ブログにて、Lighthouse使ってみると、表示速度あたりで怒られていたので、<br>
まずはサムネ画像をWebPに変えてみました。

WebPとは、Googleが開発しているオープンな静止画像フォーマットで、<br>
トラフィック量軽減と表示速度短縮を目的しています。 （[wikiから拝借](https://ja.wikipedia.org/wiki/WebP)）


# WebPを採用した結果

以下のツイートのとおりです。

たまたま100が撮れただけで、もう一回テストしみると少し落ちました。<br>
それでも90台はキープできていそうです。

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">個人ブログ（Desktop版）のPerformanceが78だったので、画像をwebpに変えたら一気に100になった🎊<br>（モバイルは未だに70切ってる😇） <a href="https://t.co/VNxztIsR28">pic.twitter.com/VNxztIsR28</a></p>&mdash; hon-D (@yyh_gl) <a href="https://twitter.com/yyh_gl/status/1329487413400375296?ref_src=twsrc%5Etfw">November 19, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>


# Safariでは注意が必要

多くのブラウザでWebPへの対応が既に完了しています。<br>
ただし、Safariに関してはv14でようやく対応しました。

[対応状況](https://ja.wikipedia.org/wiki/WebP#%E5%AF%BE%E5%BF%9C%E7%92%B0%E5%A2%83)

Safari v14は2020年9月17日（日本時間）にリリースされたばかりなので、<br>
まだ画像をちゃんと見れないユーザが多く存在すると思われます。

[リリースノート](https://developer.apple.com/documentation/safari-release-notes/safari-14-release-notes)

<br>

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">Safariのwebp対応ってバージョン14からだったんだ😇<br><br>自分のブログに来る人の90%弱がSafariじゃないから、まぁいいか←</p>&mdash; hon-D (@yyh_gl) <a href="https://twitter.com/yyh_gl/status/1331834104254369794?ref_src=twsrc%5Etfw">November 26, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

<br>

> 自分のブログに来る人の90%弱がSafariじゃないから、まぁいいか←

嘘です、10%ほどの方々すみません🙇‍♂ <br>
WebPにしたのはサムネ画像だけで、記事本文内の画像はWebPじゃないので許してください。。。
