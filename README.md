# BBZBL Modul 324: Nginx Beispiel

Beispiel CI/CI nach AWS eines simplen Nginx Image

## Woher

Wie man ein einfaches NGINX image erstellt könnt Ihr in diesem Tutorial nachbauen.

- [https://www.baeldung.com/linux/nginx-docker-container](https://www.baeldung.com/linux/nginx-docker-container)

Da wird auch darauf eingegangen, dass ihr direkt ein offizielles Image von Nginx holen könnt.
Das ist natürlich praktisch, zum über ist es aber gut es selbst zu bauen.

## AWS CLI

[https://github.com/marketplace/actions/configure-aws-cli](https://github.com/marketplace/actions/configure-aws-cli)

## TODO

- [x] Basic Nginx Image
- [x] Docker Compose file to build Nginx
- [x] Connect to AWS with aws-cli from github actions
- [x] Configure terraform to work on AWS / Basic EC2
- [ ] Configure aws registry via terraform
- [ ] Build nginx and push it to registry
- [ ] Deploy nginx container to aws fargate
