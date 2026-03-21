# AGENTS.md

Instruções para agentes de IA (Codex, Copilot, Cursor, Windsurf, etc.) que operam neste workspace.

## Visão Geral do Repositório

Este é o **monorepo de desenvolvimento da Attus** — um workspace que agrega ferramentas, skills, documentação e os próprios projetos para facilitar o desenvolvimento com IDEs de IA. Os repositórios dos microsserviços ficam em `projetos/` (gitignored, cada um com seu próprio repositório Git no GitLab) e são clonados via `scripts/git/clone-all.sh`. A IDE de IA enxerga todo o contexto (skills, docs e código) em um único workspace.

### Estrutura

```
workspace/
├── .windsurf/
│   ├── skills/             # Skills de IA (arquiteto-java, arquiteto-angular, arquiteto-python, ...)
│   ├── rules/              # Regras always-on (java-attus, angular-attus, python-attus, commits)
│   └── workflows/          # Workflows (/nova-feature, /criar-testes, /revisar-mr, ...)
├── scripts/git/            # Scripts de gestão de repositórios
├── catalogo/services.yaml   # Catálogo de microsserviços
├── docs/
│   ├── arquitetura/        # Documentação detalhada por stack (fonte de verdade)
│   │   ├── java/           # Padrões, nomenclatura, testes, eventos, segurança
│   │   ├── angular/        # Nomenclatura, testes
│   │   └── python/         # Stack, estrutura, testes
│   └── onboarding/         # Setup local e fluxo de desenvolvimento
└── projetos/               # Repos clonados (gitignored)
```

## Idioma

- **Português (PT-BR)** para toda documentação, skills, nomes de negócio, métodos, variáveis e classes.
- Exceções: prefixos Java convencionais (`get`, `set`, `is`, `has`, `to`, `equals`), query derivation do Spring Data (`findBy`, `deleteBy`), e termos técnicos sem tradução consagrada.

## Stack Tecnológico

| Camada | Tecnologia |
|--------|------------|
| **Backend** | Java 25 + Spring Boot 4 (legados: Java 17 + Spring Boot 2.4) |
| **Frontend** | Angular (projeto `frontng`) |
| **Build** | Gradle (Java 25) / Maven (Java 17 legados) |
| **Libs internas** | `ai.attus:lib-core`, `lib-database`, `lib-security`, `lib-cache`, `lib-starter`, `lib-test`, `lib-utils`, `lib-auditoria`, `lib-parametro` — gerenciadas via BOM `ai.attus:attus-platform-bom` |
| **Segurança** | Spring Security + OAuth2/JWT |
| **Mensageria** | Kafka (eventos) + Spring Events (intra-serviço) |
| **Cache** | Memória local (L1) + Redis (L2) |
| **Banco** | JPA/Hibernate, Flyway |
| **Comunicação** | Feign Client (inter-serviço) |
| **IA/ML** | Python (`attus-genai`, `attus-ml`) |

## Regras Obrigatórias para Código Java

Ao gerar, modificar ou revisar código Java neste workspace, o agente **DEVE**:

1. Consultar `.windsurf/skills/arquiteto-java/SKILL.md` e **todas** as referências em `docs/arquitetura/java/` antes de produzir código.
2. Seguir a hierarquia de camadas: **Controller → Component → Service → Repository → Mapper** (Component é opcional em CRUDs simples).
3. Usar **nomenclatura PT-BR** para todos os métodos (públicos, protected e privados), exceto as exceções listadas acima.
4. Verbos de métodos no **infinitivo** (`salvar`, `buscarPorId`, `listarAtivos`), nunca conjugados na 3ª pessoa (`remove` → `remover`).
5. Toda conversão Entity ↔ DTO **exclusivamente via Mapper** (`@Component`), nunca `of()` ou `toEntity()` no DTO.
6. Testes obrigatórios: **JUnit 5 + Mockito**, estrutura **BDD** (`Dado_` → `Quando_` → `Entao_`), cobertura > 80%.
7. Verificação Sonar antes de finalizar — nenhum issue novo pode ser introduzido.

### Proibições Críticas

