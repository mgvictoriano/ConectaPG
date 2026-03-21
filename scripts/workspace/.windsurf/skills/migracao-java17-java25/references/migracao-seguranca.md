# Migração de Segurança

## SecurityConfig

### Antes (legado — Spring Security OAuth2):
```java
@Configuration
@EnableResourceServer
@EnableOAuth2Client
@EnableGlobalMethodSecurity(prePostEnabled = true)
public class SecurityConfig extends ResourceServerConfigurerAdapter {

    @Override
    public void configure(HttpSecurity http) throws Exception {
        http.authorizeRequests()
            .antMatchers("/endpoint/**").hasAuthority("ROLE_USUARIO");
    }

    @Bean
    public RoleHierarchy roleHierarchy() { ... }

    @Bean
    public RoleHierarchyVoter roleHierarchyVoter() { ... }

    @Bean
    public AffirmativeBased accessDecisionManager() { ... }
}
```

### Depois (migrado — Spring Security 6+):
```java
@Configuration
@EnableMethodSecurity(prePostEnabled = true)
public class SecurityConfig {

    @Bean
    public SecurityRequestCustomizer securityRequestCustomizer() {
        return authz -> authz
            .requestMatchers(HttpMethod.GET, "/endpoint/publico")
                .hasAnyAuthority(Privilegio.ROLE_USUARIO.name(), Privilegio.ROLE_USUARIO_PORTAL.name())
            .requestMatchers("/endpoint/**")
                .hasAuthority(Privilegio.ROLE_USUARIO.name());
    }
}
```

### Checklist de Remoções

| Item | Motivo |
|------|--------|
| `extends ResourceServerConfigurerAdapter` | API removida no Spring Security 6 |
| `@EnableResourceServer` | OAuth2 Resource Server agora via `lib-security` |
| `@EnableOAuth2Client` | OAuth2 Client agora via `lib-security` |
| `@EnableGlobalMethodSecurity` | Substituído por `@EnableMethodSecurity` |
| `RoleHierarchy` bean | Fornecido pela `lib-security` |
| `RoleHierarchyVoter` bean | Fornecido pela `lib-security` |
| `AffirmativeBased` bean | Fornecido pela `lib-security` |
| `FeignConfiguration` | Fornecido pela `lib-security`/`lib-starter` |
| `JpaTransactionManagerConfig` | Auto-configurado pelo Spring Boot |

### Alterações em Matchers

| Antes | Depois |
|-------|--------|
| `.antMatchers("/path")` | `.requestMatchers("/path")` |
| `.antMatchers(HttpMethod.GET, "/path")` | `.requestMatchers(HttpMethod.GET, "/path")` |

## @PreAuthorize — Strings Literais vs Privilegio Enum

Substituir strings literais em `@PreAuthorize` por referências ao `Privilegio` enum via access handler.

### Antes:
```java
@PreAuthorize("hasAnyAuthority('PRV_MANUTENCAO_AJUIZAMENTO_EF','ROLE_ADMIN_ATTORNATUS')")
public void metodo() { ... }
```

### Depois:
```java
// No AccessHandler:
public boolean hasPermissaoParaOperacao() {
    return SecurityContextUtils.hasRole(Privilegio.PRV_MANUTENCAO_AJUIZAMENTO_EF)
           || SecurityContextUtils.hasRole(Privilegio.ROLE_ADMIN_ATTORNATUS);
}

// No Service:
@PreAuthorize("@accessHandler.hasPermissaoParaOperacao()")
public void metodo() { ... }
```

## SecurityRequestCustomizer — Usar Privilegio.name()

No `SecurityRequestCustomizer`, usar `Privilegio.X.name()` em vez de strings literais:

```java
.requestMatchers("/path/**").hasAuthority(Privilegio.ROLE_USUARIO.name())
.requestMatchers("/path/especial").hasAnyAuthority(
    Privilegio.ROLE_USUARIO.name(),
    Privilegio.ROLE_USUARIO_PORTAL.name())
```

## ApplicationContextAware — Proibido

Classes que implementam `ApplicationContextAware` devem ser refatoradas para usar injeção via construtor. Exemplos comuns:

| Antes | Depois |
|-------|--------|
| `implements ApplicationContextAware` + `setApplicationContext()` | Injeção de `AutowireCapableBeanFactory` via construtor |
| `ApplicationContextProvider.getBean(X.class)` | Injeção direta da dependência via `@Autowired` |

## RunAs — Métodos Renomeados

| Nome Antigo | Nome Novo |
|-------------|-----------|
| `RunAs.runAsTenant()` | `RunAs.runMethodAsTenant()` |
| `RunAs.runComRetornoAsTenant()` | `RunAs.runFunctionAsTenant()` |
| `RunAs.runAsAdmin()` | `RunAs.runMethodAsAdmin()` |

## SecurityContext entre Requests (Spring Security 6)

O `SecurityContextHolderFilter` limpa o `SecurityContextHolder` após cada request. Impactos:

- Testes que fazem múltiplos `perform()` (ex: POST + GET) perdem autenticação no segundo request
- **Solução**: Reestruturar testes para **um `perform()` por `@Test`** (padrão BDD com `@Nested`)
- **Alternativa**: Usar `SecurityMockMvcRequestPostProcessors` em cada `perform()` individual
