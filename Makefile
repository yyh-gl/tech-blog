.DEFAULT_GOAL := help
.PHONY: help
help: ## helpを表示
	@echo '  see:'
	@echo '   - https://github.com/yyh-gl/tech-blog'
	@echo '   - https://github.com/yyh-gl/tech-blog-settings'
	@echo ''
	@grep -E '^[%/a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'

.PHONY: new
new: ## 記事テンプレート生成
	@if [ -z "${title}" ]; then \
		echo 'titleを指定してください。'; \
		exit 1; \
    fi
	git checkout master
	git checkout -b ${title}
	@echo ''
	hugo new blog/${title}.md
	@echo ''
	mkdir -p ./static/img/tech-blog/`date +"%Y/%m"`/${title}
	@echo ''
	open ./static/img/tech-blog/`date +"%Y/%m"`/${title}
	@echo ''
	open http://localhost:1313/tech-blog/
	@echo ''
	open ~/workspaces/blog/tech-blog/static/img/tech-blog/default_ogp.key

.PHONY: post
post: ## 記事を投稿
	@if [ -z "${title}" ]; then \
		echo 'titleを指定してください。'; \
		exit 1; \
	fi
	curl -X POST -H "Content-Type: application/json" -d "{\"title\":\"${title}\"}" https://super.hobigon.work/api/v1/blogs
	@echo ''
	make git-push msg="【公開】記事コード：${title}"
	@echo ''
	hugo --buildFuture
	@echo ''
	cd ./public && make git-push msg="【公開】記事コード：${title}"

.PHONY: update
update: ## 記事を更新（修正）
	@if [ -z "${title}" ]; then \
		echo 'titleを指定してください。'; \
		exit 1; \
	fi
	make git-push msg="【修正】記事コード：${title}"
	@echo ''
	hugo --buildFuture
	@echo ''
	cd ./public && make git-push msg="【修正】記事コード：${title}"

.PHONY: reserve
reserve: ## 記事投稿を予約
	@if [ -z "${title}" ]; then \
		echo 'titleを指定してください。'; \
		exit 1; \
	fi
	curl -X POST -H "Content-Type: application/json" -d "{\"title\":\"${title}\"}" https://super.hobigon.work/api/v1/blogs
	@echo ''
	make git-push msg="【予約公開】記事コード：${title}"

.PHONY: reserve-post
reserve-post: ## 予約記事を投稿
	@if [ -z "${title}" ]; then \
		echo 'titleを指定してください。'; \
		exit 1; \
	fi
	git fetch origin
	git reset --hard origin/master
	cd ./public && git fetch origin && git reset --hard origin/master
	@echo ''
	git pull origin master
	hugo --buildFuture
	@echo ''
	cd ./public && make git-push msg="【予約公開】記事コード：${title}"
	@echo ''
	curl -X POST -H "Content-Type: application/json" -d "{\"text\":\"【予約公開】記事コード：${title}\"}" ${WEBHOOK_URL_TO_51}

.PHONY: post
git-push: ## GitへPUSH（Makefile内部で使用）
	git add .
	git cm -m "${msg}"
	git push origin master