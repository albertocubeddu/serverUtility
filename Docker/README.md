#Docker Introduction

## Build from dockerfile
docker build -t <tagThatYouPrefer> <locationDockerFile>

## Cofigure the shell
eval "$(docker-machine env default)"

## Basic command
docker ps (all the live container)   
docker exec -it (imageName) bash   
docker run -tid -p 80:80 -p 443:443 (imageName)   

#### Stop all container
docker stop \`docker ps -q\`

#### Remove all container
docker rm \`docker ps -aq\`
