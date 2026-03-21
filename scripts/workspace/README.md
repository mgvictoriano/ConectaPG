# Workspace

Workspace de desenvolvimento da Attus para facilitar o uso de IDEs de IA.

Este workspace agrega ferramentas, skills, documentação e os próprios projetos em um único diretório. Cada projeto em `projetos/` possui seu próprio repositório Git no GitLab. A IDE de IA enxerga todo o contexto (skills, docs e código) em um único workspace.

- **Skills de IA** — Diretrizes e boas práticas para agentes de codificação (Windsurf)
- **Scripts de gestão** — Clone, sincronização e gestão de múltiplos repositórios
- **Documentação global** — Arquitetura, domínio de negócio e onboarding

## Setup Rápido

1. Clone este repositório
2. Preencha as URLs dos repos em `catalogo/services.yaml`
3. Execute o clone dos projetos:
   ```bash
   ./scripts/git/clone-all.sh
   ```
4. Abra a pasta `workspace` no Windsurf — as skills serão carregadas automaticamente

## Scripts Disponíveis

| Script | Descrição |
|--------|-----------|
| `scripts/git/clone-all.sh` | Clona todos os projetos do catálogo |
| `scripts/git/pull-all.sh` | Atualiza todos os projetos (git pull) |
| `scripts/git/switch-branch.sh <branch>` | Troca branch em todos os projetos |
| `scripts/git/status-all.sh` | Status resumido de todos os projetos |

Todos os scripts aceitam `--filter nome1,nome2` para operar em projetos específicos.

## Estrutura

```
workspace/
├── .windsurf/
│   ├── skills/             # Skills de IA (arquiteto-java, arquiteto-angular, arquiteto-python, ...)
│   ├── rules/              # Regras always-on (java-attus, angular-attus, python-attus, commits)
│   └── workflows/          # Workflows (/nova-feature, /criar-testes, /revisar-mr, ...)
├── scripts/git/            # Scripts de gestão de repositórios
├── catalogo/services.yaml   # Catálogo de microsserviços
├── docs/
│   ├── arquitetura/        # Documentação detalhada por stack (fonte de verdade)
│   │   ├── java/           # Padrões, nomenclatura, testes, eventos, segurança
│   │   ├── angular/        # Nomenclatura, testes
│   │   └── python/         # Stack, estrutura, testes
│   └── onboarding/         # Setup local e fluxo de desenvolvimento
└── projetos/               # Repos clonados (gitignored)
```

## Contribuição

- **Arquitetos**: merge direto (maintainers)
- **Devs e Tech Leads**: via Merge Request (MR) no GitLab
- Veja [CONTRIBUTING.md](CONTRIBUTING.md) para detalhes
