.DEFAULT_GOAL := help
.PHONY: help
help: ## helpを表示
	@echo '  see:'
	@echo '   - https://github.com/yyh-gl/tech-blog'
	@echo ''
	@grep -E '^[%/a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'

.PHONY: setup
setup: ## Hugoサーバをセットアップ
	docker build . -t tech-blog --no-cache

.PHONY: server
server: ## Hugoサーバを起動
	docker run --rm -it --name tech-blog \
	  -v `pwd`:/go/src/github.com/yyh-gl/tech-blog \
	  -p 1313:1313 \
	  tech-blog \
	  server \
	    -D \
	    -p 1313 \
	    --buildFuture \
	    --bind 0.0.0.0 \
	    --baseURL=http://$(shell ipconfig getifaddr en0)

.PHONY: login
login: ## Hugoサーバ用コンテナにログイン
	docker exec -it tech-blog /bin/bash

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
	docker exec tech-blog hugo new blog/${title}.md
	@echo ''
	mkdir -p ./static/img/`date +"%Y/%m"`/${title}
	@echo ''
	open ./static/img/`date +"%Y/%m"`/${title}
	@echo ''
	open http://$(shell ipconfig getifaddr en0):1313/

.PHONY: init-blog-like-count
init-blog-like-count: ## いいね数カウント用テーブルに記事登録
	@if [ -z "${title}" ]; then \
		echo 'titleを指定してください。'; \
		exit 1; \
	fi
	curl -X POST https://hobigon.yyh-gl.dev/api/v1/blogs -H "Content-Type: application/json" -d "{\"title\":\"${title}\"}"

.PHONY: create-ogp
create-ogp: ## OGP画像を生成
	@if [ -z "${title}" ]; then \
		echo 'titleを指定してください。'; \
		exit 1; \
	fi
	docker exec tech-blog /go/bin/tcardgen -c template.yaml -f static/font/kinto-master/Kinto\ Sans -o static/img/`date +"%Y/%m"`/${title}/featured.png content/blog/${title}.md
	docker exec tech-blog cwebp static/img/`date +"%Y/%m"`/${title}/featured.png -o static/img/`date +"%Y/%m"`/${title}/featured.webp
	rm -f static/img/`date +"%Y/%m"`/${title}/featured.png

.PHONY: convert-to-webp
convert-to-webp: ## 画像をwebp形式に変換
	@if [ -z "${title}" ]; then \
		echo 'titleを指定してください。'; \
		exit 1; \
	fi
	ls static/img/`date +"%Y/%m"`/${title} | \
	grep -v .webp | \
	grep .png | \
	xargs -I{} basename {} .png | \
	xargs -I{} docker exec tech-blog cwebp static/img/`date +"%Y/%m"`/${title}/{}.png -o static/img/`date +"%Y/%m"`/${title}/{}.webp
	ls static/img/`date +"%Y/%m"`/${title} | \
	grep -v .webp | \
	grep .jpg | \
	xargs -I{} basename {} .jpg | \
	xargs -I{} docker exec tech-blog cwebp static/img/`date +"%Y/%m"`/${title}/{}.jpg -o static/img/`date +"%Y/%m"`/${title}/{}.webp
