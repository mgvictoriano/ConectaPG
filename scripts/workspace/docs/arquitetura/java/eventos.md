# Event Driven Architecture Attus

Guia de arquitetura orientada a eventos no ecossistema Attus (Spring Events e Kafka).

## Visão Geral

O sistema adota arquitetura híbrida de eventos para desacoplamento:

| Tipo | Tecnologia | Uso | Sincronicidade |
|------|------------|-----|----------------|
| **Interno** | Spring Events | Dentro do mesmo microsserviço | Síncrono/Assíncrono |
| **Externo** | Apache Kafka | Entre microsserviços | Assíncrono |

---

## Eventos Internos (Spring Events)

Utilizar `ApplicationEventPublisher` e `@EventListener` para desacoplar lógica dentro do mesmo microsserviço.

### Casos de Uso

- Auditoria de operações
- Logs de domínio
- Triggers de processamento local
- Notificações internas
- Cache invalidation

### Estrutura

#### 1. Evento (Record ou Classe)

```java
public record UsuarioCriadoEvent(
    Long usuarioId,
    String email,
    LocalDateTime dataCriacao
) {}
```

#### 2. Publicação do Evento

```java
@Service
public class UsuarioServiceImpl implements UsuarioService {

    private final UsuarioRepository usuarioRepository;
    private final ApplicationEventPublisher eventPublisher;

    public UsuarioServiceImpl(UsuarioRepository usuarioRepository, ApplicationEventPublisher eventPublisher) {
        this.usuarioRepository = usuarioRepository;
        this.eventPublisher = eventPublisher;
    }

    @Override
    @Transactional
    public Usuario salvar(Usuario usuario) {
        Usuario salvo = usuarioRepository.save(usuario);
        
        // Publicar evento
        eventPublisher.publishEvent(new UsuarioCriadoEvent(
            salvo.getId(),
            salvo.getEmail(),
            LocalDateTime.now()
        ));
        
        return salvo;
    }
}
```

#### 3. Listener

```java
@Component
@Slf4j
public class UsuarioEventListener {

    private final AuditoriaService auditoriaService;
    private final EmailService emailService;

    public UsuarioEventListener(AuditoriaService auditoriaService, EmailService emailService) {
        this.auditoriaService = auditoriaService;
        this.emailService = emailService;
    }

    @EventListener
    public void handleUsuarioCriado(UsuarioCriadoEvent event) {
        log.info("Usuário criado: id={}, email={}", event.usuarioId(), event.email());
        auditoriaService.registrarCriacao(event);
    }

    @EventListener
    @Async  // Processamento assíncrono
    public void enviarEmailBoasVindas(UsuarioCriadoEvent event) {
        emailService.enviarBoasVindas(event.email());
    }
}
```

### Configuração Assíncrona

```java
@Configuration
@EnableAsync
public class AsyncConfig {

    @Bean(name = "eventAsyncExecutor")
    public Executor eventAsyncExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(5);
        executor.setMaxPoolSize(10);
        executor.setQueueCapacity(100);
        executor.setThreadNamePrefix("event-");
        executor.initialize();
        return executor;
    }
}
```

### Listener com Executor Específico

```java
@EventListener
@Async("eventAsyncExecutor")
public void processarEvento(UsuarioCriadoEvent event) {
    // Processamento assíncrono com executor customizado
}
```

---

## Eventos Externos (Apache Kafka)

Utilizar Kafka para comunicação assíncrona entre microsserviços.

### Princípios Fundamentais

- **Semântica de Fato (Evento)**: o evento descreve algo que **já aconteceu** (passado imutável). Não é uma solicitação para o consumidor fazer algo.
- **Produtor "Ignorante"**: quem publica não sabe quem consome. Novos serviços podem consumir eventos existentes sem impactar o ecossistema (Plug & Play).
- **Regras de Negócio no Consumer**: o produtor não decide o fluxo. As regras ficam nos microsserviços que consomem.
- **Idempotência**: o mesmo evento pode ser processado múltiplas vezes sem causar inconsistências (At-Least-Once). Usar chaves de negócio únicas para deduplicação.
- **Payloads Enxutos**: enviar dados, não regras. Backward Compatibility via campos opcionais.

