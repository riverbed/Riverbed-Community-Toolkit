
TARGET = opentelemetry-go-example

build: module
	go build -o bin/${TARGET} cmd/${TARGET}/main.go

module:
	rm -f go.mod go.sum
	go mod init ${TARGET}
	go mod tidy

clean:
	rm -rf bin
	rm -f go.mod go.sum
	rm -f *traces.txt
