# Checklist de Migração Java 17 → Java 25

Checklist completo para migração de microsserviços Attus. Cada item deve ser verificado e marcado como concluído.

## 1. Build System (Maven → Gradle)

- [ ] Criar `build.gradle` com plugins: `java`, `maven-publish`, `axion-release`, `spring-boot 4.0.2`, `dependency-management`, `graalvm native`, `sonarqube`, `jacoco`
- [ ] Criar `settings.gradle` com `rootProject.name` e inclusão condicional de bibliotecas locais
- [ ] Criar `gradle.properties` com `attusPlatformVersion`, `org.gradle.caching=true`, `org.gradle.jvmargs`
- [ ] Instalar Gradle wrapper (`gradle/wrapper/gradle-wrapper.jar` + `gradle-wrapper.properties` + `gradlew`)
- [ ] **Centralizar versões no BOM** — verificar que NENHUMA dependência no `build.gradle` tem versão hardcoded. Se a dependência não existe no `attus-platform-bom`, adicioná-la lá (`constraints` + `gradle.properties`). Exceção: plugins Gradle (bloco `plugins {}`)
- [ ] Remover `pom.xml`
- [ ] Remover arquivos Maven desnecessários
- [ ] Atualizar `.gitignore` para Gradle:
  ```
  # IntelliJ IDEA
  .idea/
  *.iws
  *.iml
  *.ipr

  # Ignore Gradle project-specific cache directory
  .gradle

  # Ignore Gradle build output directory
  build/

  # Cache of project
  .gradletasknamecache

  # Compiled class file
  *.class
  /target/
  /bin/
  ```

## 2. Pacotes e Imports

- [ ] Renomear pacote raiz `br.com.attornatus.<servico>` → `ai.attus.<servico>`
- [ ] Renomear pacote `server` → `ai.attus.<nome_servico>`
- [ ] Renomear pacote `br.com.attornatus.core` → imports das libs `ai.attus.lib.*`
- [ ] Substituir TODOS os `javax.*` → `jakarta.*` (persistence, validation, annotation)
- [ ] Mover DTOs de `domain/dto/` para dentro do pacote do domínio correspondente (ex: `domain/alerta/AlertaDto.java`, `domain/parametro/ParametroDto.java`)
- [ ] Mover DTOs de subpacotes internos para `domain/<contexto>/dto/` quando fizer sentido (ex: `DeadLetterDto` → `domain/messageria/dto/`)

## 3. Dependências (Libs Attus)

- [ ] Substituir `br.com.attornatus:core` → múltiplas libs `ai.attus:lib-*`
- [ ] Mapear imports antigos para novos:

| Import Legado | Import Novo |
|---------------|-------------|
| `br.com.attornatus.core.domain.auditoria.EntityAudit` | `ai.attus.lib.auditoria.domain.repository.EntityAudit` |
| `br.com.attornatus.core.support.BaseRepository` | `ai.attus.lib.database.domain.repository.BaseRepository` |
| `br.com.attornatus.core.support.service.BaseService` | `ai.attus.lib.database.domain.service.BaseService` |
| `br.com.attornatus.core.support.service.AbstractService` | `ai.attus.lib.database.domain.service.AbstractService` |
| `br.com.attornatus.core.exception.RegistroNaoEncontradoException` | `ai.attus.lib.core.domain.exception.RegistroNaoEncontradoException` |
| `br.com.attornatus.core.support.MessageBundle` | `ai.attus.lib.core.MessageBundle` |
| `br.com.attornatus.core.security.SecurityContextUtils` | `ai.attus.lib.security.domain.SecurityContextUtils` |
| `br.com.attornatus.core.security.Privilegio` | `ai.attus.lib.security.domain.Privilegio` |
| `br.com.attornatus.core.security.LocalToken` | `ai.attus.lib.security.domain.jwt.LocalToken` |
| `br.com.attornatus.core.tenant.TenantContextHolder` | `ai.attus.lib.security.domain.SecurityContextUtils` (usar `.getTenantId()`) |
| `br.com.attornatus.core.util.DataUtil` | `ai.attus.lib.utils.domain.DataUtils` |
| `br.com.attornatus.core.util.DigestUtils` (sha256Hex) | `ai.attus.lib.utils.domain.CryptoUtils` (sha256Hex) |
| `br.com.attornatus.core.domain.BaseEntity` | `ai.attus.lib.core.domain.BaseEntity` |
| `br.com.attornatus.core.support.ApplicationContextProvider` | **REMOVIDO** (não usar) |
| `ai.attus.lib.core.domain.SimplePageImpl` | `org.springframework.data.domain.Page` / `PageImpl` + `PageRequest` |

