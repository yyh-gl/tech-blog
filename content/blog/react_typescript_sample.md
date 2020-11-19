+++
author = "yyh-gl"
categories = ["React", "TypeScript", "Advent Calendar"]
tags = ["Tech"]
date = "2019-12-02T00:00:00Z"
description = "TypeScript Advent Calendar 2019 2日目"
title = "【React+TypeScript】TypeScript入門"
type = "post"
draft = false
[[images]]
  src = "img/tech-blog/2019/12/react_typescript_sample/featured.webp"
  alt = "featured"
  stretch = "stretchH"
+++


# TypeScript Advent Calendar 2019

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/12/react_typescript_sample/qiita_advent_calendar_2019.png" width="700">

本記事は [TypeScript Advent Calendar 2019](https://qiita.com/advent-calendar/2019/typescript) の 2 日目の記事です。

内容としては、TypeScript 初級者のための TypeScript 入門です。 

基礎的な内容から入り、<br> 
最終的には、企業や個人の技術ブログを参考に、<br>
React の実プロジェクトにおいて、<br>
どのように TypeScript が使われているのか紹介できればと思います。  
（APIリクエスト周りのTypeScript活用事例を紹介）

今日の記事を読んで TypeScript に入門し、<br>
今後の TypeScript Advent Calendar をお楽しみいただけると幸いです！


# 基礎編

## TypeScript とは

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/12/react_typescript_sample/ts.png" width="200">

[TypeScript](https://www.typescriptlang.org/index.html) は Microsoft 社によって開発され、 
現在は [OSS](https://github.com/microsoft/TypeScript) として開発が進められています。

「TypeScript とは何か」を簡単に説明すると、<br> 
<u>JavaScript に対して、省略も可能な静的型付けとクラスベースオブジェクト指向を加えたスーパーセット</u> です。

[公式サイト](https://www.typescriptlang.org/) はこちらで、<br>
2019年12月2日現在、最新版は 3.7.2 となっています。

 

では、実際にコードを交えながら基礎的な部分を説明していきます。<br>
ただし、実践編で使用する内容に絞って説明していきますので、<br> 
その点はご了承ください🙇‍<br>
（足りない情報は[公式ドキュメント](https://www.typescriptlang.org/docs/home.html)を参考にしてください）

## 型

では、早速、TypeScript の型に触れていきましょう。<br>
TypeScript で使用できる基本的な型として以下のものがあります。

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

Tuple や Never といった、他言語では見慣れない型もあると思いますが、<br>
他サイトでたくさん説明されているので割愛します。 

【参考サイト】

- [公式サイト](https://www.typescriptlang.org/docs/handbook/basic-types.html)
- [Qiita記事](https://qiita.com/uhyo/items/e2fdef2d3236b9bfe74a)

 

型の宣言方法は以下のとおりです。

```typescript
function greeter(person: string) {
    return "Hello, " + person;
}

const user: string = "Jane User";

document.body.textContent = greeter(user);
```

1行目にて、greeter() に person という string 型の引数を渡すことが明示されています。<br>
また、変数 `user` は string 型であることが明記されています。

仮に `greeter()` に string 型以外の値を渡すと、<br>
コンパイル時 or IDE 上にエラーが吐かれるので、ミスに気づくことが可能です。

## インターフェース

次にインターフェースについて見ていきます。

インターフェースは本来、JavaScript に無い機能ですが、<br>
TypeScript によってその機能が追加されています。

インターフェースは、クラスやオブジェクトの規格を定義するのに使用します。<br>
クラスだけでなく、オブジェクトの規格を定義できるため、<br>
API のレスポンスとして返ってくるデータ（＝オブジェクト）の規格を定義することが可能です。

有用性の高い機能のひとつではないでしょうか。

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

 

クラスの規格定義としてのインターフェースは以下のとおりです。<br>
こちらは他言語でよく見る形なので詳細な説明は省略します。

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

なお、クラスという概念は JavaScript（ES6） に組み込まれているクラスの機能を<br>
ES6 以前の JavaScript でも使えるようにしたものです。 

 

## 入門時の落とし穴

僕が TypeScript を初めて触ったときに戸惑ったのが以下のエラーでした。

```zsh
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
「ライブラリで使用する関数や変数に関する型宣言情報がないから、どう解釈したらいいか分からん！」<br>
ってことです。

ライブラリは TypeScript のためではなく、JavaScript のためのものなので、<br>
インポートしたライブラリの中には、TypeScript 対応していないものがあるのは当然ですよね。

では、どうするかですが、<br>
`@types` を使ってやればOKです。

## @types

`@types` を使用することで、提供されている型定義ファイルを取得することができます。

[本サイト](https://typescript-jp.gitbook.io/deep-dive/type-system/types)によると、<br>
JavaScriptライブラリの90%に対応しているんだとか。<br>
すごすぎる。。。

例えば、さきほどのエラーに対応する場合は、<br>
`npm install @types/react-router-config` を実行してやることで、<br> 
react-router-config ライブラリの型に関する定義を取得できます。

## 型定義ファイル

もし型定義ファイルが提供されていない場合は、 
自分で型定義ファイルを作る必要があります。 
作るときは[本サイト](https://qiita.com/Nossa/items/726cc3e67527e896ed1e#2-%E5%9E%8B%E5%AE%9A%E7%BE%A9%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB-dts-%E3%82%92%E8%87%AA%E4%BD%9C%E3%81%99%E3%82%8B)
が参考になると思います。

（[こんな技](https://qiita.com/Nossa/items/726cc3e67527e896ed1e#3-require-%E3%81%A7%E3%83%A2%E3%82%B8%E3%83%A5%E3%83%BC%E3%83%AB%E3%82%92%E8%AA%AD%E3%81%BF%E8%BE%BC%E3%82%80)
もあるようですが…）


# 実践編

では、（かなりざっくりと）基本的なことはお話したので、<br>
実践的な内容に入っていきます。

今回は、React + TypeScript を使用します。

ソースは[GitHub](https://github.com/yyh-gl/react-typescript-sample)上にあげています。

## React ＋ TypeScript 環境のセットアップ

React ＋ TypeScript の開発環境は下記コマンドひとつで揃います。<br>
`$ npx create-react-app my-app --typescript`

ここから、src配下のディレクトリ構成を少し変更していきます。<br>
今回は下記のようなディレクトリ構成を取りました。<br>
Webのフロントエンド開発においてよく見られる形ではないでしょうか？

```zsh
$ tree react-typescript-sample
react-typescript-sample
├── package-lock.json
├── package.json
├── public
├── src
│   ├── App.css
│   ├── App.test.tsx
│   ├── App.tsx
│   ├── api
│   │   ├── client.ts
│   │   └── user.ts
│   ├── components
│   ├── index.css
│   ├── index.tsx
│   ├── layouts
│   ├── models
│   │   └── user.ts
│   ├── pages
│   │   └── users.tsx
│   ├── react-app-env.d.ts
│   ├── router
│   │   └── index.tsx
│   └── serviceWorker.ts
├── tsconfig.json
└── yarn.lock
```

なお、今回は説明しやすくするために、<br>
`components` および `layouts` は使用していません。

本来であれば、`pages` は `components` 配下のコンポーネントを組み合わせることにより表現します。<br> 
`components` 配下は、Atomic Design に沿ったディレクトリ構成が取られることが多い気がします。 

また、ページのレイアウト（ヘッダーやフッター、メインコンテンツの位置など）は、<br>
`layouts` 配下のコンポーネントによって表現します。

## API リクエスト

最近のフロントエンドでは、<br>
フロントから API リクエストを行うシーンが多くあると思います。

そのさいに、API のレスポンスが<br>
どういったフィールドを持っているのかが定義されていれば、<br>
以下のようなメリットがあります。

- レスポンス内容がフロントのコードから読み取れる
  - 存在しないパラメータにアクセスしようとするといった凡ミスを無くせる
- IDE による補完が効く

では、実際にどうやって API のレスポンスを定義するのか見ていきます。

今回は、例としてユーザ情報を受け取る API を用意しました。 
下記のような JSON を取得します。

```json
GET https://localhost:3000/api/v1/users

[
    {
        "id": 1,
        "first_name": "信長",
        "last_name": "織田"
    },
    {
        "id": 2,
        "first_name": "秀吉",
        "last_name": "豊臣"
    },
    {
        "id": 3,
        "first_name": "光秀",
        "last_name": "明智"
    }
]
```

## 1. interface を定義

まずは、ユーザ情報がどういった形式で送られてくるのか、<br>
interfaceを使って表現します。

```typescript
// /src/models/user.ts

export interface User {
    id: number;
    firstName: string;
    lastName: string;
}
```

## 2. API クライアントを実装

次は API リクエストを送る Axios クライアントを作っていきます。

```typescript
// /src/api/client.js

import axios, { AxiosInstance, AxiosResponse } from 'axios';
import camelCaseKeys from 'camelcase-keys';

let client: AxiosInstance;

export default client = axios.create({
    baseURL: `http://localhost:3000/api/v1`,
    headers: {
        'Content-Type': 'application/json',
    }
});

client.interceptors.response.use(
    (response: AxiosResponse): AxiosResponse => {
        const data = camelCaseKeys(response.data);
        return { ...response.data, data };
    }
);
```

ここで注目すべき点が2つあります。

1つ目は、Axios をインポートするさいに型情報も合わせて取得している点です。<br>
3行目にて、`axios` 以外に `AxiosInstance` と `AxiosResponse` を取得しています。

この `AxiosInstance` と `AxiosResponse` こそが Axios ライブラリで使用する型情報です。<br>
それぞれ 6行目 と 16行目 で使用しています。

 

2つ目は、`camelcase-keys` というライブラリを使用している点です。<br>
JavaScript のコーディング規約では、変数名にキャメルケースを使用します。<br>
しかしながら、 JSON のキー名は多くの場合でスネークケースです。 

つまり、普通に JSON を受け取ると、<br>
`resposen.first_name` のようにしてデータを取り出します。

しかし、これでは JavaScript の命名規則的に気持ち悪いですね。<br>
加えて、`User` モデル（interface）は `firstName` として定義しているため、<br>
`first_name` として受け取るのはよろしくありません。

ここで `camelcase-keys` ライブラリの登場です。<br>
スネークケースのキー名をキャメルケースに変換するためのもので、<br>
本ライブラリを用いて、受け取った JSON データのキー名を全てをキャメルケースに変換しています。

TypeScript の話から少し脱線しましたが、<br>
これで User インターフェースどおりのオブジェクトを受け取ることが可能になりました。

## 3. ユーザ一覧取得 API リクエストを実装

では、さきほど実装した Axios クライアントを使って、<br>
API サーバにユーザ情報をもらうリクエストをします。

```typescript
// /src/api/user.ts

import { AxiosPromise } from 'axios';

import client from './client';
import { User } from '../models/user';

export const fetchUsers = (): AxiosPromise<User[]> => client.get(`/users`);
``` 

8行目にて、`User[]` を受け取ることを明示しています。

## 4. ユーザ一覧を取得＆表示

では、受け取ったユーザ情報を表示してみます。<br>
なお、冒頭で説明したとおり、<br>
簡略化のために、表示に関する全実装を `pages` コンポーネント内で行います。

```typescript
// /src/pages/users.tsx

import React, { useEffect, useState } from 'react';

import { fetchUsers } from '../api/user';
import { User } from '../models/user';

const Users: React.FC = () => {
    const [userList, setUserList] = useState<User[] | undefined>(undefined);

    const fetchUsersReq = async () => {
        try {
            const { data } = await fetchUsers();
            return data;
        } catch (e) {
            console.log(e);
        }
    };

    useEffect(() => {
        const data = fetchUsersReq();
        data.then(users => {
            setUserList(users);
        });
    }, []);

    return (
        <>
            <h1>User List</h1>
            {
                userList && userList.map((user) => {
                    return (
                        <p key={user.id}>{`${user.lastName} ${user.firstName}`}</p> <!-- ポイント3 -->
                    );
                })
            }
        </>
    );
};

export default Users;
```

まず初めに登場する型は、`React.FC`（8行目）です。<br>
この型は React Functional Component を意味します。 

次に登場するのは、9行目の `useState<User[] | undefined>` ですね。<br>
この定義は、`userList` の型が User[] または undefined であることを示します。

あとは、useEffect() でさきほど実装した API リクエストを行い、<br>
取得したユーザ情報を `userList` にセットしています。

<br>

このとき、33行目のユーザ情報表示処理では、<br>
User インターフェースを定義しているため、<br>
IDE において、どういったキーが存在するかが補完候補として出てきます！ ↓

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/12/react_typescript_sample/complement.png" width="700">

型がちゃんと定義されているので、<br>
取得したデータに対して、どういった処理ができる（どのメソッドを適用できる）かが明確になり、<br>
凡ミスを減らすことができますし、コードの可読性向上にも繋がります。

いいですね！

 

実践編は以上です。<br>
API リクエスト部分だけかよというツッコミはどうかご勘弁を😇

最後に TypeScript を使う上での注意点と最新版で追加された機能を少し紹介して終わりにしたいと思います。


# TypeScriptを使う上での注意点

## TypeScript の型情報はなくなる

TypeScript で型を定義していたとしても、最終的にそのコードは JavaScript に変換されます。

ご存知のとおり、JavaScript には型などありません。<br>
したがって、実際に動くコードには型情報はついていません。

あくまで開発段階で型の整合性チェックや補完などができるだけであること、<br>
ちゃんと理解しておくことが、とても重要だと思います。

## create-react-app では使えない機能がある

create-react-app の最新版 3.2.0 では、<br>
TypeScript 3.7 から使用できる一部機能にまだ対応していません。

本内容については、次章にて詳細に話します。


# 最新安定版 3.7 で追加された機能

2019年11月7日にメジャーアップデートが行われ、バージョン 3.7 がリリースされました。<br>
今回は以下の新機能をついて紹介します。

## [Optional Chaining](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-7.html#optional-chaining)

Kotlin を書いたことがある人は、見覚えのある文法ではないでしょうか？

```typescript
let x = foo?.bar.baz();
```

このように書けば、`foo` が null または undefined じゃない場合にのみ `foo.bar.baz()` を実行します。<br>
下記のコードと同義です。

```typescript
let x = (foo === null || foo === undefined) ?
    undefined :
    foo.bar.baz();
```

<br>

ここで、さきほど、最新版の create-react-app では 最新版 TypeScript の一部機能が使えないと言いましたが、<br>
その機能がこの Optional Chaining です。

本機能を使用しようとすると、

```zsh
./src/pages/users.tsx
SyntaxError: /Users/yyh-gl/workspaces/React/react-typescript-sample/src/pages/users.tsx: Support for the experimental syntax 'optionalChaining' isn't currently enabled (29:25):

  27 |             <h1>User List</h1>
  28 |             {
> 29 |                 userList?.map((user) => {
     |                         ^
  30 |                     return (
  31 |                         <p>{user.firstName}</p>
  32 |                     );

Add @babel/plugin-proposal-optional-chaining (https://git.io/vb4Sk) to the 'plugins' section of your Babel config to enable transformation.
```

このようにエラーが出て、<br>
Babel（TypeScript を JavaScript に変換するやつ）の設定ファイルに <br>
`@babel/plugin-proposal-optional-chaining ` を追加しろと言われます。

しかしながら、現在、Babel の設定ファイルである `.babelrc` や `babel.config.js` に create-react-app（厳密には `react-scripts`）が対応しておらず、読み込むことができません。

本件については、すでに Issue が出されて、PRもマージ済みということなので、<br>
今後のリリースに期待ですね。。。

[参考サイト](https://qiita.com/Nkzn/items/e76b5fad43f238e76fb9#%E7%B4%A0%E3%81%AEcra%E3%81%A7%E3%81%AF%E4%BD%BF%E3%81%88%E3%81%AA%E3%81%84)

 

なお、Optional Chaining は本家 JavaScript にも組み込まれる予定です！<br>
TypeScript は、JavaScript の Class のように、<br>
JavaScriptのバージョンを上げないと使えない機能を<br>
ライブラリレベルで使えるようにしてくれるのでいいですね👍

## [Nullish Coalescing](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-7.html#nullish-coalescing)

Nullish Coalescing をコードで表すと下記のようになります。

```typescript
let x = foo ?? bar();
```

`foo` が null または undefined でなければ、 `foo` が代入されます。<br>
null または undefined であれば、`bar()` が実行されます。

下記のコードと同義です。

```typescript
let x = (foo !== null && foo !== undefined) ?
    foo :
    bar();
```

コードの記述量が減っていいですね👍


# まとめ

TypeScript 入門 いかがでしたでしょうか？

詳細な説明を飛ばしたところもありましたが、<br>
TypeScript がどんな感じなのか、少しでも感じてもらえたならば幸いです。

TypeScript は型に注目がいきがちですが、<br>
他にも様々な便利機能があるので、どんどん使い倒していきたいですね！

明日からのアドベントカレンダー記事も楽しみです😃

<br>

TypeScript Advent Calendar 2019、<br>
明日は [kimromi](https://qiita.com/kimromi) さんの『[FlowからTypeScriptに段階的に移行する](https://kimromi.hatenablog.jp/entry/2019/12/03/134214)』です🛫
