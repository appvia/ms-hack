VERSION ?= latest

image:
	CGO_ENABLED=0 docker build --build-arg VERSION=${VERSION} -t quay.io/appvia/ms-hack:${VERSION} -f Dockerfile .

push-image:
	@$(MAKE) image
	docker push quay.io/appvia/ms-hack:${VERSION}
