# ============================================
# Afetto — Dockerfile
# FIAP 2026 — DevOps Tools & Cloud Computing
# ============================================

# --- Stage 1: Build ---
FROM gradle:8.14-jdk21 AS build

LABEL maintainer="Iago Liziero"
LABEL version="1.0"
LABEL description="API REST Afetto — Spring Boot + H2"

WORKDIR /app

# Copia todos os arquivos do projeto
COPY . .

# Gera o jar sem rodar os testes
RUN gradle clean build -x test

# --- Stage 2: Runtime ---
FROM eclipse-temurin:21-jre-jammy

LABEL application="afetto-api"

WORKDIR /app

# Copia o jar gerado no stage anterior
COPY --from=build /app/build/libs/*.jar app.jar

# Volume para persistência dos dados do H2
VOLUME /app/data

# Porta da aplicação
EXPOSE 8080

# Cria usuário sem privilégios administrativos
RUN useradd -ms /bin/bash afettouser

# Define o usuário não-root
USER afettouser

# Executa a aplicação
ENTRYPOINT ["java", "-jar", "app.jar"]
