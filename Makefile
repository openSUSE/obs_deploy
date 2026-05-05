docker-dev:
	docker build -f Dockerfile.dev -t $(USER)/obs_deploy_dev .
	docker run --rm -it -v "$(HOME)/.ssh:/tmp/.ssh:ro,Z" -v "$(PWD):/obs_deploy:Z" $(USER)/obs_deploy_dev bash
