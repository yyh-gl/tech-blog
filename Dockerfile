FROM klakegg/hugo:ext

ENV TZ="Asia/Tokyo"

WORKDIR /go/src/github.com/yyh-gl/tech-blog
COPY . .

RUN apt-get update && apt-get install -y webp
RUN npm install
RUN go install github.com/Ladicle/tcardgen@latest

EXPOSE 1313

CMD ["server"]
