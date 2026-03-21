# Testes BDD Java — Attus

Guia de testes Behavior Driven Development (BDD) para Java (JUnit 5).

---

## Estrutura BDD

Usar anotação `@Nested` para hierarquia de cenários e nomenclatura em **PT-BR**.

## Classes Base Abstratas

Existem **duas** classes base abstratas. Cada `@MockitoBean` recria o contexto do Spring, por isso todos os mocks ficam centralizados em `AbstractControllerTest`. Dessa forma o contexto é recriado apenas **duas vezes**: uma para testes de Service (integração) e outra para testes de Controller (mock).

### AbstractServiceTest — Testes de Integração

Testes de Service são **testes de integração** com banco real (H2), WireMock para simular chamadas a outros microsserviços, e EmbeddedKafka quando necessário.

```java
@ActiveProfiles("test")
@DisplayNameGeneration(DisplayNameGenerator.ReplaceUnderscores.class)
@SpringBootTest(classes = {SdaServer.class})
@ExtendWith(MockitoExtension.class)
@WithMockAuthenticationToken
@AutoConfigureWireMock(port = 0)
@EmbeddedKafka(partitions = 1, brokerProperties = {"listeners=PLAINTEXT://localhost:9093", "port=9093"})
public abstract class AbstractServiceTest {

    @DynamicPropertySource
    static void overrideWebClientBaseUrl(DynamicPropertyRegistry registry) {
        registry.add("svc.admin.url", () -> "http://localhost:${wiremock.server.port}/admin");
    }
}
```

**Características:**
- `@SpringBootTest` — contexto completo da aplicação
- `@AutoConfigureWireMock(port = 0)` — WireMock em porta aleatória para simular Feign Clients
- `@DynamicPropertySource` — redireciona URLs de serviços externos para o WireMock
- `@EmbeddedKafka` — Kafka embarcado para testes de consumers/producers
- `@WithMockAuthenticationToken` — mock de autenticação (de `ai.attus:lib-test`)
- `@ExtendWith(MockitoExtension.class)` — centralizado em `AbstractServiceTest`, herdado por todas as subclasses
- É aceito usar `@Mock` junto com `@Autowired` na mesma classe de teste: beans reais do Spring via `@Autowired` e dependências mockadas via `@Mock`, construindo o objeto testado manualmente no `@BeforeEach`. Isso evita o uso de `@MockitoBean` (que criaria um contexto Spring separado). Exemplo: usar `@Autowired ParametroMapper` (bean real) + `@Mock ParametroService` (mock) e construir `new ParametroComponent(parametroServiceMock, parametroMapper, ...)` no `@BeforeEach`
- **NUNCA mockar Mapper** (`@Mock` ou `@MockitoBean`) — Mappers devem ser sempre reais (`@Autowired`). É através dos testes de Controller e Component/Service que os Mappers são testados indiretamente. Mockar o Mapper esconde bugs de mapeamento e reduz a cobertura real
- **Nunca repetir `@ExtendWith(MockitoExtension.class)` nas subclasses** — já herdado de `AbstractServiceTest`

### AbstractControllerTest — Testes de Controller (MockMvc)

**Todo teste de Controller DEVE obrigatoriamente herdar de `AbstractControllerTest`** — sem exceção. Testes de Controller usam MockMvc com `@MockitoBean` para mockar os Services e Components. **Todos os `@MockitoBean` ficam centralizados aqui** para evitar recriação do contexto.

**Feign Clients devem ser simulados via WireMock**, não via `@MockitoBean`. O `AbstractControllerTest` deve configurar WireMock e redirecionar as URLs dos serviços externos, da mesma forma que o `AbstractServiceTest`.

