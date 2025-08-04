build: init unpack-puppet
	packer build -var "sops_version=${SOPS_VERSION}" .

unpack-puppet:
	bash unpack-puppet.sh
	
init:
	packer init .

login:
	echo '${DOCKER_TOKEN}' | docker login --username akester --password-stdin

push-remote: login
	docker push akester/puppet:alpine
