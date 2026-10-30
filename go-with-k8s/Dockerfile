# Build stage
FROM golang:1.27.1 AS build
WORKDIR /src

# Cache dependencies separately from source
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /app .

# Runtime stage
FROM harbor.ddtechcg.com:5001/k8s-utils/alpine:3.24.3
RUN apk add jq
COPY --from=build /app /myapp
ENTRYPOINT [""]
