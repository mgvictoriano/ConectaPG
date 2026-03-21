---
name: gerador-openapi
description: Geração de documentação OpenAPI 3.0 para microsserviços Java/Spring Boot. Use quando precisar: (1) Gerar spec OpenAPI a partir de código existente, (2) Documentar endpoints REST de microsserviços, (3) Criar documentação de API em docs/apis, (4) Validar conformidade com padrões Attus.
---

# Gerador OpenAPI

Esta skill gera documentação OpenAPI 3.0 para microsserviços Java/Spring Boot, extraindo endpoints, schemas e operações diretamente do código fonte.

## Pré-requisitos

- Projeto Java com Spring Boot
- Dependências: `springdoc-openapi-starter-webmvc-ui` ou `springfox`
- Acesso ao código fonte do microsserviço em `projetos/`

## Geração de Spec OpenAPI

### Opção 1: Via Script Automatizado

Execute o script de geração:

```bash
python3 .windsurf/skills/gerador-openapi/scripts/gerar_openapi.py \
  --projeto <nome-projeto> \
  --output docs/apis/
```

O script irá:
1. Analisar os controllers do projeto
2. Extrair endpoints, parâmetros e responses
3. Gerar arquivo `openapi.yaml` em `docs/apis/<projeto>/`

### Opção 2: Manual via Anotações Spring

Adicione dependência no `build.gradle`:

```groovy
implementation 'org.springdoc:springdoc-openapi-starter-webmvc-ui:2.5.0'
```

Configure em `application.yml`:

```yaml
springdoc:
  api-docs:
    path: /v3/api-docs
  swagger-ui:
    path: /swagger-ui.html
```

Crie classe de configuração:

```java
@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
            .info(new Info()
                .title("API Nome do Serviço")
                .version("1.0.0")
                .description("Descrição da API"));
    }
}
```

Acesse:
- Swagger UI: `http://localhost:8080/swagger-ui.html`
- Spec JSON: `http://localhost:8080/v3/api-docs`
- Spec YAML: `http://localhost:8080/v3/api-docs.yaml`

### Opção 3: Via Spring Boot Actuator

Adicione no `application.yml`:

```yaml
management:
  endpoints:
    web:
      exposure:
        include: openapi,swagger-ui
  endpoint:
    openapi:
      enabled: true
```

## Estratura de Saída

A spec gerada deve seguir a estrutura em `docs/apis/`:

```
docs/apis/
└── <nome-servico>/
    ├── openapi.yaml      # Spec principal
    ├── README.md         # Documentação complementar
    └── changelog.md      # Histórico de versões
```

## Padrões Attus

Consulte [references/padroes-openapi.md](references/padroes-openapi.md) para:
- Convenções de nomenclatura
- Estrutura de paths e operations
- Definição de schemas
- Códigos de resposta
- Versionamento de API