- [ ] Substituir `SimplePageImpl` → `Page`/`PageImpl` (Spring Data) em Feign clients, mocks e testes. Construtor muda de `new SimplePageImpl<>(list, page, size, total)` para `new PageImpl<>(list, PageRequest.of(page, size), total)`

## 4. Configurações

- [ ] Migrar `application.yml` para formato YAML hierárquico expandido — converter notação inline (`server.servlet.context-path: /xxx`) para hierárquica indentada (`server:\n  servlet:\n    context-path: /xxx`). Inclui profiles (`---`) com `spring.config.activate.on-profile` também em formato expandido
- [ ] Remover `info.app.version: '@project.version@'` — já fornecido pela `lib-starter`
- [ ] Atualizar `spring.config.import` de `optional:classpath:starter-application.yml` para `classpath:starter-application.yml`
- [ ] Remover `logback-spring.xml` (agora fornecido pela lib-starter)
- [ ] Atualizar `application-test.yml`: `spring.config.import: classpath:test-application.yml`
- [ ] Adicionar `spring.flyway.locations` no `application-test.yml`
- [ ] Remover `security.oauth2.client.*` do `application.yml` — OAuth2 legado removido no stack migrado
- [ ] Consolidar profiles em um único `application.yml` usando separador `---` — remover arquivos `application-localhost.yml`, `application-postgres.yml` etc. e mover o conteúdo para profiles inline:
  ```yaml
  ---

  spring:
    config:
      activate:
        on-profile: localhost

  server:
    port: 8091
  ```
- [ ] Remover `kubernetes.yaml` e `kubernetes-developer.yaml` (se existirem)
- [ ] Remover certificados `.p12` e `keystore.jks` do repositório
- [ ] Remover `spring.batch.*` do `application.yml` (se existir Spring Batch)
- [ ] Remover configs legadas do `application-test.yml`: `spring.redis.*`, `spring.cloud.kubernetes.*`, `spring.cache.type`, `spring.jpa.eclipselink.*`, `spring.datasource.*` (H2 explícito)
- [ ] **Verificar duplicações com `starter-application.yml`** — comparar property por property do `application.yml` do microsserviço com o `starter-application.yml`. Remover propriedades que já existem no starter com o mesmo valor. Manter sobrescritas intencionais (ex: schema legado diferente do nome do app) com comentário explicativo. Ver tabela completa em `migracao-configuracoes.md` seção "Verificação de Duplicações"
- [ ] **NÃO redefinir profiles de banco** (`postgres`, `oracle`, `pgesp`, etc.) — já fornecidos por `application-{profile}.yml` do lib-starter. Manter no microsserviço apenas sobrescritas de schema legado quando o nome do schema difere do `${spring.application.name}`. Remover todos os placeholders duplicados

## 5. Segurança

- [ ] Remover `SecurityConfig extends ResourceServerConfigurerAdapter`
- [ ] Remover `@EnableResourceServer`, `@EnableOAuth2Client`, `@EnableGlobalMethodSecurity`
- [ ] Criar nova `SecurityConfig` com `@EnableMethodSecurity(prePostEnabled = true)`
- [ ] Usar `SecurityRequestCustomizer` bean ao invés de `configure(HttpSecurity)`
- [ ] Substituir `.antMatchers()` → `.requestMatchers()`
- [ ] Remover `RoleHierarchy`, `RoleHierarchyVoter`, `AffirmativeBased` (agora na lib-security)
- [ ] Remover `FeignConfiguration` (agora na lib-security/lib-starter)
- [ ] Remover `JpaTransactionManagerConfig` (agora auto-configurado)
- [ ] Substituir strings literais em `@PreAuthorize` por referências ao `Privilegio` enum via access handler
- [ ] Substituir strings literais em `SecurityRequestCustomizer` por `Privilegio.X.name()`
- [ ] Remover `ApplicationContextAware` — usar injeção via construtor

