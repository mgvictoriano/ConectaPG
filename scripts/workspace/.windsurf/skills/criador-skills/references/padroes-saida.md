# Padrões de Saída

Use estes padrões quando skills precisam produzir saída consistente e de alta qualidade.

## Padrão de Template

Forneça templates para formato de saída. Combine o nível de rigidez com suas necessidades.

**Para requisitos estritos (como respostas de API ou formatos de dados):**

```markdown
## Estrutura do relatório

SEMPRE use esta estrutura exata de template:

# [Título da Análise]

## Resumo executivo
[Visão geral em um parágrafo dos principais achados]

## Principais achados
- Achado 1 com dados de suporte
- Achado 2 com dados de suporte
- Achado 3 com dados de suporte

## Recomendações
1. Recomendação acionável específica
2. Recomendação acionável específica
```

**Para orientação flexível (quando adaptação é útil):**

```markdown
## Estrutura do relatório

Aqui está um formato padrão sensato, mas use seu melhor julgamento:

# [Título da Análise]

## Resumo executivo
[Visão geral]

## Principais achados
[Adapte seções baseado no que você descobrir]

## Recomendações
[Adapte ao contexto específico]

Ajuste as seções conforme necessário para o tipo específico de análise.
```

## Padrão de Exemplos

Para skills onde a qualidade da saída depende de ver exemplos, forneça pares de entrada/saída:

```markdown
## Formato de mensagem de commit

Gere mensagens de commit seguindo estes exemplos:

**Exemplo 1:**
Input: Adicionada autenticação de usuário com tokens JWT
Output:
```
feat(auth): implementa autenticação baseada em JWT

Adiciona endpoint de login e middleware de validação de token
```

**Exemplo 2:**
Input: Corrigido bug onde datas exibiam incorretamente em relatórios
Output:
```
fix(reports): corrige formatação de data na conversão de timezone

Use timestamps UTC consistentemente em toda a geração de relatórios
```

Siga este estilo: tipo(escopo): breve descrição, então explicação detalhada.
```

Exemplos ajudam o Agente a entender o estilo desejado e nível de detalhe mais claramente do que descrições sozinhas.
