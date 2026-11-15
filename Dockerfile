FROM golang:latest

ENV TZ="Asia/Tokyo"

WORKDIR /go/src/github.com/yyh-gl/tech-blog
COPY . .

RUN apt-get update && apt-get install -y webp nodejs
RUN corepack enable && corepack prepare pnpm@latest --activate
RUN go install github.com/Ladicle/tcardgen@latest
RUN CGO_ENABLED=1 go install -tags extended github.com/gohugoio/hugo@v0.170.0

EXPOSE 1313

ENTRYPOINT ["hugo"]
CMD ["server"]
