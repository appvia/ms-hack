FROM golang:1.15-alpine3.12 AS builder

WORKDIR /go/src/github.com/appvia/ms-hack
ADD . .
RUN go build -v .


FROM alpine:3.7

COPY --from=builder /go/src/github.com/appvia/ms-hack/ms-hack /ms-hack

ENTRYPOINT ["/ms-hack"]