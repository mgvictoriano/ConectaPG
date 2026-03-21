# Padrões de Nomenclatura — Angular

Guia de nomenclatura para código Angular/TypeScript (projeto `frontng`) conforme Constituição v1.4.0.

## Princípio Fundamental

**Idioma padrão: Português (PT-BR)** para nomes de classes, métodos e variáveis de negócio.

Termos técnicos (frameworks, patterns, libraries) mantêm-se em inglês.

> Para regras de nomenclatura Java, consulte `docs/arquitetura/java/nomenclatura.md`.

---

## Arquivos

**kebab-case**:

| Tipo | Padrão | Exemplo |
|------|--------|---------|
| Component | `{feature}.component.ts` | `usuario-list.component.ts` |
| Service | `{feature}.service.ts` | `usuario.service.ts` |
| Controller | `{feature}.controller.ts` | `usuario.controller.ts` |
| Model | `{feature}.model.ts` | `usuario.model.ts` |
| Template | `{feature}.component.html` | `usuario-list.component.html` |
| Styles | `{feature}.component.css` | `usuario-list.component.css` |
| Module | `{feature}.module.ts` | (evitar — usar standalone) |

## Classes

**PascalCase**:

| Tipo | Padrão | Exemplo |
|------|--------|---------|
| Component | `NomeComponent` | `UsuarioListComponent` |
| Service | `NomeService` | `UsuarioService` |
| Controller (API client) | `NomeController` | `UsuarioController` |
| Interface/Model | `Nome` (sem prefixo `I`) | `Usuario`, `UsuarioDto` |
| Enum | `Nome` | `StatusUsuario` |

## Métodos e Variáveis

**camelCase**, verbos em português no **infinitivo**:

```typescript
// Variáveis
usuarios = signal<Usuario[]>([]);
usuarioSelecionado = signal<Usuario | null>(null);
isCarregando = signal<boolean>(false);

// Observables (sufixo $ opcional)
usuarios$ = this.usuarioService.listar();

// Métodos
buscarPorId(id: number): void { }
salvar(usuario: Usuario): Observable<Usuario> { }
listarAtivos(): Observable<Usuario[]> { }
```

## Signals

```typescript
// Writable signals
readonly contador = signal(0);
readonly usuario = signal<Usuario | null>(null);

// Computed signals
readonly usuarioAtivo = computed(() => this.usuario()?.ativo === true);
readonly totalUsuarios = computed(() => this.usuarios().length);

// Métodos de atualização
incrementar(): void {
  this.contador.update(c => c + 1);
}

setUsuario(usuario: Usuario): void {
  this.usuario.set(usuario);
}
```

## Estrutura de Módulo por Domínio

Cada feature tem sua estrutura:

```
{feature}/
├── controller/         # API clients (@Injectable, chamadas HTTP)
├── components/         # Componentes standalone
├── models/             # Interfaces e tipos
├── services/           # Lógica de negócio
└── pages/              # Componentes de página (rotas)
```

## Proibições

- **NÃO** usar `any` como tipo — criar interface apropriada
- **NÃO** fazer chamadas HTTP diretamente no componente — usar Controller (API client)
- **NÃO** usar `ngOnInit` para lógica complexa — delegar para services
- **NÃO** usar `console.log` em código commitado — usar logger service
- **NÃO** hardcodear URLs de API — usar environment files

## Exemplo Completo

```typescript
// usuario-list.component.ts
@Component({
  selector: 'app-usuario-list',
  templateUrl: './usuario-list.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class UsuarioListComponent {
  private readonly usuarioService = inject(UsuarioService);
  
  readonly usuarios = signal<Usuario[]>([]);
  readonly isCarregando = signal<boolean>(false);
  readonly totalUsuarios = computed(() => this.usuarios().length);
  
  ngOnInit(): void {
    this.carregarUsuarios();
  }
  
  carregarUsuarios(): void {
    this.isCarregando.set(true);
    this.usuarioService.listarAtivos()
      .subscribe(usuarios => {
        this.usuarios.set(usuarios);
        this.isCarregando.set(false);
      });
  }
  
  selecionarUsuario(usuario: Usuario): void {
    this.usuarioSelecionado.set(usuario);
  }
}
```
