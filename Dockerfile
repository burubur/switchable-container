FROM golang:1.12.9-alpine

# install os utils & dependencies
RUN apk update && apk add --no-cache bash=5.0.0-r0 curl=7.65.1-r0 openssh=8.0_p1-r0 make=4.2.1-r2 git=2.22.0-r0 g++=8.3.0-r0 musl-dev=1.1.22-r3 pkgconf=1.6.1-r1

# attach ssh private key
ARG SSH_PRIVATE_KEY
RUN mkdir ~/.ssh/
RUN echo "${SSH_PRIVATE_KEY}" > ~/.ssh/id_rsa
RUN chmod 0600 ~/.ssh/id_rsa
RUN touch ~/.ssh/known_hosts
RUN ssh-keyscan bitbucket.org >> ~/.ssh/known_hosts

ENV BUILD_PATH=/go/app
ARG VAULT_ADDR=http://127.0.0.1:8200
ARG VAULT_TOKEN=s.jHtIrZHNR7PnGCK1TRDBGMUB

WORKDIR ${BUILD_PATH}
COPY . .
ENV GO111MODULE=on
RUN go mod download
RUN GOOS=linux GOARCH=amd64 && GITCOMMIT=$(git rev-parse --short HEAD) && go build -o microservice -ldflags "-X main.GitCommit=$GITCOMMIT" .

# add user deployer
RUN adduser -D deployer deployer
# set directory & file owner
RUN chown -R deployer:deployer .
# set user as deployer
USER deployer

# ENTRYPOINT [ "./microservice serve --vault-address ${VAULT_ADDR} --vault-token ${VAULT_TOKEN}" ]