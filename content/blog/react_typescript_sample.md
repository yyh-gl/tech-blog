+++
author = "yyh-gl"
categories = ["React", "TypeScript"]
date = "2019-11-24"
description = "TypeScript Advent Calendar 2019 2日目"
featured = "react_typescript_sample/featured.png"
featuredalt = "画像がどこかへ逝ってしまったようだ…"
featuredpath = "date"
linktitle = ""
title = "【React+TS】ガチ素人のTypeScript入門"
type = "post"

+++


<br>

---
# TypeScript Advent Calendar 2019
---

本記事は TypeScript Advent Calendar 2019 の 2 日目の記事です。

内容としては、TypeScript（TS）ガチ素人の僕がお届けする、TS 入門です。<br>
したがって、TS 上級者用ではなく、<br>
これから TS を使っていこうとされている方向けです。<br>

基礎的な内容から入り、<br>
最終的には、企業や個人の技術ブログを参考に、<br>
React の実プロジェクトにおいて、<br>
どのように TS が使われているのか紹介できればと思います。

今日の記事を読んで TS に入門し、<br>
今後の TS Advent Calendar をお楽しみいただけると幸いです！

<br>

---
# TypeScript とは
---

<img src="http://localhost:1313/tech-blog/img/tech-blog/2019/11/react_typescript_sample/ts.png" width="200">

[TypeScript（TS）](https://www.typescriptlang.org/index.html) は Microsoft 社によって開発され、<br>
現在は [OSS](https://github.com/microsoft/TypeScript) として開発が進められています。

「TS とは何か」を簡単に説明すると、<br>
<u>JavaScript に対して、省略も可能な静的型付けとクラスベースオブジェクト指向を加えたスーパーセット</u> です。

[公式サイト](https://www.typescriptlang.org/) はこちらです。

2019年12月2日現在、最新版は 3.7.2 となっています。

<br>

では、実際にコードを交えながら基礎的な部分を説明していきます。<br>
ただし、応用編で使用する内容に絞って説明していきますので、<br>
その点はご了承ください🙇‍

<br>

---
# 型
---

では、早速、TS の型に触れていきましょう。<br>
TS で使用できる基本的な型として以下のものがあります。

- Boolean
- Number
- String
- Array
- Tuple
- Enum
- Any
- Void
- Null and Undefined
- Never
- Object

だいたいの型は他言語でも用意されているので、<br>
説明がなくても理解できると思います。

Tuple や Never といった見慣れない型もあると思いますが、<br>
他サイトでたくさん説明されているので割愛します。<br>
気になる方は、下記サイトを参考にしてみてください。
- [公式サイト](https://www.typescriptlang.org/docs/handbook/basic-types.html)
- [Qiita記事](https://qiita.com/uhyo/items/e2fdef2d3236b9bfe74a)

<br>

型の宣言方法は以下のとおりです。

```typescript
function greeter(person: string) {
    return "Hello, " + person;
}

const user: string = "Jane User";

document.body.textContent = greeter(user);
```

1行目にて、greeter() に person という string 型の引数を渡すことが明示されています。<br>
また、関数定義においては、引数と戻り値の型を宣言しています。

<br>

---
# インターフェース
---

次にインターフェースについて見ていきます。<br>
（本来、インターフェースは JavaScript に無い仕様です）

インターフェースはクラスやオブジェクトの規格を定義します。<br>
クラスだけでなく、オブジェクトの規格を定義できるため、<br>
API のレスポンスとして返ってくるオブジェクトを定義することが可能です。

有用性の高い仕様のひとつではないでしょうか。

定義方法は以下のとおりです。

```typescript
interface LabeledValue {
    label: string;
}

function printLabel(labeledObj: LabeledValue) {
    console.log(labeledObj.label);
}

let myObj = {size: 10, label: "Size 10 Object"};
printLabel(myObj);
```

上記コードは、`LabeledValue` というインターフェースと、<br>
そのインターフェースを満たす `myObj` というオブジェクトを定義しています。<br>
加えて、`printLabel()` という `LabeledValue` インターフェースを受け取る関数が用意されています。

`myObj` は `label` を持っているので、`LabeledValue` インターフェースを満たしており、<br>
`printLabel()` に引数として渡すことが可能です。

<br>

クラスの規格定義としてのインターフェースは以下のとおりです。<br>
こちらは他言語でよく見る形なので説明は省略します。

```typescript
interface ClockInterface {
    currentTime: Date;
    setTime(d: Date): void;
}

class Clock implements ClockInterface {
    currentTime: Date = new Date();
    setTime(d: Date) {
        this.currentTime = d;
    }
    constructor(h: number, m: number) { }
}
```

なお、クラスという概念は JavaScript（ES6） に組み込まれているクラスの機能を <br>
ES6 以前の JavaScript でも使えるようにしただけ（←重要）であるため説明は省略します。


<br>

---
# 入門時の落とし穴
---

僕が TS を初めて触ったときに戸惑ったのが以下のエラーでした。

```
Could not find a declaration file for module 'react-router-config'. '/hoge/index.js' implicitly has an 'any' type.
  Try `npm install @types/react-router-config` if it exists or add a new declaration (.d.ts) file containing `declare module 'react-router-config';`  TS7016

    1 | import React from 'react';
  > 2 | import { renderRoutes, RouteConfigComponentProps } from 'react-router-config';
      |                                                         ^
    3 | import './App.css';
    4 | 
    5 | const App: React.FC<RouteConfigComponentProps> = ({ route }) => {
```

このエラーが何を言っているかと言うと、<br>



<br>

---
# 実践編
---

<br>

## ライブラリ使用時の注意

<br>

## API リクエスト

<br>

## 

<br>

---
# 最新安定版 3.7 で追加された機能
---

2019年11月7日にメジャーアップデートが行われ、バージョン 3.7 がリリースされました。<br>
ここからは 3.7 でどのような機能が







<img src="http://localhost:1313/tech-blog/img/tech-blog/2019/09/-/-" width="600">
<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/09/-/-" width="600">
