# Setup Local

Configuração do ambiente de desenvolvimento para projetos Attus.

## Pré-requisitos

| Ferramenta | Versão | Observação |
|------------|--------|------------|
| JDK | 25 (ou 17 para legados) | GraalVM recomendado para Java 25 |
| Node.js | 18+ | Para o projeto `frontng` (Angular) |
| Docker | 24+ | Para banco, Redis, Kafka local |
| Git | 2.40+ | — |
| IDE | Windsurf / IntelliJ | Windsurf para usar skills e workflows |

## Java

### Java 25 (projetos novos)

```bash
# Verificar versão
java -version
# Deve retornar 25.x

# Build com Gradle
./gradlew build

# Rodar testes
./gradlew test
```

### Java 17 (projetos legados)

```bash
# Verificar versão
java -version
# Deve retornar 17.x

# Build com Maven
./mvnw clean install

# Rodar testes
./mvnw test
```

## Infraestrutura Local (Docker)

Para rodar microsserviços localmente, você precisa de:

- **PostgreSQL** — Banco de dados
- **Redis** — Cache L2
- **Kafka + Zookeeper** — Mensageria (se o serviço usa eventos)

> Cada microsserviço pode ter um `docker-compose.yml` com a infra necessária. Consulte o README do projeto específico.

## Angular (frontng)

```bash
cd projetos/attornatus/microsservicos/frontng

# Instalar dependências
npm install

# Rodar em desenvolvimento
ng serve

# Rodar testes
npm test
```

## Configuração de Profiles

Cada microsserviço tipicamente tem:

| Profile | Arquivo | Uso |
|---------|---------|-----|
| `default` | `application.yml` | Configurações comuns |
| `local` | `application-local.yml` | Desenvolvimento local |
| `test` | `application-test.yml` | Testes automatizados |

Para rodar localmente:

```bash
# Via Gradle
./gradlew bootRun --args='--spring.profiles.active=local'

# Via Maven (legados)
./mvnw spring-boot:run -Dspring-boot.run.profiles=local
```

## Scripts Úteis

```bash
# Atualizar todos os projetos
./scripts/git/pull-all.sh

# Status de todos os projetos
./scripts/git/status-all.sh

# Trocar branch em todos
./scripts/git/switch-branch.sh develop

# Filtrar por projeto específico
./scripts/git/pull-all.sh --filter pessoa,demanda
```
