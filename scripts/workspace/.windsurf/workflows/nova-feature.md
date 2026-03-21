---
description: Implementar uma nova feature end-to-end seguindo os padrões Attus (Java ou Angular)
---

# Nova Feature

Workflow completo para implementar uma feature no padrão Attus.

## Pré-requisitos

- Ter o projeto clonado em `projetos/`
- Branch criada a partir de `main` ou `develop`
- Identificar a stack: **Java** (backend) ou **Angular** (frontend)

## Fluxo de Decisão: Stack

| Stack | Skill a invocar | Docs de referência |
|-------|-----------------|-------------------|
| Java/Spring Boot | `arquiteto-java` | `docs/arquitetura/java/` |
| Angular/TypeScript | `arquiteto-angular` | `docs/arquitetura/angular/` |

---

## Stack Java — Passos

1. **Entender o requisito** — Ler a descrição da demanda e identificar:
   - Qual microsserviço será alterado
   - Quais entidades/DTOs são necessários
   - Quais endpoints serão criados ou alterados
   - Se há comunicação com outros serviços (Feign/Kafka)

2. **Invocar a skill `arquiteto-java`** — Carregar TODAS as referências em `docs/arquitetura/java/` antes de produzir qualquer código

3. **Criar testes BDD** — Para cada camada:
   - Estrutura `Dado_` → `Quando_` → `Entao_` com `@Nested`
   - Controller: herdar `AbstractControllerTest`
   - Service: herdar `AbstractServiceTest`
   - Cobertura > 80%

4. **Criar/alterar a Entity e Migration** — Se necessário:
   - Criar a entidade JPA com anotações adequadas
   - Criar migration Flyway em `src/main/resources/db/migration/`
   - Nomenclatura: `V{timestamp}__descricao_em_snake_case.sql`

5. **Criar o Mapper** — `@Component` que converte Entity ↔ DTO
   - Nunca usar `of()` ou `toEntity()` no DTO

6. **Criar o Repository** — Estender `BaseRepository`
   - Usar `@Query` para consultas complexas
   - Projections para leituras parciais

7. **Criar o Service** — Interface + Impl
   - Estender `BaseService` / `AbstractService` quando aplicável
   - Regras de negócio puras, opera sobre entidades
   - Nomenclatura PT-BR, verbos no infinitivo

8. **Criar o Component** *(se necessário)* — Orquestração complexa
   - Omitir em CRUDs simples (Controller → Service direto)

9. **Criar o Controller** — Endpoints REST
   - `@Valid` nos DTOs de entrada
   - Delegar para Component ou Service

10. **Verificação Sonar** — Revisar cada arquivo contra checklist de Clean Code
    - Imports não usados, campos não usados, throws desnecessários
    - Diamond operator, `@Override`, sem `@SuppressWarnings`

11. **Verificação de Nomenclatura PT-BR** — Método por método, verificar se estão em português
    - Exceções: `get`, `set`, `is`, `has`, `to`, `equals`, `findBy`, `deleteBy`

12. **Commit** — `feat(<escopo>): <descrição em português>`

---

## Stack Angular — Passos

1. **Entender o requisito** — Ler a descrição da demanda e identificar:
   - Qual domínio/módulo será alterado
   - Quais componentes, services ou models são necessários
   - Se há integração com API (qual endpoint)
   - Se há comunicação entre componentes

2. **Invocar a skill `arquiteto-angular`** — Carregar TODAS as referências em `docs/arquitetura/angular/` antes de produzir qualquer código

3. **Criar/alterar o Model** — Interfaces/types em `libs/{dominio}/{lib}/src/`
   - PascalCase, sem prefixo `I`
   - Nomenclatura PT-BR para propriedades de negócio

4. **Criar o Controller** — API client (`@Injectable`)
   - Encapsula chamadas HTTP para o backend
   - Métodos retornam `Observable<T>` ou `Signal<T>`
   - Nomenclatura PT-BR: `buscarUsuarios`, `salvarDemanda`

5. **Criar o Service** — Lógica de negócio e gerenciamento de estado
   - Pode usar signals para estado reativo
   - Não faz chamadas HTTP diretas — usa o Controller

6. **Criar o Component** — Standalone component (Angular 17+)
   - `@Component({ standalone: true, ... })`
   - Usar signals para estado local
   - Usar `async pipe` no template, evitar `.subscribe()`
   - Inputs com `Input()`, Outputs com `Output()`

7. **Criar a Page** — Componente de rota (se aplicável)
   - Lazy loading via `loadChildren`
   - Estrutura: `pages/{feature}/`

8. **Criar testes BDD** — Para cada componente/service:
   - Estrutura `Dada_` → `Quando_` → `Deve_` com `describe` → `it`
   - Usar Jest + Vitest
   - Mocks via `Builder<T>()` (pattern do frontng)
   - Simular inputs com `Object.assign(component, { ... })`

9. **Verificação de Qualidade**:
   - Sem `any` — sempre tipar adequadamente
   - Sem `console.log` — usar logger service
   - URLs de API via environment files
   - Imports organizados em blocos

10. **Verificação de Nomenclatura PT-BR**:
    - Arquivos: kebab-case (`usuario-lista.component.ts`)
    - Classes: PascalCase (`UsuarioListaComponent`)
    - Métodos: verbos no infinitivo em português

11. **Executar testes afetados**:
    ```bash
    yarn test:nx:affected
    ```

12. **Commit** — `feat(<escopo>): <descrição em português>`
