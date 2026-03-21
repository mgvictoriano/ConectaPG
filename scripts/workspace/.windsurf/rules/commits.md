
---

trigger: always_on
description: Ao sugerir ou gerar mensagens de commit, seguir Conventional Commits em Português.

---

# Convenção de Commits Attus

Toda mensagem de commit DEVE seguir o padrão **Conventional Commits**:

```
<tipo>(<escopo>): <descrição curta em português>
```

## Tipos Permitidos

| Tipo | Uso |
|------|-----|
| `feat` | Nova funcionalidade |
| `fix` | Correção de bug |
| `refactor` | Refatoração sem mudança de comportamento |
| `docs` | Documentação |
| `test` | Adição ou correção de testes |
| `chore` | Tarefas de manutenção (build, CI, deps) |
| `perf` | Melhoria de performance |
| `style` | Formatação (sem mudança de lógica) |

## Regras

- **Descrição em Português** — clara e no imperativo (`adicionar`, `corrigir`, `remover`)
- **Escopo opcional** — nome do módulo/domínio quando aplicável (`feat(pessoa): adicionar filtro por CPF`)
- **Linha do assunto** — máximo 72 caracteres
- **Breaking changes** — usar `!` após o tipo (`feat!: migrar endpoint de pessoa para v2`)
- **Sem ponto final** na linha do assunto
