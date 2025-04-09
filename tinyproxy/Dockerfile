ARG BUILD_FROM
FROM ${BUILD_FROM}

LABEL maintainer="Your Name <you@example.com>"

# Install necessary packages: tinyproxy + jq
RUN apk update && apk add --no-cache tinyproxy jq

# Copy default config
COPY tinyproxy.conf /etc/tinyproxy/tinyproxy.conf

# Copy run script
COPY run.sh /run.sh
RUN chmod a+x /run.sh

# Launch script on container start
CMD [ "/run.sh" ]
