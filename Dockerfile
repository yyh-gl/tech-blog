FROM klakegg/hugo:ext-alpine

WORKDIR /go/src/github.com/yyh-gl/tech-blog

RUN apk add --no-cache libwebp-tools
RUN npm install
RUN go get github.com/Ladicle/tcardgen

EXPOSE 1313

CMD ["server"]
