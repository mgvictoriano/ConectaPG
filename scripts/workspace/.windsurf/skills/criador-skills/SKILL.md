---
name: criador-skills
description: Guia para criação efetiva de skills. Esta skill deve ser usada quando usuários querem criar uma nova skill (ou atualizar uma existente) que estenda as capacidades do Agente com conhecimento especializado, workflows ou integrações de ferramentas.
---

# Criador de Skills

Esta skill fornece orientação para criar skills efetivas.

## Sobre Skills

Skills são pacotes modulares e autocontidos que estendem as capacidades do Agente fornecendo conhecimento especializado, workflows e ferramentas. Pense nelas como "guias de integração" para domínios ou tarefas específicas — elas transformam o Agente de um agente de propósito geral em um agente especializado equipado com conhecimento procedural que nenhum modelo pode possuir completamente.

### O que Skills Fornecem

1. Workflows especializados - Procedimentos de múltiplos passos para domínios específicos
2. Integrações de ferramentas - Instruções para trabalhar com formatos específicos de arquivos ou APIs
3. Expertise de domínio - Conhecimento específico da empresa, schemas, lógica de negócio
4. Recursos empacotados - Scripts, referências e ativos para tarefas complexas e repetitivas

## Princípios Core

### Conciso é Fundamental

A janela de contexto é um bem público. Skills compartilham a janela de contexto com tudo o que o Agente precisa: prompt do sistema, histórico da conversa, metadados de outras Skills e a requisição atual do usuário.

**Premissa padrão: Agente já é muito inteligente.** Adicione apenas contexto que o Agente não possui. Desafie cada informação: "O Agente realmente precisa desta explicação?" e "Este parágrafo justifica seu custo em tokens?"

Prefira exemplos concisos em vez de explicações verbose.

### Definir Graus de Liberdade Apropriados

Combine o nível de especificidade com a fragilidade e variabilidade da tarefa:

**Alta liberdade (instruções textuais)**: Use quando múltiplas abordagens são válidas, decisões dependem de contexto ou heurísticas guiam a abordagem.

**Liberdade média (pseudocódigo ou scripts com parâmetros)**: Use quando um padrão preferido existe, alguma variação é aceitável ou configuração afeta o comportamento.

**Baixa liberdade (scripts específicos, poucos parâmetros)**: Use quando operações são frágeis e propensas a erros, consistência é crítica ou uma sequência específica deve ser seguida.

Pense no Agente como explorando um caminho: uma ponte estreita com penhascos precisa de guardrails específicos (baixa liberdade), enquanto um campo aberto permite muitas rotas (alta liberdade).

### Anatomia de uma Skill

Toda skill consiste em um arquivo SKILL.md obrigatório e recursos empacotados opcionais:

```
nome-da-skill/
├── SKILL.md (obrigatório)
│   ├── Metadados frontmatter YAML (obrigatório)
│   │   ├── name: (obrigatório)
│   │   ├── description: (obrigatório)
│   │   └── compatibility: (opcional, raramente necessário)
│   └── Instruções Markdown (obrigatório)
└── Recursos Empacotados (opcional)
    ├── scripts/          - Código executável (Python/Bash/etc.)
    ├── references/       - Documentação destinada a ser carregada no contexto conforme necessário
    └── assets/           - Arquivos usados na saída (templates, ícones, fontes, etc.)
```

#### SKILL.md (obrigatório)

Todo SKILL.md consiste em:

- **Frontmatter** (YAML): Contém campos `name` e `description` (obrigatórios), mais campos opcionais como `license`, `metadata` e `compatibility`. Apenas `name` e `description` são lidos pelo Agente para determinar quando a skill é acionada, então seja claro e abrangente sobre o que a skill é e quando deve ser usada. O campo `compatibility` é para anotar requisitos de ambiente (produto alvo, pacotes do sistema, etc.) mas a maioria das skills não precisa disso.
- **Corpo** (Markdown): Instruções e orientações para usar a skill. Carregado APENAS DEPOIS que a skill é acionada (se for).

