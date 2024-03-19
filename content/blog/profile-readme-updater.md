+++
title = "【GitHub Actions】GitHubのプロフィールを自動更新する仕組みを作った"
author = "yyh-gl"
categories = ["GitHub Actions", "GitHub", "Go"]
tags = ["Tech"]
date = 2021-02-19T18:53:19+09:00
description = "技術的な説明はなく、ただの独り言です"
type = "post"
draft = false
[[images]]
src = "img/2021/02/profile-readme-updater/featured.webp"
alt = "featured"
stretch = "stretchH"
+++

# おもしろいツイートを見つけた

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">GitHub ActionsでQiita/Zennの投稿をGitHubプロフィールに自動反映できるようにした <a href="https://t.co/o47E7YHSsx">pic.twitter.com/o47E7YHSsx</a></p>&mdash; mikkame (@mikkameee) <a href="https://twitter.com/mikkameee/status/1360887240587571201?ref_src=twsrc%5Etfw">February 14, 2021</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

とても便利そうだったので僕もやってみました。


# 作った

<img src="https://tech.yyh-gl.dev/img/2021/02/profile-readme-updater/profile.webp" width="600">

↑こんな感じで `Recent posts - Blog 📝` に直近5個のブログ記事を表示するようにして、<br>
なおかつ自動で更新されるようにしました。

コードは[こちら](https://github.com/yyh-gl/yyh-gl)に置いてあります。

やっていることはとてもシンプルで、<br>
Goで書いたプロフィール（README）更新スクリプトをGitHub Actionsで実行しているだけです。

興味あったらコードを覗いてみてください。
