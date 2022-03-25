FROM klakegg/hugo:ext-alpine

ENV TZ="Asia/Tokyo"

WORKDIR /go/src/github.com/yyh-gl/tech-blog
COPY . .

RUN apk add --no-cache libwebp-tools
RUN npm install
RUN go get -u github.com/Ladicle/tcardgen

EXPOSE 1313

CMD ["server"]
