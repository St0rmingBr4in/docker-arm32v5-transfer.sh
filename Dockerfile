FROM arm32v5/debian as build

RUN apt update -y
RUN apt-get install -y golang

# Necessary to run 'go get' and to compile the linked binary
RUN apt-get install -y musl-dev
RUN apt-get install -y git

ADD transfer.sh /go/src/github.com/dutchcoders/transfer.sh

WORKDIR /go/src/github.com/dutchcoders/transfer.sh

ENV GO111MODULE=on

# build & install server
RUN go get -u ./...
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm GOARM=5 go build -ldflags -a -tags netgo -ldflags '-w -extldflags "-static"' -o /go/bin/transfersh github.com/dutchcoders/transfer.sh

FROM scratch AS final
LABEL maintainer="Andrea Spacca <andrea.spacca@gmail.com>"

COPY --from=build  /go/bin/transfersh /go/bin/transfersh
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

ENTRYPOINT ["/go/bin/transfersh", "--listener", ":8080"]

EXPOSE 8080
