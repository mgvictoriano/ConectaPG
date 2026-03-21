---
description: Criar testes unitários seguindo a estrutura BDD obrigatória da Attus
---

# Criar Testes

Workflow para criação de testes unitários no padrão Attus.

## Passos

1. **Invocar a skill `escritor-testes-unitarios`** — Carregar todas as referências de teste

2. **Identificar a classe a ser testada** — Determinar:
   - Tipo: Controller, Component, Service, Mapper
   - Dependências que precisam de mock
   - Cenários de negócio a cobrir

3. **Definir a classe base**:
   - **Controller** → herdar `AbstractControllerTest`
   - **Service/Component** → herdar `AbstractServiceTest` ou usar `@ExtendWith(MockitoExtension.class)`
   - **Nunca** usar `@WithMockUser` → usar `@WithMockAuthenticationToken`
   - **Feign Clients** → simular via WireMock, nunca `@MockitoBean`

4. **Estruturar em BDD obrigatório** — Para cada cenário:

   ```java
   @Nested
   class Dado_contexto_do_cenario {

       @BeforeEach
       void setup() {
           // Configurar mocks e dados de entrada — APENAS contexto
       }

       @Nested
       class Quando_acao_executada {

           @BeforeEach
           void executar() {
               // Executar a ação sendo testada — APENAS execução
               resultado = service.buscarPorId(id);
           }

           @Test
           void Entao_deve_retornar_resultado_esperado() {
               // APENAS asserções
               assertThat(resultado).isNotNull();
           }

           @Test
           void Entao_deve_chamar_dependencia() {
               // APENAS verificações de interação
               verify(repository).findById(id);
           }
       }
   }
   ```

5. **Regras de nomenclatura**:
   - `Dado_` → descreve o contexto/cenário em PT-BR
   - `Quando_` → descreve a ação em PT-BR
   - `Entao_` → descreve o resultado esperado em PT-BR
   - Usar underscores para separar palavras (`Dado_usuario_existente`)

6. **Verificar cobertura** — Objetivo: > 80%
   - Cenários de sucesso (happy path)
   - Cenários de erro (exceções, validações)
   - Cenários de borda (lista vazia, null, valores limites)

7. **Verificar integridade**:
   - Setup de dados NUNCA no `Quando_`
   - Execução da ação NUNCA no `Entao_`
   - `Quando_` é SEMPRE `@Nested` com `@BeforeEach`, nunca `@Test`
   - Nunca alterar visibilidade de métodos para facilitar teste
   - Nunca alterar um teste para forçá-lo a passar

8. **Commit** — `test(<escopo>): adicionar testes para <classe>`
