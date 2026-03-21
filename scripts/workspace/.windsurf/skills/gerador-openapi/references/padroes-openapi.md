# Padrões OpenAPI Attus

Este documento define as convenções e padrões para documentação de APIs OpenAPI 3.0 nos microsserviços Attus.

## Estrutura de Paths

Formato: `/versao/recurso/acao`

- **Versão**: `v1`, `v2` (substitui major version)
- **Recurso**: substantivo no plural, kebab-case
- **Ação**: apenas para actions específicas (ex: `/usuarios/{id}/ativar`)

### Exemplos

```
/v1/pessoas
/v1/pessoas/{id}
/v1/pessoas/{id}/enderecos
/v1/pessoas/buscar
```

## Operações HTTP

| Método | Uso | Código Sucesso |
|--------|-----|----------------|
| `GET` | Listar/Consultar | 200 |
| `POST` | Criar | 201 |
| `PUT` | Substituir | 200 |
| `PATCH` | Atualizar parcial | 200 |
| `DELETE` | Remover | 204 |

## Códigos de Resposta

### Padrão

```yaml
responses:
  '200':
    description: Sucesso
    content:
      application/json:
        schema:
          $ref: '#/components/schemas/ResponseDto'
  '201':
    description: Criado com sucesso
  '400':
    description: Requisição inválida
    content:
      application/json:
        schema:
          $ref: '#/components/schemas/ErrorDto'
  '401':
    description: Não autorizado
  '403':
    description: Proibido
  '404':
    description: Recurso não encontrado
  '500':
    description: Erro interno
```

### Códigos Obrigatórios

- `200` - Sucesso em operações de leitura
- `201` - Criação bem-sucedida
- `400` - Erro de validação
- `401` - Falta autenticação
- `500` - Erro interno do servidor

## Schemas

### Estrutura de Response

```yaml
ResponseDto:
  type: object
  properties:
    dados:
      type: object
      description: Dados da resposta
    mensagem:
      type: string
      description: Mensagem de retorno
    sucesso:
      type: boolean
      description: Indica se a operação foi bem-sucedida
```

### Estrutura de Error

```yaml
ErrorDto:
  type: object
  properties:
    codigo:
      type: string
      description: Código de erro de negócio
    mensagem:
      type: string
      description: Mensagem de erro amigável
    detalhes:
      type: array
      items:
        $ref: '#/components/schemas/CampoErroDto'
      description: Lista de campos com erro
    timestamp:
      type: string
      format: date-time
      description: Data/hora do erro
```

### Estrutura de Paginação

```yaml
PaginaDto:
  type: object
  properties:
    conteudo:
      type: array
      items:
        type: object
      description: Lista de elementos
    paginaAtual:
      type: integer
      description: Página atual (0-based)
    totalElementos:
      type: integer
      description: Total de elementos
    totalPaginas:
      type: integer
      description: Total de páginas
    tamanho:
      type: integer
      description: Tamanho da página
```

## Nomenclatura

### Paths

- Plural: `/pessoas`, `/enderecos`
- kebab-case: `/pessoas-fisicas`
- Parâmetros: camelCase `pessoaId`

### Schemas

- PascalCase: `PessoaDto`, `EnderecoResponse`
- Sufixos: `Request`, `Response`, `Dto`, `Filtro`

### Operation IDs

- camelCase: `buscarPessoa`, `salvarPessoa`, `listarPessoas`

## Segurança

Todas as APIs devem incluir autenticação JWT:

```yaml
components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
security:
  - bearerAuth: []
```

## Versionamento

- Usar URL path: `/v1/...`
- Manter versões anteriores por 6 meses após nova versão
- Documentar breaking changes no changelog

## Documentação Adicional

Cada API em `docs/apis/<servico>/` deve incluir:

- `openapi.yaml` - Spec principal
- `README.md` - Visão geral, autenticação, rate limiting
- `changelog.md` - Histórico de versões e mudanças
