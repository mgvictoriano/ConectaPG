# Migração de Testes

## Classes Base de Teste

### AbstractControllerTest

Classe base para testes de Controller. Centraliza MockMvc, mocks de Services/Components, ObjectMapper e segurança.

```java
@ActiveProfiles("test")
@NestedTestConfiguration(NestedTestConfiguration.EnclosingConfiguration.INHERIT)
@SpringBootTest(classes = {<Nome>Server.class, <Nome>TestConfig.class})
@DisplayNameGeneration(DisplayNameGenerator.ReplaceUnderscores.class)
@WithMockAuthenticationToken(authorities = {"ROLE_USUARIO", "ROLE_ADMIN_ATTORNATUS"})
public abstract class AbstractControllerTest {

    protected MockMvc mockMvc;

    @Autowired
    private WebApplicationContext webApplicationContext;

    @Autowired
    protected ObjectMapper objectMapper;  // tools.jackson.databind.ObjectMapper

    @MockitoBean
    protected <Service>Mock serviceMock;  // Um @MockitoBean por Service do Controller

    @RegisterExtension
    protected static WireMockExtension wireMock = WireMockExtension.newInstance()
            .options(wireMockConfig().dynamicPort())
            .build();

    @DynamicPropertySource
    static void configureWireMock(DynamicPropertyRegistry registry) {
        registry.add("svc.xxx.url", () -> wireMock.baseUrl());
        // Repetir para cada Feign client
    }

    @BeforeEach
    void setupMockMvc() {
        mockMvc = webAppContextSetup(webApplicationContext)
                .apply(springSecurity())
                .build();
    }
}
```

### AbstractServiceTest

Classe base para testes de Service/Integration. Centraliza Spring Boot Test, WireMock e profiles.

```java
@ActiveProfiles("test")
@NestedTestConfiguration(NestedTestConfiguration.EnclosingConfiguration.INHERIT)
@ExtendWith(MockitoExtension.class)
@SpringBootTest(classes = {<Nome>Server.class, <Nome>TestConfig.class})
@DisplayNameGeneration(DisplayNameGenerator.ReplaceUnderscores.class)
@WithMockAuthenticationToken(authorities = {"ROLE_USUARIO", "ROLE_ADMIN_ATTORNATUS"})
public abstract class AbstractServiceTest {

    @RegisterExtension
    protected static WireMockExtension wireMock = WireMockExtension.newInstance()
            .options(wireMockConfig().dynamicPort())
            .build();

    @DynamicPropertySource
    static void configureWireMock(DynamicPropertyRegistry registry) {
        registry.add("svc.xxx.url", () -> wireMock.baseUrl());
    }
}
```

## @NestedTestConfiguration — INHERIT vs OVERRIDE

| Modo | Comportamento | Quando usar |
|------|---------------|-------------|
| `INHERIT` (recomendado) | Classes `@Nested` herdam contexto da classe pai automaticamente | Padrão para todos os testes migrados |
| `OVERRIDE` | Classes `@Nested` criam contexto próprio | Apenas quando necessário isolar contextos |

> **Migração**: O stack legado pode usar `OVERRIDE`. Sempre migrar para `INHERIT` para simplificar a estrutura e evitar problemas de beans não encontrados em classes `@Nested`.

## TestConfig — Mocks de Feign Clients e Infraestrutura

Criar um `<Nome>TestConfig` com `@TestConfiguration` que fornece mocks para Feign clients e infraestrutura:

```java
@TestConfiguration
public class <Nome>TestConfig {

    // Mocks de Feign clients
    @Bean public DividaService dividaService() { return Mockito.mock(DividaService.class); }
    @Bean public CobrancaService cobrancaService() { return Mockito.mock(CobrancaService.class); }
    // ... um bean por Feign client

    // Mocks de Kafka
    @Bean
    public KafkaTemplate<String, String> kafkaTemplate() {
        KafkaTemplate<String, String> mock = Mockito.mock(KafkaTemplate.class);
        Mockito.when(mock.isAllowNonTransactional()).thenReturn(true);
        return mock;
    }

    @Bean
    public ConsumerFactory<String, String> consumerFactory() {
        return Mockito.mock(ConsumerFactory.class);
    }
}
```

> **Por que mocks no TestConfig?** Feign clients fazem chamadas HTTP reais. Sem mocks, os testes falham ao tentar conectar a serviços externos. O WireMock cobre cenários onde se quer testar a integração HTTP real.

## Migração de Anotações de Mock