### Nomenclatura de Tópicos

**Padrão adotado:**
```
nome_microservico.acao.recurso.versao
```

- **Verbos sempre no passado** (ex: `alterou`, `criou`, `excluiu`, `publicou`)
- **Versão numérica** ao final (ex: `.0`)

**Exemplos reais:**
```
requisitorio.alterou.indexadores.0
documento.publicou.documentos.0
demanda.excluiu.manifestacoes.0
security.alterou.usuario.username.0
```

**Antipadrões (NÃO usar):**
```
✘ agendador.cmd.cadastrar.andamento_demanda.0    ← Comando RPC (acoplamento)
✘ demanda.cmd.criar-historico-andamento.0         ← Produtor dita a ação
✘ usuario.criado.v1                                ← Fora do padrão de nomenclatura
```

> **Por que evitar comandos?** O produtor dita a ação ("Faça isso"), impede que outros serviços reajam ao mesmo fato, e cria dependência direta entre times.

### Estrutura

#### 1. Constantes de Tópicos (KafkaConfig)

Definir constantes de tópicos em uma classe de configuração:

```java
@Configuration
public class KafkaConfig {

    public static final String TOPICO_SECURITY_ALTEROU_USERNAME = "security.alterou.usuario.username.0";
    public static final String TOPICO_AUDITORIA_INCLUIU = "auditoria.incluiu.auditoria.0";
}
```

#### 2. Producer (MessageService)

```java
@Component
public class MessageService {

    private final KafkaTemplate<String, Object> kafkaTemplate;

    @Autowired
    public MessageService(KafkaTemplate<String, Object> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    public void incluiuAuditoria(EventoAuditoriaDto eventoAuditoriaDto) {
        kafkaTemplate.send(KafkaConfig.TOPICO_AUDITORIA_INCLUIU, eventoAuditoriaDto);
    }
}
```

#### 3. Consumer

**Consumer enxuto**: repassa imediatamente para Service (classe de negócio). Facilita testes unitários.

```java
@Component
@Slf4j
public class AuditoriaConsumer {

    private final AuditoriaService auditoriaService;
    private final AuditoriaFactory auditoriaFactory;
    private final MessageService messageService;

    @Autowired
    public AuditoriaConsumer(AuditoriaService auditoriaService,
                             AuditoriaFactory auditoriaFactory,
                             MessageService messageService) {
        this.auditoriaService = auditoriaService;
        this.auditoriaFactory = auditoriaFactory;
        this.messageService = messageService;
    }

    @KafkaListener(topics = {KafkaConfig.TOPICO_AUDITORIA})
    public void salvarAuditoria(EventoAuditoriaDto eventoAuditoria) {
        Auditoria auditoria = auditoriaFactory.fabricar(eventoAuditoria);

        if (auditoria.hasAlteracoes()) {
            auditoriaService.incluirAuditoria(auditoria);
        }
    }
}
```

**Regras do Consumer:**
- **SEM try-catch genérico**: deixar o container Kafka gerenciar erros para ativar retries e DLQ automaticamente. Blocos try-catch que apenas relancam a exceção são redundantes.
- **Delegar para Service**: o consumer não contém regras de negócio, apenas orquestra a chamada.
- **Responsabilidade única**: cada consumer faz uma coisa. Se precisar processar o mesmo evento de formas diferentes, usar Consumer Groups com `groupId` distintos.

#### 4. Consumer Groups (groupId distintos)

Para processar o **mesmo evento** de formas diferentes e paralelas, usar `groupId` distintos:

