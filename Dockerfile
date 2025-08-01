FROM alpine:3.22.1

# For access via VNC
EXPOSE 5900

# Expose Ports of RouterOS
EXPOSE 1194 1701 1723 1812/udp 1813/udp 21 22 23 443 4500/udp 50 500/udp 51 2021 2022 2023 2027 5900 80 8080 8291 8728 8729 8900

# Change work dir (it will also create this folder if is not exist)
WORKDIR /routeros

RUN mkdir -p  /routeros_source

# Install dependencies
RUN set -xe \
    && apk add --no-cache --update \
    netcat-openbsd qemu-x86_64 qemu-system-x86_64 \
    busybox-extras iproute2 iputils \
    bridge-utils iptables jq bash python3 curl

# Environments which may be change
ARG ROUTEROS_VERSION
ENV ROUTEROS_VERSION=${ROUTEROS_VERSION}
ENV ROUTEROS_IMAGE="chr-${ROUTEROS_VERSION}.vdi"
ENV ROUTEROS_PATH="https://cdn.mikrotik.com/routeros/${ROUTEROS_VERSION}/${ROUTEROS_IMAGE}.zip"

# Download VDI image from remote site using curl with DNS servers
RUN curl --dns-servers 8.8.8.8,1.1.1.1 --connect-timeout 30 --retry 3 \
    "$ROUTEROS_PATH" -o "/routeros_source/${ROUTEROS_IMAGE}.zip" && \
    unzip "/routeros_source/${ROUTEROS_IMAGE}.zip" -d "/routeros_source" && \
    rm -f "/routeros_source/${ROUTEROS_IMAGE}.zip"

# Copy script to routeros folder
ADD ["./scripts", "/routeros_source"]

ENTRYPOINT ["/routeros_source/entrypoint.sh"]
