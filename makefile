release: build push

build:
	docker pull bellsoft/liberica-openjre-debian:8
	docker pull bellsoft/liberica-openjre-debian:11
	source ./version && docker build -t ghcr.io/eugenmayer/confluence . --build-arg CONFLUENCE_VERSION=$${VERSION}

push: tag-docker-hub tag-github push-github push-hub
	echo "done pushing"

push-github:
	docker push ghcr.io/eugenmayer/confluence
	source ./version && docker push ghcr.io/eugenmayer/confluence:$${VERSION}

push-hub:
	docker push eugenmayer/confluence
	source ./version && docker push eugenmayer/confluence:en-$${VERSION}
	source ./version && docker push eugenmayer/confluence:$${VERSION}

tag-docker-hub:
	source ./version && docker tag ghcr.io/eugenmayer/confluence eugenmayer/confluence:en-"$${VERSION}"
	source ./version && docker tag ghcr.io/eugenmayer/confluence eugenmayer/confluence:"$${VERSION}"
	source ./version && docker tag ghcr.io/eugenmayer/confluence eugenmayer/confluence

tag-github:
	source ./version && docker tag ghcr.io/eugenmayer/confluence ghcr.io/eugenmayer/confluence:"$${VERSION}"
