#!/bin/bash

if [ $# -ne 1 ]
   then echo "引数でタイトルを指定"
   exit -1
fi

echo "途中記事PUSH ..." &&

# ブログ設定用リポジトリへのPUSH
echo -e "\nブログ設定用リポジトリへPUSH" &&
msg="【WIP】記事コード：$1"
git add -A &&
git commit -m "$msg" &&
git push origin master &&
echo "ブログ設定用リポジトリへPUSH完了" &&

echo -e "\n途中記事PUSH完了！"

