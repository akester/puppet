IMAGE_NAME=akester/puppet

build-x86: init
	packer build --only=docker.debian-amd64 .

push-x86: login
	docker push $(IMAGE_NAME):debian-amd64-$(CI_COMMIT_BRANCH)

init:
	packer init .

login:
	echo '${DOCKER_TOKEN}' | docker login --username akester --password-stdin

push-manifest: login
	docker manifest create $(IMAGE_NAME):$(CI_COMMIT_BRANCH) $(IMAGE_NAME):debian-amd64-$(CI_COMMIT_BRANCH) $(IMAGE_NAME):debian-arm64-$(CI_COMMIT_BRANCH)
	docker manifest push --purge $(IMAGE_NAME):$(CI_COMMIT_BRANCH)
