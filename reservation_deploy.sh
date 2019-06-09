#!/bin/bash

cd ~/tech-blog-settings &&
git pull origin master&&
hugo &&
cd public &&
msg="【予約公開】記事コード：$1"
git add -A &&
git commit -m "$msg" &&
git push origin master &&
curl -X POST -H "Content-Type: application/json" -d "{\"title\":\"$1\"}" https://super.hobigon.work/api/v1/blogs &&
curl -X POST -H "Content-Type: application/json" -d "{\"text\":\"hoge\"}" https://hooks.slack.com/services/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
