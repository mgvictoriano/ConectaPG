# Migração de Configurações

## application.yml

### Formato YAML

Converter notação inline para hierárquica indentada:

**Antes (inline):**
```yaml
server.servlet.context-path: /xxx
spring.config.import: [ "optional:classpath:starter-application.yml" ]
spring.application.name: meu-servico
security.oauth2.client.clientSecret: "xxx"
```

**Depois (hierárquico):**
```yaml
server:
  servlet:
    context-path: /xxx

spring:
  config:
    import: classpath:starter-application.yml
  application:
    name: meu-servico
    name.upper: MEU-SERVICO
```

### Remoções Obrigatórias

| Propriedade | Motivo |
|-------------|--------|
| `info.app.version: '@project.version@'` | Fornecido pela `lib-starter` |
| `security.oauth2.client.*` | OAuth2 legado removido |
| `spring.batch.initialize-schema` | Spring Batch removido (se aplicável) |
| `spring.batch.job.enabled` | Spring Batch removido (se aplicável) |

### Alterações

| Antes | Depois |
|-------|--------|
| `spring.config.import: [ "optional:classpath:starter-application.yml" ]` | `spring.config.import: classpath:starter-application.yml` |
| `logging.level.br.com.attornatus` | `logging.level.ai.attus` |

### Profiles

Consolidar profiles em um único `application.yml` usando separador `---`. Remover arquivos `application-localhost.yml`, `application-postgres.yml`, etc.

```yaml
---

spring:
  config:
    activate:
      on-profile: localhost

server:
  port: 8089

logging:
  level:
    ai.attus.<servico>.client: DEBUG

---

spring:
  config:
    activate:
      on-profile: postgres

quartz:
  jobStore:
    driverDelegateClass: org.quartz.impl.jdbcjobstore.PostgreSQLDelegate
```

## Verificação de Duplicações com starter-application.yml

Após migrar o `application.yml`, verificar **property por property** se alguma já está definida no `starter-application.yml`. Propriedades duplicadas devem ser removidas do microsserviço para evitar manutenção em dois lugares.

### Checklist Mecânico

1. Ler o `starter-application.yml` da lib-starter (`lib-starter/src/main/resources/starter-application.yml`)
2. Para **cada propriedade** do `application.yml` do microsserviço, verificar se:
   - Já existe no starter com **o mesmo valor** → **REMOVER** do microsserviço
   - Já existe no starter com **valor template** (ex: `ATT_${spring.application.name}`) e o microsserviço sobrescreve com valor fixo → **MANTER** somente se o valor fixo for diferente do que o template resolveria (ex: schema `ATT_DOCUMENTO` quando o app se chama `updoc`)
   - **Não existe** no starter → **MANTER** no microsserviço

### Propriedades comumente duplicadas

| Propriedade | Já no starter? | Ação |
|-------------|---------------|------|
| `spring.flyway.table: FLYWAY_SCHEMA_HISTORY` | ✅ Mesmo valor | Remover |
| `spring.flyway.tablespace: TBS_<SERVICO>` | ✅ Template `TBS_${spring.application.name}` | Remover se nome coincide, manter se difere |
| `spring.datasource.hikari.schema` | ✅ Template `ATT_${spring.application.name}` | Remover se nome coincide, manter se difere |
| `spring.datasource.hikari.maximumPoolSize` | ✅ Valor 20 | Remover se igual |
| `spring.jpa.properties.hibernate.highlight_sql` | ✅ `true` | Remover |
| `spring.jpa.properties.hibernate.use_sql_comments` | ✅ `true` | Remover |
| `spring.jpa.properties.hibernate.generate_statistics` | ✅ `true` | Remover |
| `spring.jackson.default-property-inclusion` | ✅ `non_empty` | Remover |
| `spring.jackson.deserialization.fail-on-unknown-properties` | ✅ `false` | Remover |
| `management.endpoints.*` | ✅ Completo | Remover |
| `management.tracing.*` / `management.opentelemetry.*` | ✅ Completo | Remover |
| `spring.kafka.consumer.group-id` | ✅ Template `${spring.application.name}` | Remover |
| `spring.kafka.listener.observation-enabled` | ✅ `true` | Remover |
| `spring.messages.basename` | ✅ `messages/messages, messages/starter-messages` | Remover se igual |
| `logging.level.root: WARN` | ✅ Definido no starter | Remover |
| `logging.level.ai.attus: INFO` | ✅ Definido no starter | Remover |
| `springdoc.swagger-ui.enabled: false` | ✅ Definido no starter | Remover |
| `springdoc.api-docs.enabled: false` | ✅ Definido no starter | Remover |

### Propriedades que DEVEM permanecer no microsserviço

- `server.servlet.context-path` — único por microsserviço
- `spring.application.name` — único por microsserviço
- `spring.servlet.multipart.*` — específico (ex: updoc com 750MB)
- `spring.kafka.max-poll-records` — específico por consumidor
- Propriedades de domínio (`attornatus.*`, `attus.*`, `storage.*`)
- Propriedades de profile (`localhost`, `postgres`, `oracle`, `pgesp`)
- `spring.datasource.username` — específico por microsserviço
- `spring.flyway.schemas` — específico por microsserviço
- `logging.level` de pacotes específicos do microsserviço

### Profiles de banco já fornecidos pelo lib-starter

O `lib-starter` já fornece `application-postgres.yml`, `application-oracle.yml`, `application-pgesp.yml`, `application-pgeba.yml`, `application-pgepe.yml`, `application-agemg.yml` e `application-sas.yml` com **todas** as configurações de banco (datasource, flyway, placeholders, tenants).

**Regra:** O microsserviço **NÃO deve redefinir** profiles de banco. Manter apenas sobrescritas de valores que diferem do template `${spring.application.name}`:

