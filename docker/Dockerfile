# syntax=docker/dockerfile:1

# ---------- Stage 1: build the runnable jar ----------
FROM maven:3.9-eclipse-temurin-22 AS build
WORKDIR /src

# Copy the whole multi-module reactor and build the fat jar.
COPY . .
RUN mvn -q -B -DskipTests package

# ---------- Stage 2: minimal Alpine runtime ----------
FROM eclipse-temurin:22-jre-alpine AS runtime

# Run as an unprivileged user.
RUN addgroup -S app && adduser -S app -G app

WORKDIR /app
COPY --from=build /src/mcp-application/target/mcp-server.jar /app/app.jar

# H2 file + generated encryption key live here by default.
ENV APP_DATA_DIR=/app/data
RUN mkdir -p /app/data && chown -R app:app /app

USER app
EXPOSE 9999

# busybox wget ships with alpine; health endpoint is public (see SecurityConfig).
HEALTHCHECK --interval=30s --timeout=5s --start-period=45s --retries=3 \
	CMD wget -qO- http://localhost:9999/actuator/health | grep -q '"status":"UP"' || exit 1

ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "/app/app.jar"]