#### Recursos Empacotados (opcional)

##### Scripts (`scripts/`)

Código executável (Python/Bash/etc.) para tarefas que requerem confiabilidade determinística ou são reescritas repetidamente.

- **Quando incluir**: Quando o mesmo código está sendo reescrito repetidamente ou confiabilidade determinística é necessária
- **Exemplo**: `scripts/rotate_pdf.py` para tarefas de rotação de PDF
- **Benefícios**: Eficiente em tokens, determinístico, pode ser executado sem carregar no contexto
- **Nota**: Scripts ainda podem precisar ser lidos pelo Agente para patches ou ajustes específicos de ambiente

##### References (`references/`)

Documentação e material de referência destinado a ser carregado conforme necessário no contexto para informar o processo e o pensamento do Agente.

- **Quando incluir**: Para documentação que o Agente deve referenciar enquanto trabalha
- **Exemplos**: `references/finance.md` para schemas financeiros, `references/mnda.md` para template de NDA da empresa, `references/policies.md` para políticas da empresa, `references/api_docs.md` para especificações de API
- **Casos de uso**: Schemas de banco de dados, documentação de API, conhecimento de domínio, políticas da empresa, guias detalhados de workflow
- **Benefícios**: Mantém SKILL.md enxuto, carregado apenas quando o Agente determina que é necessário
- **Melhor prática**: Se arquivos são grandes (>10k palavras), inclua padrões de busca grep em SKILL.md
- **Evite duplicação**: Informação deve viver em SKILL.md ou arquivos de referência, não ambos. Prefira arquivos de referência para informação detalhada a menos que seja realmente core da skill — isso mantém SKILL.md enxuto enquanto torna a informação descobrível sem consumir a janela de contexto. Mantenha apenas instruções procedurais essenciais e orientação de workflow em SKILL.md; mova material de referência detalhado, schemas e exemplos para arquivos de referência.

##### Assets (`assets/`)

Arquivos não destinados a ser carregados no contexto, mas usados na saída que o Agente produz.

- **Quando incluir**: Quando a skill precisa de arquivos que serão usados na saída final
- **Exemplos**: `assets/logo.png` para ativos de marca, `assets/slides.pptx` para templates PowerPoint, `assets/frontend-template/` para boilerplate HTML/React, `assets/font.ttf` para tipografia
- **Casos de uso**: Templates, imagens, ícones, código boilerplate, fontes, documentos de amostra que são copiados ou modificados
- **Benefícios**: Separa recursos de saída da documentação, permite que o Agente use arquivos sem carregá-los no contexto

#### O que NÃO Incluir em uma Skill

Uma skill deve conter apenas arquivos essenciais que suportam diretamente sua funcionalidade. NÃO crie documentação extraneea ou arquivos auxiliares, incluindo:

- README.md
- INSTALLATION_GUIDE.md
- QUICK_REFERENCE.md
- CHANGELOG.md
- etc.

A skill deve conter apenas a informação necessária para um agente de IA fazer o trabalho. Não deve conter contexto auxiliar sobre o processo que foi feito para criá-la, procedimentos de setup e teste, documentação voltada ao usuário, etc. Criar documentação adicional apenas adiciona desordem e confusão.

### Princípio de Divulgação Progressiva

Skills usam um sistema de carregamento de três níveis para gerenciar contexto eficientemente:

1. **Metadados (name + description)** - Sempre no contexto (~100 palavras)
2. **Corpo SKILL.md** - Quando a skill é acionada (<5k palavras)
3. **Recursos empacotados** - Conforme necessário pelo Agente (Ilimitado porque scripts podem ser executados sem ler na janela de contexto)

#### Padrões de Divulgação Progressiva