```java
// Consumer 1: Criar demanda
@KafkaListener(
    topics = {KafkaConfig.TOPICO_MOTOR_BPMN_CRIOU_TAREFA},
    groupId = "demanda-criar-demanda"
)
public void criarDemanda(String tarefaId) {
    demandaService.criarDemanda(tarefaId);
}

// Consumer 2: Gerar manifestações automáticas (mesmo tópico, grupo diferente)
@KafkaListener(
    topics = {KafkaConfig.TOPICO_MOTOR_BPMN_CRIOU_TAREFA},
    groupId = "demanda-manifestacao-automatica"
)
public void gerarManifestacoesAutomaticas(String tarefaId) {
    automatizacaoDocumentoComponent.gerarManifestacoesAutomaticas(tarefaId);
}
```

> **Nota:** Grupos diferentes não interferem entre si. Cada grupo recebe todas as mensagens do tópico independentemente.

### Configuração por Tópico (ConsumerProperties)

Configuração granular por tópico via `application.yml`:

```yaml
attornatus:
  kafka:
    consumers:
      - topico: security.alterou.usuario.username.0
        concurrency: 1
        max-poll-records: 1
        shutdown-timeout: 10s
```

| Propriedade | Descrição |
|-------------|----------|
| `topico` | Identificador do tópico de eventos de domínio |
| `concurrency` | Número de threads consumidoras na instância. **Manter em 1** para escala horizontal via HPA |
| `max-poll-records` | Batch size. Usar **1** para processamentos pesados/críticos |
| `shutdown-timeout` | Tempo de espera para concluir tarefas antes do Pod desligar (graceful shutdown) |

### Dead Letter Queue (DLQ) + BackOff

Estratégias de retry configuradas por tipo de exceção:

```yaml
backoff:
  configs:
    # Estratégia Exponencial (erros transitórios)
    - tipo: "EXPONENCIAL"
      espera-inicial-segundos: 2
      multiplicador-retentativas: 2.0
      quantidade-retentativas: 5
      exceptions:
        - "java.net.SocketTimeoutException"
        - "org.springframework.dao.TransientDataAccessException"

    # Horário Fixo (lote noturno)
    - tipo: "HORARIO_FIXO"
      hora: 22
      quantidade-retentativas: 3
      exceptions:
        - "ai.attus.lib.core.domain.exception.BusinessRuleException"

    # Fixo Simples
    - tipo: "FIXO"
      espera-inicial-segundos: 60
      quantidade-retentativas: 3
      exceptions:
        - "java.io.IOException"

    # Erros Fatais (sem retry)
    - tipo: "NENHUM"
      exceptions:
        - "java.lang.IllegalArgumentException"
```

**Tipos de BackOff:**
- **EXPONENCIAL**: `t + (N^mult * delay)` — para erros transitórios
- **FIXO**: `t + (N * delay)` — retry linear
- **HORARIO_FIXO**: próxima execução em horário específico (ex: 22h)
- **NENHUM**: erro fatal, sem retry

**Fluxo DLQ:**
1. Consumer falha → mensagem vai para DLQ com `proxExec` calculada
2. Agendador busca na DLQ onde `proxExec <= NOW`
3. Se `isExpirado()` (tentativas > max), arquiva
4. Admin pode reprocessar manualmente enviando de volta ao Consumer

### Escalabilidade: Horizontal vs Vertical

**Regra de ouro: `concurrency = 1`** — escalar por Pods, não por threads.

| Cenário | Resultado |
|---------|----------|
| **Pods = Partições** | ⭐ Ideal (recomendado) |
| **Pods > Partições** | ⚠️ Desperdício — Pods excedentes ficam ociosos |
| **Pods < Partições** | ⚠️ Gargalo — Pod assume múltiplas partições sequencialmente |

**Antipadrão (escala vertical):**
```yaml
# NÃO FAZER: aumentar concurrency dentro do mesmo Pod
concurrency: 4  # Threads ociosas se > partições, debugging complexo
```

**Recomendado (escala horizontal):**
```yaml
# FAZER: manter concurrency=1 e escalar via HPA (Pods)
concurrency: 1  # 1 thread por Pod, HPA escala linearmente
```

> **Por que horizontal?** Mapeamento 1:1 com partições Kafka, HPA nativo baseado em CPU/RAM, isolamento de falhas (se um Pod falha, apenas uma partição é afetada).

