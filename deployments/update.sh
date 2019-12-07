#!/bin/bash

if [ $# -ne 1 ]
   then echo "引数でタイトルを指定"
   exit -1
fi

echo "デプロイ開始 ..." &&

# 記事コンパイル
echo -e "\nコンパイルを開始" &&
hugo --buildFuture &&
echo "コンパイルが完了" &&

cd public &&

# ブログ設定用リポジトリへのPUSH
echo -e "\nブログ設定用リポジトリへPUSH" &&
msg="【修正】記事コード：$1"
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

echo -e "\nデプロイ完了！"

