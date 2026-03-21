---
name: escritor-testes-unitarios
description: Escrever testes unitários para Java (JUnit 5 + Mockito) e Angular (Jest) seguindo padrões BDD, nomenclatura em PT-BR e estrutura hierárquica. Use quando o usuário pedir para criar, refatorar ou revisar testes unitários, ou quando for necessário implementar cobertura de testes para componentes, services, controllers ou facades seguindo as diretrizes da Constituição do projeto.
---

# Guia de Escrita de Testes Unitários

Este guia fornece instruções para escrita de testes unitários consistentes e de alta qualidade para Java (backend) e Angular (frontend).

## Decisão Rápida: Qual Framework?

- **Backend Java**: JUnit 5 + Mockito → [Ver seção Java](#backend-java)
- **Frontend Angular**: Jest → [Ver seção Angular](#frontend-angular)

---

## Backend Java

### Stack

- **JUnit 5**: Framework principal de testes
- **Mockito**: Framework de mocking para isolamento
- **Spring Boot Test**: Para testes de integração com contexto Spring

### Estrutura BDD (Behavior Driven Development)

Organize testes em classes aninhadas (`@Nested`) seguindo o padrão **Dado / Quando / Então**:

1. **Dado_...**: Contexto inicial (setup do cenário)
2. **Quando_...**: Ação sendo testada
3. **Entao_...**: Método `@Test` com as asserções

```java
@DisplayNameGeneration(DisplayNameGenerator.ReplaceUnderscores.class)
class ExemploComponentTest extends DemandaServerTest {

    @Nested
    class Dado_uma_condicao_inicial extends DemandaServerTest {
        
        @BeforeEach
        void setup() {
            // Configuração do cenário
        }

        @Nested
        class Quando_realizar_uma_acao extends DemandaServerTest {

            @Test
            void Entao_deve_produzir_o_resultado_esperado() {
                // Asserções
            }
        }
    }
}
```

### Padrões de Nomenclatura

- **Classes de Teste**: `NomeDaClasseTest` (ex: `ProtocoloComponentTest`)
- **Classes Nested (Contexto)**: `Dado_...`, `Quando_...`
- **Métodos de Teste**: `Entao_deve_...`, `Entao_lanca_excecao...`
- **Idioma**: Português (PT-BR)

Use `DisplayNameGenerator.ReplaceUnderscores.class` para converter underscores em espaços nos relatórios.

### Configuração Base

A maioria dos testes de integração deve estender `DemandaServerTest`:

```java
@DisplayNameGeneration(DisplayNameGenerator.ReplaceUnderscores.class)
class MeuTeste extends DemandaServerTest {
    // Fornece: contexto Spring, profile 'test', segurança mockada
}
```

### Criação de Dados de Teste

Use `MockFactory` para objetos de domínio pré-preenchidos:

```java
@Autowired
private MockFactory mockFactory;

Demanda demanda = mockFactory.construirDemanda("sequencial");
```

### Mocking

```java
@Mock
private ClientFacade clientFacadeMock;

@BeforeEach
void setup() {
    when(clientFacadeMock.buscarAlgo(any())).thenReturn(valorEsperado);
}
```

### Evitar `verify` do Mockito

Evite ao máximo o uso de `verify`. Ele amarra o teste à implementação interna, tornando-o frágil a refatorações. Prefira **asserções sobre o resultado observável** (retorno do método, estado do objeto, resposta HTTP, dados persistidos, etc.).

- **Ruim** (acoplado à implementação):
```java
@Test
void Entao_deve_delegar_para_service() {
    controller.salvar(dto);
    verify(serviceMock).salvar(any()); // quebra se a implementação mudar
}
```

- **Bom** (valida o comportamento observável):
```java
@Test
void Entao_deve_retornar_entidade_salva() {
    var resultado = controller.salvar(dto);
    assertNotNull(resultado.getId());
    assertEquals(dto.getNome(), resultado.getNome());
}
```

Use `verify` apenas quando não houver resultado observável para validar (ex: envio de evento assíncrono, log de auditoria).

### Asserções (JUnit 5)

- `assertEquals(esperado, atual)`
- `assertTrue(condicao)` / `assertFalse(condicao)`
- `assertNotNull(objeto)`
- `assertThrows(ClasseExcecao.class, () -> codigo())`

### Segurança nos Testes

Use `@WithMockAuthenticationToken` (de `ai.attus:lib-test`) para simular usuário autenticado. **NÃO usar `@WithMockUser`**:

```java
@Test
@WithMockAuthenticationToken(authorities = {"ROLE_ADMIN"})
void Entao_deve_permitir_acesso() {
    // ...
}
```

### Exemplo Completo

```java
@DisplayNameGeneration(DisplayNameGenerator.ReplaceUnderscores.class)
class CalculadoraServiceTest extends DemandaServerTest {

    @Autowired
    private CalculadoraService service;

    @Nested
    class Dado_dois_numeros_positivos extends DemandaServerTest {
        
        @Test
        void Entao_a_soma_deve_ser_correta() {
            int resultado = service.somar(2, 3);
            assertEquals(5, resultado);
        }
    }
}
```

---

## Frontend Angular

### Stack

- **Jest**: Framework principal de testes
- **Angular Testing Utilities**: `TestBed`, `ComponentFixture`

### Estrutura BDD

Use `describe` e `it` com frases em português (PT-BR):

- **describe**: `Ao...` ou contexto do cenário
- **it**: `Deve...` ou resultado esperado

```typescript
describe('Ao calcular parcelas', () => {
  it('Deve retornar as parcelas corretas', () => {
    // ...
  });
});
```

### Padrões de Nomenclatura

- **Arquivos de Teste**: `*.spec.ts`
- **Idioma**: Português (PT-BR)
- **Estrutura**: `Ao/Quando...` no describe, `Deve...` no it

### Exemplo Completo

```typescript
describe('MeuComponent', () => {
  let component: MeuComponent;
  let fixture: ComponentFixture<MeuComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [MeuComponent]
    }).compileComponents();

    fixture = TestBed.createComponent(MeuComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  describe('Ao receber dados válidos', () => {
    it('Deve exibir o resultado', () => {
      // Arrange
      const dados = { valor: 100 };
      
      // Act
      component.processar(dados);
      
      // Assert
      expect(component.resultado).toBe(100);
    });
  });
});
```

---

## Checklist de Qualidade

Antes de concluir testes, verifique:

- [ ] **Nomenclatura** segue padrões (PT-BR, BDD)
- [ ] **Estrutura** está hierárquica e organizada
- [ ] **Cobertura** cobre casos principais e exceções
- [ ] **Mocks** isolam corretamente as dependências
- [ ] **Asserções** são específicas e verificam o resultado esperado
- [ ] **Verify** não foi usado desnecessariamente (preferir asserções sobre resultados observáveis)
- [ ] **Setup** usa `MockFactory` (Java) ou `TestBed` (Angular) apropriadamente
