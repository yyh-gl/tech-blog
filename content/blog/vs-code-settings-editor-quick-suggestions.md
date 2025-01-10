<!-- textlint-disable -->

+++
title = "VS Codeのeditor.quickSuggestionsについて調べたメモ"
author = "yyh-gl"
categories = ["VS Code"]
tags = ["Tech"]
date = 2025-01-10T19:34:56+09:00
description = ""
type = "post"
draft = false
[[images]]
  src = "img/2025/01/vs-code-settings-editor-quick-suggestions/featured.webp"
  alt = "featured"
  stretch = "stretchH"
+++

<!-- textlint-enable -->

# はじめに

VS Codeの設定に`editor.quickSuggestions`というものがある。<br>
サジェストを出すかどうかを設定できる。

サジェストというのは以下のようなやつ。

<img src="https://tech.yyh-gl.dev/img/2025/01/vs-code-settings-editor-quick-suggestions/suggest.webp" width="600">

この設定項目について調べたのでメモを残す。


# editor.quickSuggestions

`editor.quickSuggestions`は以下のような設定ができる。

```json
"editor.quickSuggestions": {
  "other": "on",
  "comments": "off",
  "strings": "off"
},
```
ref: https://code.visualstudio.com/docs/getstarted/settings

`other`, `comments`, `strings` の意味がわからず、調べた内容をメモする。

なお、公式Docsから各項目に関する説明を見つけられなかったので、
ChatGPTにざっくりした説明を聞いたうえで、実際に設定をon/offして挙動を確認した。<br>
よって、後述の説明はあくまで自分の解釈であることに注意。<br>
おそらく文字どおりの意味だから説明がない…？<br>
公式Docsの説明を見つけたら更新する。<br>
（ChatGPTからの回答で「VS Codeドキュメントによると」って言われたんだけどね）

## comments

コメント内でのサジェスト有効/無効を設定できる。

<img src="https://tech.yyh-gl.dev/img/2025/01/vs-code-settings-editor-quick-suggestions/suggest_in_comment.webp" width="600">

## strings

文字列内でのサジェスト有効/無効を設定できる。

<img src="https://tech.yyh-gl.dev/img/2025/01/vs-code-settings-editor-quick-suggestions/suggest_in_strings.webp" width="600">

## other

その他の場所におけるサジェスト有効/無効を設定できる。

コード書いてるときに出てくるサジェストの大半はこれに該当するはず。


# 調査背景

自分はMarkdown編集時に改行や強調などのHTMLタグをよく使う。<br>
HTMLやReact, Vueなどのコードを書いているときのようにHTMLタグをサジェストしてほしい。<br>
（`<`や`>`、閉じタグを打つのめんどくさいし）<br>
よって、Markdown編集時によく使うHTMLタグは、snippetに登録し、サジェストされるようにしている。

しかし、VS Codeのデフォルト設定では、Markdownに関するサジェストが出ないようになっている。<br>
Markdownに関するサジェストを有効にできないか調べていると`editor.quickSuggestions`にたどり着いた。
