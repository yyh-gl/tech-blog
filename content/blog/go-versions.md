+++
author = "yyh-gl"
categories = ["Go"]
tags = ["Tech"]
date = "2020-03-03T00:00:00Z"
description = "Goの後方互換性すばらしい"
title = "Goのバージョン管理について"
type = "post"
draft = false
[[images]]
  src = "img/tech-blog/2020/03/go-versions/featured.webp"
  alt = "featured"
  stretch = "stretchH"
+++


# Goのバージョン管理

<b>注意1：本記事はGo自体のバージョン管理についてです。Go Modulesなどは対象外です。</b> <br>
<b>注意2：基本的にMacユーザを対象にしています。（WindowsもLinuxも好きですよ😅）</b>

<br>

開発において言語のバージョン管理はつきものだと思います。<br>
そのニーズは高く、rbenv や nodenv といったバージョン管理ツールが普及しています。

ただし、Goの場合は少し話が変わってきます。<br>
もちろんGoでも goenv が用意されていますが、<br>
（今のところ）Goは後方互換性が担保されているので、<b>基本的に最新バージョンに上げ続ければOK</b>です。 

<br>

…と言いつつも、GAEを使用するといった場合に、どうしてもバージョン管理したくなることがあると思います。

そこで今回はまずGoのバージョン管理ツールの紹介をした後で、<br>
最新バージョンをインストールする方法を紹介していきたいと思います。

# Goのバージョン管理ツール

## ▼ [goenv](https://github.com/syndbg/goenv)

○○env系は有名ですよね。<br>
言語のバージョン管理といえばこれです。

導入手順は[公式の手順](https://github.com/syndbg/goenv/blob/master/INSTALL.md)通りなので省略します。

1点はまりどころがあります。<br>
<u>$GOPATHが変わらなくなってしまうという問題</u>です。

本件に関しては以前、僕のブログで対処法を書いているので、<br>
[こちら](https://yyh-gl.github.io/tech-blog/blog/gopath/)を参考にしてみてください。

## ▼ go get（公式おすすめ）

（バージョン管理ツールではないですが…👼）

本方法が[公式おすすめ](https://golang.org/doc/install#extra_versions)の方法です。

```zsh
$ go get golang.org/dl/goX.Y.Z
$ goX.Y.Z download
$ goX.Y.Z version
go version goX.Y.Z linux/amd64
```

コマンド打つたびに、バージョンまで打つのがめんどくさいという方は、<br>
bash や zsh の設定でエイリアスでも貼ってやればOKですね。


# 最新バージョンのインストール方法

次は常に最新バージョンをインストールする方法です。<br>
特に新しいこともなくいろんなサイトで紹介されているのでさらっと流していきます。

## ▼ Homebrew

```zsh
$ brew install go
```

以上です！

標準出力にて「必要ならパスの設定してね」と言われます。<br>
設定したい場合は、言われたとおりにやればOKです。

## ▼ ソースからのインストール

こちらの方法は先述の方法と比べると、少しややこしくなります。

ざっくり手順を説明します。（[公式の説明ページ](https://golang.org/doc/install/source)）

1. Go1.4をインストール

    https://golang.org/doc/install/source#go14

    なぜ、いきなりv1.4をインストールするかというと、<br>
    v1.5以降は全てGoで書かれているため、Go自身でコンパイルすることができます。
    
    よって、v1.5以降のGoをインストールするために <u>GoをビルドするためのGoが必要になる</u> というわけです。<br>
    （ややこしいですが、[セルフホスティング](https://ja.wikipedia.org/wiki/%E3%82%BB%E3%83%AB%E3%83%95%E3%83%9B%E3%82%B9%E3%83%86%E3%82%A3%E3%83%B3%E3%82%B0)ってやつですね）

1. Gitから最新版のソースをもってくる

    https://golang.org/doc/install/source#fetch

1. 最新版をインストール

    https://golang.org/doc/install/source#install

1. 動作確認

    https://golang.org/doc/install/source#testing

（ただのリンク集になっていますが）以上となります。


# まとめ

Goでは常に最新版を使えばいい！