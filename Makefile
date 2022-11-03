docker-dev:
	docker build -f Dockerfile.dev -t $(USER)/obs_deploy_dev .
	docker run --rm -it -v "$(HOME)/.ssh:/tmp/.ssh:ro" -v "$(PWD):/obs_deploy" $(USER)/obs_deploy_dev bash