```java
@ActiveProfiles("test")
@SpringBootTest(classes = SdaServer.class)
@DisplayNameGeneration(DisplayNameGenerator.ReplaceUnderscores.class)
@WithMockAuthenticationToken
public abstract class AbstractControllerTest {

    protected MockMvc mockMvc;

    @Autowired
    private WebApplicationContext webApplicationContext;

    @Autowired
    protected MockFactory mockFactory;

    @Autowired
    protected ObjectMapper objectMapper;

    @RegisterExtension
    protected static WireMockExtension wireMock = WireMockExtension.newInstance()
            .options(wireMockConfig().dynamicPort())
            .build();

    @DynamicPropertySource
    static void configureWireMock(DynamicPropertyRegistry registry) {
        registry.add("svc.security.url", () -> wireMock.baseUrl());
        registry.add("svc.admin.url", () -> wireMock.baseUrl());
    }

    @MockitoBean
    protected TributoService tributoServiceMock;

    @MockitoBean
    protected CategoriaService categoriaServiceMock;

    @MockitoBean
    protected DebitoService debitoServiceMock;

    // ... todos os Services/Components mockados do microsserviço
    // NUNCA @MockitoBean em Feign Clients — usar WireMock

    @BeforeEach
    void setupMockMvc() {
        mockMvc = MockMvcBuilders.webAppContextSetup(webApplicationContext)
                .apply(springSecurity())
                .build();
    }
}
```

**Regras:**
- **Todos** os `@MockitoBean` ficam em `AbstractControllerTest` — nunca nas subclasses
- Usar `@MockitoBean` (Spring Boot 3.4+), não `@MockBean` (deprecated)
- **`@MockitoBean` apenas para Services e Components** — nunca para Feign Clients
- **Feign Clients simulados via WireMock** com `@RegisterExtension` + `@DynamicPropertySource` redirecionando URLs
- `MockFactory` e `ObjectMapper` são injetados via `@Autowired`
- Subclasses herdam os mocks via `protected`
- **`ObjectMapper` é sempre `tools.jackson.databind.ObjectMapper`** — NUNCA `com.fasterxml.jackson.databind.ObjectMapper` (Spring Boot 4 usa Jackson 3)
- **NUNCA** definir bean `com.fasterxml.jackson.databind.ObjectMapper` em `TestConfig` — causa conflito de beans
- Todas as dependências de bibliotecas internas (ex: `lib-utils`) que usam `com.fasterxml.jackson` devem ser migradas para `tools.jackson` antes de usar em projetos Spring Boot 4

## MockFactory

Classe `@Component` que centraliza a criação de entidades para testes. Usa builder pattern.

```java
@Component
public class MockFactory {

    public Tributo fabricarTributo(Long id, String identificadorNoCliente) {
        return Tributo.builder()
                .id(id)
                .nome("IPTU")
                .tenantId("ATTUS")
                .assuntoInstituicaoId(123L)
                .identificadorNoCliente(identificadorNoCliente)
                .build();
    }

    public Debito fabricarDebito(UUID id) {
        return Debito.builder()
                .id(id)
                .tenantId("ATTUS")
                .numero("6753090581812")
                .categoria(fabricarCategoria(1L, "1"))
                .tributo(fabricarTributo(1L, "1"))
                .natureza(Natureza.TRIBUTARIA)
                .build();
    }
}
```

**Regras:**
- Anotado com `@Component` — gerenciado pelo Spring
- Métodos `fabricar{Entidade}` — sempre usando builder
- Reutilizado em testes de Service e Controller

## WireMock — Simulação de Feign Clients

WireMock simula chamadas HTTP para outros microsserviços (Feign Clients). Deve ser configurado **tanto** em `AbstractServiceTest` **quanto** em `AbstractControllerTest`. Feign Clients **nunca** devem ser mockados via `@MockitoBean` — sempre usar WireMock para manter o comportamento real do client HTTP (serialização, headers, error handling).

```java
// No teste, simular resposta de outro microsserviço:
WireMock.stubFor(WireMock.get(WireMock.urlEqualTo("/admin/algum-recurso"))
        .willReturn(WireMock.aResponse()
                .withStatus(200)
                .withHeader("Content-Type", "application/json")
                .withBody("{ \"id\": 123, \"nome\": \"Recurso Admin\" }")));
```

## Template de Teste de Service (Integração)

