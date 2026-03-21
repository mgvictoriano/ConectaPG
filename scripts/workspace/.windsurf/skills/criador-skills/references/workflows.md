# Padrões de Workflow

## Workflows Sequenciais

Para tarefas complexas, divida operações em passos claros e sequenciais. Frequentemente é útil dar ao Agente uma visão geral do processo próximo ao início do SKILL.md:

```markdown
Preencher um formulário PDF envolve estes passos:

1. Analisar o formulário (rodar analyze_form.py)
2. Criar mapeamento de campos (editar fields.json)
3. Validar mapeamento (rodar validate_fields.py)
4. Preencher o formulário (rodar fill_form.py)
5. Verificar saída (rodar verify_output.py)
```

## Workflows Condicionais

Para tarefas com lógica de ramificação, guie o Agente através dos pontos de decisão:

```markdown
1. Determine o tipo de modificação:
   **Criando novo conteúdo?** → Siga o "Workflow de criação" abaixo
   **Editando conteúdo existente?** → Siga o "Workflow de edição" abaixo

2. Workflow de criação: [passos]
3. Workflow de edição: [passos]
```
