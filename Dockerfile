FROM eclipse-temurin:21-jre

RUN apt-get update \
    && apt-get install -y --no-install-recommends xvfb \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY target/BankingSystem-1.0.jar app.jar

ENTRYPOINT ["xvfb-run", "-a", "-s", "-screen 0 1024x768x24", "java", "-jar", "app.jar"]

COPY target/BankingSystem-1.0.jar app.jar

ENTRYPOINT ["java", "-jar", "app.jar"]