```java
class TributoServiceTest extends AbstractServiceTest {

    @Autowired
    private TributoService tributoService;

    @Autowired
    private MockFactory mockFactory;

    @Nested
    class Dado_um_tributo extends AbstractServiceTest {

        private Tributo tributo;

        @BeforeEach
        void setup() {
            tributo = mockFactory.fabricarTributo(null, "111");
        }

        @Nested
        class Quando_salvar {

            @BeforeEach
            void setup() {
                tributo = tributoService.salvar(tributo);
            }

            @Nested
            class Quando_buscar_por_id extends AbstractServiceTest {

                private Tributo resultado;

                @BeforeEach
                void setup() {
                    resultado = tributoService.buscarPorIdOrElseThrow(tributo.getId());
                }

                @Test
                void Entao_deve_retornar_o_objeto_correto() {
                    assertThat(resultado.getId()).isEqualTo(tributo.getId());
                    assertThat(resultado.getTenantId()).isEqualTo("ATTUS");
                    assertThat(resultado.getNome()).isEqualTo("IPTU");
                }
            }

            @Nested
            class Quando_excluir {

                @BeforeEach
                void setup() {
                    tributoService.excluir(tributo.getId());
                }

                @Test
                void Entao_nao_deve_mais_existir_no_banco() {
                    assertThatThrownBy(() ->
                            tributoService.buscarPorIdOrElseThrow(tributo.getId())
                    ).isInstanceOf(RegistroNaoEncontradoException.class);
                }
            }
        }
    }
}
```

**Características:**
- Services são **reais** (injetados pelo Spring, não mockados)
- Testa fluxo completo: Service → Repository → Banco
- `@Nested` internos podem estender `AbstractServiceTest` quando necessário
- `MockFactory` cria entidades com `id = null` para inserção real no banco

## Template de Teste de Component

**Todo teste de Component DEVE herdar de `AbstractServiceTest`** — sem exceção. O Mapper é injetado via `@Autowired` (bean real do Spring, **nunca `new`**), e o Service é mockado via `@Mock`. O Component é construído manualmente no `@BeforeEach` combinando o Mapper real com os mocks.

```java
class ErroFrontendComponentTest extends AbstractServiceTest {

    @Mock
    private ErroFrontendService erroFrontendServiceMock;

    @Autowired
    private ErroFrontendMapper erroFrontendMapper;

    private ErroFrontendComponent erroFrontendComponent;

    @BeforeEach
    void setup() {
        erroFrontendComponent = new ErroFrontendComponent(erroFrontendServiceMock, erroFrontendMapper);
    }

    @Nested
    class Dado_registros_existentes {

        private final ErroFrontend erroFrontend = ErroFrontend.builder()
                .id(1L).nome("Erro").build();

        @Nested
        class Quando_buscar_por_id_existente {

            private ErroFrontendDto resultado;

            @BeforeEach
            void setup() {
                when(erroFrontendServiceMock.buscarPorId(1L)).thenReturn(Optional.of(erroFrontend));
                resultado = erroFrontendComponent.buscarPorId(1L);
            }

            @Test
            void Entao_deve_retornar_o_erro() {
                assertNotNull(resultado);
                assertEquals(1L, resultado.getId());
            }
        }
    }
}
```

**Regras:**
- **Herda `AbstractServiceTest`** — contexto Spring completo (não `@ExtendWith(MockitoExtension.class)` isolado)
- **`@Autowired` para Mapper** — nunca `new XxxMapper()`, nunca `@Mock XxxMapper`
- **`@Mock` para Service** — dependências que se quer mockar
- **Construção manual no `@BeforeEach`** — `new XxxComponent(serviceMock, mapper)` combinando mocks com beans reais
- O Mapper real garante cobertura indireta do mapeamento (sem necessidade de `*MapperTest`)

## Template de Teste de Controller

