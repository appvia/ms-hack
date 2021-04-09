VERSION ?= latest
REPO ?= quay.io/appvia
IMAGE ?= ms-hack

image:
	CGO_ENABLED=0 docker build --build-arg VERSION=${VERSION} -t ${REPO}/${IMAGE}:${VERSION} -f Dockerfile .

push-image:
	@$(MAKE) image
	docker push ${REPO}/${IMAGE}:${VERSION}
