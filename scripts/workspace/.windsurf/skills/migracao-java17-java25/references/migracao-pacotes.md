# Migração de Pacotes e Imports

## Renomeação de Pacotes

### Pacote Raiz

| Antes | Depois |
|-------|--------|
| `br.com.attornatus.<servico>` | `ai.attus.<servico>` |
| `server` (classe principal) | `ai.attus.<servico>` |

### Procedimento

1. **Renomear diretórios** — Mover `src/main/java/br/com/attornatus/<servico>` → `src/main/java/ai/attus/<servico>`
2. **Renomear diretórios de teste** — Mover `src/test/java/br/com/attornatus/<servico>` → `src/test/java/ai/attus/<servico>`
3. **Mover classe principal** — De `server/<Nome>Server.java` para `ai/attus/<servico>/<Nome>Server.java`
4. **Mover teste principal** — De `server/<Nome>ServerTest.java` para `ai/attus/<servico>/<Nome>ServerTest.java` (ou excluir se desnecessário)
5. **Ajustar declarações `package`** — Em todos os arquivos movidos
6. **Ajustar imports** — Em todos os arquivos que referenciam classes movidas

> **Recomendação**: Fazer o rename como commit isolado (sem alterações de conteúdo) para que o Git detecte renames automaticamente.

## Migração de Imports — Libs Attus

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
| `br.com.attornatus.core.support.entity.BaseDto` | `ai.attus.lib.core.domain.BaseDto` |
| `br.com.attornatus.core.support.ApplicationContextProvider` | **REMOVIDO** (não usar) |
| `br.com.attornatus.core.support.cache.LimparCache` | `org.springframework.cache.annotation.CacheEvict` (Spring padrão) |
| `br.com.attornatus.core.support.monitoramentorecursos.*` | `ai.attus.lib.observability.domain.monitoramentorecursos.*` |
| `br.com.attornatus.core.exception.SemHeapSpaceDisponivelException` | `ai.attus.lib.observability.domain.monitoramentorecursos.SemHeapSpaceDisponivelException` |
| `ai.attus.lib.core.domain.SimplePageImpl` | `org.springframework.data.domain.Page` / `PageImpl` + `PageRequest` |

## Migração javax → jakarta

Substituir **todos** os imports:

| javax | jakarta |
|-------|---------|
| `javax.persistence.*` | `jakarta.persistence.*` |
| `javax.validation.*` | `jakarta.validation.*` |
| `javax.annotation.*` | `jakarta.annotation.*` |
| `javax.servlet.*` | `jakarta.servlet.*` |
| `javax.transaction.*` | `jakarta.transaction.*` |

> **Exceções**: `javax.crypto.*`, `javax.sql.*` e `javax.net.*` permanecem com `javax` (são do JDK, não do Jakarta EE).

## SimplePageImpl → Page/PageImpl

`SimplePageImpl` foi removida no stack moderno. Substituir em Feign clients, mocks e testes:

| Uso | Antes | Depois |
|-----|-------|--------|
| Tipo de retorno (Feign, interface) | `SimplePageImpl<T>` | `Page<T>` |
| Tipo de variável/campo | `SimplePageImpl<T>` | `Page<T>` |
| Instanciação | `new SimplePageImpl<>(list, page, size, total)` | `new PageImpl<>(list, PageRequest.of(page, size), total)` |
| Import | `ai.attus.lib.core.domain.SimplePageImpl` | `org.springframework.data.domain.Page` + `PageImpl` + `PageRequest` |

## BaseDto — Interface vs Abstract Class

O `BaseDto` legado (`br.com.attornatus.core.support.entity.BaseDto`) é uma **abstract class** no jar publicado. O novo `ai.attus.lib.core.domain.BaseDto` é uma **interface**.

| Antes | Depois |
|-------|--------|
| `extends BaseDto` | `implements BaseDto` |
| `import br.com.attornatus.core.support.entity.BaseDto` | `import ai.attus.lib.core.domain.BaseDto` |
