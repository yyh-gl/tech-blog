+++
author = "yyh-gl"
categories = ["React"]
date = "2019-07-13"
description = "Hooks 楽しい"
featured = "react_redux_hooks/featured.png"
featuredalt = "画像がどこかへ逝ってしまったようだ…"
featuredpath = "date"
linktitle = ""
title = "【React + Redux Hooks】Redux Hooks を使って Reactアプリを書いてみた"
type = "post "

+++


<br>

---
# はじめに
---

今回は React と Redux の Hooks API を使って簡単なアプリを作り、<br>
特に Redux Hooks を触った所感を書いていこうと思います。 

---
# React Hooks 
---

React 16.8 にて <u>[Hooks](https://reactjs.org/docs/hooks-intro.html)</u> という機能が新しく追加されました。

Hooks は関数コンポーネントにおいて以下のような機能を提供してくれます。

- `useState()`：state 管理
- `useEffect()`：コンポーネントのライフサイクル管理

弊社のReact研修では、関数コンポーネント ＋ Hooks を使ってアプリを作っていたのですが、<br>
`useState()` のおかげで、クラスコンポーネントと比較して state 管理に関するコードの記述量を減らすことができました。


```jsx
// クラスコンポーネント

this.state = {
  key: initState,
}

// ...いろんな処理

this.setState({
  key: newState,
});
```

↓

```jsx
// Hooks

const [key, setKey] = useState(initState);

// ...いろんな処理

setKey(newState);
```

減らせる数は少しですが、地理も積もれば山となるです。

---
# Redux Hooks
---

React に続いて、Redux も バージョン7.1.0 にて Hooks 機能を出しました。<br>
それが <u>[Redux Hooks](https://react-redux.js.org/next/api/hooks)</u> です。

今回は Redux Hooks を使って簡単な TODO アプリを作っていきます。


---
# 1. React プロジェクト作成
---

`create-react-app` を使ってささっと作っていきます。

> `create-react-app` が入っていない人は下記コマンドで入れてください。
> 
> ```zsh
> $ npm install -g create-react-app
> ```



<img src="http://localhost:1313/tech-blog/img/tech-blog/2019/06/-/-" width="600">
<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/06/-/-" width="600">
