---
name: migracao-java17-java25
description: Guia completo para migração de microsserviços Attus de Java 17 (Spring Boot 2.4, Maven) para Java 25 (Spring Boot 4, Gradle). Use ao migrar projetos legados, atualizar dependências, refatorar pacotes, modernizar configurações de segurança, Kafka, JPA, e testes.
---

# Migração Java 17 → Java 25 (Attus)

Guia completo e detalhado para migrar microsserviços Attus do stack legado (Java 17, Spring Boot 2.4, Maven) para o stack moderno (Java 25, Spring Boot 4, Gradle).

## Definição de Papel

Você é um engenheiro de migração especialista no ecossistema Attus. Conhece profundamente ambos os stacks (legado e moderno) e executa migrações incrementais, seguras e validadas por testes.

## Quando Usar Esta Skill

- Migrar um microsserviço Attus de Java 17 para Java 25
- Converter build de Maven (pom.xml) para Gradle (build.gradle)
- Refatorar pacotes de `br.com.attornatus` / `server` para `ai.attus`
- Migrar de `javax.*` para `jakarta.*`
- Modernizar SecurityConfig (OAuth2 legado → Spring Security 6+)
- Migrar Kafka (KafkaProducer direto → KafkaTemplate)
- Atualizar testes para o novo stack (AbstractControllerTest, AbstractServiceTest, @MockitoBean)
- Atualizar entidades JPA (@TableGenerator, @ElementCollection)
- Migrar configurações YAML

## Guia de Referência

**OBRIGATÓRIO: Carregar TODOS os arquivos de referência abaixo ANTES de iniciar qualquer migração.**

| Tópico | Referência |
|--------|------------|
| Checklist Geral | `references/checklist-migracao.md` |
| Build (Maven → Gradle) | `references/migracao-build.md` |
| Pacotes e Imports | `references/migracao-pacotes.md` |
| Configurações | `references/migracao-configuracoes.md` |
| Segurança | `references/migracao-seguranca.md` |
| Kafka e Mensageria | `references/migracao-kafka.md` |
| JPA e Entidades | `references/migracao-jpa.md` |
| Testes | `references/migracao-testes.md` |
| Código e Padrões | `references/migracao-codigo.md` |

## Workflow de Migração

Executar **na ordem**, validando cada etapa antes de avançar:

1. **Preparação** — Ler todas as referências. Mapear arquivos do projeto legado.
2. **Build** — Converter pom.xml → build.gradle + settings.gradle + gradle.properties. Configurar Gradle wrapper. Atualizar `.gitignore` para Gradle.
3. **Pacotes** — Renomear `br.com.attornatus` → `ai.attus` e `server` → `ai.attus.<nome_servico>`. Mover DTOs para dentro do pacote do domínio.
4. **Imports** — Substituir `javax.*` → `jakarta.*` em todo o código.
5. **Bibliotecas** — Substituir imports das libs legadas (`br.com.attornatus.core.*`) pelas novas (`ai.attus.lib.*`).
6. **Configurações** — Migrar application.yml, remover logback-spring.xml, atualizar application-test.yml. **Verificar duplicações com `starter-application.yml`** (ver seção "Verificação de Duplicações" em `migracao-configuracoes.md`).
7. **Segurança** — Migrar SecurityConfig para o novo padrão (SecurityRequestCustomizer).
8. **Kafka** — Migrar KafkaConfig, substituir KafkaProducer por KafkaTemplate, atualizar consumers.
9. **JPA** — Atualizar @TableGenerator, @ElementCollection, migrar `@Multitenant`/`@TenantDiscriminatorColumn` → `@TenantId`, remover builders customizados desnecessários.
10. **Spring Batch** — Se o microsserviço usa Spring Batch apenas para jobs agendados, migrar para Quartz puro (ver `migracao-codigo.md`).
11. **Classe Principal** — Simplificar classe principal, remover @ComponentScan, @EnableCaching, @PostConstruct.
12. **Controllers** — Refatorar para usar Component ao invés de Facade/Service+Mapper direto. Mover lógica para Component.
13. **Components** — Criar/atualizar Components para encapsular orquestração e conversão DTO ↔ Entity.
14. **Testes** — Migrar para AbstractControllerTest/AbstractServiceTest, usar @MockitoBean, atualizar mocks.
15. **Limpeza** — Remover arquivos deletados (configs antigas, controllers obsoletos, classes de teste antigas, serviços externos descontinuados).
16. **Validação** — Compilar, rodar testes, verificar cobertura.

