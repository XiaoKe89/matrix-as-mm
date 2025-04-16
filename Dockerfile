# Stage 1: Build the application
FROM golang:1.18-alpine as builder

# Install git and dependencies
RUN apk add --no-cache git

# Set working directory and clone the repository
WORKDIR /go/src/github.com/your-username/matrix-as-mm
RUN git clone https://github.com/XiaoKe89/matrix-as-mm.git .

# Get Go dependencies
RUN go mod download

# Build the binary
RUN go build -o /go/bin/matrix-as-mm .

# Stage 2: Copy the built binary to a fresh minimal image
FROM alpine:3.16

# Install the necessary runtime dependencies
RUN apk add --no-cache \
    ca-certificates \
    bash \
    libmagic \
    && update-ca-certificates

# Copy the binary from the builder stage
COPY --from=builder /go/bin/matrix-as-mm /usr/local/bin/

# Set up the working directory
WORKDIR /root

# Expose the necessary port
EXPOSE 8008

# Command to run the bot
CMD ["matrix-as-mm"]