```java
class TributoControllerTest extends AbstractControllerTest {

    @Autowired
    private TributoMapper tributoMapper;

    @Nested
    class Dado_um_tributo {

        private ResultActions resultActions;
        private Tributo tributo;

        @BeforeEach
        void setup() {
            tributo = mockFactory.fabricarTributo(1L, "111");
            when(tributoServiceMock.buscarPorIdOrElseThrow(any())).thenReturn(tributo);
        }

        @Nested
        class Quando_buscar_por_id {

            @BeforeEach
            void setup() throws Exception {
                resultActions = mockMvc.perform(get("/tributos/" + tributo.getId())
                        .contentType(MediaType.APPLICATION_JSON)
                        .accept(MediaType.APPLICATION_JSON));
            }

            @Test
            void Entao_deve_retornar_status_ok() throws Exception {
                resultActions.andExpect(status().isOk())
                        .andExpect(jsonPath("$.id").value(tributo.getId()))
                        .andExpect(jsonPath("$.nome").value("IPTU"));
            }
        }

        @WithMockAuthenticationToken(authorities = "ROLE_USUARIO_EXTERNO")
        @Nested
        class Quando_usuario_externo {

            @Nested
            class Quando_buscar_por_id {

                @BeforeEach
                void setup() throws Exception {
                    resultActions = mockMvc.perform(get("/tributos/" + tributo.getId())
                            .contentType(MediaType.APPLICATION_JSON));
                }

                @Test
                void Entao_deve_retornar_acesso_negado() throws Exception {
                    resultActions.andExpect(status().isForbidden());
                }
            }
        }

        @Nested
        class Quando_salvar {

            @BeforeEach
            void setup() throws Exception {
                when(tributoServiceMock.salvar(any())).thenReturn(tributo);
                resultActions = mockMvc.perform(
                        post("/tributos")
                                .with(csrf())
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(tributoMapper.toTributoDto(tributo))));
            }

            @Test
            void Entao_deve_retornar_o_registro_criado() throws Exception {
                resultActions.andExpect(status().isOk())
                        .andExpect(jsonPath("$.id").value(tributo.getId()))
                        .andExpect(jsonPath("$.nome").value(tributo.getNome()));
            }
        }

        @Nested
        class Quando_excluir {

            @BeforeEach
            void setup() throws Exception {
                doNothing().when(tributoServiceMock).excluir(tributo.getId());
                resultActions = mockMvc.perform(
                        delete("/tributos/{id}", tributo.getId())
                                .with(csrf())
                                .contentType(MediaType.APPLICATION_JSON));
            }

            @Test
            void Entao_deve_excluir_o_registro() throws Exception {
                resultActions.andExpect(status().isOk());
            }
        }
    }
}
```

**Características:**
- Herda de `AbstractControllerTest` — mocks já disponíveis via `protected`
- `when(...).thenReturn(...)` para configurar mocks (não `given()`)
- `csrf()` obrigatório em POST, PUT, DELETE
- `@WithMockAuthenticationToken(authorities = "...")` pode ser sobrescrito em `@Nested` para testar acesso negado
- `ResultActions` declarado no `@Nested` e populado no `@BeforeEach`
- **Evitar `verify`** — preferir asserções sobre o resultado observável (status HTTP, corpo da resposta via `jsonPath`, dados persistidos). Usar `verify` apenas quando não houver resultado observável (ex: envio de evento assíncrono)

## Nomenclatura de Testes

| Elemento | Padrão | Exemplo |
|----------|--------|---------|
| Classe @Nested inicial | `Dado_{condicao}` | `Dado_um_tributo`, `Dado_um_debito` |
| Classe @Nested ação | `Quando_{acao}` | `Quando_salvar`, `Quando_buscar_por_id` |
| Método @Test | `Entao_{resultado}` | `Entao_deve_retornar_status_ok`, `Entao_nao_deve_mais_existir_no_banco` |

### Regras de Nomenclatura do `Entao_`

O nome do `Entao_` deve descrever **apenas o resultado esperado**, de forma concisa. Não deve repetir contexto que já está no `Dado_` ou `Quando_` — a hierarquia de classes `@Nested` já fornece esse contexto.

❌ **Errado** — repete contexto e é longo:
```java
@Nested
class Quando_modificar_ManyToMany_adicionando_e_removendo {
    @Test
    void Entao_ManyToMany_modificado_deve_ter_valorAntigo_e_valorNovo() { ... }
    //   ^^^^^^^^^^^^^^^^^^^^^^^^^ repete o contexto do Quando_
}
```

