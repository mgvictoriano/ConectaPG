# Migração de Código e Padrões

## Classe Principal (Server)

### Antes (legado):
```java
package server;

@SpringBootApplication
@ComponentScan({"br.com.attornatus", "server"})
@EnableCaching
public class NomeServer {
    @PostConstruct
    public void init() {
        TimeZone.setDefault(TimeZone.getTimeZone("America/Sao_Paulo"));
    }

    @Bean
    public RestTemplate restTemplate() { return new RestTemplate(); }

    public static void main(String[] args) {
        SpringApplication.run(NomeServer.class, args);
    }
}
```

### Depois (migrado):
```java
package ai.attus.<servico>;

@SpringBootApplication
public final class <Nome>Server {
    private <Nome>Server() {}

    static void main(String[] args) {
        TimeZone.setDefault(TimeZone.getTimeZone("America/Sao_Paulo"));
        SpringApplication.run(<Nome>Server.class, args);
    }
}
```

### Checklist

- [ ] Mover de `server.*` para `ai.attus.<servico>.*`
- [ ] Remover `@ComponentScan` — auto-scan pelo pacote base
- [ ] Remover `@EnableCaching` — fornecido pela `lib-cache`
- [ ] Remover `@Bean RestTemplate` — fornecido pela `lib-starter`
- [ ] Substituir `@PostConstruct init()` por chamada direta no `main()`
- [ ] Tornar classe `final` com construtor privado
- [ ] Tornar `main()` package-private (`static void main`)

## Spring Batch → Quartz Puro

Microsserviços que usam Spring Batch para jobs agendados devem migrar para Quartz puro. Spring Batch é para processamento em lotes com steps, readers, writers e listeners — se o job é simples (executar lógica por tenant/instituição), Quartz puro é suficiente.

### Remoções

| Classe/Config | Motivo |
|---------------|--------|
| `SpringBatchConfig` | Não necessário sem Spring Batch |
| `AbstractBatchJob` | Substituir por `implements org.quartz.Job` |
| `LogProcessListener`, `LogReadListener`, `LogWriterListener`, `LogStepListener` | Listeners do Spring Batch |
| `ResumoListener` | Listener do Spring Batch |
| `FalhasJobContext` / `FalhasJobContextTest` | Contexto de falhas do Spring Batch |
| `BatchJobExecutionParams` / `BatchJobExecutionParamsRepository` | Entidade/Repositório específicos do Spring Batch |
| Readers/Writers específicos (ex: `CoordenadasDividaReader`, `CoordenadasWriter`) | Step components do Spring Batch |
| `spring-boot-starter-batch` | Dependência do Spring Batch |

### Padrão de Migração

**Antes (Spring Batch):**
```java
public class MeuJob extends AbstractBatchJob {
    @Override
    protected Job buildJob(JobDto jobDto) {
        return jobBuilderFactory.get("meuJob")
            .start(stepBuilderFactory.get("step1")
                .<Input, Output>chunk(100)
                .reader(reader)
                .processor(processor)
                .writer(writer)
                .listener(logStepListener)
                .build())
            .listener(resumoListener)
            .build();
    }
}
```

**Depois (Quartz puro):**
```java
@Slf4j
@DisallowConcurrentExecution
public class MeuJob implements Job {

    @Autowired
    private JobDtoFactory jobDtoFactory;
    @Autowired
    private MeuService meuService;

    @Override
    public void execute(JobExecutionContext context) throws JobExecutionException {
        JobDto jobDto = jobDtoFactory.fabricar(context.getTrigger().getJobDataMap());
        log.info("Executando job {} - {}", jobDto.getId(), jobDto.getNome());

        RunAs.runMethodAsTenant(jobDto.getTenant(), () -> {
            meuService.processar(jobDto);
        });
    }
}
```

### Job que Processa por Instituição

Para jobs que iteram sobre todas as instituições:

```java
@Slf4j
public abstract class ProcessamentoPorInstituicaoJob implements Job {

    @Override
    public void execute(JobExecutionContext context) {
        JobDto jobDto = getJobDtoFactory().fabricar(context.getTrigger().getJobDataMap());
        processarJobPorInstituicao(jobDto.getTenant(), jobDto);
    }

    public abstract JobDtoFactory getJobDtoFactory();
    public abstract SecurityService getSecurityService();
    public abstract void processar(JobDto jobDto);

    public void processarJobPorInstituicao(String tenant, JobDto jobDto) {
        Page<InstituicaoDto> instituicoes;
        Pageable pageable = PageRequest.of(0, 50);
        do {
            Pageable finalPageable = pageable;
            instituicoes = RunAs.runFunctionAsTenant(tenant,
                () -> getSecurityService().listarInstituicoes(finalPageable), Page.class);
            for (InstituicaoDto instituicao : instituicoes) {
                try {
                    RunAs.runMethodAsTenant(instituicao.getId(), () -> this.processar(jobDto));
                } catch (Exception e) {
                    log.error("Erro ao processar job {} por instituição", jobDto.getId(), e);
                }
            }
            pageable = pageable.next();
        } while (instituicoes.hasNext());
    }
}
```

## ObjectMapper — Jackson 3

### Migração de imports

Substituir **todos** os imports em código de produção e testes:

| Jackson 2 | Jackson 3 |
|-----------|-----------|
| `com.fasterxml.jackson.databind.ObjectMapper` | `tools.jackson.databind.ObjectMapper` |
| `com.fasterxml.jackson.annotation.*` | `tools.jackson.annotation.*` |
| `com.fasterxml.jackson.core.*` | `tools.jackson.core.*` |
| `com.fasterxml.jackson.databind.node.*` | `tools.jackson.databind.node.*` |
| `com.fasterxml.jackson.datatype.jsr310.*` | **REMOVIDO** (incluído no Jackson 3) |

### Bibliotecas internas

Libs internas (ex: `lib-utils`) que usam `com.fasterxml.jackson` devem ser migradas para `tools.jackson` **antes** de serem usadas no projeto migrado.

Se a lib usa `ObjectMapper` para serialização/deserialização:
1. Migrar imports para `tools.jackson.*`
2. Criar `AutoConfiguration` com `AutoConfiguration.imports` para registro automático
3. Usar `TimeZone.getDefault()` na serialização de datas

## Controllers — Padrão Attus

### Renomear Facade → Component

| Antes | Depois |
|-------|--------|
| `ParametroFacade` | `ParametroComponent` |
| `AlertaFacade` | `AlertaComponent` |

### TenantContextHolder → SecurityContextUtils

| Antes | Depois |
|-------|--------|
| `TenantContextHolder.get()` | `SecurityContextUtils.getTenantId()` |
| `import br.com.attornatus.core.tenant.TenantContextHolder` | `import ai.attus.lib.security.domain.SecurityContextUtils` |

## Remoção de Serviços Externos Descontinuados

Durante a migração, avaliar se serviços externos legados ainda são necessários. Exemplos comuns de remoção:

- Integrações com ferramentas descontinuadas (ex: Bitrix, JIRA legado)
- Clients de APIs internas obsoletas
- DTOs de integrações removidas

### Checklist de remoção

Para cada serviço removido:
1. Remover a interface `@FeignClient` / classe `@Service`
2. Remover DTOs associados
3. Remover exceções específicas
4. Remover testes
5. Remover referências no `TestConfig` (mocks)
6. Remover propriedades no `application.yml` / `application-test.yml`
