#!/bin/bash

docker exec -it $CONTAINER_ID /bin/bash
docker logs $CONTAINER_ID
docker logs --tail 100 $CONTAINER_ID
docker top $CONTAINER_ID
docker inspect $CONTAINER_ID
docker ps
docker start $CONTAINER_ID
docker stop $CONTAINER_ID
docker kill $CONTAINER_ID
docker history $IMAGE_ID
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker rmi $(docker images -a -q) --force
docker system prune -a
docker rmi $(docker images -a -q) --force && docker rm $(docker ps -a -q)
docker rmi $(docker images | grep "^<none>" | awk "{print $3}")
docker run -d -p 5000:5000 --restart=always --name registry -v /mnt/datamount/registry:/var/lib/registry registry:2
docker run --runtime=nvidia --rm nvidia/cuda nvidia-smi
docker buildx ls - list all
docker buildx imagetools inspect dockerhub.io/my-test:latest
docker build -t my-test:latest . --platform linux/arm64
docker buildx build --platform linux/amd64,linux/arm/v7
docker buildx build -t my-test:latest -f Dockerfile-buildx --platform linux/amd64 --progress plain --no-cache .
docker buildx build -t my-test:latest -f Dockerfile-buildx --platform linux/arm64 --progress plain .

docker login -u -p https://harbor.domaine.com/
for image_name in $(docker images --format="{{.Repository}}:{{.Tag}}" | grep nexus.domain.com)
do
  new_image_name=$(echo $image_name | sed 's/nexus.domain.com/harbor.domaine.com\/project_name/')
  docker tag $image_name $new_image_name
  docker push $new_image_name
done
