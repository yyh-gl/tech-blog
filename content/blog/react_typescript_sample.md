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

説明はこれくらいにして、ここからは簡単なコンポーネントを作りながら、<br>
実際に TS に触れていきたいと思います。

---
# 静的型付け
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

Tuple や Never といった見慣れない型もあると思います。<br>
型について、より詳細に知りたい方は、<br>
[こちらの記事](https://qiita.com/uhyo/items/e2fdef2d3236b9bfe74a)が参考になると思います。

<br>

型の宣言方法は以下のとおりです。

```typescript
function greeter(person: string) {
    return "Hello, " + person;
}

const user = "Jane User";

document.body.textContent = greeter(user);
```

1行目にて、greeter() に person という string 型の引数を渡すことが明示されています。



<br>

---
# Interface
---


<br>

---
# 最新安定版 3.7 で追加された機能
---

2019年11月7日にメジャーアップデートが行われ、バージョン 3.7 がリリースされました。<br>
ここからは 3.7 でどのような機能が







<img src="http://localhost:1313/tech-blog/img/tech-blog/2019/09/-/-" width="600">
<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/09/-/-" width="600">
