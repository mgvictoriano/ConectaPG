
---

trigger: always_on
description: Ao gerar, modificar ou revisar código Angular/TypeScript neste workspace, SEMPRE invocar a skill arquiteto-angular e seguir TODAS as suas regras.

---

# Regras Angular Attus — Aplicação Obrigatória

Ao gerar, modificar ou revisar código Angular/TypeScript (projeto `frontng`), você DEVE:

1. **Invocar a skill `arquiteto-angular`** antes de produzir qualquer código
2. **Carregar as referências** listadas na skill (`docs/arquitetura/angular/nomenclatura.md`, `docs/arquitetura/angular/testes.md`)
3. **Seguir rigorosamente TODAS as regras** abaixo e da skill

## Arquitetura

1. **Controllers como API clients** — no Angular Attus, Controllers são classes `@Injectable` que encapsulam chamadas HTTP. Não confundir com controllers de backend
2. **Estrutura de módulos por domínio** — cada feature tem seu módulo com: `controller/`, `components/`, `models/`, `services/`, `pages/`
3. **Componentes standalone** — preferir standalone components (Angular 17+) em novos desenvolvimentos
4. **Lazy loading** — módulos de feature devem ser lazy-loaded via `loadChildren`

## Nomenclatura

- **Idioma**: Português (PT-BR) para nomes de negócio, variáveis e métodos
- **Arquivos**: kebab-case (`usuario-lista.component.ts`)
- **Classes**: PascalCase com sufixo do tipo (`UsuarioListaComponent`, `PessoaController`, `DemandaService`)
- **Métodos**: camelCase, verbos no infinitivo em português (`buscarUsuarios`, `salvarDemanda`, `listarAtivos`)
- **Interfaces/Models**: PascalCase, sem prefixo `I` (`UsuarioDto`, `PessoaFiltro`)

## Qualidade

- **Testes**: Jest, estrutura BDD (`describe` → `it` com nomes em PT-BR)
- **Tipagem forte**: nunca usar `any` — definir interfaces/types para todos os modelos
- **Reactive**: usar `Observable` e `async pipe` no template, evitar `.subscribe()` manual no componente
- **Imports**: organizar em blocos (Angular core → libs externas → módulos internos)

## Proibições

- **NÃO** usar `any` como tipo — criar interface apropriada
- **NÃO** fazer chamadas HTTP diretamente no componente — usar Controller (API client)
- **NÃO** usar `ngOnInit` para lógica complexa — delegar para services
- **NÃO** usar `console.log` em código commitado — usar logger service
- **NÃO** hardcodear URLs de API — usar environment files
