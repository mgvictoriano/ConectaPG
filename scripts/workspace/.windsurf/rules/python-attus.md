
---

trigger: always_on
description: Ao gerar, modificar ou revisar código Python neste workspace, SEMPRE invocar a skill arquiteto-python e seguir TODAS as suas regras.

---

# Regras Python Attus — Aplicação Obrigatória

Ao gerar, modificar ou revisar código Python (produção ou teste) neste workspace, você DEVE:

1. **Invocar a skill `arquiteto-python`** antes de produzir qualquer código
2. **Carregar a referência** listada na skill (`docs/arquitetura/python/README.md`)
3. **Seguir rigorosamente TODAS as regras** da skill — arquitetura, nomenclatura, testes BDD, proibições e qualidade

A skill é a fonte da verdade. Se houver dúvida, consultar `.windsurf/skills/arquiteto-python/SKILL.md` e `docs/arquitetura/python/`.