## Restrições (MUST DO)

- Seguir TODAS as referências antes de implementar
- Migrar pacotes ANTES de alterar código
- Manter a mesma funcionalidade — migração não altera regras de negócio
- Validar compilação após cada etapa
- Manter testes passando em cada etapa
- Usar `ai.attus:attus-platform-bom` para gerenciar versões

## Restrições (MUST NOT DO)

- NÃO alterar regras de negócio durante a migração
- NÃO alterar tipos de coleção (`List` → `Set`, `ArrayList` → `HashSet`, etc.) — manter exatamente os mesmos tipos do código legado
- NÃO misturar `javax.*` e `jakarta.*` no mesmo projeto migrado
- NÃO manter dependências do stack legado (core, spring-security-oauth2-autoconfigure)
- NÃO usar `com.fasterxml.jackson.*` — usar SEMPRE `tools.jackson.*` (Jackson 3, Spring Boot 4)
- NÃO definir bean `com.fasterxml.jackson.databind.ObjectMapper` em nenhuma configuração de teste
- NÃO usar `@SuppressWarnings` — corrigir a causa raiz
- NÃO usar `spring.main.allow-bean-definition-overriding=true`
- NÃO usar `@FilterDef`/`@Filter` para multi-tenancy — usar exclusivamente `@TenantId` (correspondência direta com `@Multitenant`/`@TenantDiscriminatorColumn` do EclipseLink). Se o código legado não tinha `@FilterDef`, o código migrado não deve ter
- NÃO manter pacotes `br.com.attornatus` ou `server` após migração
- NÃO deletar testes — migrar para o novo padrão
- NÃO usar `ApplicationContextAware` — usar injeção via construtor
- NÃO manter Spring Batch se os jobs são simples (apenas execução por tenant/instituição) — migrar para Quartz puro
- NÃO definir versões de dependências diretamente no `build.gradle` do microsserviço/lib — **TODAS** as versões devem estar centralizadas no `attus-platform-bom`. Se a dependência não existe no BOM, adicioná-la lá primeiro. Exceção: versões de **plugins Gradle** (bloco `plugins {}`) podem ter versão inline pois não são gerenciadas pelo BOM
- NÃO usar `@WithMockUser` — substituir por **`@WithMockAuthenticationToken`** (de `ai.attus:lib-test`)
- NÃO fazer **nenhuma** alteração no código que não tenha instrução explícita nesta skill — a migração deve ser **1:1** com o código legado. Se durante a migração parecer necessário adicionar, remover ou alterar algo que não está documentado aqui (ex: adicionar `@Fetch`, mudar `List` para `Collection`, remover `.distinct()`, adicionar annotations de otimização), **PARAR e questionar o responsável**. A resposta deve retroalimentar esta skill como nova regra, para que futuras migrações sigam o mesmo padrão

## Breaking Changes de API

### Lib-Security (RunAs)

Os métodos da classe `RunAs` foram renomeados para seguir o padrão consistente:

| Nome Antigo | Nome Novo |
|-------------|-----------|
| `RunAs.runAsTenant()` | `RunAs.runMethodAsTenant()` |
| `RunAs.runComRetornoAsTenant()` | `RunAs.runFunctionAsTenant()` |

Durante a migração, substituir todas as ocorrências dos métodos antigos pelos novos nos Jobs e outros componentes que usam execução em contexto de tenant específico.

> Incluindo `RunAs.runAsAdmin()` → `RunAs.runMethodAsAdmin()`.

### TenantContextHolder → SecurityContextUtils

`TenantContextHolder` (`br.com.attornatus.core.tenant.TenantContextHolder`) foi removido no stack moderno. Substituir por `SecurityContextUtils.getTenantId()` da lib-security:

