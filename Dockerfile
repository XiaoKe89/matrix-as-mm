# Start with the official Golang image
FROM golang:1.18-alpine as builder

# Set working directory in the container
WORKDIR /go/src/github.com/mattermost/matrix-as-mm

# Clone the repository
RUN apk add --no-cache git
RUN git clone https://github.com/XiaoKe89/matrix-as-mm.git .

# Get dependencies
RUN go mod download

# Build the binary
RUN go build -o /go/bin/matrix-as-mm .

# Final image: Start with a minimal Alpine base image
FROM alpine:3.16

# Install required dependencies
RUN apk add --no-cache \
    ca-certificates \
    bash \
    libmagic \
    && update-ca-certificates

# Copy the built binary from the builder stage
COPY --from=builder /go/bin/matrix-as-mm /usr/local/bin/

# Set up the working directory for the bot
WORKDIR /root

# Expose the port the bot will run on
EXPOSE 8008

# Command to run the bot
CMD ["matrix-as-mm"]
