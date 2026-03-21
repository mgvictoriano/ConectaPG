# Segurança Attus

Guia de implementação de segurança nos microsserviços do ecossistema Attus. Toda a infraestrutura de segurança (OAuth2, JWT, filtros, CORS) é fornecida pela biblioteca `ai.attus:lib-security`. Os microsserviços **não** implementam segurança manualmente.

## Visão Geral

- **`ai.attus:lib-security`**: Fornece toda a configuração base de segurança (SecurityFilterChain, OAuth2 Resource Server, JWT)
- **`ai.attus:lib-starter`**: Importa `starter-application.yml` com configurações padrão (incluindo OAuth2)
- **OAuth2 Client Credentials**: Autenticação entre serviços
- **`SecurityRequestCustomizer`**: Interface funcional de `lib-security` para definir autorização por endpoint
- **`Privilegio`**: Enum de `lib-security` com todas as authorities do sistema
- **`SecurityContextUtils`**: Utilitário de `lib-security` para acessar dados do contexto de segurança (tenantId, username)

---

## Dependências

```groovy
implementation 'ai.attus:lib-security'
implementation 'ai.attus:lib-starter'
```

Todas as dependências transitivas de Spring Security e OAuth2 já são fornecidas por `lib-security`.

---

## Configuração de Segurança no Microsserviço

O microsserviço **não** declara `SecurityFilterChain`, `@EnableWebSecurity`, `JwtAuthenticationConverter`, `PasswordEncoder` nem qualquer filtro de segurança. Tudo isso é fornecido por `lib-security`.

O único código de segurança no microsserviço é:

1. A classe `SecurityConfig` com `@EnableMethodSecurity`
2. Um bean `SecurityRequestCustomizer` que define as regras de autorização por endpoint

### Exemplo (auditoria)

```java
@Configuration
@EnableMethodSecurity
public class SecurityConfig {

    @Bean
    public SecurityRequestCustomizer requisitorioSecurityCustomizer() {
        return authz -> authz
                .requestMatchers(HttpMethod.GET, "/auditorias/**").hasAuthority(Privilegio.FUNC_AUDITORIAS.name())
                .requestMatchers(HttpMethod.GET, "/entidades/**").hasAuthority(Privilegio.FUNC_AUDITORIAS.name())
                .requestMatchers(HttpMethod.GET, "/registro-login-portal/**").hasAuthority(Privilegio.FUNC_AUDITORIAS.name());
    }
}
```

### Exemplo (sda)

```java
@Configuration
@EnableMethodSecurity
public class SecurityConfig {

    @Bean
    public SecurityRequestCustomizer requisitorioSecurityCustomizer() {
        return authz -> authz
                .requestMatchers("/tipos-situacoes-debito/**").hasAuthority(Privilegio.ROLE_USUARIO.name())
                .requestMatchers("/tipos-verbas/**").hasAuthority(Privilegio.ROLE_USUARIO.name())
                .requestMatchers("/debitos/**").hasAuthority(Privilegio.ROLE_USUARIO.name());
    }
}
```

### Regras

- **NÃO** usar `@EnableWebSecurity` — já está em `lib-security`
- **NÃO** declarar `SecurityFilterChain` — já está em `lib-security`
- **NÃO** implementar `JwtService`, `AuthController`, `PasswordEncoder` — responsabilidade do microsserviço `security`
- Usar `Privilegio` enum de `ai.attus.lib.security.domain.Privilegio` para authorities
- Usar `hasAuthority(Privilegio.XXX.name())` — não usar strings literais
- O nome do bean deve seguir o padrão `requisitorioSecurityCustomizer`

---

## SecurityContextUtils

Utilitário de `lib-security` para acessar informações do contexto de segurança (usuário autenticado, tenant):

```java
import ai.attus.lib.security.domain.SecurityContextUtils;

// Obter o tenantId do usuário autenticado
Long tenantId = SecurityContextUtils.getTenantId();
```

Usar sempre que precisar do tenant ou dados do usuário logado em qualquer camada.

---

## Configuração OAuth2 (application.yml)

A configuração base vem do `starter-application.yml` (importado via `lib-starter`). O microsserviço só precisa declarar o `clientSecret`:

```yaml
spring:
  config:
    import:
      - "classpath:starter-application.yml"
security:
  oauth2:
    client:
      clientSecret: ${OAUTH2_CLIENT_SECRET}
```

---

## Checklist de Segurança

- [ ] Dependência `ai.attus:lib-security` declarada
- [ ] `SecurityConfig` com `@EnableMethodSecurity` e `SecurityRequestCustomizer`
- [ ] Todos os endpoints mapeados no `SecurityRequestCustomizer` com `Privilegio` adequado
- [ ] `SecurityContextUtils` usado para obter tenantId/username (nunca extrair manualmente do token)
- [ ] `clientSecret` configurado via variável de ambiente (nunca hardcoded em produção)
- [ ] HTTPS obrigatório em produção
- [ ] Validação de inputs (@Valid)
