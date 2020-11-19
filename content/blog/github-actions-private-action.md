+++
author = "yyh-gl"
categories = ["CI/CD", "GitHub"]
date = "2019-10-22T00:00:00Z"
description = "HCLではなくてyml版です"
title = "【GitHub Actions】プライベートアクションを使ってみた"
type = "post"
draft = false
[[images]]
  src = "img/tech-blog/2019/10/github-actions-private-action/featured.png"
  alt = "featured"
  stretch = "stretchH"
+++


# プライベートアクションとは
GitHub Actions では、開発者がアクション（Lint やテストといったジョブなど）を作って、公開することができます。
<br>
この公開されたアクションは、世界中の人が使えるため、もちろん自分のプロジェクトに持ってきて使用できます。
<br>
この公開されたアクションのことを <u>パブリックアクション</u> といいます。

パブリックアクションが溢れた世界を想像するだけでワクワクしますね👍
<br>
（野良 Docker イメージと同様に、ほいそれとは使えないでしょうが…）



<br>
今回、とりあげるのはパブリックアクションの正反対にあるものです。
<br>
つまり、公開しない（できない）アクション ＝ <u>プライベートアクション</u> です。


# プライベートアクションを使うための準備
ディレクトリ構成は以下のとおりです。

```
.github
├── actions
│   └── golang-test
│       ├── Dockerfile
│       ├── action.yml
│       └── entrypoint.sh
└── workflows
    └── golang.yml
```

`/actions` ディレクトリ配下に golang-test という、Lint とテストを実行するアクションを作ってみます。

`/workflow` ディレクトリ配下には、golang 用のワークフロー定義ファイルを置いています。

では、次から各ファイルの定義を見ていきます。


# プライベートアクションの定義
```yml
# /actions/golang-test/action.yml

name: 'Golang Lint and Test Action'
description: 'Lint and Test for Golang'
author: 'yyh-gl'
runs:
  # Docker を使って実行することを宣言
  using: 'docker'
  # 使用する Docker イメージを指定
  image: 'Dockerfile'
```

