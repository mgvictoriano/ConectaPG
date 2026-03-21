# Documentação Attus

Visão geral da Attus, arquitetura, domínio de negócio e guias de referência.

## O que é a Attus?

A Attus é uma plataforma de serviços financeiros que utiliza arquitetura de microsserviços para oferecer soluções de crédito e cobrança.

## Stack Tecnológica

| Camada | Tecnologia |
|--------|------------|
| **Backend** | Java 25 + Spring Boot 4 (legados: Java 17 + Spring Boot 2.4) |
| **Frontend** | Angular (projeto `frontng`) |
| **IA/ML** | Python (`attus-genai`, `attus-ml`) |
| **Build** | Gradle (Java 25) / Maven (Java 17 legados) |
| **Segurança** | Spring Security + OAuth2/JWT |
| **Mensageria** | Kafka + Spring Events |
| **Cache** | Memória local (L1) + Redis (L2) |
| **Banco** | JPA/Hibernate, Flyway |
| **Comunicação** | Feign Client |

## Estrutura

```
docs/
├── arquitetura/            # Documentação detalhada por stack (fonte de verdade)
│   ├── README.md           # Visão geral, diagrama, microsserviços, stack
│   ├── java/               # Padrões Java
│   │   ├── padroes-arquitetura.md   # Camadas, Clean Code, pacotes
│   │   ├── nomenclatura.md          # Nomes PT-BR para Java
│   │   ├── testes.md                # BDD com JUnit 5
│   │   ├── eventos.md               # Spring Events, Kafka, DLQ
│   │   └── seguranca.md             # OAuth2/JWT via lib-security
│   ├── angular/            # Padrões Angular
│   │   ├── nomenclatura.md          # Nomes PT-BR para Angular
│   │   └── testes.md                # BDD com Jest
│   └── python/             # Padrões Python
│       └── README.md                # Stack, estrutura, testes
├── onboarding/             # Guia para novos desenvolvedores
│   ├── README.md           # Primeiro dia e fluxo de desenvolvimento
│   └── setup-local.md      # Configuração do ambiente local
└── README.md               # Este arquivo
```

## Por Onde Começar

1. **Novo na Attus?** — Comece pelo [Onboarding](onboarding/README.md)
2. **Entender a arquitetura?** — Leia a [Visão Geral](arquitetura/README.md)
3. **Padrões Java?** — Consulte [docs/arquitetura/java/](arquitetura/java/)
4. **Padrões Angular?** — Consulte [docs/arquitetura/angular/](arquitetura/angular/)
5. **Padrões Python?** — Consulte [docs/arquitetura/python/](arquitetura/python/)
6. **Setup do ambiente?** — Siga o [Setup Local](onboarding/setup-local.md)

## Integração com Skills

Estes docs são a **fonte de verdade** para regras de arquitetura, nomenclatura e testes. As skills em `.windsurf/skills/` referenciam diretamente estes arquivos:

| Stack | Docs | Skill |
|-------|------|-------|
| Java | `docs/arquitetura/java/` | `arquiteto-java` |
| Angular | `docs/arquitetura/angular/` | `arquiteto-angular` |
| Python | `docs/arquitetura/python/` | `arquiteto-python` |
