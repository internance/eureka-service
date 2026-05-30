# syntax=docker/dockerfile:1

# ---- Build stage ----
FROM gradle:8.14-jdk21 AS build
WORKDIR /workspace

# Cache dependencies first
COPY build.gradle settings.gradle ./
COPY gradle ./gradle
RUN gradle dependencies --no-daemon || true

# Build the application
COPY src ./src
RUN gradle bootJar --no-daemon

# ---- Runtime stage ----
FROM eclipse-temurin:21-jre-alpine AS runtime
WORKDIR /app

# Run as a non-root user
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

COPY --from=build /workspace/build/libs/*.jar app.jar

ENV SERVER_PORT=8761 \
    SPRING_PROFILES_ACTIVE=docker
EXPOSE 8761

ENTRYPOINT ["java", "-jar", "app.jar"]
