# Aternity Tech-Community
# 105-opentelemetry-go-app
# version: 22.03.01

# Build container
FROM golang:latest AS gobuild

WORKDIR /gobuild
COPY . .
RUN make

# Run container
FROM alpine:latest

WORKDIR /
COPY --from=gobuild /gobuild/bin/opentelemetry-go-example /
COPY --from=gobuild /gobuild/configs/opentelemetry-go-example.yml configs/
RUN apk add --no-cache libc6-compat

ENTRYPOINT ["/opentelemetry-go-example"]