Mantenha o corpo de SKILL.md nos essenciais e abaixo de 500 linhas para minimizar inchaço de contexto. Divida conteúdo em arquivos separados quando se aproximar deste limite. Ao dividir conteúdo em outros arquivos, é muito importante referenciá-los de SKILL.md e descrever claramente quando lê-los, para garantir que o leitor da skill saiba que eles existem e quando usar.

**Princípio chave:** Quando uma skill suporta múltiplas variações, frameworks ou opções, mantenha apenas o workflow core e orientação de seleção em SKILL.md. Mova detalhes específicos de variante (padrões, exemplos, configuração) para arquivos de referência separados.

**Padrão 1: Guia de alto nível com referências**

```markdown
# Processamento de PDF

## Início rápido

Extraia texto com pdfplumber:
[exemplo de código]

## Recursos avançados

- **Preenchimento de formulários**: Veja [FORMS.md](FORMS.md) para guia completo
- **Referência de API**: Veja [REFERENCE.md](REFERENCE.md) para todos os métodos
- **Exemplos**: Veja [EXAMPLES.md](EXAMPLES.md) para padrões comuns
```

Agente carrega FORMS.md, REFERENCE.md ou EXAMPLES.md apenas quando necessário.

**Padrão 2: Organização por domínio**

Para Skills com múltiplos domínios, organize conteúdo por domínio para evitar carregar contexto irrelevante:

```
bigquery-skill/
├── SKILL.md (visão geral e navegação)
└── reference/
    ├── finance.md (receita, métricas de faturamento)
    ├── sales.md (oportunidades, pipeline)
    ├── product.md (uso de API, features)
    └── marketing.md (campanhas, atribuição)
```

Quando um usuário pergunta sobre métricas de vendas, Agente lê apenas sales.md.

Similarmente, para skills suportando múltiplos frameworks ou variantes, organize por variante:

```
cloud-deploy/
├── SKILL.md (workflow + seleção de provider)
└── references/
    ├── aws.md (padrões de deploy AWS)
    ├── gcp.md (padrões de deploy GCP)
    └── azure.md (padrões de deploy Azure)
```

Quando o usuário escolhe AWS, Agente lê apenas aws.md.

**Padrão 3: Detalhes condicionais**

Mostre conteúdo básico, link para conteúdo avançado:

```markdown
# Processamento de DOCX

## Criando documentos

Use docx-js para novos documentos. Veja [DOCX-JS.md](DOCX-JS.md).

## Editando documentos

Para edições simples, modifique o XML diretamente.

**Para tracked changes**: Veja [REDLINING.md](REDLINING.md)
**Para detalhes OOXML**: Veja [OOXML.md](OOXML.md)
```

Agente lê REDLINING.md ou OOXML.md apenas quando o usuário precisa daquelas features.

**Diretrizes importantes:**

- **Evite referências profundamente aninhadas** - Mantenha referências a um nível de profundidade de SKILL.md. Todos os arquivos de referência devem linkar diretamente de SKILL.md.
- **Estruture arquivos de referência longos** - Para arquivos com mais de 100 linhas, inclua um sumário no topo para que Agente possa ver o escopo completo ao visualizar.

## Processo de Criação de Skills

A criação de skills envolve estes passos:

1. Entender a skill com exemplos concretos
2. Planejar conteúdos reutilizáveis da skill (scripts, referências, assets)
3. Inicializar a skill (rodar init_skill.py)
4. Editar a skill (implementar recursos e escrever SKILL.md)
5. Empacotar a skill (rodar package_skill.py)
6. Iterar baseado em uso real

Siga estes passos em ordem, pulando apenas se houver razão clara de por que não são aplicáveis.

### Passo 1: Entender a Skill com Exemplos Concretos

Pule este passo apenas quando os padrões de uso da skill já estão claramente entendidos. Ele permanece valioso mesmo quando trabalhando com uma skill existente.

Para criar uma skill efetiva, entenda claramente exemplos concretos de como a skill será usada. Este entendimento pode vir de exemplos do usuário diretamente ou exemplos gerados que são validados com feedback do usuário.