✅ **Correto** — conciso, foca no resultado:
```java
@Nested
class Quando_modificar_ManyToMany_adicionando_e_removendo {
    @Test
    void Entao_deve_conter_categorias_anteriores_no_valorAntigo() { ... }
    @Test
    void Entao_deve_conter_categorias_atualizadas_no_valorNovo() { ... }
    @Test
    void Entao_deve_ter_operacao_de_alteracao() { ... }
}
```

> **Regra prática:** se o nome do `Entao_` tem mais de **~8 palavras** após o prefixo, provavelmente está repetindo contexto ou descrevendo múltiplas asserções. Quebrar em vários `Entao_` focados.

### Tamanho Máximo de Métodos `@Test`

Métodos `Entao_` (`@Test`) devem ter **no máximo ~15 linhas** e verificar **um único aspecto** do resultado. Se um `@Test` precisa de filtragem, extração, múltiplos asserts sobre aspectos diferentes, ele deve ser decomposto em vários `Entao_`.

❌ **Errado** — método gigante (~35 linhas) que faz tudo:
```java
@Test
void Entao_ManyToMany_modificado_deve_ter_valorAntigo_e_valorNovo() {
    verify(kafkaTemplate, atLeast(0)).send(captor1.capture(), captor2.capture());
    eventosCapturados = captor2.getAllValues();
    List<EventoAuditoriaDto> eventosCategorias = eventosCapturados.stream()
            .filter(e -> e.getEntidade().equals("tabela_intermediaria")).toList();
    assertThat(eventosCategorias).hasSize(1);
    EventoAuditoriaDto evento = eventosCategorias.getFirst();
    assertThat(evento.getOperacao()).isEqualTo(Operacao.A);
    // ... mais 20 linhas de extração e asserts
}
```

✅ **Correto** — captura no `@BeforeEach` do `Quando_`, `Entao_` focados:
```java
@Nested
class Quando_modificar_ManyToMany {
    private EventoAuditoriaDto evento;

    @BeforeEach
    void setup() {
        // captura e filtragem ficam aqui
        verify(kafkaTemplate, atLeastOnce()).send(captor1.capture(), captor2.capture());
        evento = captor2.getAllValues().stream()
                .filter(e -> e.getEntidade().equals("tabela_intermediaria"))
                .findFirst().orElseThrow();
    }

    @Test
    void Entao_deve_ter_operacao_de_alteracao() {
        assertThat(evento.getOperacao()).isEqualTo(Operacao.A);
    }

    @Test
    void Entao_valorAntigo_deve_conter_categorias_originais() {
        var atributo = evento.getAtributos().getFirst();
        assertThat(atributo.getValorAntigo()).contains(idCategoria1, idCategoria2);
    }

    @Test
    void Entao_valorNovo_deve_refletir_adicao_e_remocao() {
        var atributo = evento.getAtributos().getFirst();
        assertThat(atributo.getValorNovo()).contains(idCategoria1, idCategoria3)
                .doesNotContain(idCategoria2);
    }
}
```

> **Regra:** a captura/filtragem de dados para asserção (ex: `verify` + `ArgumentCaptor`, filtragem de listas) deve estar no `@BeforeEach` do `Quando_`, não no `@Test`. O `@Test` (`Entao_`) deve conter **apenas asserções**.

> **Regra obrigatória:** `Quando_` é **obrigatoriamente** uma classe `@Nested` — **NUNCA** um método `@Test`. Apenas `Entao_` pode ser `@Test`. Toda classe `Dado_` e `Quando_` **deve** ter um `@BeforeEach` que garanta o que o nome da classe está afirmando. O `@BeforeEach` é a implementação concreta da condição ou ação descrita no nome da classe.

