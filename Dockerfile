# Multi-stage build.
#   - first stage will build latest ha-bridge from source
#   - second stage copies binaries from first stage


# FIRST STAGE
FROM openjdk:8-jdk-alpine as builder

RUN apk update && \
    apk add --update maven git && \
    mkdir -p /src/ha-bridge && \
    git clone https://github.com/bwssytems/ha-bridge.git /src/ha-bridge && \
    cd /src/ha-bridge && \
    mvn validate && \
    mvn package && \
    find /src/ha-bridge/target -type f -name 'ha-bridge-*.jar' -exec cp -v {} /src/ha-bridge.jar \; && \
    rm -rf /var/cache/apk/*


# SECOND STAGE
FROM openjdk:8-jdk-alpine
# 80/tcp = Web server port
# 50000/udp = UPNP response port
# 1900/udp = UPNP listener
EXPOSE 80/tcp 50000/udp 1900/udp
COPY --from=builder /src/ha-bridge.jar /ha-bridge/ha-bridge.jar
VOLUME [ "/ha-bridge/data" ]
WORKDIR /ha-bridge
ENTRYPOINT [ "java", "-jar", "/ha-bridge/ha-bridge.jar" ]