アクションの定義は上記のとおりです。
<br>
[公式ドキュメント](https://help.github.com/ja/github/automating-your-workflow-with-github-actions/creating-a-docker-container-action#create-an-action-metadata-file)を参考にしました。

`action.yml` 内で使用している `Dockerfile` は以下のとおりです。

```dockerfile
# /actions/golang-test/Dockerfile
FROM golang:1.12.5

LABEL "name"="Golang workflow" \
    "maintainer"="yyh-gl <yhonda.95.gl@gmail.com>" \
    "com.github.actions.icon"="code" \
    "com.github.actions.color"="green-dark" \
    "com.github.actions.name"="golang　workflow" \
    "com.github.actions.description"="This is an Action to run go and golangci-lint commands."

ENV LINT_VERSION="v1.18.0"

COPY entrypoint.sh /entrypoint.sh

RUN curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh -s -- -b $(go env GOPATH)/bin ${LINT_VERSION} \
  && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
```

`Dockerfile` 内で使用している `entorypoint.sh` は以下のとおりです。

```shell script
# /actions/golang-test/entrypoint.sh

#!/bin/bash

APP_DIR="/go/src/github.com/${GITHUB_REPOSITORY}/"

mkdir -p "${APP_DIR}" && cp -r ./ "${APP_DIR}" && cd "${APP_DIR}"

export GO111MODULE=on
go mod tidy
go mod verify

if [[ "$1" == "lint" ]]; then
    echo "############################"
    echo "# Running GolangCI-Lint... #"
    echo "############################"
    golangci-lint --version
    echo
    golangci-lint run --tests --disable-all --enable=goimports --enable=golint --enable=govet --enable=errcheck ./...
fi
```

`Dockerfile` と `entrypoint.sh` は[こちら](https://dev.classmethod.jp/etc/github-actions-golang/)を参考にしました。


# ワークフローの定義
```yml
# /workflow/golang.yml

# ワークフローの名前
name: Workflow for Golang
# push をトリガーとしてワークフローを実行
on: [push]

# ジョブを定義：ジョブは並列処理される（デフォルト動作）
jobs:
  lint:
    name: Lint
    runs-on: ubuntu-latest
    # job の中にさらに細かい粒度で step が存在：step は job と違い上から順に実行される
    steps:
      - name: Checkout
        uses: actions/checkout@v1
      - name: Lint
        uses: ./.github/actions/golang
  test:
    name: Test
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v1
      - name: Test
        run: go test ./...

```

`/workflows/golang.yml` の中身を上記のとおりです。
<br>
今回は Lint と go test を並列で実行しています。

## 重要ポイント：プライベートアクションとパブリックアクションでの設定差異
<u>プライベートアクションを使用するときは チェックアウト が必須です！</u>

[公式ドキュメントのサンプル](https://help.github.com/ja/github/automating-your-workflow-with-github-actions/configuring-a-workflow#workflow-file-example)を下記に示します。

```yml
name: Greet Everyone
# This workflow is triggered on pushes to the repository.
on: [push]

jobs:
  build:
    # Job name is Greeting
    name: Greeting
    # This job runs on Linux
    runs-on: ubuntu-latest
    steps:
      # This step uses GitHub's hello-world-javascript-action: https://github.com/actions/hello-world-javascript-action
      - name: Hello world
        uses: actions/hello-world-javascript-action@v1
        with:
          who-to-greet: 'Mona the Octocat'
        id: hello
      # This step prints an output (time) from the previous step's action.
      - name: Echo the greeting's time
        run: echo 'The time was $｛｛ steps.hello.outputs.time ｝｝.'
```

14行目でパブリックアクションを使用しています。
<br>
パブリックアクション使用時は、アクションの本体（コード）がどこからでも取得可能な場所にあるのでチェックアウトが必要ありません。

しかし、プライベートアクションは自分のプロジェクト内にアクションの本体があります。
<br>
したがって、チェックアウトして、プロジェクトのコードをアクション実行環境に持ってくる必要があります。

## 重要ポイント：チェックアウト

ここで、GitHub Actions ではどのようにしてチェックアウトするのか。ですが、
<br>
答えは <u>パブリックアクションを使用する</u> です。

GitHub が公開している公式アクションの中に、[actions/checkout](https://github.com/actions/checkout) があります。
<br>
これを使用します。

僕のコードでいうと、 `/workflow/golang.yml` 内の 16 行目で使用しています。

---
「チェックアウト って何？」という方は、
<br>
[actions/checkout](https://github.com/actions/checkout) の README の説明がとても分かりやすいと思います。

> This action checks out your repository to $GITHUB_WORKSPACE, so that your workflow can access the contents of your repository.
>
> （あなたのリポジトリ（コード）を $GITHUB_WORKSPACE に持ってきて、ワークフローがそのコードにアクセスできるようにする）

↑ これを実現するためのものです。

<u>プライベートアクションはネット上に公開されていないから、
<br>
手元にあるアクション本体（コード）を GtHub Actions の実行環境に持っていった</u>
<br>
というだけですね。

---

・

・

・

# ワークフローを実行
後は push するだけです。

実際、push してみると、
<br>
下記のとおり、ワークフローが実行されました🎉

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/10/github-actions-private-action/result.png" width="600">

ログを見ると、Dockerfile からアクションが組み立てられていることが、なんとなく読み取れると思います。

# まとめ
パブリックアクションが実現する CI/CD まわりのエコシステムは、とてもワクワクしますね。
<br>
でも、やっぱり公開できないアクションもあると思います。

そういったときにはプライベートアクションを活用していきましょう。

<br>
【余談】

<br>

ワークフローについてもっと知りたい方は、
ぜひ[公式ドキュメント](https://help.github.com/ja/github/automating-your-workflow-with-github-actions/configuring-a-workflow)を読んでみてください。

<br>

日本語対応しています👍


# 参考記事
- [Docker コンテナのアクションを作成する｜Docker公式ドキュメント](https://help.github.com/ja/github/automating-your-workflow-with-github-actions/creating-a-docker-container-action)
- [ワークフローを設定する｜Docker公式ドキュメント](https://help.github.com/ja/github/automating-your-workflow-with-github-actions/configuring-a-workflow)
- [GitHub Actionsのワークフロー構文｜Docker公式ドキュメント](https://help.github.com/ja/github/automating-your-workflow-with-github-actions/workflow-syntax-for-github-actions)