> **Regra obrigatória:** `Entao_` **NUNCA** pode ser `@Test` diretamente dentro de `Dado_` — deve **sempre** haver um `Quando_` intermediário. A hierarquia correta é `Dado_` → `Quando_` → `Entao_`. Se um `@Test` `Entao_` está diretamente dentro de `Dado_` (sem `Quando_`), a ação está no `@BeforeEach` do `Dado_` ou no próprio `@Test`, o que viola a separação BDD.
>
> ❌ **Errado** — `Entao_` direto no `Dado_`:
> ```java
> @Nested
> class Dado_uma_entidade_salva {
>     @BeforeEach
>     void setup() { entidade = service.salvar(entidade); } // ação no Dado_!
>
>     @Test
>     void Entao_deve_ter_id() { assertNotNull(entidade.getId()); } // sem Quando_!
> }
> ```
>
> ✅ **Correto** — com `Quando_` intermediário:
> ```java
> @Nested
> class Dado_uma_entidade {
>     @BeforeEach
>     void setup() { entidade = mockFactory.fabricarEntidade(null, "teste"); }
>
>     @Nested
>     class Quando_salvar {
>         @BeforeEach
>         void setup() { entidade = service.salvar(entidade); }
>
>         @Test
>         void Entao_deve_ter_id() { assertNotNull(entidade.getId()); }
>     }
> }
> ```

### Tamanho Máximo de Classes @Nested

Classes `@Nested` (`Dado_`) não devem ultrapassar **~150 linhas**. Quando um `Dado_` fica gigante (muitos `Quando_` e `Entao_`), isso indica que está testando cenários demais em um único contexto. Decompor em múltiplas classes `Dado_` menores e focadas.

❌ **Errado** — `Dado_` gigante com tudo dentro:
```java
@Nested
class Dado_fluxo_completo_de_ATUALIZACAO { // 300+ linhas
    @BeforeEach
    void setup() { /* salva, atualiza, configura tudo */ }

    @Nested class Quando_modificar_campo_simples { ... }
    @Nested class Quando_modificar_ManyToMany { ... }
    @Nested class Quando_modificar_ElementCollection { ... }
    @Nested class Quando_excluir_entidade { ... }  // excluir não é atualização!
}
```

✅ **Correto** — cenários separados:
```java
@Nested
class Dado_uma_entidade_existente {
    @BeforeEach
    void setup() { entidade = service.salvar(mockFactory.fabricar(...)); }

    @Nested class Quando_atualizar_campo_simples { ... }   // ~30 linhas
    @Nested class Quando_adicionar_ManyToMany { ... }       // ~30 linhas
}

@Nested
class Dado_uma_entidade_com_colecoes {
    @BeforeEach
    void setup() { /* contexto específico para coleções */ }

    @Nested class Quando_remover_ElementCollection { ... }  // ~30 linhas
}

@Nested
class Dado_fluxo_de_EXCLUSAO {
    @BeforeEach
    void setup() { /* contexto específico para exclusão */ }

    @Nested class Quando_excluir_entidade { ... }           // ~30 linhas
}
```

> **Regra prática:** cada `Dado_` deve representar **um único contexto** coeso. Se o `Dado_` precisa de mais de ~150 linhas, provavelmente está misturando contextos diferentes (criação + atualização + exclusão) que deveriam ser `Dado_` separados.

## Anotações Obrigatórias

Centralizadas nas **classes base abstratas** (nunca repetir nas subclasses):

```java
@DisplayNameGeneration(DisplayNameGenerator.ReplaceUnderscores.class)  // nas classes base
@WithMockAuthenticationToken                                          // nas classes base (ai.attus:lib-test)
@ActiveProfiles("test")                                               // nas classes base
```

> **Nota:** `@WithMockAuthenticationToken` pode ser sobrescrita em subclasses `@Nested` ou métodos `@Test` para testar cenários com authorities diferentes (ex: `@WithMockAuthenticationToken(authorities = "ROLE_USUARIO_EXTERNO")`).

---

## Cobertura de Testes

### Metas Attus

- **Backend:** > 80% cobertura
- **Camadas obrigatórias:**
  - Service (100% regras de negócio)
  - Controller (validação e HTTP status)

### O Que Testar

| Camada | Obrigatório | Prioridade |
|--------|-------------|------------|
| Service/Component | Sim | Alta - regras de negócio |
| Controller | Sim | Alta - contrato da API |

### O Que NÃO Testar Diretamente

