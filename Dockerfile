# ── STAGE 1: Create a mock frontend asset ──
FROM alpine:3.18 AS frontend-builder
WORKDIR /html
RUN mkdir public && echo '<h1>Journal Frontend Mock</h1><p>Kubernetes Best Practices</p>' > public/index.html

# ── STAGE 2: Build the Go binary securely ──
FROM golang:1.26-alpine AS backend-builder
WORKDIR /app

# TARGETOS and TARGETARCH are automatically injected by Docker Buildx
ARG TARGETOS
ARG TARGETARCH

# Copy dependency manifests first to leverage Docker layer caching
COPY go.mod ./
RUN go mod download

# Copy source and cross-compile dynamically based on target platform variables
COPY main.go ./
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -ldflags="-w -s" -o server .

# ── STAGE 3: Final secure, minimal runtime image ──
FROM alpine:3.18
WORKDIR /app

# K8s Best Practice: Never run processes as root inside a container
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy build outcomes from previous stages
COPY --from=backend-builder /app/server /app/server
COPY --from=frontend-builder /html/public /app/public

# Switch context to the non-privileged system user
USER appuser
EXPOSE 8080

ENTRYPOINT ["/app/server"]
