+++
author = "yyh-gl"
categories = ["Go"]
date = "2019-06-13"
description = ""
title = "【goenv】GOPATH が変わらないときの対処法"
type = "post"
draft = false
[[images]]
  src = "img/tech-blog/2019/06/gopath/featured.png"
  alt = "featured"
  stretch = "stretchH"
+++


# GOPATH が変わらない…

今日こんな現象に遭遇した。

```
$ export GOPATH=/Users/yyh-gl/workspaces/Go

$ echo $GOPATH
/Users/yyh-gl/workspaces/Go

$ go env GOPATH
/Users/yyh-gl/go/1.12.5
```

GOPATH が書き換わらない。


# 解決方法

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/06/gopath/help.png" width="600">


社内Slack で適当につぶやいたら、同期が助けてくれた（神）

画像にある Qiita のリンクが [こちら](https://qiita.com/gimKondo/items/add08298e24ae400505e)

ちなみに僕の環境の goenv は バージョン 1.12.5 だったので、2系に上げなくても発生する模様。

> （追記：19/06/14）またまた同期が教えてくれました。<br>
> [こちらの記事](https://blog.ast.moe/blog/2019-03-26/) によると、
> goenv による管理は バージョン 1.12 からとのこと。

<br>

結論：<u>goenv が GOPATH を管理しようとしてた</u>


<br>

goenv の管理から外してやるには `GOENV_DISABLE_GOPATH=1` にしてやればOK。

僕は `zshrc` に以下のとおり追記しました。

`export GOENV_DISABLE_GOPATH=1`

（zshrc の読み込み直しを忘れずに）


# 結果

```
$ go env GOPATH
/Users/yyh-gl/workspaces/Go
```

変わった。よかった
