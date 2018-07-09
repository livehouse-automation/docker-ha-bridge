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

FROM openjdk:8-jdk-alpine

ENV DEVMODE=false

COPY --from=builder /src/ha-bridge.jar /ha-bridge/ha-bridge.jar

VOLUME [ "/ha-bridge/config" ]

# 80/tcp = Web server port
# 50000/udp = UPNP response port
# 1900/udp = UPNP listener
EXPOSE 80/tcp 50000/udp 1900/udp

# Using a shell so we can do variable substitution for the secret key
ENTRYPOINT [ "sh", "-c", "java -jar /ha-bridge/ha-bridge.jar -Ddev.mode=${DEVMODE} -Dsecurity.key=${SECURITYKEY} -Dconfig.file /ha-bridge/config/habridge.config -Djava.net.preferIPv4Stack=true" ]
