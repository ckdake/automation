all: build run

container=sample-app-web
tag=$(container):dev
build:
	docker build ./ -f Dockerfile -t $(tag)

run:
	docker run -it --rm \
	--name $(container) \
	--read-only \
	--mount type=tmpfs,destination=/tmp,tmpfs-mode=1777 \
	--mount type=tmpfs,destination=/var/lib/nginx/tmp/,tmpfs-mode=1777 \
	--mount type=tmpfs,destination=/run/nginx,tmpfs-mode=1777 \
	-p 8080:8080 \
	$(tag)