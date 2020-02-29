#!/bin/bash

# Mac で実行
# TODO: Makefileに移行

if [ $# -ne 1 ]
   then echo "引数でタイトルを指定"
   exit -1
fi

echo "予約投稿開始 ..." &&

# ブログ設定用リポジトリへのPUSH
echo -e "\nブログ設定用リポジトリへPUSH" &&
msg="【予約公開】記事コード：$1"
git add -A &&
git commit -m "$msg" &&
git push origin master &&
echo "ブログ設定用リポジトリへPUSH完了" &&

echo -e "\n予約投稿完了！"

