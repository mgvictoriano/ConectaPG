# Arquitetura Attus

Visão geral da arquitetura de microsserviços da plataforma Attus.

## Visão Geral

A Attus é uma plataforma de serviços financeiros construída sobre uma arquitetura de **microsserviços desacoplados**. Cada serviço é responsável por um domínio de negócio específico e se comunica com outros serviços via **Feign Client** (síncrono) ou **Kafka** (assíncrono).

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   frontng   │────▶│   Gateway   │────▶│  Security   │
│  (Angular)  │     │             │     │ (OAuth2/JWT)│
└─────────────┘     └──────┬──────┘     └─────────────┘
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
        ┌──────────┐ ┌──────────┐ ┌──────────┐
        │  Pessoa  │ │ Demanda  │ │ Processo │  ... (30+ serviços)
        └────┬─────┘ └────┬─────┘ └────┬─────┘
             │            │            │
             ▼            ▼            ▼
        ┌──────────────────────────────────┐
        │         Kafka (Eventos)          │
        └──────────────────────────────────┘
```

## Princípios

1. **Domínio isolado** — cada microsserviço é dono de suas entidades e banco de dados
2. **Comunicação via contrato** — Feign Clients definem interfaces explícitas entre serviços
3. **Eventos como fatos** — Kafka transporta eventos no passado (`alterou`, `criou`), nunca comandos
4. **Segurança centralizada** — OAuth2/JWT via `lib-security`, token propagado entre serviços
5. **Libs compartilhadas** — funcionalidades transversais em bibliotecas (`lib-core`, `lib-database`, etc.)

## Stack

| Camada | Tecnologia | Observação |
|--------|------------|------------|
| Frontend | Angular 17+ | Projeto `frontng`, standalone components |
| Backend | Java 25 + Spring Boot 4 | Legados em Java 17 + Spring Boot 2.4 |
| IA/ML | Python 3.11+ | Projetos `attus-genai`, `attus-ml` |
| Build | Gradle | Legados em Maven |
| Banco | PostgreSQL via JPA/Hibernate | Migrations via Flyway |
| Cache | Memória (L1) + Redis (L2) | Via `lib-cache` |
| Mensageria | Kafka | Eventos assíncronos entre serviços |
| Eventos internos | Spring Events | Comunicação intra-serviço |
| Segurança | Spring Security + OAuth2/JWT | Via `lib-security` |
| Deploy | Kubernetes | Helm charts, HPA |

## Microsserviços

Consultar `catalogo/services.yaml` para a lista completa. Principais domínios:

| Serviço | Domínio |
|---------|---------|
| `pessoa` | Cadastro de pessoas (física/jurídica) |
| `demanda` | Gestão de demandas judiciais |
| `processo` | Acompanhamento processual |
| `cobranca` | Réguas e ações de cobrança |
| `documento` | Gestão documental |
| `calculo` | Cálculos financeiros |
| `comunicacao` | Notificações e comunicações |
| `security` | Autenticação e autorização |
| `admin` | Administração e configurações |
| `auditoria` | Trilha de auditoria |
| `frontng` | Frontend Angular |
| `attus-genai` | IA Generativa |
| `attus-ml` | Machine Learning |

## Documentação por Stack

| Stack | Docs | Skill |
|-------|------|-------|
| **Java** | [`docs/arquitetura/java/`](java/) | `arquiteto-java` |
| **Angular** | [`docs/arquitetura/angular/`](angular/) | `arquiteto-angular` |
| **Python** | [`docs/arquitetura/python/`](python/) | `arquiteto-python` |

### Java (`docs/arquitetura/java/`)

| Doc | Conteúdo |
|-----|----------|
| [`padroes-arquitetura.md`](java/padroes-arquitetura.md) | Camadas, Clean Code, estrutura de pacotes |
| [`nomenclatura.md`](java/nomenclatura.md) | Nomes de classes, métodos, variáveis em PT-BR |
| [`testes.md`](java/testes.md) | BDD com JUnit 5, classes base, MockFactory, WireMock |
| [`eventos.md`](java/eventos.md) | Spring Events, Kafka, DLQ, escalabilidade |
| [`seguranca.md`](java/seguranca.md) | OAuth2/JWT via lib-security |

### Angular (`docs/arquitetura/angular/`)

| Doc | Conteúdo |
|-----|----------|
| [`nomenclatura.md`](angular/nomenclatura.md) | Nomes de arquivos, classes, métodos, signals |
| [`testes.md`](angular/testes.md) | BDD com Jest, templates de Service e Component |

### Python (`docs/arquitetura/python/`)

| Doc | Conteúdo |
|-----|----------|
| [`README.md`](python/README.md) | Stack, estrutura, nomenclatura, testes |
