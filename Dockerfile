# Stage 1: Use a Go image that already has the repository downloaded (if possible)
FROM golang:1.18-alpine as builder

# Install git and dependencies
RUN apk add --no-cache git

# Set the working directory
WORKDIR /go/src/github.com/XiaoKe89/matrix-as-mm

# Copy the files directly into the Docker image (Assuming you’ve downloaded the repo separately)
# You can use `COPY . .` if you have a local folder with the code on your host
COPY ./matrix-as-mm /go/src/github.com/XiaoKe89/matrix-as-mm

# Install dependencies
RUN go mod download

# Build the binary
RUN go build -o /go/bin/matrix-as-mm .

# Stage 2: Use a lightweight image to run the built application
FROM alpine:3.16

# Install the necessary runtime dependencies
RUN apk add --no-cache \
    ca-certificates \
    bash \
    libmagic \
    && update-ca-certificates

# Copy the binary from the build stage
COPY --from=builder /go/bin/matrix-as-mm /usr/local/bin/

# Set up the working directory
WORKDIR /root

# Expose the necessary port
EXPOSE 8008

# Command to run the bot
CMD ["matrix-as-mm"]
