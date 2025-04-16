FROM golang:1.16-alpine AS build

# Install dependencies
RUN apk add --no-cache git

# Clone the repository
RUN git clone https://github.com/kty0mka/matrix-as-mm.git /go/src/matrix-as-mm

# Build the project
WORKDIR /go/src/matrix-as-mm
RUN go build -o /bin/matrix-as-mm

# Run the app
CMD ["/bin/matrix-as-mm"]