Por exemplo, ao construir uma skill image-editor, perguntas relevantes incluem:

- "Que funcionalidade a skill image-editor deve suportar? Edição, rotação, mais alguma coisa?"
- "Pode dar alguns exemplos de como esta skill seria usada?"
- "Posso imaginar usuários pedindo coisas como 'Remova o red-eye desta imagem' ou 'Gire esta imagem'. Há outras formas que você imagina esta skill sendo usada?"
- "O que um usuário diria que deveria acionar esta skill?"

Para não sobrecarregar usuários, evite fazer muitas perguntas em uma única mensagem. Comece com as perguntas mais importantes e faça follow up conforme necessário para melhor efetividade.

Conclua este passo quando houver clareza da funcionalidade que a skill deve suportar.

### Passo 2: Planejar os Conteúdos Reutilizáveis da Skill

Para transformar exemplos concretos em uma skill efetiva, analise cada exemplo:

1. Considere como executar o exemplo do zero
2. Identifique que scripts, referências e assets seriam úteis ao executar estes workflows repetidamente

Exemplo: Ao construir uma skill `pdf-editor` para lidar com queries como "Me ajude a rotacionar este PDF", a análise mostra:

1. Rotacionar um PDF requer reescrever o mesmo código cada vez
2. Um script `scripts/rotate_pdf.py` seria útil de armazenar na skill

Exemplo: Ao desenhar uma skill `frontend-webapp-builder` para queries como "Crie um app de tarefas" ou "Crie um dashboard para rastrear meus passos", a análise mostra:

1. Escrever um frontend webapp requer o mesmo boilerplate HTML/React cada vez
2. Um template `assets/hello-world/` contendo os arquivos boilerplate do projeto HTML/React seria útil de armazenar na skill

Exemplo: Ao construir uma skill `big-query` para lidar com queries como "Quantos usuários fizeram login hoje?", a análise mostra:

1. Querying BigQuery requer redescobrir os schemas e relações de tabelas cada vez
2. Um arquivo `references/schema.md` documentando os schemas de tabelas seria útil de armazenar na skill

Para estabelecer os conteúdos da skill, analise cada exemplo concreto para criar uma lista dos recursos reutilizáveis a incluir: scripts, referências e assets.

### Passo 3: Inicializar a Skill

Neste ponto, é hora de criar a skill de fato.

Pule este passo apenas se a skill sendo desenvolvida já existe, e iteração ou empacotamento é necessário. Neste caso, continue para o próximo passo.

Ao criar uma nova skill do zero, sempre rode o script `init_skill.py`. O script gera convenientemente um novo diretório template de skill que automaticamente inclui tudo que uma skill requer, tornando o processo de criação de skill muito mais eficiente e confiável.

Uso:

```bash
scripts/init_skill.py <nome-da-skill> --path <diretório-saída>
```

O script:

- Cria o diretório da skill no caminho especificado
- Gera um template SKILL.md com frontmatter apropriado e placeholders TODO
- Cria diretórios de recursos de exemplo: `scripts/`, `references/` e `assets/`
- Adiciona arquivos de exemplo em cada diretório que podem ser customizados ou deletados

Após inicialização, customize ou remova o SKILL.md gerado e os arquivos de exemplo conforme necessário.

### Passo 4: Editar a Skill

Ao editar a skill (recém-gerada ou existente), lembre-se que a skill está sendo criada para outra instância do Agente usar. Inclua informação que seria benéfica e não-óbvia para o Agente. Considere que conhecimento procedural, detalhes específicos de domínio ou ativos reutilizáveis ajudariam outra instância do Agente a executar estas tarefas mais efetivamente.

#### Aprender Padrões de Design Comprovados

Consulte estes guias úteis baseado nas necessidades da sua skill:

- **Processos de múltiplos passos**: Veja references/workflows.md para workflows sequenciais e lógica condicional
- **Formatos específicos de saída ou padrões de qualidade**: Veja references/padroes-saida.md para padrões de template e exemplos

