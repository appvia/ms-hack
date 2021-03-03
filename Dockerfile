FROM alpine:3.7
ADD ./ms-hack /
ENTRYPOINT ["/ms-hack"]