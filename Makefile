TAG        := latest
IMAGE_NAME := panubo/helm
REGISTRY   := docker.io

AWS_DEFAULT_REGION := ap-southeast-2

build:
	docker build -t ${IMAGE_NAME}:${TAG} .

bash:
	docker run --rm -it ${IMAGE_NAME}:${TAG}

bash-aws:
	@printf "AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}\nAWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}\nAWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}\nAWS_SECURITY_TOKEN=${AWS_SECURITY_TOKEN}\n" > make.env
	docker run --rm -it -e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) --env-file ./make.env ${IMAGE_NAME}:${TAG}
	-rm ./make.env
