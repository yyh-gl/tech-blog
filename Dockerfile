FROM klakegg/hugo:ext-alpine AS build

WORKDIR /go/src/github.com/yyh-gl/tech-blog

RUN npm install

EXPOSE 1313

CMD ["server"]
