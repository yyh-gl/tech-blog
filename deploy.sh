#!/bin/bash

if [ $# -ne 1 ]
   then echo "引数でタイトルを指定"
   exit -1
fi

echo "デプロイ開始 ..." &&

# 記事コンパイル
hugo &&

cd public &&

# ブログ設定用リポジトリへのPUSH
msg="【公開】記事コード：$1"
git add -A &&
git commit -m "$msg" &&
git push origin master &&

cd .. &&

# GitHub Pages用リポジトリへPUSH
git add -A &&
git commit -m "$msg" &&
git push origin master &&

# 新規記事をサーバに登録
curl -X POST -H "Content-Type: application/json" -d "{\"title\":\"$1\"}" https://super.hobigon.work/api/v1/blogs &&

echo "\nデプロイ完了！"

