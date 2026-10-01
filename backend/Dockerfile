FROM maven:3.9.6-eclipse-temurin-17-alpine AS builder
WORKDIR /app

# Copiar configuración de dependencias
COPY pom.xml .
COPY mvnw .
COPY .mvn .mvn
RUN mvn dependency:go-offline -B

# Copiar fuente y compilar JAR
COPY src ./src
RUN mvn clean package -DskipTests

# Etapa 2: Ejecución JRE Alpine
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

RUN addgroup -S pathseek && adduser -S pathseek -G pathseek
USER pathseek

COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "-Djava.security.egd=file:/dev/./urandom", "app.jar"]