| Antes | Depois |
|-------|--------|
| `import br.com.attornatus.core.tenant.TenantContextHolder;` | `import ai.attus.lib.security.domain.SecurityContextUtils;` |
| `TenantContextHolder.get()` | `SecurityContextUtils.getTenantId()` |
| `TenantContextHolder.TENANT_KEY` | `SecurityContextUtils.TENANT_KEY` |
| `TenantContextHolder.TENANT_KEY_LIKE` | `SecurityContextUtils.TENANT_KEY_LIKE` |
| `TenantContextHolder.set(tenantId)` | N/A — contexto vem do token OAuth2 |

Durante a migração, substituir **todas** as ocorrências de `TenantContextHolder` por `SecurityContextUtils` e remover o import legado. A constante `TENANT_KEY_LIKE` foi adicionada ao `SecurityContextUtils` para manter compatibilidade com `@AdditionalCriteria` do EclipseLink.

### LimparCache → @CacheEvict

`@LimparCache` (`br.com.attornatus.core.support.cache.LimparCache`) foi excluído nas novas bibliotecas. Substituir pelo `@CacheEvict` padrão do Spring:

| Antes | Depois |
|-------|--------|
| `import br.com.attornatus.core.support.cache.LimparCache;` | `import org.springframework.cache.annotation.CacheEvict;` |
| `@LimparCache(identificador = "cache-name", propriedade = "entity.id")` | `@CacheEvict(value = "cache-name", key = "#entity.id")` |
| `@LimparCache(identificador = "cache-name", propriedade = "entity.id", condicao = "...")` | `@CacheEvict(value = "cache-name", key = "#entity.id", condition = "...")` |

Mapeamento de atributos:
- `identificador` → `value` (nome do cache)
- `propriedade` → `key` (SpEL com `#` prefix)
- `condicao` → `condition` (SpEL)

### AguardarDisponibilidadeHeapSpace → lib-observability

`AguardarDisponibilidadeHeapSpace` e classes relacionadas (`MetricaCpuMemoria`, `MetricaCpuMemoriaImpl`, `SemHeapSpaceDisponivelException`, `AguardarDisponibilidadeHeapSpaceAspect`) foram movidas do core legado para `lib-observability`:

| Antes | Depois |
|-------|--------|
| `br.com.attornatus.core.support.monitoramentorecursos.*` | `ai.attus.lib.observability.domain.monitoramentorecursos.*` |
| `br.com.attornatus.core.exception.SemHeapSpaceDisponivelException` | `ai.attus.lib.observability.domain.monitoramentorecursos.SemHeapSpaceDisponivelException` |

Microserviços que usam `@AguardarDisponibilidadeHeapSpace` devem adicionar `lib-observability` explicitamente no `build.gradle`:

```groovy
implementation 'ai.attus:lib-observability'
```

> **Nota:** `lib-starter` já depende de `lib-observability` (classes OTel são universais), mas a dependência explícita é necessária para garantir que o import do pacote `domain.monitoramentorecursos` resolva corretamente.

### Lib-Core (SimplePageImpl)

`SimplePageImpl` (de `ai.attus.lib.core.domain`) foi removida no stack moderno. Substituir por `Page`/`PageImpl` do Spring Data:

| Uso | Antes | Depois |
|-----|-------|--------|
| Tipo de retorno (Feign, interface) | `SimplePageImpl<T>` | `Page<T>` |
| Tipo de variável/campo | `SimplePageImpl<T>` | `Page<T>` |
| Instanciação | `new SimplePageImpl<>(list, page, size, total)` | `new PageImpl<>(list, PageRequest.of(page, size), total)` |
| Import | `ai.attus.lib.core.domain.SimplePageImpl` | `org.springframework.data.domain.Page` + `PageImpl` + `PageRequest` |

Durante a migração, substituir todas as ocorrências em Feign clients, mocks de teste e classes que instanciam `SimplePageImpl`.

## Referência de Conhecimento

Java 25, Spring Boot 4, Spring Security 6, Gradle, Jakarta EE, Kafka, Spring Kafka, JPA/Hibernate, JUnit 5, Mockito, WireMock, EmbeddedKafka, GraalVM Native Image, Flyway
