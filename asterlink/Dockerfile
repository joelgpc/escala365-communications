FROM golang:1.21-alpine AS builder

WORKDIR /build

# Instalar git y dependencias de compilación
RUN apk add --no-cache git

# Clonar el repositorio de AsterLink
RUN git clone https://github.com/serfreeman1337/asterlink.git .

# Compilar para ARM64 (nativo en Oracle Cloud)
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -ldflags="-s -w" -o asterlink ./cmd/asterlink

FROM alpine:latest

WORKDIR /app

# Instalar CA certificates para HTTPS
RUN apk --no-cache add ca-certificates tzdata

# Copiar binario compilado
COPY --from=builder /build/asterlink /app/asterlink

# Puerto WebSocket para SuiteCRM
EXPOSE 8010

CMD ["/app/asterlink", "-config", "/app/config.yml"]
