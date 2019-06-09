#!/bin/bash

cd ~/tech-blog-settings &&
git pull origin master&&
hugo &&
cd public &&
msg="【予約公開】記事コード：$1"
git add -A &&
git commit -m "$msg" &&
git push origin master &&
curl -X POST -H "Content-Type: application/json" -d "{\"title\":\"$1\"}" https://super.hobigon.work/api/v1/blogs
