# BBZBL Modul 324: Nginx Beispiel App

Beispiel CI/CI Pipeline nach AWS, eines simplen Nginx Image

## Woher

Wie man ein einfaches NGINX image erstellt könnt Ihr in diesem Tutorial nachbauen.

- [https://www.baeldung.com/linux/nginx-docker-container](https://www.baeldung.com/linux/nginx-docker-container)

Da wird auch darauf eingegangen, dass ihr direkt ein offizielles Image von Nginx angeben könnt.
Das ist in der praxis vorzuziehen, zum über ist es aber gut es selbst zu bauen.

## AWS CLI

- [https://github.com/marketplace/actions/configure-aws-cli](https://github.com/marketplace/actions/configure-aws-cli)

## TODO

- [x] Basic Nginx Image
- [x] Docker Compose file to build Nginx
- [x] Connect to AWS with aws-cli from github actions
- [x] Configure terraform to work on AWS / Basic EC2
- [x] Add devcontainer
  - .devcontainer in github.dev nicht möchlich :(
- [x] .devcontainer with aws-cli, terraform and kamal working
- [x] Configure aws registry via terraform
- [x] Build nginx and push it to registry
  - We should not commit the "terraform.tfstate" file
  - It is deleted after every deploy so resources are created multiple times
  - We import the resources now live!! 😄
- [x] Check resouces with aws-cli and import them with terraform
- [x] HTML Linting
- [x] Install Kamal
  - [x] repository info to kamal via env
  - [x] Remote SSH ection with public ip
- [x] Access nginx via http port 80
- [x] add .editorconfig
- [ ] Kamal config under ./kamal and not ./config

## Bonus

- [ ] Access nginx via https port 443 and letsencrypt
- [] Deploy nginx container to aws fargate
