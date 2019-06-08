#!/bin/bash

if [ $# -ne 1 ]
   then echo "引数でタイトルを指定"
   exit -1
fi

echo "デプロイ開始 ..." &&

# 記事コンパイル
echo -n "\nコンパイルを開始" &&
hugo &&
echo "コンパイルが完了" &&

cd public &&

# ブログ設定用リポジトリへのPUSH
echo -n "\nブログ設定用リポジトリへPUSH" &&
msg="【公開】記事コード：$1"
git add -A &&
git commit -m "$msg" &&
git push origin master &&
echo "ブログ設定用リポジトリへPUSH完了" &&

cd .. &&

# GitHub Pages用リポジトリへPUSH
echo -n "\nGitHub Pages用リポジトリへPUSH" &&
git add -A &&
git commit -m "$msg" &&
git push origin master &&
echo "GitHub Pages用リポジトリへPUSH完了" &&

# 新規記事をサーバに登録
echo -n "\nサーバに記事を登録" &&
curl -X POST -H "Content-Type: application/json" -d "{\"title\":\"$1\"}" https://super.hobigon.work/api/v1/blogs &&
echo -n -e "\nサーバに記事を登録完了" &&

echo -n -e "\nデプロイ完了！"

