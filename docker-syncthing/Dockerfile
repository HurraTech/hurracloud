ARG GOVERSION=latest
FROM golang:$GOVERSION AS builder

WORKDIR /src

echo "**** fetch source code ****" && \
 if [ -z ${SYNCTHING_RELEASE+x} ]; then \
	SYNCTHING_RELEASE=$(curl -sX GET "https://api.github.com/repos/syncthing/syncthing/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 mkdir -p \
	/tmp/sync && \
 curl -o \
 /tmp/syncthing-src.tar.gz -L \
	"https://github.com/syncthing/syncthing/archive/${SYNCTHING_RELEASE}.tar.gz" && \
 tar xf \
 /tmp/syncthing-src.tar.gz -C \
	/tmp/sync --strip-components=1 && \

ENV CGO_ENABLED=0
ENV BUILD_HOST=syncthing.net
ENV BUILD_USER=docker
RUN rm -f syncthing && go run build.go -no-upgrade build syncthing

FROM alpine

EXPOSE 8384 22000 21027/udp

VOLUME ["/var/syncthing"]

RUN apk add --no-cache ca-certificates su-exec tzdata

COPY --from=builder /src/syncthing /bin/syncthing
COPY --from=builder /src/script/docker-entrypoint.sh /bin/entrypoint.sh

ENV PUID=1000 PGID=1000 HOME=/var/syncthing

HEALTHCHECK --interval=1m --timeout=10s \
  CMD nc -z 127.0.0.1 8384 || exit 1

ENV STGUIADDRESS=0.0.0.0:8384
ENTRYPOINT ["/bin/entrypoint.sh", "/bin/syncthing", "-home", "/var/syncthing/config"]