### Performance Tuning

| Propriedade | Default | Impacto |
|-------------|---------|--------|
| `max.poll.records` | 500 | Aumentar melhora throughput, mas consome mais memória e aumenta risco de timeout |
| `max.poll.interval.ms` | 30 min | Se batch demorar mais que isso, consumer é expulso → rebalanceamento |

**Atenção:** Se `max.poll.records=500` e cada msg leva 4s: `500 × 4s = 2000s (33m) > 30m` → Timeout! Para processamento pesado, use `max-poll-records: 1`.

---

## Decisão: Spring Events vs Kafka

| Critério | Spring Events | Kafka |
|----------|---------------|-------|
| Escopo | Mesmo microsserviço | Entre microsserviços |
| Persistência | Em memória | Persistido em disco |
| Resiliência | Perde-se no restart | Retido no broker |
| Escalabilidade | Limitado ao serviço | Horizontal ilimitada |
| Orquestração | Simples | Complexa (Saga) |
| Latência | Baixíssima | Baixa (ms) |
| Complexidade | Baixa | Média/Alta |

### Fluxo de Decisão

```
Mesmo microsserviço?
├── SIM → Spring Events
│   ├── Precisa persistir? → SIM: Salvar estado + Event
│   └── Pode perder? → SIM: Evento simples
│
└── NÃO → Kafka
    ├── Saga/Orquestração? → Configurar tópicos de compensação
    └── Simples notificação? → Tópico único
```

---

## Padrões Comuns

### Saga Pattern (Compensação)

```java
@Component
public class ProcessamentoSaga {

    private final KafkaTemplate<String, Object> kafkaTemplate;

    @Autowired
    public ProcessamentoSaga(KafkaTemplate<String, Object> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    @KafkaListener(topics = "pedido.criou.pedidos.0")
    public void iniciarSaga(PedidoCriadoMessage message) {
        kafkaTemplate.send("estoque.reservou.itens.0", message);
    }

    @KafkaListener(topics = "estoque.reservou.itens.0")
    public void processarPagamento(EstoqueReservadoMessage message) {
        kafkaTemplate.send("pagamento.processou.pagamentos.0", message);
    }

    @KafkaListener(topics = "pagamento.falhou.pagamentos.0")
    public void compensar(PagamentoFalhouMessage message) {
        kafkaTemplate.send("estoque.liberou.itens.0", message);
        kafkaTemplate.send("pedido.cancelou.pedidos.0", message);
    }
}
```

---

## Checklist de Implementação Kafka

Validação de arquitetura e segurança antes do deploy:

### Nomenclatura
- [ ] Padrão: `nome_microservico.acao.recurso.versao`
- [ ] Semântica de fato passado (ex: `alterou`, `criou`, `excluiu`)
- [ ] Evitar comandos (ex: `criar`, `enviar`, `cmd`)

### Design de Eventos
- [ ] Payload enxuto (dados, não regras)
- [ ] Backward Compatibility via novos campos opcionais
- [ ] Chaves definidas para particionamento

### Consumers
- [ ] Consumer enxuto (delega para Service)
- [ ] Sem try-catch genérico (silenciador)
- [ ] Logs estruturados com correlation ID

### Idempotência
- [ ] TTL configurado (ex: 24h)
- [ ] Tratamento de duplicatas (Ack e ignora)

### Dead Letter Queue
- [ ] BackOff configurado (Exponencial, Fixo, Horário Fixo, Nenhum)
- [ ] Exceções fatais vs retentáveis definidas
- [ ] Monitoramento ativo da DLQ

### Configurações
- [ ] `max.poll.records` ajustado ao throughput
- [ ] `max.poll.interval.ms` > tempo de processamento do lote
- [ ] `auto.offset.reset` adequado

### Concurrency
- [ ] `concurrency = 1` (escala horizontal)
- [ ] Nº Pods <= Nº Partições
- [ ] Monitoramento de Consumer Lag
