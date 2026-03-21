---
description: Revisar um Merge Request (MR) seguindo os critérios de qualidade Attus
---

# Revisar MR

Workflow para revisão de Merge Request no GitLab seguindo a Constituição Attus.

## Passos

1. **Invocar a skill `arquiteto-java`** — Carregar TODAS as referências em `docs/arquitetura/java/` antes de revisar

2. **Verificar arquitetura de camadas** — Para cada arquivo Java alterado:
   - Controller só delega (para Component ou Service)
   - Service contém regras de negócio puras
   - Repository estende `BaseRepository`
   - Mapper é `@Component`, sem `of()`/`toEntity()` no DTO
   - Component só existe se há orquestração complexa

3. **Verificar nomenclatura PT-BR** — Método por método:
   - Verbos no infinitivo (`salvar`, `buscarPorId`, nunca `remove`)
   - Constantes em UPPER_SNAKE_CASE com nomes específicos
   - Exceções permitidas: `get`, `set`, `is`, `has`, `to`, `equals`, `findBy`

4. **Verificar testes** — Para cada classe de teste:
   - Estrutura BDD: `Dado_` → `Quando_` → `Entao_` com `@Nested`
   - `Quando_` é `@Nested` com `@BeforeEach`, NUNCA `@Test`
   - `Entao_` tem APENAS asserções
   - Controller herda `AbstractControllerTest`
   - Usa `@WithMockAuthenticationToken`, nunca `@WithMockUser`
   - Feign Clients simulados via WireMock, não `@MockitoBean`

5. **Verificar proibições críticas**:
   - [ ] Sem `@RequiredArgsConstructor` (construtores explícitos)
   - [ ] Sem `@SuppressWarnings`
   - [ ] Sem `@WithMockUser`
   - [ ] Sem try-catch genérico em Kafka Consumers
   - [ ] Sem try-catch silencioso (log + engolir exceção)
   - [ ] Sem import de BOMs direto (tudo via `attus-platform-bom`)
   - [ ] Sem `spring.main.allow-bean-definition-overriding=true`
   - [ ] Sem blocos `static { System.setProperty(...) }` em testes
   - [ ] Sem múltiplos `@FeignClient` com mesmo `name` sem `contextId`

6. **Verificar Clean Code (Sonar)**:
   - [ ] Imports não usados
   - [ ] Campos privados não usados
   - [ ] `throws` de exceções que não são lançadas
   - [ ] Diamond operator `<>` usado
   - [ ] `@Override` presente em todos os overrides
   - [ ] Sem TODO pendentes
   - [ ] Construtores privados em classes utilitárias

7. **Verificar commits** — Conventional Commits em português

8. **Resultado** — Aprovar ou solicitar alterações com feedback específico citando a regra violada
