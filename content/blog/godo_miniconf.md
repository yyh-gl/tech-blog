+++
author = "yyh-gl"
categories = ["Go", "勉強会"]
tags = ["Tech"]
date = "2019-08-06T00:00:00Z"
description = "CyberAgent ＆ merpay 主催の Golang 勉強会"
title = "【Go同miniConf】Golangの勉強会に参加してきた話"
type = "post"
draft = false
[[images]]
  src = "img/tech-blog/2019/08/godo_miniconf/featured.webp"
  alt = "featured"
  stretch = "stretchH"
+++


# 概要

CyberAgent ＆ merpay が共催した Golang のイベント

- [Connpass情報](https://mercari.connpass.com/event/141047/)
- ハッシュタグ：#godo_miniconf


（写真撮るの忘れた…）


以下、発表まとめ


# 1. マイクロサービスとMonoRepo

- 登壇者：江頭 宏亮さん（@_hiro511）
- [発表スライド](https://speakerdeck.com/_hiro511/microservices-and-monorepo)

## リポジトリ管理について

WinTicket というサービス開発・運用中

<u>36個のマイクロサービスで動いている</u>

- マルチリポジトリ：マイクロサービスごとにリポジトリが別れている
- モノリポジトリ：ひとつのリポジトリ。WinTicket ではこっち

## モノリポジトリ

- Google, FB, Tiwtter, Uberが採用
- メリット
  - 依存管理をシンプルにできる
    - マルチリポジトリの場合、複数のリポジトリに変更を加える必要があるし、変更を取り込むのが面倒
    - モノレポだとすべてのコードが一箇所にあるので変更が楽
  - 一貫性のある変更
    - 複数のサービスにまたがる変更においても、アトミックなコミットが可能
  - コードの共有と再利用が用意
    - common ディレクトリがあればできる
  - 大きなリファクタリングが容易

## ビルドとテストを効率良くしたいという

<u>モノリポジトリだと、ビルドとテストに時間がかかる</u> ので、効率よくビルドとテストしたい

- Bazel（ベイゼル）：ビルド・テストツール
  - Go,  Andoroid, iOSなど様々な言語に対応
  - Googleが使っている（Googleの自社ツールがOSS化）
  - 必要箇所だけビルド・テストする
    - 速い
  - スケーラブル
  - 拡張可能
    - StarDarkという独自言語で設定定義
  - WinTicketではDockerビルドもこれ

## Golang with Bazel

1. Bazel のインストール by brew
2. WORKSPACEファイルの作成
   - 外部の依存関係を記述
3. BUILDファイルを作成
   - ビルド方法を示したもの
   - Gazzelを利用して自動生成可能


ディレクトリ構成例

```
.
├BUILD.bazel
├WORKSPACE
└cmd
   └main.go
```

## Gazzelは Go Modules と dep に対応

go.mod, Gopkg.lockファイルから依存パッケージを取りこみWORKSPACEファイルに書き込んでくれる

## Protocol Buffer を Golang コンパイル可能

golang/protocolbufとgogoprotoに対応している

## ビルドアウトプットをリモートにキャッシュできる
- 開発者やCIなどでビルドアウトプットを共有できる
  - 全員が高速なビルド体験を得られる
- キャッシュバックエンド
  - nginx
  - google cloud storage などなど


# Go Modules and Proxy Walkthrough

- 登壇者：キタローさん（@ktr_0731）
- [発表スライド](https://speakerdeck.com/ktr_0731/go-modules-and-proxy-walkthrough-515ee291-bab5-4eb0-861d-9b0c0ca0050b)

## Go modules の特徴
- リポジトリのモジュール化
- セマンティックバージョニング
- go.modによる依存管理
- go.sumによるチェックサムの管理
  - 正しい（安全な）モジュールか確認できる

★ Go 1.13 でもautoがデフォルトのまま

ただし、src内でもgo.modがあればonになるようになる

## Go Modules 有効時の go get の挙動
- $GOPATH/src 配下にモジュールが配置されなくなる
- go.modとgo.sumが書き換わる
- `go get -u=patch` とするとパッチを当てられる

## Go Modules 周辺ツール

[追加資料](https://text.baldanders.info/release/2019/06/next-steps-toward-go-2/)

- Module Index
  - パブリックに利用可能なモジュールをクエリ検索できる
- Module Authentication
  - GOPATHに取得する go get は取得したモジュールを検証するすべがなかった
  - go modules で検証が可能になった
- Go checksum database（sumdb）
  - あらゆるモジュールのチェックサムを集約
  - モジュールの初回インストール時はチェックサムできないのを解決
- Module Mirrors
  - モジュールのコードやチェックサムのキャッシュを行う
  - 特定のサーバの可用性やレイテンシに影響されるのを防ぐ
  - 一度キャッシュされたものは基本的に削除されないので注意
    - 突然のリポジトリ削除に対処するため（ex. go-bindata）
- Module Proxy
  - Go 1.13 から go modules はproxyからモジュールを取得しにいくようになる
  - $GOPROCXY と $GOSUMDB で設定変更可能

## Private Modules
- github のプライベートリポジトリに proxy.golang.org はアクセスできない
  - セキュリティ的な問題からモジュール取得に失敗するとエラーとなる
- $GONNOPROXY を使えば解決可能
  - Go 1.13 からは、デフォルトで (link: http://proxy.golang.org) proxy.golang.org 経由で依存を解決しにいく
    - プライベートリポジトリへのアクセスに失敗する
    - 環境変数に GONOPROXY を設定して回避したらOK
    

# パネルディスカッション

登壇者：
- とのもりさん（@osamingo）メルカリ

- 江頭さん（@_hiro511）サイバー

- たかなみさん（@storz）メルペイ


# プロダクト関連の話

## テスト
- WinTicket
  - クリーンアーキテクチャなので全部tesableな（interface）作りを意識
  - gomockというライブラリを使っている
  - codecov というカバレッジを可視化している
    - 現在91%くらい
  - testifyのassertを使っている
    - アサーション使わない問題は認識した上で選択
  - どこが違うか知りたいときはgocmp を使っている
- メルペイ
  - gomockを使ってモッキング
  - codecov というカバレッジを可視化している
  - assertを使わず、gocmpという構造体の比較を行っている
    - testifyコントリビュータに聞くと madrier...? というライブラリをおすすめされた

## ロギング
- WinTicket
  - zapを使っている
  - ログ収集はCloudLoggingを使っている
    - GCPのk8sを使っているから
  - アクセスログはビッグクエリに流している
- メルペイ
  - zapを使っている
  - datadogに全て流している
    - お金かかるのでログを残すものの取捨選択をし始めている
  - templateリポジトリがあってログとかの基盤系処理が容易されている
  - アクセスログはビッグクエリに流している

## repository/package戦略
- WinTicket
  - kubernetesのリポジトリ構成を参考にしている
    - /pkg 配下にマイクロサービスごとにディレクトリが切られている
      - 各マイクロサービスはクリーンアーキテクチャ
      - 一般的なクリーンアーキテクチャ
    - /cmd 配下にマイクロサービスごとにmain.go と bin が入ってる
- メルペイ
  - マイクロサービスごとにリポジトリを分けている
  - ディレクトリ構成はマイクロサービス（チーム）ごとに別れている
    - 主流はクリーンアーキテクチャ
    - フラットにパッケージを切るのも主流
      - ドメインごとに切っている
      - 人によってパッケージの切り方が異なってくるので、統一するために、最近はクリーンアーキテクチャを採用することが増えている
      
## エディタ

- WinTicket
  - IntelliJ

- メルペイ
  - GoLand
  - Vim
  - Emacs

acme（russが使ってるやつ）はいないｗ

## go modules は使っているか

- WinTicket
  - dep使用

- メルペイ
  - 昔ながらのやつはdep
  - 最近のはmodules


# エンジニアの育成について

## 育成どうしてます？

- WinTicket
  - ディベロッパーガイドラインを作っており、クリーンアーキテクチャとかについてかっちりとルールを決めている
    - プロジェクトにおける、クリーンアーキテクチャの各層ごとの役割が明文化されている
  - モノレポなので結構人によってズレがでないようなパッケージ構成になっている
  - 指摘とかはみんながちゃんと言えるような環境づくりをしている（心理的安全性が高い環境）

- メルペイ
  - tentenさんのGopher道場で実力をつけていってる
  - 明文化されているガイドラインはない
    - 各マイクロサービスのリポジトリを見て盗むのが主流
  - アーキテクトチームがあり、マイクロサービスの基本的な考え方を指導している
  - [Design Doc](https://github.com/kaiinui/note/blob/master/Design--Designdoc.md) を導入しており、他のチームからレビューしてもらえる環境を作っている

## Webエンジニアの採用

- メルペイ
  - 技術試験のコードを自動採点する仕組みがある


## 新卒教育

- サイバー
  - 現場に入って学ぶ（OJT）

- メルカリ
  - tentenさんのGopher道場
    - （いいなぁ）
