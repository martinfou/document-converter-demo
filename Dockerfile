# ────────────── Stage 1 : Build ──────────────
FROM maven:3.9-eclipse-temurin-17-alpine AS builder

WORKDIR /build
COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn package -B -DskipTests

# ────────────── Stage 2 : Runtime ──────────────
FROM eclipse-temurin:17-jre-alpine

RUN apk add --no-cache tzdata ca-certificates bash && \
    addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=builder /build/target/document-converter-demo.war app.war
COPY samples/ ./samples/

ENV SERVER_PORT=8080 \
    SERVER_URL=http://localhost:8080 \
    ONLYOFFICE_DS_URL=http://localhost:3080 \
    ONLYOFFICE_DOCSERVICE_URL=http://localhost:3080

EXPOSE 8080

USER appuser

ENTRYPOINT ["/bin/bash", "-c", "exec java \
    -Dserver.address=0.0.0.0 \
    -Dserver.port=${SERVER_PORT} \
    -Dserver.url=${SERVER_URL} \
    -Donlyoffice.ds.url=${ONLYOFFICE_DS_URL} \
    -Donlyoffice.docservice.url=${ONLYOFFICE_DOCSERVICE_URL} \
    -jar app.war"]
