+++
author = "yyh-gl"
categories = ["React"]
date = "2019-09-18"
description = "React Hooks 楽しい"
title = "React.memo について調べたのでメモを残しておく"
type = "post"
draft = false
[[images]]
  src = "img/tech-blog/2019/09/react_memo/featured.png"
  alt = "featured"
  stretch = "stretchH"
+++


# React.memo とは

[公式ドキュメント](https://ja.reactjs.org/docs/react-api.html#reactmemo)を見ると、

> これは React.PureComponent に似ていますが、クラスではなく関数コンポーネント用です。

とあります。

つまり、 React.PureComponent を関数コンポーネントで実現するための手段らしいです。


# React.PureComponent とは

[公式ドキュメント](https://ja.reactjs.org/docs/react-api.html#reactpurecomponent)を見ると、

> React.PureComponent は React.Component と似ています。
> 両者の違いは React.Component が shouldComponentUpdate() を実装していないことに対し、
> React.PureComponent は props と state を浅く (shallow) 比較することでそれを実装していることです。

とあります。

<u>shouldComponentUpdate() によって、どういった変更があれば再描画するかを定義する</u>ようです。

<br>

追加でこの[参考記事](https://the2g.com/2814)を読んでみると、

> PureComonentはprops及びstateの変更を検出した場合のみレンダリングを行います。
> Messageコンポーネントではmessage propsの変更を察知し、必要分の更新を行うようになります。

とあります。

自分で再描画条件を定義できるので、無駄な再描画を省くことができ、パフォーマンス向上を実現できるんですね。。

→ React.PureComponent を用いることでパフォーマンスを向上させることができるようです。<br>
（参考記事内にもあるとおり銀の弾丸ではないようですが…）


# 浅い比較 とは

> shouldComponentUpdate() は浅い比較によって変更検知を行う。

とありましたが、浅い比較とはなんでしょうか。<br>
（shouldComponentUpdate() のデフォルトが浅い比較というだけで、オリジナルの比較方法を実装可能なようです）

さきほどの[参考記事](https://the2g.com/2814)にて説明されていました。

> 浅い比較というのは、簡潔に述べるとオブジェクトの参照先が同じであれば等しいと見なすことです。

参照先しか見ていないので、中身は見ていないということですね。<br>
（このような実装なのは、React の思想として、props や state といったデータは immutable であるべきだとしているからだと思います）

## ちなみに
ミューテート（変更）せずに新しいオブジェクトを作るには下記のようにして、新しいオブジェクトを作って返してやればいいようです。（[参考](https://ja.reactjs.org/docs/optimizing-performance.html#the-power-of-not-mutating-data)）

```javascript
Object.assign({}, prevState, {color: 'blue'});
```


# React.memo 実践（していく予定）

React.memo の使い方は

- [公式ドキュメント](https://ja.reactjs.org/docs/react-api.html#reactmemo)
- [他の方のブログ記事](https://aloerina01.github.io/blog/2018-10-25-1)

上記を見ればだいたいわかりそうです。

会社のプロジェクトに導入できそうなところあったら使ってみたいと思います💪