- **NÃO** quebrar hierarquia de camadas (Controller chamar Repository diretamente).
- **NÃO** usar `@RequiredArgsConstructor` — construtores explícitos.
- **NÃO** usar `@WithMockUser` — usar `@WithMockAuthenticationToken` (de `lib-test`).
- **NÃO** usar `@SuppressWarnings` — corrigir a causa raiz.
- **NÃO** alterar visibilidade de métodos para facilitar testes.
- **NÃO** alterar testes para forçá-los a passar — investigar a causa raiz.
- **NÃO** importar BOMs diretamente (`spring-boot-dependencies`, etc.) — tudo via `attus-platform-bom`.
- **NÃO** usar try-catch genérico em Kafka Consumers.
- **NÃO** criar workarounds antes de investigar a causa raiz a fundo.

## Skills Disponíveis

- **`arquiteto-java`** — Padrões de arquitetura, nomenclatura e qualidade Java (Constituição v1.4.0)
- **`arquiteto-angular`** — Padrões de frontend: Controllers como API clients, standalone components, signals, nomenclatura PT-BR
- **`arquiteto-python`** — Padrões de IA/ML: FastAPI, pytest, nomenclatura PT-BR
- **`escritor-controllers`** — Criação de controllers Java Spring e Angular
- **`escritor-testes-unitarios`** — Testes unitários JUnit 5/Jest seguindo BDD
- **`migracao-java17-java25`** — Guia de migração Java 17 → Java 25, Spring Boot 2.4 → 4
- **`criador-skills`** — Guia para criação de novas skills

## Rules (sempre ativas)

- **`java-attus`** — Invocar skill `arquiteto-java` ao trabalhar com Java
- **`angular-attus`** — Invocar skill `arquiteto-angular` ao trabalhar com Angular/TypeScript
- **`python-attus`** — Invocar skill `arquiteto-python` ao trabalhar com Python
- **`commits`** — Conventional Commits em português

## Workflows

- **`/nova-feature`** — Implementar feature end-to-end (Entity → Migration → Mapper → Repository → Service → Component → Controller → Testes)
- **`/criar-testes`** — Criar testes BDD (Dado_ → Quando_ → Entao_)
- **`/revisar-mr`** — Checklist de revisão de MR contra Constituição Attus
- **`/novo-microsservico`** — Criar microsserviço do zero com estrutura padrão
- **`/atualizar-agents`** — Sincronizar AGENTS.md após alterações no workspace

## Documentação (`docs/`)

A documentação está organizada por stack em `docs/arquitetura/`. Os docs são a **fonte de verdade** — as skills referenciam estes arquivos.

### Java (`docs/arquitetura/java/`)

| Doc | Conteúdo |
|-----|----------|
| `padroes-arquitetura.md` | Camadas, Clean Code, estrutura de pacotes, SRP |
| `nomenclatura.md` | Nomes de classes, métodos, variáveis, constantes em PT-BR |
| `testes.md` | BDD com JUnit 5, classes base, MockFactory, WireMock |
| `eventos.md` | Spring Events, Kafka, DLQ, escalabilidade |
| `seguranca.md` | OAuth2/JWT via lib-security |

### Angular (`docs/arquitetura/angular/`)

| Doc | Conteúdo |
|-----|----------|
| `nomenclatura.md` | Nomes de arquivos, classes, métodos, signals |
| `testes.md` | BDD com Jest, templates de Service e Component |

### Python (`docs/arquitetura/python/`)

| Doc | Conteúdo |
|-----|----------|
| `README.md` | Stack, estrutura de projeto, nomenclatura, testes |

### Demais docs

- **`docs/arquitetura/README.md`** — Visão geral, diagrama, microsserviços, stack
- **`docs/onboarding/`** — Setup local e fluxo de desenvolvimento

## Convenções de Contribuição

- **Arquitetos**: merge direto (maintainers).
- **Devs e Tech Leads**: via Merge Request (MR) no GitLab, revisado por pelo menos 1 arquiteto.
- **Commits**: Conventional Commits (`feat:`, `fix:`, `refactor:`, `docs:`).
- **Scripts Bash**: `set -euo pipefail`, comentário de uso no topo.
- **Markdown**: formatação consistente, títulos hierárquicos.
- **Idioma**: Português (PT-BR) para documentação, skills e código de negócio.

## O que NÃO entra neste repositório

- Código-fonte dos projetos (vivem em seus próprios repos).
- Documentação técnica específica de um serviço.
- Arquivos de configuração local ou credenciais.
- Artefatos de build.
