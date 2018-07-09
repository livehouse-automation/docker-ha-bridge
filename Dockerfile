FROM java:8-jdk as builder

RUN apt-get update && \
    apt-get install -y --no-install-recommends maven && \
    mkdir -p /src/ha-bridge && \
    git clone https://github.com/bwssytems/ha-bridge.git /src/ha-bridge && \
    cd /src/ha-bridge && \
    mvn validate && \
    mvn package && \
    find /src/ha-bridge/target -type f -name 'ha-bridge-*.jar' -exec cp -v {} /src/ha-bridge.jar \; && \
    rm -rf /var/lib/apt/lists/*

FROM java:8-jdk-alpine
COPY --from=builder /src/ha-bridge.jar /ha-bridge/ha-bridge.jar
EXPOSE 80/tcp 50000/udp 1900/udp
ENTRYPOINT [ "java", "-jar", "/ha-bridge/ha-bridge.jar" ]

