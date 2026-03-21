# Onboarding

Guia para novos desenvolvedores que estão entrando no ecossistema Attus.

## Primeiro Dia

### 1. Clonar o workspace

```bash
git clone <url-do-workspace>
cd workspace
```

### 2. Clonar os projetos

Preencha as URLs no `catalogo/services.yaml` (se ainda não estiverem) e execute:

```bash
./scripts/git/clone-all.sh
```

Para clonar apenas projetos específicos:

```bash
./scripts/git/clone-all.sh --filter pessoa,demanda,frontng
```

### 3. Abrir no Windsurf

Abra a pasta `workspace/` no Windsurf. As skills e rules serão carregadas automaticamente.

### 4. Configurar ambiente local

Consulte o guia de [Setup Local](setup-local.md) para configurar o ambiente de desenvolvimento.

## Leituras Obrigatórias

Antes de escrever código, leia (nesta ordem):

1. **[Arquitetura](../arquitetura/README.md)** — Visão geral do ecossistema, diagrama, stack
2. **[Padrões Java](../arquitetura/java/padroes-arquitetura.md)** — Camadas, Clean Code, pacotes
3. **[Nomenclatura Java](../arquitetura/java/nomenclatura.md)** — Regras de nomes em PT-BR
4. **[Testes Java](../arquitetura/java/testes.md)** — Estrutura BDD obrigatória
5. **[Eventos](../arquitetura/java/eventos.md)** — Spring Events, Kafka, DLQ
6. **[Segurança](../arquitetura/java/seguranca.md)** — OAuth2/JWT via lib-security
7. **[Nomenclatura Angular](../arquitetura/angular/nomenclatura.md)** — Nomes PT-BR para frontend
8. **[Testes Angular](../arquitetura/angular/testes.md)** — BDD com Jest

## Fluxo de Desenvolvimento

```
1. Pegar demanda
       │
2. Criar branch a partir de main/develop
       │
3. Escrever testes BDD (cobertura > 80%)
       │
4. Implementar (seguindo camadas + nomenclatura)
       │
5. Verificar Clean Code (checklist Sonar)
       │
6. Commit (Conventional Commits em PT-BR)
       │
7. Abrir Merge Request (MR) no GitLab
       │
8. Revisão por arquiteto
       │
9. Merge
```

## Ferramentas do Workspace

| Ferramenta | Descrição | Como Usar |
|------------|-----------|-----------|
| Skills | Diretrizes para IA | Automático no Windsurf |
| Rules | Regras always-on | Automático no Windsurf |
| Workflows | Fluxos passo-a-passo | `/nova-feature`, `/criar-testes`, etc. |
| Scripts | Gestão de repos | `scripts/git/*.sh` |

## Dúvidas?

- Consulte `docs/arquitetura/` para documentação detalhada por stack (Java, Angular, Python)
- Consulte `.windsurf/skills/` para skills de IA (`arquiteto-java`, `arquiteto-angular`, `arquiteto-python`)
- Em caso de dúvida sobre nomenclatura, a regra é: **Português, verbos no infinitivo**
