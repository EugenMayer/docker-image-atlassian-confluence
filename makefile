build:
	docker pull bellsoft/liberica-openjre-debian:17
	docker build -t ghcr.io/eugenmayer/confluence . --build-arg CONFLUENCE_VERSION=${VERSION}

build11:
	docker pull bellsoft/liberica-openjre-debian:11
	docker build -t ghcr.io/eugenmayer/confluence:${VERSION} -f Dockerfile_java11 --build-arg CONFLUENCE_VERSION=${VERSION} .
