# Migração de JPA e Entidades

## @TableGenerator

### Antes (legado — EclipseLink):
```java
@TableGenerator(name = "SEQ_ENTIDADE", allocationSize = 1)
@GeneratedValue(strategy = GenerationType.TABLE, generator = "SEQ_ENTIDADE")
private Long id;
```

### Depois (migrado — Hibernate):
```java
@TableGenerator(
    name = "SEQ_ENTIDADE",
    table = "sequence",
    pkColumnName = "seq_name",
    valueColumnName = "seq_count",
    allocationSize = 1
)
@GeneratedValue(strategy = GenerationType.TABLE, generator = "SEQ_ENTIDADE")
private Long id;
```

> O Hibernate exige `table`, `pkColumnName` e `valueColumnName` explícitos. O EclipseLink inferira esses valores automaticamente.

## @ElementCollection

Adicionar `fetch = FetchType.EAGER` em `@ElementCollection` onde necessário:

```java
@ElementCollection(fetch = FetchType.EAGER)
@CollectionTable(name = "entidade_valores", joinColumns = @JoinColumn(name = "entidade_id"))
private Set<String> valores;
```

> O Hibernate usa `LAZY` como padrão para `@ElementCollection`. O EclipseLink usava `EAGER`.

## RepositoryConfig

### Antes:
```java
import org.springframework.boot.autoconfigure.domain.EntityScan;

@Configuration
@EntityScan("br.com.attornatus.servico")
public class RepositoryConfig { }
```

### Depois:
```java
import org.springframework.boot.persistence.autoconfigure.EntityScan;

@Configuration
@EntityScan("ai.attus.<servico>")
public class RepositoryConfig { }
```

> O pacote do `@EntityScan` mudou no Spring Boot 4: `org.springframework.boot.autoconfigure.domain` → `org.springframework.boot.persistence.autoconfigure`.

## CustomRepositoryImpl

Usar `CustomRepositoryImpl` de `ai.attus.lib.database` ao invés de implementação local:

```java
import ai.attus.lib.database.domain.repository.CustomRepositoryImpl;
```

## Builders Customizados

Remover builders customizados desnecessários (ex: `CustomDeadLetterBuilder`). Preferir:
- Lombok `@Builder` para DTOs
- Construtores simples para entidades

## Multi-Tenancy (@Multitenant → @TenantId)

### Antes (legado — EclipseLink):
```java
import org.eclipse.persistence.annotations.Multitenant;
import org.eclipse.persistence.annotations.TenantDiscriminatorColumn;

@Multitenant
@TenantDiscriminatorColumn(name = "instituicao_id")
@Entity
public class Documento {
    @Column(name = "instituicao_id", insertable = false, updatable = false)
    private String instituicaoId;
}
```

### Depois (migrado — Hibernate 6):
```java
import org.hibernate.annotations.TenantId;

@Entity
public class Documento {
    @TenantId
    @Column(name = "instituicao_id", nullable = false)
    private String instituicaoId;
}
```

> **Mapeamento direto:** `@Multitenant` + `@TenantDiscriminatorColumn(name = "instituicao_id")` → `@TenantId` no campo correspondente.
> O Hibernate 6 adiciona automaticamente `WHERE instituicao_id = :tenantId` em todas as queries (SELECT, UPDATE, DELETE).
> O tenant é resolvido pelo `TenantIdentifierResolver` configurado na `lib-database`.

### PROIBIDO: @FilterDef/@Filter para multi-tenancy

**NUNCA** usar `@FilterDef` + `@Filter` como substituto de `@Multitenant`/`@TenantDiscriminatorColumn`.

```java
// ❌ ERRADO — NÃO FAZER
@FilterDef(name = "tenantFilter", parameters = @ParamDef(name = "tenantId", type = String.class))
@Filter(name = "tenantFilter", condition = "instituicao_id = :tenantId")
@Entity
public class Documento { ... }

// ✅ CORRETO
@Entity
public class Documento {
    @TenantId
    @Column(name = "instituicao_id", nullable = false)
    private String instituicaoId;
}
```

- `@FilterDef`/`@Filter` requer ativação manual na sessão e é redundante com `@TenantId`
- `@TenantId` é o mecanismo nativo do Hibernate 6 para multi-tenancy discriminator — sempre ativo, sem configuração extra
- Se o código legado **não** tinha `@FilterDef`, o código migrado **não** deve ter

### Também remover: @AdditionalCriteria

Se o EclipseLink usava `@AdditionalCriteria` para filtro de tenant:
```java
// ❌ Legado — remover
@AdditionalCriteria("this.instituicaoId = :tenantId")
```
Substituir por `@TenantId` no campo, conforme acima.

## EclipseLink → Hibernate

| EclipseLink | Hibernate |
|-------------|-----------|
| `spring.jpa.eclipselink.*` | **REMOVER** (Hibernate é o padrão) |
| `spring.jpa.show-sql: true` | Manter se desejado |
| `weaving: true` | Não necessário (Hibernate usa bytecode enhancement diferente) |

## Flyway — Vendor Scripts

O Flyway suporta `{vendor}` no path para auto-selecionar scripts por banco:

```yaml
spring:
  flyway:
    locations: filesystem:../scripts/microservicos/<servico>/base_inicial, filesystem:../scripts/microservicos/<servico>/comum, filesystem:../scripts/microservicos/<servico>/{vendor}
```

Isso permite ter scripts específicos em subpastas `h2/`, `postgresql/`, `oracle/`.