## 6. Kafka

- [ ] Substituir `KafkaProducer<String, String>` → `KafkaTemplate<String, String>`
- [ ] Substituir `kafkaProducer.send(record)` → `kafkaTemplate.send(record)`
- [ ] Remover `KafkaTransactionManager` manual (agora auto-configurado)
- [ ] Remover `ConsumerFactory` manual do KafkaConfig (usar `CustomKafkaProperties` da lib-messageria)
- [ ] Simplificar `KafkaConfig`: manter apenas constantes e bean `AdminClient`
- [ ] Migrar `@KafkaListener` para usar constantes do `KafkaConfig`
- [ ] Mover constantes de headers Kafka para `KafkaConfig`

## 7. JPA e Entidades

- [ ] Atualizar `@TableGenerator` para incluir `table = "sequence"`, `pkColumnName = "seq_name"`, `valueColumnName = "seq_count"`
- [ ] Adicionar `fetch = FetchType.EAGER` em `@ElementCollection` onde necessário
- [ ] Remover builders customizados desnecessários (ex: `CustomDeadLetterBuilder`)
- [ ] Atualizar `RepositoryConfig`: usar `org.springframework.boot.persistence.autoconfigure.EntityScan` ao invés de `org.springframework.boot.autoconfigure.domain.EntityScan`
- [ ] Usar `CustomRepositoryImpl` de `ai.attus.lib.database`

## 8. Spring Batch (se aplicável)

- [ ] Avaliar se o microsserviço usa Spring Batch apenas para jobs agendados simples
- [ ] Se sim, migrar jobs para Quartz puro (`implements org.quartz.Job`)
- [ ] Remover `SpringBatchConfig`
- [ ] Remover `AbstractBatchJob` e classes base de batch
- [ ] Remover listeners do Spring Batch (`LogProcessListener`, `LogReadListener`, `LogWriterListener`, `LogStepListener`, `ResumoListener`)
- [ ] Remover `FalhasJobContext` e seu teste
- [ ] Remover entidades/repositórios específicos do Spring Batch (`BatchJobExecutionParams`, etc.)
- [ ] Remover Readers/Writers específicos (ex: `CoordenadasDividaReader`, `CoordenadasWriter`)
- [ ] Remover dependência `spring-boot-starter-batch` do `build.gradle`
- [ ] Remover `spring.batch.*` do `application.yml`

## 9. Classe Principal

- [ ] Mover de `server.<Nome>Server` para `ai.attus.<nome_servico>.<Nome>Server`
- [ ] Remover `@ComponentScan` (auto-scan pelo pacote base)
- [ ] Remover `@EnableCaching` (agora na lib-cache)
- [ ] Remover `@Bean RestTemplate` (agora na lib-starter)
- [ ] Substituir `@PostConstruct init()` por chamada direta no `main()`
- [ ] Tornar classe `final` com construtor privado
- [ ] Tornar `main()` package-private (`static void main`)

## 10. Controllers

- [ ] Renomear `Facade` → `Component` (ex: `ParametroFacade` → `ParametroComponent`)
- [ ] Mover lógica de conversão DTO do Controller para o Component
- [ ] Remover injeção direta de Mapper e Service no Controller quando Component existe
- [ ] Substituir `TenantContextHolder.get()` → `SecurityContextUtils.getTenantId()`
- [ ] Remover controllers obsoletos (ex: `ApresentacaoController`)

## 11. Components

- [ ] Criar Components para domínios que não tinham (ex: `ErroFrontendComponent`)
- [ ] Mover lógica de orquestração dos Controllers para Components
- [ ] Garantir que Component faz conversão Entity ↔ DTO via Mapper
- [ ] Component retorna DTOs, não Entities

## 12. Testes

