<!-- textlint-disable -->

+++
title = "Indigo VPS上に個人開発用のk8sクラスターを構築する"
author = "yyh-gl"
categories = ["k8s", "個人開発"]
tags = ["Tech"]
date = 2023-05-04T11:20:17+09:00
description = "kubeadmがとても便利"
type = "post"
draft = false
[[images]]
  src = "img/2023/05/k8s-setup/featured.webp"
  alt = "featured"
  stretch = "stretchH"
+++

<!-- textlint-enable -->

# 概要

[WebARENA Indigo](https://web.arena.ne.jp/indigo/)でVPSを2台借りて、
個人開発用のk8sクラスターを構築したので、その手順をメモとして残します。

k8sクラスターの構築は下記2つの公式ドキュメントを参考に進めました。

- [kubeadmのインストール](https://kubernetes.io/ja/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
- [kubeadmを使用したクラスターの作成](https://kubernetes.io/ja/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)

ドキュメントに記載のある手順を最終的にはスクリプトにしています。
<br>
（本ブログ公開時点では自動構築スクリプトとして活用可能ですが、
k8sまわりのアップデートにより動かなくなる可能性が高いと思います）


# k8sクラスターについて

- Masterノード 1台, Workerノード 1台の計2台構成
  - 個人開発なのでお金の節約のために冗長構成は取っていません
- サーバーOSは Ubuntu 22.04
- k8sのバージョンは v1.27.1
- CNIはFlannelを使用


# Indigo VPS固有の内容

## Swapの無効化は不要

k8sを構築するサーバーに関して、公式ドキュメントに以下の記載があります。

> Swapがオフであること。kubeletが正常に動作するためにはswapは必ずオフでなければなりません。

[参考](https://kubernetes.io/ja/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#:~:text=Swap%E3%81%8C%E3%82%AA%E3%83%95%E3%81%A7%E3%81%82%E3%82%8B%E3%81%93%E3%81%A8%E3%80%82kubelet%E3%81%8C%E6%AD%A3%E5%B8%B8%E3%81%AB%E5%8B%95%E4%BD%9C%E3%81%99%E3%82%8B%E3%81%9F%E3%82%81%E3%81%AB%E3%81%AFswap%E3%81%AF%E5%BF%85%E3%81%9A%E3%82%AA%E3%83%95%E3%81%A7%E3%81%AA%E3%81%91%E3%82%8C%E3%81%B0%E3%81%AA%E3%82%8A%E3%81%BE%E3%81%9B%E3%82%93%E3%80%82)

Indigo VPSではデフォルトでSwapが無効になっているのでこの手順は不要です。

## ファイアウォール

インバウンドに対してのみ制限を設けます。
<br>
公式ドキュメントに公開しないといけないポート情報が記載されているので、こちらを参照して必要なポートだけ開けます。
<br>
[公開しないといけないポート情報](https://kubernetes.io/ja/docs/reference/networking/ports-and-protocols/)

ufwについては特になにもしていません。

このままでは手元のPCからSSHができなくなりますが、そこはTailscaleで解決しています。
<br>
Tailscaleのインストールはスクリプト内で行っています。

# スクリプト

下記リポジトリに置いています。

[yyh-gl/k8s-setup](https://github.com/yyh-gl/k8s-setup)

以下のとおり実行すれば、k8sクラスターが構築されます。

- Masterノード：`setup_common.sh`→`setup-master.sh`の順で実行
  - 注意：`setup-master.sh`の`<Master node IP>`部分はMasterノードのIPアドレスに置き換える必要あり
    - advertise addressの変更に使用（僕はTailscaleが払い出すIPにしたかったので）
- Workerノード：`setup_common.sh`を実行後に`kubeadm join`

<img src="https://tech.yyh-gl.dev/img/2023/05/k8s-setup/nodes.webp" width="600">
