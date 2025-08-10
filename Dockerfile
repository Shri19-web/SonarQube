FROM openjdk:21-slim
WORKDIR /app
COPY target/sonarqube-app-1.0.0-SNAPSHOT.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
