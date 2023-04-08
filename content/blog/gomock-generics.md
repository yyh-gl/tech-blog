<!-- textlint-disable -->

+++
title = "gomockのgenerics対応状況"
author = "yyh-gl"
categories = ["Go"]
tags = ["Tech"]
date = 2023-04-09T00:25:48+09:00
description = "対応されているがリリースはまだ"
type = "post"
draft = false
[[images]]
  src = "img/2023/04/gomock-generics/featured.webp"
  alt = "featured"
  stretch = "stretchH"
+++

<!-- textlint-enable -->

# gomock

[gomock](https://github.com/golang/mock)はGo用のモック生成ツールです。

今回はこのgomockのgenerics対応状況について共有します。

# gomockのgenerics対応状況

残念ながらgomockはまだgenericsに対応していません。

ただし、generics対応がリリースされていないだけで、
すでに`main`ブランチには
[generics対応のPR](https://github.com/golang/mock/pull/640)がマージされています
（Issueは[こちら](https://github.com/golang/mock/issues/621)）。
したがって、`go install github.com/golang/mock/mockgen@main`とすればgenerics対応したgomockを利用可能です。

# いつリリース？

`v1.7.0`としてリリース予定らしく、すでにタグは作成されています。
https://github.com/golang/mock/releases/tag/v1.7.0-rc.1

ただ、タグが作成されてからもうすぐ1年が経とうとしています…

無事リリースされることを祈りましょう。

<br>

（タグがあるので`go install github.com/golang/mock/mockgen@v1.7.0-rc.1`でもOKですね）


# まとめ

<!-- textlint-disable ja-technical-writing/sentence-length -->

generics対応したgomockを使いたい場合は、
`go install github.com/golang/mock/mockgen@main`か
`go install github.com/golang/mock/mockgen@v1.7.0-rc.1`を実行しましょう。

<!-- textlint-enable ja-technical-writing/sentence-length -->
