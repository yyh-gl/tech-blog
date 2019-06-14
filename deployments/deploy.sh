#!/bin/bash

if [ $# -ne 1 ]
   then echo "引数でタイトルを指定"
   exit -1
fi

echo "デプロイ開始 ..." &&

# 記事コンパイル
echo -e "\nコンパイルを開始" &&
hugo &&
echo "コンパイルが完了" &&

cd public &&

# ブログ設定用リポジトリへのPUSH
echo -e "\nブログ設定用リポジトリへPUSH" &&
msg="【公開】記事コード：$1"
git add -A &&
git commit -m "$msg" &&
git push origin master &&
echo "ブログ設定用リポジトリへPUSH完了" &&

cd .. &&

# GitHub Pages用リポジトリへPUSH
echo -e "\nGitHub Pages用リポジトリへPUSH" &&
git add -A &&
git commit -m "$msg" &&
git push origin master &&
echo "GitHub Pages用リポジトリへPUSH完了" &&

# 新規記事をサーバに登録
echo -e "\nサーバに記事を登録" &&
curl -X POST -H "Content-Type: application/json" -d "{\"title\":\"$1\"}" https://super.hobigon.work/api/v1/blogs &&
echo -e "\nサーバに記事を登録完了" &&

echo -e "\nデプロイ完了！"
