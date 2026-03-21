# Arquitetura Python — Attus

Guia de arquitetura para projetos Python no ecossistema Attus (`attus-genai`, `attus-ml`).

## Projetos

| Projeto | Domínio | Descrição |
|---------|---------|-----------|
| `attus-genai` | IA Generativa | Modelos de linguagem, RAG, assistentes |
| `attus-ml` | Machine Learning | Modelos preditivos, classificação, scoring |

## Stack

| Camada | Tecnologia |
|--------|------------|
| **Linguagem** | Python 3.11+ |
| **API** | FastAPI |
| **ML/IA** | LangChain, scikit-learn, PyTorch |
| **Banco** | SQLAlchemy + Alembic (migrations) |
| **Mensageria** | Kafka (confluent-kafka) |
| **Testes** | pytest + pytest-bdd |
| **Qualidade** | Ruff (linter), mypy (tipos) |
| **Containerização** | Docker |

## Nomenclatura

Seguir o princípio geral Attus: **Português (PT-BR)** para nomes de negócio.

| Elemento | Convenção | Exemplo |
|----------|-----------|---------|
| Módulo/Pacote | snake_case | `processamento_demanda` |
| Classe | PascalCase | `ProcessadorDemanda`, `ModeloClassificacao` |
| Função/Método | snake_case, verbos no infinitivo | `processar_demanda`, `classificar_documento` |
| Variável | snake_case | `lista_demandas`, `modelo_treinado` |
| Constante | UPPER_SNAKE_CASE | `LIMITE_TOKENS`, `MODELO_PADRAO` |
| Endpoint | kebab-case | `/api/v1/processar-documento` |

### Exceções em Inglês

- Termos técnicos de ML/IA sem tradução: `embeddings`, `tokenizer`, `pipeline`, `prompt`
- Métodos de framework: `fit`, `predict`, `transform`
- Variáveis de configuração: `batch_size`, `learning_rate`

## Estrutura de Projeto

```
{projeto}/
├── src/
│   ├── {modulo}/
│   │   ├── __init__.py
│   │   ├── rotas.py              # Endpoints FastAPI
│   │   ├── servico.py            # Regras de negócio
│   │   ├── repositorio.py        # Acesso a dados
│   │   ├── modelos.py            # Pydantic models (DTOs)
│   │   └── entidades.py          # SQLAlchemy models
│   ├── config/
│   └── main.py
├── tests/
│   └── {modulo}/
│       └── test_servico.py
├── alembic/                      # Migrations
├── pyproject.toml
├── Dockerfile
└── README.md
```

## Testes

Estrutura BDD com pytest:

```python
class TestProcessadorDemanda:
    """Testes do ProcessadorDemanda."""

    class TestDadoDemandaExistente:
        """Dado uma demanda existente no sistema."""

        @pytest.fixture(autouse=True)
        def setup(self, mock_repositorio):
            self.demanda = fabricar_demanda(id=1)
            mock_repositorio.buscar_por_id.return_value = self.demanda

        class TestQuandoClassificar:
            """Quando classificar a demanda."""

            @pytest.fixture(autouse=True)
            def executar(self, servico):
                self.resultado = servico.classificar(id=1)

            def test_entao_deve_retornar_classificacao(self):
                assert self.resultado is not None
                assert self.resultado.categoria == "tributaria"
```

## Proibições

- **NÃO** usar `print()` — usar `logging`
- **NÃO** hardcodear credenciais — usar variáveis de ambiente
- **NÃO** ignorar tipos — usar type hints em todas as funções
- **NÃO** usar `Any` como tipo — definir modelos Pydantic
- **NÃO** commitar notebooks (.ipynb) com output — limpar antes

## A Fazer

> Este documento é um esqueleto inicial. Deve ser expandido conforme os projetos Python evoluem.
> Contribuições via Merge Request no GitLab.
