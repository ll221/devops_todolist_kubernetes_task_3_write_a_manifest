# Use the official Alpine Linux image as a base
FROM alpine:latest

# Install curl
RUN apk update && apk add curl

# Set the entry point to bash for testing purposes
ENTRYPOINT ["/bin/sh"]
