---
description: Criar um novo microsserviço seguindo o padrão Attus
---

# Novo Microsserviço

Workflow para criar um novo microsserviço no ecossistema Attus.

## Pré-requisitos

- Acesso ao repositório Git da Attus
- Conhecer o domínio de negócio que o serviço atenderá

## Passos

1. **Definir escopo e nome** — O nome deve ser:
   - Substantivo em português que representa o domínio (`pessoa`, `demanda`, `cobranca`)
   - Lowercase, sem hífens
   - Registrar no `catalogo/services.yaml` no grupo e diretório correto

2. **Criar repositório** — No Git da Attus, seguindo o padrão de URL:
   - `https://git.eloware.com.br/{grupo}/microservicos/{nome}.git`

3. **Estrutura do projeto** — Spring Boot com Gradle:

   ```
   {nome}/
   ├── build.gradle              # Herda do attus-platform-bom
   ├── settings.gradle
   ├── src/
   │   ├── main/
   │   │   ├── java/ai/attus/{nome}/
   │   │   │   ├── Application.java
   │   │   │   ├── controller/            # Controllers REST
   │   │   │   ├── domain/
   │   │   │   │   └── {entidade}/        # Entity, DTO, Service, ServiceImpl, Repository, Mapper
   │   │   │   ├── client/                # Feign Clients + DTOs de outros microsserviços
   │   │   │   ├── config/
   │   │   │   ├── messageria/            # Kafka producers
   │   │   │   └── exception/
   │   │   └── resources/
   │   │       ├── application.yml
   │   │       ├── application-local.yml
   │   │       └── db/migration/
   │   └── test/
   │       └── java/ai/attus/{nome}/
   │           ├── base/
   │           │   ├── AbstractControllerTest.java
   │           │   └── AbstractServiceTest.java
   │           └── domain/
   └── Dockerfile
   ```

4. **Configurar `build.gradle`**:
   - Herdar **exclusivamente** do `ai.attus:attus-platform-bom`
   - Nunca importar BOMs diretamente (`spring-boot-dependencies`, etc.)
   - Incluir libs Attus necessárias: `lib-core`, `lib-database`, `lib-security`, `lib-starter`
   - Para testes: `lib-test`

5. **Configurar segurança** — Spring Security + OAuth2/JWT
   - Usar `lib-security` para configuração padrão

6. **Configurar banco** — JPA/Hibernate + Flyway
   - Usar `lib-database` e `BaseRepository`
   - Criar migration inicial `V1__criar_tabela_{entidade}.sql`

7. **Criar classes base de teste**:
   - `AbstractControllerTest` — para testes de Controller com MockMvc
   - `AbstractServiceTest` — para testes de Service com mocks
   - Configurar WireMock para Feign Clients

8. **Criar primeiro endpoint de health** — Verificar que o serviço sobe corretamente

9. **Registrar no catálogo** — Adicionar entrada em `catalogo/services.yaml`

// turbo
10. **Clonar no workspace** — `./scripts/git/clone-all.sh --filter {nome}`

11. **Commit inicial** — `feat({nome}): criar estrutura inicial do microsserviço`