```yaml
# ❌ ERRADO — profile postgres inteiro copiado no microsserviço
spring:
  config:
    activate:
      on-profile: postgres
  datasource:
    url: jdbc:postgresql://localhost/attornatus
    driver-class-name: org.postgresql.Driver
    username: att_meu_servico_app
    # ... 30+ linhas de placeholders duplicados ...

# ✅ CORRETO — apenas sobrescritas do schema legado
spring:
  config:
    activate:
      on-profile: postgres
  datasource:
    username: att_documento_app  # Schema legado difere do nome do app
    password: ${DB_PASSWORD:}
    hikari:
      schema: att_documento
  flyway:
    user: att_documento
    password: ${DB_FLYWAY_PASSWORD:}
    schemas: att_documento
    placeholders:
      alterar_coluna_not_null: "SET NOT NULL"  # Placeholder extra não presente no starter
```

**Quando NÃO precisa de profile postgres no microsserviço:**
- Se o schema do banco coincide com o nome do app (ex: app `calculo` → schema `att_calculo`)
- Se não há placeholders extras além dos definidos no starter
- Se não há sobrescritas de senha (starter já define padrão localhost)

### Exemplo: sobrescrita intencional

O microsserviço `updoc` define `spring.datasource.hikari.schema: ATT_DOCUMENTO` (não `ATT_UPDOC`) porque o schema do banco legado usa o nome `DOCUMENTO`. Neste caso, a sobrescrita é **intencional** e deve ser mantida com um comentário explicativo:

```yaml
spring:
  datasource:
    hikari:
      schema: ATT_DOCUMENTO  # Schema legado difere do nome do microsserviço (updoc)
```

## Arquivos a Remover

| Arquivo | Motivo |
|---------|--------|
| `logback-spring.xml` | Fornecido pela `lib-starter` |
| `keystore.jks` / `*.p12` | Certificados não devem estar no repositório |
| `kubernetes.yaml` / `kubernetes-developer.yaml` | Não necessários no stack migrado |

## application-test.yml

### Antes (legado típico):
```yaml
spring.config.import: [ "optional:classpath:starter-application-test.yml" ]
spring:
  redis:
    host: localhost
    port: 6379
  cloud:
    kubernetes:
      config:
        enableApi: false
  cache:
    type: none
  jpa:
    eclipselink:
      loggingLevel: WARNING
      weaving: true
  datasource:
    url: jdbc:h2:mem:db;MODE=Oracle;DATABASE_TO_LOWER=TRUE
    hikari:
      connectionInitSql: ''
```

### Depois (migrado):
```yaml
spring:
  config:
    import:
      - "classpath:test-application.yml"
  jackson:
    deserialization:
      fail-on-null-for-primitives: false
  flyway:
    locations: filesystem:../scripts/microservicos/<servico>/base_inicial, filesystem:../scripts/microservicos/<servico>/comum, filesystem:../scripts/microservicos/<servico>/{vendor}
  messages:
    basename: messages/messages
```

### Remoções do application-test.yml

| Propriedade | Motivo |
|-------------|--------|
| `spring.redis.*` | Auto-configurado ou mockado |
| `spring.cloud.kubernetes.*` | Não existe no stack migrado |
| `spring.cache.type: none` | Auto-configurado pela lib-cache |
| `spring.jpa.eclipselink.*` | Hibernate substitui EclipseLink |
| `spring.datasource.*` (H2 explícito) | H2 auto-configurado pelo Spring Boot Test |
| `logging.level.root: WARN` | Desnecessário em testes |

## Flyway Multitenant

Microsserviços que usam Flyway multitenant precisam:

1. **Configurar `spring.flyway.locations`** no `application-test.yml` com o path correto dos scripts
2. **Usar `{vendor}`** no path para auto-selecionar scripts por banco (H2, PostgreSQL, Oracle)
3. **Usar `@DependsOn("flywayMultitenantMigrationRunner")`** em beans que dependem do banco já migrado (ex: `SchedulerFactoryBean`)
4. **Usar `@ConditionalOnProperty`** para bifurcar beans com/sem Flyway:

```java
@Bean
@DependsOn("flywayMultitenantMigrationRunner")
@ConditionalOnProperty(name = "attus.database.flyway.multitenant.enabled", havingValue = "true")
public Scheduler scheduler(DataSource dataSource, SpringBeanJobFactory jobFactory) throws Exception {
    return createScheduler(dataSource, jobFactory);
}

@Bean
@ConditionalOnProperty(name = "attus.database.flyway.multitenant.enabled", havingValue = "false", matchIfMissing = true)
public Scheduler schedulerWithoutFlyway(DataSource dataSource, SpringBeanJobFactory jobFactory) throws Exception {
    return createScheduler(dataSource, jobFactory);
}
```

## Quartz Scheduler

Microsserviços que usam Quartz com JDBC Job Store:

1. **Configurar `quartz.useRamJobStore: true`** no `application-test.yml` para testes usarem RAMJobStore
2. **Manter `quartz.jobStore.driverDelegateClass`** configurável por profile (Oracle, PostgreSQL, H2)
3. **Usar `AutoWiringSpringBeanJobFactory`** com injeção via construtor (não `ApplicationContextAware`):

```java
public final class AutoWiringSpringBeanJobFactory extends SpringBeanJobFactory {
    private final AutowireCapableBeanFactory beanFactory;

    public AutoWiringSpringBeanJobFactory(AutowireCapableBeanFactory beanFactory) {
        this.beanFactory = beanFactory;
    }

    @Override
    protected Object createJobInstance(TriggerFiredBundle bundle) throws Exception {
        Object job = super.createJobInstance(bundle);
        beanFactory.autowireBean(job);
        return job;
    }
}
```
