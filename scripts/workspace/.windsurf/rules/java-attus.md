
---

trigger: always_on
description: Ao gerar, modificar ou revisar código Java neste workspace, SEMPRE invocar a skill arquiteto-java e seguir TODAS as suas regras.

---

# Regras Attus — Aplicação Obrigatória

Ao gerar, modificar ou revisar código Java (produção ou teste) neste workspace, você DEVE:

1. **Invocar a skill `arquiteto-java`** antes de produzir qualquer código
2. **Carregar TODAS as referências** listadas na skill (`docs/arquitetura/java/padroes-arquitetura.md`, `docs/arquitetura/java/nomenclatura.md`, `docs/arquitetura/java/testes.md`, etc.)
3. **Seguir rigorosamente TODAS as regras** da skill — arquitetura, nomenclatura, testes BDD, proibições, clean code e dependências
4. **Executar o passo 7 (Verificação Sonar)** do workflow core da skill antes de finalizar

A skill é a fonte da verdade. Se houver dúvida, consultar `.windsurf/skills/arquiteto-java/SKILL.md` e `docs/arquitetura/java/`.
