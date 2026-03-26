# 🌐 ConectaPG

Sistema de reporte e acompanhamento de ocorrências urbanas desenvolvido para facilitar a comunicação entre **cidadãos** e **prefeitura** da cidade de **Praia Grande (SP)**.  
O objetivo é aumentar a **transparência**, a **agilidade na manutenção urbana** e o **engajamento social**, permitindo que qualquer cidadão registre problemas nas vias públicas (como buracos no asfalto), acompanhe o status do atendimento e receba notificações do andamento.

---

## ✨ Funcionalidades (MVP)

| Função | Descrição |
|-------|-----------|
| Registro de ocorrência | Envio de foto + descrição + endereço/geolocalização |
| Consulta de ocorrências | Cidadão acompanha o status em tempo real |
| Painel da prefeitura | Gestor visualiza, filtra e prioriza atendimentos |
| Atualização de status | Prefeitura avança etapas (em análise → execução → resolvido) |
| Notificações | Cidadão recebe alerta quando o status muda |

---


## 🧱 Arquitetura do Sistema

A solução foi modelada utilizando o **Modelo C4** com separação em múltiplos containers:

- **Frontend (React)** — Interface do cidadão e do gestor
- **Backend (Java 17 + Spring Boot 3)** — API REST, regras de negócio e integrações
- **Banco de Dados (PostgreSQL)** — Armazenamento relacional seguro
- **Storage S3/Compatível** — Armazenamento de imagens de forma eficiente
- **Swagger / OpenAPI** — Catálogo e teste da API

> Diagramas completos estão na pasta `/docs`.

---

## 🚀 Status do Desenvolvimento

### ✅ Implementado

- **Módulo de Usuários**
  - CRUD completo com 8 endpoints REST
  - Validações de email único e regras de negócio
  - Criptografia de senhas com BCrypt
  - Filtros por tipo (CIDADAO, GESTOR) e status ativo
  - Testes unitários com cobertura completa
  - Documentação Swagger integrada

- **Módulo de Ocorrências**
  - CRUD completo de ocorrências urbanas
  - Upload e gerenciamento de imagens
  - Sistema de status e priorização
  - Filtros avançados por status, categoria e localização

- **Frontend React**
  - Interface completa e responsiva
  - 5 telas principais (Login, Lista, Criar, Detalhe, Painel)
  - Autenticação com persistência
  - Filtros e busca de ocorrências
  - Dashboard com estatísticas e gráficos
  - Design moderno com TailwindCSS

### 🔄 Em Desenvolvimento

- Sistema de autenticação JWT no backend
- Upload de imagens
- Notificações em tempo real
- Mapa interativo de ocorrências

---

## 📡 Endpoints da API

### Usuários (`/usuarios`)

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/usuarios` | Lista todos os usuários |
| GET | `/usuarios/{id}` | Busca usuário por ID |
| GET | `/usuarios/email/{email}` | Busca usuário por email |
| GET | `/usuarios/tipo/{tipo}` | Busca usuários por tipo (CIDADAO/GESTOR) |
| GET | `/usuarios/ativos` | Lista apenas usuários ativos |
| POST | `/usuarios` | Cria novo usuário |
| PUT | `/usuarios/{id}` | Atualiza usuário existente |
| PATCH | `/usuarios/{id}/ativo` | Ativa/desativa usuário |
| DELETE | `/usuarios/{id}` | Remove usuário |

### Ocorrências (`/ocorrencias`)

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/ocorrencias` | Lista todas as ocorrências |
| GET | `/ocorrencias/{id}` | Busca ocorrência por ID |
| GET | `/ocorrencias/status/{status}` | Filtra por status |
| POST | `/ocorrencias` | Cria nova ocorrência |
| PUT | `/ocorrencias/{id}` | Atualiza ocorrência |
| PATCH | `/ocorrencias/{id}/status` | Atualiza status da ocorrência |
| DELETE | `/ocorrencias/{id}` | Remove ocorrência |

> 📖 Documentação completa disponível em: `http://localhost:8080/swagger-ui.html`

---

## 🛠️ Tecnologias Utilizadas

### Backend
- **Java 17**
- **Spring Boot 3.x**
- **Spring Data JPA** - Persistência de dados
- **Spring Security** - Segurança e autenticação
- **PostgreSQL** - Banco de dados relacional
- **Lombok** - Redução de boilerplate
- **MapStruct** - Mapeamento de DTOs
- **Swagger/OpenAPI** - Documentação da API
- **JUnit 5 + Mockito** - Testes unitários

### Frontend
- **React 18**
- **Vite** - Build tool
- **React Router DOM** - Navegação
- **Axios** - Cliente HTTP
- **React Hook Form** - Formulários
- **Zustand** - Estado global
- **TailwindCSS** - Estilização
- **React Icons** - Ícones
- **date-fns** - Datas

---

## 🚀 Como Executar

### 🐳 Opção 1: Com Docker (Recomendado)

**Pré-requisitos:**
- Docker 20.10+
- Docker Compose 2.0+

**Início rápido:**

```bash
# Inicia tudo (PostgreSQL + Backend)
./start.sh

# Acesse a aplicação
# API: http://localhost:8080/api
# Swagger: http://localhost:8080/api/swagger-ui.html
```

**Comandos úteis:**

```bash
./logs.sh      # Ver logs em tempo real
./stop.sh      # Parar a aplicação
./rebuild.sh   # Rebuild após mudanças no código
```

> 📖 **Guia completo de setup**: Veja [SETUP.md](./SETUP.md) para instruções detalhadas, troubleshooting e mais opções.

### 💻 Opção 2: Desenvolvimento Local (sem Docker)

**Pré-requisitos:**
- Java 17+
- Maven 3.8+
- PostgreSQL 14+

**Passos:**

1. **Configure o banco de dados**:
```bash
createdb conectapg
```

2. **Configure variáveis de ambiente**:
```bash
export DB_USERNAME=postgres
export DB_PASSWORD=sua_senha
```

3. **Execute o projeto**:
```bash
cd backend
./mvnw spring-boot:run
```

4. **Acesse a aplicação**:
```
http://localhost:8080/api/swagger-ui.html
```

### 🧪 Testes

```bash
cd backend
./mvnw test
```

### 🎨 Frontend

**Pré-requisito:** Node.js 18+

```bash
# Instalar dependências
cd frontend
npm install

# Iniciar em modo desenvolvimento
npm run dev

# Acesse: http://localhost:3000
```

> 📖 **Guia completo do frontend**: Veja [FRONTEND_SETUP.md](./FRONTEND_SETUP.md)

**Usuários de teste:**
- Admin: `admin@conectapg.com` / senha: `password`
- Cidadão: `joao@example.com` / senha: `password`

---

## 📂 Estrutura do Repositório

