.DEFAULT_GOAL := help
.PHONY: help
help: ## helpを表示
	@echo '  see:'
	@echo '   - https://github.com/yyh-gl/tech-blog'
	@echo ''
	@grep -E '^[%/a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'

.PHONY: server
server: ## Hugoサーバを起動
	docker run --rm -it --name tech-blog \
	  -v `pwd`:/go/src/github.com/yyh-gl/tech-blog \
	  -p 1313:1313 \
	  tech-blog \
	  server -D --bind 192.168.2.200 --baseURL=http://192.168.2.200/tech-blog

.PHONY: lint
lint: ## textlint実行
	@git diff --name-only HEAD~ | xargs docker exec tech-blog /go/src/github.com/yyh-gl/tech-blog/node_modules/.bin/textlint

.PHONY: new
new: ## 記事テンプレート生成
	@if [ -z "${title}" ]; then \
		echo 'titleを指定してください。'; \
		exit 1; \
	fi
	git checkout main
	git checkout -b ${title}
	@echo ''
	hugo new blog/${title}.md
	@echo ''
	mkdir -p ./static/img/tech-blog/`date +"%Y/%m"`/${title}
	@echo ''
	open ./static/img/tech-blog/`date +"%Y/%m"`/${title}
	@echo ''
	open http://192.168.2.200:1313/tech-blog/

.PHONY: post
post: ## 記事を投稿
	@if [ -z "${title}" ]; then \
		echo 'titleを指定してください。'; \
		exit 1; \
	fi
	curl -X POST https://super.hobigon.work/api/v1/blogs -H "Content-Type: application/json" -d "{\"title\":\"${title}\"}"
	@echo ''
	git merge ${title}
	git push origin main
	git br -d ${title}
	git push origin :${title}

.PHONY: create-ogp
create-ogp: ## OGP画像を生成
	@if [ -z "${title}" ]; then \
		echo 'titleを指定してください。'; \
		exit 1; \
	fi
	tcardgen -c template.yaml -f static/font/kinto-master/Kinto\ Sans -o static/img/tech-blog/`date +"%Y/%m"`/${title}/featured.png content/blog/${title}.md
	cwebp static/img/tech-blog/`date +"%Y/%m"`/${title}/featured.png -o static/img/tech-blog/`date +"%Y/%m"`/${title}/featured.webp
	rm -f static/img/tech-blog/`date +"%Y/%m"`/${title}/featured.png
