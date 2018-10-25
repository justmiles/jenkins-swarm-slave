NAME=jenkins-swarm-slave
REPO=justmiles
VERSION=latest
DOCKER_ARGS=--rm --name $(NAME) -e AWS_DEFAULT_REGION -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN -e JENKINS_MASTER -e JENKINS_PASSWORD

build:
	docker build . -t $(REPO):latest

deploy: build
	docker tag $(REPO)/$(NAME):latest $(REPO)/$(NAME):$(VERSION)
	docker push $(REPO)/$(NAME):latest
	( wget -q https://registry.hub.docker.com/v1/repositories/$(REPO)/$(NAME)/tags -O -  | jq -er '.[] | select(.name == "$(VERSION)").name' >/dev/null ) || docker push $(REPO)/$(NAME):$(VERSION)
	
run: 
	docker run $(DOCKER_ARGS) $(REPO):latest
	
shell: 
	docker run $(DOCKER_ARGS) -it --user root --entrypoint /bin/bash $(REPO):latest
