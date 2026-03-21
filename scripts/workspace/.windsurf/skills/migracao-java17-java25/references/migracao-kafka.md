# Migração de Kafka e Mensageria

## KafkaConfig

### Antes (legado):
```java
@Configuration
public class KafkaConfig {
    public static final String TOPIC_X = "topic.x";

    @Bean
    public KafkaProducer<String, String> kafkaProducer(CustomKafkaProperties props) {
        return new KafkaProducer<>(props.buildProducerProperties());
    }

    @Bean
    public KafkaTransactionManager<String, String> kafkaTransactionManager(...) { ... }

    @Bean
    public ConsumerFactory<String, String> consumerFactory(...) { ... }
}
```

### Depois (migrado):
```java
@Configuration
public class KafkaConfig {
    public static final String TOPIC_X = "topic.x";
    // Manter apenas constantes de tópicos e headers
    // Beans de KafkaProducer, KafkaTransactionManager e ConsumerFactory são REMOVIDOS
}
```

### Checklist

- [ ] Remover `KafkaProducer` bean — usar `KafkaTemplate` (auto-configurado pelo Spring Boot)
- [ ] Remover `KafkaTransactionManager` bean — auto-configurado
- [ ] Remover `ConsumerFactory` bean — usar `CustomKafkaProperties` da `lib-messageria`
- [ ] Simplificar `KafkaConfig`: manter apenas constantes e bean `AdminClient` (se necessário)
- [ ] Mover constantes de headers Kafka para `KafkaConfig`

## MessageService

### Antes:
```java
@Service
public class MessageServiceImpl implements MessageService {
    private final KafkaProducer<String, String> kafkaProducer;

    public void enviar(String topic, String payload) {
        ProducerRecord<String, String> record = new ProducerRecord<>(topic, payload);
        kafkaProducer.send(record);
    }
}
```

### Depois:
```java
@Service
public class MessageServiceImpl implements MessageService {
    private final KafkaTemplate<String, String> kafkaTemplate;

    public void enviar(String topic, String payload) {
        ProducerRecord<String, String> record = new ProducerRecord<>(topic, payload);
        kafkaTemplate.send(record);
    }
}
```

> A interface `send()` do `KafkaTemplate` aceita `ProducerRecord`, então a mudança é mínima.

## @KafkaListener

Manter `@KafkaListener` com constantes do `KafkaConfig`:

```java
@KafkaListener(topics = KafkaConfig.TOPIC_X, groupId = "${spring.application.name}")
public void consumir(ConsumerRecord<String, String> record) { ... }
```

## Testes — Mocks de Kafka

No `TestConfig`, criar mocks para `KafkaTemplate` e `ConsumerFactory`:

```java
@TestConfiguration
public class KafkaTestConfig {
    @Bean
    public KafkaTemplate<String, String> kafkaTemplate() {
        return Mockito.mock(KafkaTemplate.class);
    }

    @Bean
    public ConsumerFactory<String, String> consumerFactory() {
        return Mockito.mock(ConsumerFactory.class);
    }
}
```

> **Importante**: Configurar `kafkaTemplate.setAllowNonTransactional(true)` no mock se o serviço depender de transações Kafka.