| Antes (Spring Boot 2.x) | Depois (Spring Boot 4) |
|--------------------------|------------------------|
| `@MockBean` | `@MockitoBean` |
| `@SpyBean` | `@MockitoSpyBean` |
| `@WithMockUser` | `@WithMockAuthenticationToken` (de `lib-test`) |

> **Import**: `@MockitoBean` está em `org.springframework.test.context.bean.override.mockito.MockitoBean`

## Jackson 3 (tools.jackson)

| Antes (Jackson 2) | Depois (Jackson 3) |
|--------------------|---------------------|
| `com.fasterxml.jackson.databind.ObjectMapper` | `tools.jackson.databind.ObjectMapper` |
| `com.fasterxml.jackson.annotation.*` | `tools.jackson.annotation.*` |
| `com.fasterxml.jackson.core.*` | `tools.jackson.core.*` |
| `com.fasterxml.jackson.datatype.jsr310.*` | **REMOVIDO** (incluído no Jackson 3) |

> **NUNCA** definir bean `com.fasterxml.jackson.databind.ObjectMapper` em nenhum `TestConfig`. Usar apenas `tools.jackson.databind.ObjectMapper`.

## Quartz em Testes

Microsserviços que usam Quartz com JDBC Job Store enfrentam um desafio: `@MockitoBean` no `AbstractControllerTest` pode criar um segundo contexto Spring (cache key diferente), onde as tabelas Quartz não existem (Flyway só rodou no primeiro).

### Solução — RAMJobStore para testes

Configurar `quartz.useRamJobStore: true` no `application-test.yml`:

```yaml
quartz:
  useRamJobStore: true
```

O `QuartzSchedulerConfig` deve suportar isso:

```java
@Value("${quartz.useRamJobStore:false}")
private boolean useRamJobStore;

@Bean
public Properties quartzProperties() {
    Properties prop = new Properties();
    if (useRamJobStore) {
        prop.put("org.quartz.jobStore.class", "org.quartz.simpl.RAMJobStore");
    } else {
        prop.put("org.quartz.jobStore.class", "org.quartz.impl.jdbcjobstore.JobStoreTX");
        // ...
    }
    return prop;
}
```

## ApplicationContextProvider — NullPointerException em Testes

Se algum Job ou componente usa `ApplicationContextProvider.getBean()`, testes que fazem mock do `ApplicationContext` podem deixá-lo `null`.

**Solução**: Adicionar `@AfterEach` para restaurar o `ApplicationContext`:

```java
@Autowired
private ApplicationContext applicationContext;

@AfterEach
void restoreApplicationContext() {
    ApplicationContextProvider provider = new ApplicationContextProvider();
    provider.setApplicationContext(applicationContext);
}
```

> **Melhor solução**: Refatorar para não usar `ApplicationContextProvider` — usar injeção direta.

## Bloco static no AbstractServiceTest — REMOVER

Remover todo bloco `static { System.setProperty(...) }` do `AbstractServiceTest`. Essas propriedades são do stack legado:

| Propriedade | Motivo da remoção |
|-------------|-------------------|
| `spring.main.allow-bean-definition-overriding` | **Proibido** — resolver conflito de beans na raiz |
| `eureka.client.enabled` | Eureka não existe no stack migrado |
| `spring.cloud.config.enabled` | Config Server não existe no stack migrado |
| `security.oauth2.client.*` | OAuth2 legado removido |
| `cloud.aws.region.*` | AWS SDK legado |
| `spring.pd.tipo-armazenamento` | Propriedade legada |
| `TimeZone.setDefault(...)` | Já setado pela `lib-starter` (`StarterConfig`) |

## Resolver Conflitos de @FeignClient

Se um microsserviço e uma lib definem `@FeignClient` com mesmo `name`, adicionar `contextId` no microsserviço:

```java
@FeignClient(name = "admin-svc", contextId = "adminService", url = "${svc.admin.url}")
public interface AdminService { ... }
```

> **NUNCA** resolver com `spring.main.allow-bean-definition-overriding=true`.

## Testes de DTO — Critério de Manutenção

| Tipo de teste | Ação |
|---------------|------|
| Testa getters/setters triviais | **REMOVER** |
| Testa getter que delega ao enum | **REMOVER** (tautologia) |
| Testa `compareTo` simples | **REMOVER** |
| Testa lógica de negócio real (parsing, validação, cálculo) | **MANTER** |
| Testa enum com lógica (`isXxx()`) | **MANTER** |
