FROM golang:1.13-buster

RUN mkdir -p /app
ADD . /app/
WORKDIR /app
RUN go build \
	-ldflags "-s -w" \
	-o out/helloWorld \
	./hello_world.go
EXPOSE 80
CMD ["/app/out/helloWorld"]