- [ ] Criar `AbstractControllerTest` com MockMvc, @MockitoBean dos Services/Components, ObjectMapper, WireMock, springSecurity()
- [ ] Criar `AbstractServiceTest` com @SpringBootTest, @ExtendWith(MockitoExtension), @EmbeddedKafka, WireMock
- [ ] Criar `<Nome>TestConfig` com mocks de KafkaTemplate, ConsumerFactory e TODOS os Feign clients
- [ ] Migrar `@MockBean` → `@MockitoBean` (Spring Boot 4)
- [ ] Usar `@WithMockAuthenticationToken` (de lib-test) ao invés de `@WithMockUser`
- [ ] Criar `OAuthClientTenantMock` e `TokenServicesMock` simplificados (se necessário)
- [ ] Usar `@NestedTestConfiguration(INHERIT)` em vez de `OVERRIDE`
- [ ] Configurar `quartz.useRamJobStore: true` no `application-test.yml` (se microsserviço usa Quartz)
- [ ] Atualizar `MockFactory` para novo pacote e novas entidades
- [ ] Usar `tools.jackson.databind.ObjectMapper` ao invés de `com.fasterxml.jackson.databind.ObjectMapper` (Spring Boot 4 usa Jackson 3)
- [ ] Substituir TODOS os imports `com.fasterxml.jackson.*` → `tools.jackson.*` em código de produção e testes
- [ ] Atualizar `build.gradle`: substituir `com.fasterxml.jackson.core:jackson-databind` → `tools.jackson.core:jackson-databind` (sem `jackson-datatype-jsr310` — já incluído no Jackson 3)
- [ ] Bibliotecas internas (lib-utils, etc.) que usam `com.fasterxml.jackson` devem ser migradas para `tools.jackson` antes de usar no projeto migrado
- [ ] Em testes: **NUNCA** definir bean `com.fasterxml.jackson.databind.ObjectMapper` no `TestConfig` — usar apenas `tools.jackson.databind.ObjectMapper`
- [ ] Remover classes de teste obsoletas (ex: `RedisTemplateTestConfig`, `MetodosAnotadosRecursosCache`, `DistribuicaoServiceMock`)
- [ ] Remover `AdminServerTest` (se existir)
- [ ] Remover bloco `static { System.setProperty(...) }` do `AbstractServiceTest` — todas essas propriedades são do stack legado:
  - `spring.main.allow-bean-definition-overriding` — **proibido** (resolver conflito de beans na raiz)
  - `eureka.client.enabled` — Eureka não existe no stack migrado
  - `spring.cloud.config.enabled` — Config Server não existe no stack migrado
  - `security.oauth2.client.*` — OAuth2 legado removido
  - `cloud.aws.region.*` — AWS SDK legado
  - `spring.pd.tipo-armazenamento` — propriedade legada
  - `TimeZone.setDefault(...)` — já setado pela `lib-starter` (`StarterConfig`)
- [ ] Resolver conflitos de `@FeignClient` com mesmo `name` entre microsserviço e libs — adicionar `contextId` no `@FeignClient` do microsserviço (ex: `@FeignClient(name = "admin-svc", contextId = "adminService", ...)`) em vez de usar `allow-bean-definition-overriding`

## 13. Limpeza Final

- [ ] Remover TODOS os arquivos do pacote `br.com.attornatus`
- [ ] Remover TODOS os arquivos do pacote `server`
- [ ] Remover `pom.xml`
- [ ] Remover `logback-spring.xml`
- [ ] Remover `kubernetes.yaml`, `kubernetes-developer.yaml`
- [ ] Remover certificados `.p12`, `keystore.jks`
- [ ] Remover serviços externos descontinuados (clients, DTOs, exceções, testes, mocks)
- [ ] Remover classes do Spring Batch (se migrado para Quartz puro)
- [ ] Verificar que não há imports `br.com.attornatus` remanescentes
- [ ] Verificar que não há imports `javax.*` remanescentes (exceto `javax.crypto`, `javax.sql` se necessário)
- [ ] Verificar que não há `System.setProperty` em blocos `static` de classes de teste
- [ ] Verificar que não há `spring.main.allow-bean-definition-overriding` em nenhum arquivo
- [ ] Compilar com `./gradlew build`
- [ ] Rodar testes com `./gradlew test`
- [ ] Verificar cobertura com `./gradlew jacocoTestReport`
