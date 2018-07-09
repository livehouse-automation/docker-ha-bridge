FROM maven:3-jdk-8 as builder

RUN apt-get update && \
    apt-get install -y --no-install-recommends maven && \
    mkdir -p /src/ha-bridge && \
    git clone https://github.com/bwssytems/ha-bridge.git /src/ha-bridge && \
    cd /src/ha-bridge && \
    mvn validate && \
    mvn package && \
    find /src/ha-bridge/target -type f -name 'ha-bridge-*.jar' -exec cp -v {} /src/ha-bridge.jar \; && \
    rm -rf /var/lib/apt/lists/*



FROM 3-jdk-8-slim

ENV DEVMODE=false

COPY --from=builder /src/ha-bridge.jar /ha-bridge/ha-bridge.jar

VOLUME [ "/ha-bridge/config" ]

# 80/tcp = Web server port
# 50000/udp = UPNP response port
# 1900/udp = UPNP listener
EXPOSE 80/tcp 50000/udp 1900/udp

# Using a shell so we can do variable substitution for the secret key
ENTRYPOINT [ "sh", "-c", "java", "-jar", "-Ddev.mode=$DEVMODE", "-Dsecurity.key=$SECURITYKEY", "-Dconfig.file", "/ha-bridge/config/habridge.config", "-Djava.net.preferIPv4Stack=true", "/ha-bridge/ha-bridge.jar" ]
