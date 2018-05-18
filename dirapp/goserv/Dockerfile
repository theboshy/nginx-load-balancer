FROM golang:1.9.1


WORKDIR /go/src/go_service/
COPY . ./
RUN go get -v ./...
RUN go install -v ./...

EXPOSE 80

CMD [ "go_service" ]
