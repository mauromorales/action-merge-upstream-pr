FROM alpine:3.13

RUN apk update && \
    apk upgrade && \
    apk add git && \
    apk add go && \
    apk add make && \
    git clone --depth 1 --branch v2.0.0 https://github.com/cli/cli.git gh-cli && \
    cd gh-cli && \
    make && \
    mv ./bin/gh /usr/local/bin/

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