- **Mapper** — **NUNCA** criar classe de teste dedicada para Mapper (ex: `XxxMapperTest`). A cobertura do Mapper deve ser obtida **indiretamente** pelos testes de Controller (que exercitam o fluxo Controller → [Component] → Mapper) e pelos testes de Service/Component (que usam Mapper real via `@Autowired`). Se encontrar uma classe `*MapperTest`, ela deve ser **removida**.
- **DTO** — **NUNCA** criar classe de teste dedicada para DTO. A cobertura do DTO deve ser obtida indiretamente pelos testes de Controller (serialização/deserialização via MockMvc)
- Frameworks (Spring)
- Lombok, getters/setters
- Configurações
- Métodos privados (testar via públicos)

---

## Checklist de Revisão de Testes

Ao revisar ou analisar aderência de testes, verificar **cada item abaixo para cada classe de teste**:

- [ ] Classe de teste de Service/Component estende `AbstractServiceTest`
- [ ] **Nenhuma classe de teste dedicada para Mapper ou DTO** — se encontrar `*MapperTest` ou `*DtoTest`, remover (cobertura via testes de Controller e Service)
- [ ] Classe de teste de Controller estende `AbstractControllerTest`
- [ ] Nenhum `@MockitoBean` fora de `AbstractControllerTest`
- [ ] Nenhum `@DisplayNameGeneration` fora das classes base
- [ ] Nenhum `@WithMockAuthenticationToken` fora das classes base (exceto sobrescritas intencionais em `@Nested`)
- [ ] Nenhum `@DisplayName` redundante (já coberto por `@DisplayNameGeneration` + underscores)
- [ ] **`Quando_` é sempre `@Nested` class, NUNCA `@Test`** — apenas `Entao_` pode ser `@Test`
- [ ] **`Entao_` NUNCA está diretamente dentro de `Dado_`** — deve haver `Quando_` intermediário. Hierarquia: `Dado_` → `Quando_` → `Entao_`
- [ ] **Nenhuma classe `@Nested` (`Dado_`) ultrapassa ~150 linhas** — se ultrapassar, decompor em múltiplos `Dado_` menores e focados
- [ ] **`Dado_` não mistura contextos diferentes** (ex: criação + exclusão no mesmo `Dado_`) — cada `Dado_` deve representar um único contexto coeso
- [ ] **Toda classe `@Nested` com prefixo `Dado_` ou `Quando_` possui `@BeforeEach`** que implementa concretamente a condição/ação descrita no nome. **Procedimento de verificação:** percorrer CADA classe `@Nested` do arquivo e confirmar que ela contém um método `@BeforeEach`. Se não contém, é uma violação — mesmo que a classe tenha subclasses `@Nested` que possuem `@BeforeEach`. Exemplos de violação:
  - `Dado_` sem `@BeforeEach` → falta setup de contexto (mocks, dados de entrada)
  - `Quando_` sem `@BeforeEach` → falta execução da ação (chamada HTTP, invocação de método). Significa que a ação está no `@Test`, violando a separação BDD
  - `Quando_` com `@BeforeEach` que mistura setup de mocks + ação → setup de mocks deveria estar no `@BeforeEach` do `Dado_` pai
- [ ] Nomenclatura BDD em PT-BR: `Dado_`, `Quando_`, `Entao_` (nunca `GIVEN_`, `WHEN_`, `THEN_`)
- [ ] WireMock usado para Feign Clients em **ambas** as classes base (`AbstractServiceTest` e `AbstractControllerTest`)
- [ ] Nenhum `@MockitoBean` em interfaces `@FeignClient` — sempre WireMock
- [ ] Nenhum mock manual de Feign Client (`@Service @Primary implements FeignInterface`)
- [ ] **`verify` não foi usado desnecessariamente** — preferir asserções sobre resultados observáveis (status HTTP, corpo da resposta, dados persistidos). Usar `verify` apenas quando não houver resultado observável para validar
- [ ] **Nenhum mock de Mapper** — Mappers devem ser sempre reais (`@Autowired`), nunca mockados via `@Mock` ou `@MockitoBean`
- [ ] **Nenhum `Entao_` com mais de ~15 linhas** — se ultrapassar, decompor em múltiplos `Entao_` focados e mover captura/filtragem para o `@BeforeEach` do `Quando_`
- [ ] **Nenhum `Entao_` repete contexto do `Dado_`/`Quando_`** no nome — deve descrever apenas o resultado esperado, de forma concisa (~8 palavras máximo após o prefixo)
