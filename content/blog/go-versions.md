<!-- textlint-disable -->

+++
author = "yyh-gl"
categories = ["Go"]
tags = ["Tech"]
date = 2020-03-03T09:00:00+09:00
description = "地味にいろいろとあってややこしい"
title = "Goのバージョン管理について"
type = "post"
draft = false
[[images]]
  src = "img/tech-blog/2020/03/go-versions/featured.webp"
  alt = "featured"
  stretch = "stretchH"
+++

<!-- textlint-enable -->


# Goのバージョン管理

<b>注意1：本記事はGo自体のバージョン管理についてです。Go Modulesなどは対象外です。</b> <br>
<b>注意2：基本的にMacユーザを対象にしています。（WindowsとLinuxももちろん好きです）</b>

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

◯◯env系は有名ですよね。<br>
言語のバージョン管理といえばこれです。

導入手順は[公式の手順](https://github.com/syndbg/goenv/blob/master/INSTALL.md)通りなので省略します。

1点はまりどころがあります。<br>
<u>$GOPATHが変わらなくなってしまうという問題</u>です。

本件に関しては以前、僕のブログで対処法を書いているので、<br>
[こちら](https://yyh-gl.github.io/tech-blog/blog/gopath/)を参考にしてみてください。

## ▼ go get（公式サイトに記載のある方法）

（バージョン管理"ツール"とは言えませんが…）

本方法は[公式サイト](https://golang.org/doc/manage-install#installing-multiple)に
記載されている方法です。

```zsh
$ go get golang.org/dl/goX.Y.Z
$ goX.Y.Z download
$ goX.Y.Z version
go version goX.Y.Z linux/amd64
```

コマンド打つたびに、バージョンまで打つのがめんどくさいという方は、<br>
bash や zsh の設定でエイリアスでも貼ってやればOKですね。


# 最新バージョンのインストール方法

冒頭で「基本的に最新バージョンに上げ続ければOK」と述べていたので、<br>
最新バージョンのインストール方法についても言及しておきます。

特に新しいことはなくいろんなサイトで紹介されているのでさらっと流していきます。

## ▼ Homebrew

```zsh
$ brew install go
```

以上です。

標準出力にて「必要ならパスの設定してね」と言われます。<br>
言われたとおりにやればOKです。

## ▼ ソースからのインストール

こちらの方法はHomebrewでのインストールと比べると、少しややこしくなります。

ざっくり手順を説明します。（[公式の説明ページ](https://golang.org/doc/install/source)）

1. Go1.4をインストール

    https://golang.org/doc/install/source#go14

    なぜ、いきなりv1.4をインストールするかというと、<br>
    v1.5以降は全てGoで書かれているため、Go自身でコンパイルできます。
    
    よって、v1.5以降のGoをインストールするために <u>GoをビルドするためのGoが必要になる</u> というわけです。<br>
    （ややこしいですが、[セルフホスティング](https://ja.wikipedia.org/wiki/%E3%82%BB%E3%83%AB%E3%83%95%E3%83%9B%E3%82%B9%E3%83%86%E3%82%A3%E3%83%B3%E3%82%B0)ってやつですね）

1. Gitから最新版のソースをもってくる

    https://golang.org/doc/install/source#fetch

1. 最新版をインストール

    https://golang.org/doc/install/source#install

1. 動作確認

    https://golang.org/doc/install/source#testing

（ただのリンク集になっていますが）以上です。

## ▼ 公式サイトからのインストール

この方法の方がソースからインストールするより簡単かなと思います。

こちらの方法も[公式サイト](https://golang.org/doc/install)に詳しい説明があるのでざっくりの説明だけ載せておきます。<br>
（[公式サイト](https://golang.org/doc/install)には
LinuxおよびWindowsについてもちゃんと説明があります）


1. Go本体をダウンロード

    https://golang.org/doc/install#download

    [次節の『Go install.』](https://golang.org/doc/install#install)で
    指定したOS用のGoがダウンロードされるので、Macを選択した上でダウンロードを開始します。

1. インストール

    https://golang.org/doc/install#install

    ダウンロードした`.pkg`ファイルを開くとインストールが勝手に始まります。

1. PATH設定

    https://golang.org/doc/install#install

    インストールして得たバイナリに対してPATHを通します。

以上です。


# まとめ

バージョン管理ツールおよびインストール方法はいくつか存在します。

使いやすい方法でどうぞ！