Estes arquivos contêm práticas comprovadas para design efetivo de skills.

#### Começar com Conteúdos Reutilizáveis da Skill

Para começar a implementação, comece com os recursos reutilizáveis identificados acima: arquivos `scripts/`, `references/` e `assets/`. Note que este passo pode requerer input do usuário. Por exemplo, ao implementar uma skill `brand-guidelines`, o usuário pode precisar fornecer ativos de marca ou templates para armazenar em `assets/`, ou documentação para armazenar em `references/`.

Scripts adicionados devem ser testados rodando-os de fato para garantir que não há bugs e que a saída corresponde ao esperado. Se houver muitos scripts similares, apenas uma amostra representativa precisa ser testada para garantir confiança de que todos funcionam enquanto balanceia tempo de conclusão.

Quaisquer arquivos e diretórios de exemplo não necessários para a skill devem ser deletados. O script de inicialização cria arquivos de exemplo em `scripts/`, `references/` e `assets/` para demonstrar estrutura, mas a maioria das skills não precisará de todos eles.

#### Atualizar SKILL.md

**Diretrizes de Escrita:** Sempre use forma imperativa/infinitiva.

##### Frontmatter

Escreva o frontmatter YAML com `name` e `description`:

- `name`: O nome da skill em Português-PT-BR
- `description`: Este é o mecanismo primário de acionamento da sua skill, e ajuda o Agente a entender quando usar a skill.
  - Inclua tanto o que a Skill faz quanto gatilhos/contextos específicos para quando usá-la.
  - Inclua toda informação de "quando usar" aqui — Não no corpo. O corpo é apenas carregado após acionamento, então seções "Quando Usar Esta Skill" no corpo não são úteis para o Agente.
  - Exemplo de description para uma skill `docx`: "Criação, edição e análise abrangente de documentos com suporte para tracked changes, comentários, preservação de formatação e extração de texto. Use quando Agente precisar trabalhar com documentos profissionais (arquivos .docx) para: (1) Criar novos documentos, (2) Modificar ou editar conteúdo, (3) Trabalhar com tracked changes, (4) Adicionar comentários, ou qualquer outra tarefa de documento"

Não inclua outros campos no frontmatter YAML.

##### Corpo

Escreva instruções para usar a skill e seus recursos empacotados.

### Passo 5: Empacotar uma Skill

Uma vez que o desenvolvimento da skill está completo, ela deve ser empacotada em um arquivo .skill distribuível que é compartilhado com o usuário. O processo de empacotamento valida automaticamente a skill primeiro para garantir que atende todos os requisitos:

```bash
scripts/package_skill.py <caminho/para/pasta-da-skill>
```

Especificação opcional de diretório de saída:

```bash
scripts/package_skill.py <caminho/para/pasta-da-skill> ./dist
```

O script de empacotamento vai:

1. **Validar** a skill automaticamente, verificando:

   - Formato de frontmatter YAML e campos obrigatórios
   - Convenções de nomenclatura de skill e estrutura de diretório
   - Completude e qualidade da description
   - Organização de arquivos e referências de recursos

2. **Empacotar** a skill se a validação passar, criando um arquivo .skill nomeado após a skill (ex: `minha-skill.skill`) que inclui todos os arquivos e mantém a estrutura de diretório apropriada para distribuição. O arquivo .skill é um arquivo zip com extensão .skill.

Se a validação falhar, o script reportará os erros e sairá sem criar o pacote. Corrija quaisquer erros de validação e rode o comando de empacotamento novamente.

### Passo 6: Iterar

Após testar a skill, usuários podem solicitar melhorias. Frequentemente isso acontece logo após usar a skill, com contexto fresco de como a skill performou.

**Workflow de iteração:**

1. Use a skill em tarefas reais
2. Perceba dificuldades ou ineficiências
3. Identifique como SKILL.md ou recursos empacotados devem ser atualizados
4. Implemente mudanças e teste novamente
