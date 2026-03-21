# Contribuição

## Quem pode contribuir

- **Todos os desenvolvedores** podem clonar e utilizar o workspace
- **Devs e Tech Leads** devem abrir **Merge Request (MR)** no GitLab para qualquer alteração
- **Arquitetos** são os maintainers e responsáveis pelo merge

## O que entra neste repositório

- Skills e diretrizes para agentes de codificação (`.windsurf/skills/`)
- Scripts utilitários compartilhados (`scripts/`)
- Documentação de arquitetura, negócio e onboarding (`docs/`)
- Catálogo de microsserviços (`catalogo/`)
- Configurações de estilo e linters compartilhados

## O que NÃO entra

- Código-fonte dos projetos (estes vivem em seus próprios repos)
- Documentação técnica específica de um serviço (deve ficar no repo do serviço)
- Arquivos de configuração local ou credenciais
- Artefatos de build

## Processo de Merge Request

1. Crie uma branch a partir de `main`
2. Faça suas alterações
3. Abra um MR no GitLab com descrição clara do que foi alterado e por quê
4. Aguarde a revisão de pelo menos **1 arquiteto**
5. Após aprovação, o arquiteto fará o merge

## Convenções

- **Idioma**: Português (PT-BR) para documentação, rules, skills, workflows e código de negócio
- **Commits**: Conventional Commits em português — `<tipo>(<escopo>): <descrição>` (ver `.windsurf/rules/commits.md`)
- **Scripts**: Bash, com `set -euo pipefail`, comentário de uso no topo
- **Markdown**: formatação consistente, títulos hierárquicos
