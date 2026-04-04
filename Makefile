IMAGE_NAME=akester/puppet

build-x86: init
	packer build --only=docker.debian-amd64 .

push-x86: login
	docker push $(IMAGE_NAME):debian-amd64
	
init:
	packer init .

login:
	echo '${DOCKER_TOKEN}' | docker login --username akester --password-stdin

push-manifest: login
	docker manifest create $(IMAGE_NAME):latest $(IMAGE_NAME):debian-amd64
	docker manifest push --purge $(IMAGE_NAME):latest