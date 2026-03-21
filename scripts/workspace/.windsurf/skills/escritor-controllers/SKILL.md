---
name: escritor-controllers
description: Escrever controllers para Java Spring (backend) e Angular (frontend) seguindo padroes de arquitetura da Constituicao do projeto. Use quando o usuario precisar criar novos controllers, refatorar controllers existentes ou implementar endpoints REST seguindo os padroes estabelecidos (Controller para Component/Facade para Service no Java; Controller como API client no Angular).
---

# Guia de Escrita de Controllers

Este guia fornece instruções para criação de controllers consistentes e de alta qualidade para Java (Spring Boot) e Angular.

## Decisão Rápida: Qual Plataforma?

- **Backend Java (Spring)**: REST API com arquitetura Controller → Component/Facade → Service → [Ver seção Java](#backend-java-spring)
- **Frontend Angular**: API Client puro com Controller base abstrato → [Ver seção Angular](#frontend-angular)

---

## Backend Java (Spring)

### Arquitetura

Seguir a cadeia: **Controller → Component/Facade → Service → Repository**

- **Controller**: Apenas endpoints e validação. Delega para Component/Facade.
- **Component**: Orquestrador/Facade. Chama Service e Mapper.
- **Service**: Regras de negócio puras (Entity).
- **Mapper**: Conversão Entity <-> DTO (@Component).

### Anatomia do Controller

```java
@RestController
@RequestMapping("/recursos")
public class RecursoController {

    private final RecursoService recursoService;
    private final RecursoMapper recursoMapper;
    private final RecursoFacade recursoFacade;

    public RecursoController(RecursoService recursoService,
                             RecursoMapper recursoMapper,
                             RecursoFacade recursoFacade) {
        this.recursoService = recursoService;
        this.recursoMapper = recursoMapper;
        this.recursoFacade = recursoFacade;
    }

    // Endpoints...
}
```

### Padrões de Endpoints

| Operação | HTTP | URL | Parâmetros | Retorno |
|----------|------|-----|------------|---------|
| Buscar por ID | GET | `/{id}` | `@PathVariable Long id` | DTO |
| Listar página | GET | `` | `@PageableDefault Pageable` | `Page<DTO>` |
| Listar com filtro | GET | `` | `@RequestParam("search") String` | `Page<DTO>` |
| Criar | POST | `` | `@Valid @RequestBody DTO` | DTO |
| Atualizar | PUT | `/{id}` | `@PathVariable`, `@Valid @RequestBody` | DTO |
| Excluir | DELETE | `/{id}` | `@PathVariable Long id` | void |

### Mapeamento de Anotações

```java
// Path Variable
@GetMapping("/{id}")
public DTO buscarPorId(@PathVariable Long id)

// Query Params (opcionais com default)
@GetMapping
public Page<DTO> listar(@RequestParam(value = "search", required = false) String search,
                        @PageableDefault(size = 10) Pageable pageable)

// Request Body com validação
@PostMapping
public DTO salvar(@Valid @RequestBody DTO dto)

// Path + Query combinados
@GetMapping("/{id}/subrecursos")
public List<SubDTO> listarSub(@PathVariable Long id,
                              @RequestParam(value = "ativo", defaultValue = "true") boolean ativo)
```

### Convenções de Nomenclatura

- **Classes**: PascalCase + sufixo `Controller` (ex: `RecursoController`)
- **Métodos**: camelCase, verbos em português (ex: `buscarPorId`, `listarPagina`, `salvar`, `atualizar`, `excluir`)
- **Variáveis**: camelCase
- **Endpoints**: kebab-case (ex: `/configuracao-parametro`)

### Tratamento de Erros

```java
@GetMapping("/{id}")
public DTO buscarPorId(@PathVariable Long id) {
    return recursoService.buscarPorId(id)
            .map(recursoMapper::toDto)
            .orElseThrow(() -> new RegistroNaoEncontradoException("Recurso", id));
}
```

### Paginação

```java
@GetMapping
public Page<DTO> listar(@PageableDefault(size = 10) Pageable pageable) {
    return recursoService.listarPagina(pageable)
            .map(recursoMapper::toDto);
}
```

Ver [references/java-controller-examples.md](references/java-controller-examples.md) para exemplos completos.

---

## Frontend Angular

### Arquitetura

**Controller como API Client puro** - Apenas faz chamadas HTTP, sem lógica de negócio.

- **Controller**: API Client puro (Http).
- **Service**: Orquestração e Estado (Signals).
- **Component**: View e Interação.

### Anatomia do Controller

```typescript
@Injectable({ providedIn: 'root' })
export class RecursoController extends Controller.Admin<Recurso> {
  protected readonly recurso = 'recursos';
  protected readonly mapper = Recurso.mapper;

  // Métodos customizados...
}
```

### ControllerBase Methods

Extendendo `ControllerBase<T>` ou `Controller.Admin<T>`:

| Método | Descrição | Assinatura |
|--------|-----------|------------|
| `buscarPorId` | GET por ID | `(id: Id) => Observable<T>` |
| `listarPagina` | GET paginado | `(page, size, extraParams?) => Observable<Page<T>>` |
| `adicionar` | POST | `(entity: T) => Observable<T>` |
| `atualizar` | PUT | `(param: U \| Id, entity?: T) => Observable<T>` |
| `excluir` | DELETE | `(id: Id) => Observable<boolean>` |
| `get` | GET genérico | `<K>(url, options?) => Observable<K>` |
| `post` | POST genérico | `<K, R>(url, body, options?) => Observable<R>` |
| `put` | PUT genérico | `<K, R>(url, body, options?) => Observable<R>` |
| `delete` | DELETE genérico | `<K>(url, options?) => Observable<K>` |

### Endpoints Customizados

```typescript
// GET com query params
buscarPorParametro(param: string): Observable<Recurso> {
  return this.get('', { params: { parametro: param } });
}

// POST para ação específica
executarAcao(id: Id, dados: Dados): Observable<Resultado> {
  return this.post(`${id}/acao`, dados);
}

// PUT para atualização parcial
atualizarStatus(id: Id, status: Status): Observable<Recurso> {
  return this.put(`${id}/status`, { status });
}

// DELETE com query params
excluirComMotivo(id: Id, motivo: string): Observable<boolean> {
  return this.delete(`${id}`, { params: { motivo } });
}
```

### Recursos Aninhados (Child Resources)

```typescript
export interface RecursoControllerChilds {
  forSubRecurso: (recursoId: Id) => ControllerBase<SubRecurso>;
}

useChild(): RecursoControllerChilds {
  return {
    forSubRecurso: (recursoId) => this.forChild<SubRecurso>(recursoId, 'subrecursos')
  };
}

// Uso:
const subController = recursoController.useChild().forSubRecurso(123);
subController.listarPagina(0, 10).subscribe(...);
```

### Convenções de Nomenclatura

- **Arquivos**: kebab-case (ex: `recurso.controller.ts`)
- **Classes**: PascalCase + sufixo `Controller` (ex: `RecursoController`)
- **Métodos**: camelCase, verbos em português (ex: `buscarPorId`, `listarPagina`)
- **Propriedades**: camelCase, `protected readonly` para configurações

### Tratamento de Erros

```typescript
import { catchError, of, throwError } from 'rxjs';

buscarComFallback(id: Id): Observable<Recurso> {
  return this.buscarPorId(id).pipe(
    catchError(erro => {
      const fallback = Recurso.getFallback(id);
      return fallback ? of(fallback) : throwError(() => erro);
    })
  );
}
```

Ver [references/angular-controller-examples.md](references/angular-controller-examples.md) para exemplos completos.

---

## Checklist de Qualidade

Antes de finalizar um controller:

- [ ] **Nomenclatura** segue padrões (PT-BR, camelCase/PascalCase)
- [ ] **Injeção** via construtor (Java) ou `inject()` (Angular)
- [ ] **Endpoints** mapeados corretamente com anotações apropriadas
- [ ] **Validação** aplicada (`@Valid`, `@NotNull` em DTOs)
- [ ] **Tratamento de erro** para registros não encontrados
- [ ] **Paginação** configurada com `@PageableDefault` quando aplicável
- [ ] **DTOs** usados para entrada e saída (não expor Entities)
- [ ] **Mapper** utilizado para conversões Entity <-> DTO
