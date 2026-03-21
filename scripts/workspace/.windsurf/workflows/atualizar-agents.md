---
description: Atualizar o AGENTS.md após alterações em skills, rules, workflows ou docs do workspace
---

# Atualizar AGENTS.md

Workflow para manter o `AGENTS.md` sincronizado com o estado atual do workspace. Deve ser executado sempre que houver alteração em skills, rules, workflows, docs ou na estrutura do repositório.

## Quando Executar

- Criação, remoção ou renomeação de skill em `.windsurf/skills/`
- Criação, remoção ou alteração de rule em `.windsurf/rules/`
- Criação, remoção ou alteração de workflow em `.windsurf/workflows/`
- Criação, remoção ou alteração de docs em `docs/`
- Alteração na stack tecnológica ou libs internas
- Alteração nas regras obrigatórias ou proibições
- Alteração no `catalogo/services.yaml`

## Passos

1. **Levantar estado atual do workspace** — Listar o conteúdo de cada diretório relevante:

// turbo
   ```bash
   ls .windsurf/skills/
   ls .windsurf/rules/
   ls .windsurf/workflows/
   find docs/ -name '*.md' | sort
   ```

2. **Ler o AGENTS.md atual** — Abrir `AGENTS.md` e identificar as seções que precisam de atualização

3. **Comparar e atualizar cada seção** — Para cada seção do AGENTS.md, verificar se reflete o estado atual:

   - **Visão Geral do Repositório** — Atualizar se a estrutura de diretórios mudou
   - **Stack Tecnológico** — Atualizar se tecnologias foram adicionadas ou removidas
   - **Regras Obrigatórias para Código Java** — Atualizar se regras mudaram nas skill references
   - **Proibições Críticas** — Atualizar se proibições foram adicionadas/removidas nas skill references
   - **Skills Disponíveis** — Listar TODAS as skills em `.windsurf/skills/`, com nome e descrição (extraída do `SKILL.md` de cada uma)
   - **Rules (sempre ativas)** — Listar TODAS as rules em `.windsurf/rules/`, com nome e descrição (extraída do frontmatter)
   - **Workflows** — Listar TODOS os workflows em `.windsurf/workflows/`, com comando e descrição (extraída do frontmatter)
   - **Documentação (`docs/`)** — Atualizar a tabela de mapeamento docs por stack se docs mudaram
   - **Convenções de Contribuição** — Atualizar se convenções mudaram

4. **Validar consistência** — Verificar que:
   - Nenhuma skill listada no AGENTS.md foi removida do diretório
   - Nenhuma skill existente no diretório está ausente do AGENTS.md
   - Nenhuma rule listada no AGENTS.md foi removida
   - Nenhuma rule existente está ausente do AGENTS.md
   - Nenhum workflow listado no AGENTS.md foi removido
   - Nenhum workflow existente está ausente do AGENTS.md
   - Todos os docs referenciados na tabela existem
   - Todas as skill references referenciadas na tabela existem

5. **Verificar idioma** — Todo o conteúdo do AGENTS.md deve estar em **Português (PT-BR)**
   - Sem seções ou termos em inglês (exceto nomes técnicos sem tradução)
   - Usar "Merge Request (MR)" e não "Pull Request (PR)"

6. **Commit** — `docs(workspace): atualizar AGENTS.md para refletir alterações em {área alterada}`
