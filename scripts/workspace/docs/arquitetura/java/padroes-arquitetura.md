# Padrões de Arquitetura Attus

Guia de arquitetura para microsserviços Java Spring Boot no ecossistema Attus.

## Camadas da Arquitetura

A arquitetura Attus segue a hierarquia:

```
Controller → [Component] → Service → Repository
     ↓            ↓
   Mapper       Mapper
```

> **Nota:** O Component é **opcional**. Em CRUDs simples ou fluxos sem orquestração complexa, o Controller pode usar Mapper e Service diretamente, sem necessidade de Component. O Component deve ser criado apenas quando houver orquestração entre múltiplos Services, regras de conversão complexas ou coordenação de fluxos.

> **Nota:** O Mapper é usado apenas por Controller, Component ou MessageService. O Service **não** usa Mapper — opera exclusivamente sobre Entidades.

### 1. Controller

**Responsabilidade:** Camada de entrada REST. Expor endpoints, validar inputs e converter exceções.

**Regras:**
- APENAS endpoints e validação (@Valid)
- DEVE delegar para Component ou diretamente para Service (em CRUDs simples)
- PODE usar Mapper diretamente para conversões simples (Entity ↔ DTO) quando não há Component
- NÃO contém regras de negócio
- NÃO chama Repository diretamente

**Exemplo com Component (fluxos complexos):**
```java
@RestController
@RequestMapping("/api/usuarios")
public class UsuarioController {

    private final UsuarioComponent usuarioComponent;

    public UsuarioController(UsuarioComponent usuarioComponent) {
        this.usuarioComponent = usuarioComponent;
    }

    @GetMapping("/{id}")
    public UsuarioDto buscarPorId(@PathVariable Long id) {
        return usuarioComponent.buscarPorId(id);
    }

    @PostMapping
    public UsuarioDto salvar(@Valid @RequestBody UsuarioDto dto) {
        return usuarioComponent.salvar(dto);
    }
}
```

**Exemplo sem Component (CRUD simples):**
```java
@RestController
@RequestMapping("/entidades")
public class EntidadeController {

    private final EntidadeService entidadeService;
    private final EntidadeMapper entidadeMapper;

    public EntidadeController(EntidadeService entidadeService, EntidadeMapper entidadeMapper) {
        this.entidadeService = entidadeService;
        this.entidadeMapper = entidadeMapper;
    }

    @PostMapping
    public EntidadeDto salvar(@Valid @RequestBody EntidadeDto entidadeDto) {
        Entidade entidade = entidadeService.salvar(entidadeMapper.toEntidadeEntity(entidadeDto));
        return entidadeMapper.toEntidadeDto(entidade);
    }

    @GetMapping("/{id}")
    public EntidadeDto buscarPorId(@PathVariable String id) {
        return entidadeMapper.toEntidadeDto(entidadeService.buscarPorIdOrElseThrow(id));
    }
}
```

### 2. Component (opcional)

**Responsabilidade:** Orquestração entre camadas. Coordena fluxos de conversão e chamadas a múltiplos serviços.

**Quando usar:** Criar Component apenas quando houver orquestração complexa, coordenação entre múltiplos Services, ou regras de conversão que envolvam chamadas a serviços externos. Em CRUDs simples, o Controller pode delegar diretamente para Service + Mapper, omitindo o Component.

**Regras:**
- Intermedia Controller ↔ Service
- Gerencia conversões DTO ↔ Entity (via Mapper)
- Coordena chamadas a múltiplos serviços
- NÃO contém regras de negócio puras

**Exemplo:**
```java
@Component
public class UsuarioComponent {

    private final UsuarioService usuarioService;
    private final UsuarioMapper usuarioMapper;
    private final PessoaService pessoaService;

    public UsuarioComponent(UsuarioService usuarioService, UsuarioMapper usuarioMapper, PessoaService pessoaService) {
        this.usuarioService = usuarioService;
        this.usuarioMapper = usuarioMapper;
        this.pessoaService = pessoaService;
    }

    public UsuarioDto buscarPorId(Long id) {
        Usuario usuario = usuarioService.buscarPorId(id);
        PessoaDto pessoa = pessoaService.buscarPorId(usuario.getPessoaId());
        return usuarioMapper.toUsuarioDto(usuario, pessoa);
    }

    public UsuarioDto salvar(UsuarioDto dto) {
        Usuario usuario = usuarioMapper.toUsuarioEntity(dto);
        Usuario salvo = usuarioService.salvar(usuario);
        return usuarioMapper.toUsuarioDto(salvo);
    }
}
```

### 3. Service

**Responsabilidade:** Núcleo das regras de negócio. Opera sobre Entidades.

**Regras:**
- Opera sobre Entidades (não DTOs)
- Encapsula lógica de domínio
- Agnóstico à camada web
- Interface estende `BaseService<Entity, ID>` (de `ai.attus:lib-database`)
- Implementação estende `AbstractService<Entity, ID, Repository>` (de `ai.attus:lib-database`)
- Nomeado em Português

**Exemplo:**
```java
public interface UsuarioService extends BaseService<Usuario, Long> {
    void ativar(Long id);
    void desativar(Long id);
}

@Service
public class UsuarioServiceImpl extends AbstractService<Usuario, Long, UsuarioRepository> implements UsuarioService {

    public UsuarioServiceImpl(UsuarioRepository usuarioRepository) {
        super(usuarioRepository);
    }

    @Override
    @Transactional
    public void ativar(Long id) {
        Usuario usuario = buscarPorIdOrElseThrow(id);
        usuario.ativar();
    }

    @Override
    @Transactional
    public void desativar(Long id) {
        Usuario usuario = buscarPorIdOrElseThrow(id);
        usuario.desativar();
    }
}
```

> **Nota:** `BaseService` já fornece métodos padrão como `salvar`, `buscarPorId`, `buscarPorIdOrElseThrow`, `listarPagina`, `listarPorSpecification`, `excluir`, `existe`. Só declarar na interface métodos adicionais específicos do domínio.

### 4. Repository

**Responsabilidade:** Acesso a dados. Estende `BaseRepository` (de `ai.attus:lib-database`).

**Regras:**
- Estende `BaseRepository<Entity, ID>` (de `ai.attus:lib-database`)
- Usa `@Query` (JPQL) para consultas complexas
- Projections para leituras parciais
- **Sempre usar `Page` como retorno** para evitar carregar muitos registros em uma consulta
- Nome: Entidade + Repository

**Exemplo:**
```java
@Repository
public interface UsuarioRepository extends BaseRepository<Usuario, Long> {

    Optional<Usuario> findByEmail(String email);

    boolean existsByEmail(String email);

    @Query("""
        SELECT u.id as id, u.nome as nome, u.email as email
        FROM Usuario u
        WHERE u.ativo = true
        AND u.dataCriacao >= :dataInicio
        """)
    Page<UsuarioProjection> listarAtivosDesde(@Param("dataInicio") LocalDateTime dataInicio, Pageable pageable);

    @Query(value = """
        SELECT * FROM usuarios u
        WHERE u.perfil = :perfil
        AND u.ultimo_acesso > CURRENT_DATE - INTERVAL '30 days'
        """, nativeQuery = true)
    Page<Usuario> listarAtivosPorPerfil(@Param("perfil") String perfil, Pageable pageable);
}
```

### 5. Mapper

**Responsabilidade:** Conversão Entity ↔ DTO.

**Regras:**
- Anotado com `@Component`
- Métodos explícitos de conversão
- Nome: Entidade + Mapper

**Exemplo:**
```java
@Component
public class UsuarioMapper {

    public UsuarioDto toUsuarioDto(Usuario usuario) {
        if (usuario == null) return null;
        return UsuarioDto.builder()
                .id(usuario.getId())
                .nome(usuario.getNome())
                .email(usuario.getEmail())
                .perfil(usuario.getPerfil())
                .build();
    }

    public UsuarioDto toUsuarioDto(Usuario usuario, PessoaDto pessoa) {
        return UsuarioDto.builder()
                .id(usuario.getId())
                .nome(usuario.getNome())
                .email(usuario.getEmail())
                .perfil(usuario.getPerfil())
                .pessoa(pessoa)
                .build();
    }

    public Usuario toUsuarioEntity(UsuarioDto dto) {
        if (dto == null) return null;
        return Usuario.builder()
                .nome(dto.getNome())
                .email(dto.getEmail())
                .perfil(dto.getPerfil())
                .build();
    }
}
```

## Princípio de Responsabilidade Única (SRP) em Classes de Infraestrutura

Classes que **publicam/enviam** eventos, mensagens ou notificações NÃO devem também **fabricar/construir** os objetos enviados. Quando uma classe acumula múltiplos métodos de fabricação (`fabricar*`, `construir*`, `montar*`) junto com métodos de envio (`publicar*`, `enviar*`), ela viola SRP e deve ser decomposta.

### Padrão correto: Factory + Publisher

| Classe | Responsabilidade | Sufixo |
|--------|-----------------|--------|
| **Factory** | Construir/fabricar os objetos (DTOs, eventos, mensagens) | `Factory` |
| **Publisher/Producer** | Enviar/publicar os objetos já construídos | `Publish`, `Producer` |

❌ **Errado** — classe única acumula fabricação e envio:
```java
@Component
public class EventoAuditoriaPublish {
    // Envia
    public void publicarEvento(Operacao op, EntityPersister p, Object entity, ...) { ... }
    // Fabrica (N métodos)
    private EventoAuditoriaDto fabricarEvento(...) { ... }
    private List<EventoAuditoriaAtributoDto> fabricarAtributos(...) { ... }
    private List<EventoAuditoriaAtributoDto> fabricarAtributosCriacao(...) { ... }
    private List<EventoAuditoriaAtributoDto> fabricarAtributosAlteracao(...) { ... }
    private List<EventoAuditoriaAtributoDto> fabricarAtributosDelecao(...) { ... }
    private String formatarValor(Object object) { ... }
    // ... mais métodos de fabricação
}
```

✅ **Correto** — responsabilidades separadas:
```java
@Component
public class EventoAuditoriaFactory {
    public EventoAuditoriaDto fabricarEvento(Operacao op, EntityPersister p, ...) { ... }
    public List<EventoAuditoriaAtributoDto> fabricarAtributos(Operacao op, ...) { ... }
    // ... todos os métodos de fabricação ficam aqui
}

@Component
public class EventoAuditoriaPublish {
    private final EventoAuditoriaFactory factory;
    private final KafkaTemplate<String, EventoAuditoriaDto> kafkaTemplate;

    @Async
    public void publicarEvento(Operacao op, EntityPersister p, Object entity, ...) {
        EventoAuditoriaDto evento = factory.fabricarEvento(op, p, ...);
        kafkaTemplate.send(TOPICO_AUDITORIA, evento);
    }
}
```

> **Regra prática:** se uma classe tem **3+ métodos privados** dedicados à construção/fabricação de objetos, esses métodos devem ser extraídos para uma classe `Factory` dedicada. Isso melhora testabilidade (Factory pode ser testada isoladamente com testes unitários puros) e respeita SRP.

---

## Comunicação Entre Serviços

### Feign Client

Usar Feign Clients para comunicação síncrona entre microsserviços. Nomear como `Service` (não `Client`):

```java
@FeignClient(name = "pessoa-svc", primary = false)
public interface PessoaService {

    @GetMapping("/{id}")
    PessoaDto buscarPorId(@PathVariable Long id);

    @PostMapping
    PessoaDto salvar(@RequestBody PessoaDto dto);
}
```

### DTOs de Integração

Replicar DTOs no consumidor. A configuração `ignoreUnknown = true` é tratada **globalmente** no `ObjectMapper`, não deve ser colocada nos DTOs individualmente.

```java
@Data
public class PessoaDto {
    private Long id;
    private String nome;
    private String cpf;
}
```

## Estrutura de Pacotes

Organização por **domínio** — todas as classes de um domínio ficam no mesmo pacote:

```
ai.attus.{servico}
├── controller/                    # Controllers REST
├── domain/
│   ├── {dominio1}/                # Ex: usuario/
│   │   ├── Usuario.java           # Entity
│   │   ├── UsuarioDto.java        # DTO
│   │   ├── UsuarioService.java    # Interface (extends BaseService)
│   │   ├── UsuarioServiceImpl.java# Implementação (extends AbstractService)
│   │   ├── UsuarioRepository.java # Repository (extends BaseRepository)
│   │   └── UsuarioMapper.java     # Mapper (@Component)
│   └── {dominio2}/                # Ex: perfil/
│       └── ...
├── client/                        # Feign Clients + DTOs de outros microserviços
│   └── {servico}/                 # Ex: security/
│       ├── SecurityService.java   # Feign Client (@FeignClient)
│       └── UsuarioDto.java        # DTO que representa objeto do outro microserviço
├── config/                        # Configurações
├── messageria/                    # Kafka producers
└── exception/                     # Exceções customizadas
```

> **Nota:** Controllers ficam em pacote separado (`controller/`). Todas as demais classes do domínio (Entity, DTO, Service, ServiceImpl, Repository, Mapper, Consumer) ficam agrupadas dentro de `domain/{dominio}/`.

---

## Checklist de Clean Code (Sonar) — Quality Gate da Pipeline

> **IMPORTANTE:** A pipeline do Sonar **barra o merge** se houver issues novas. Este checklist é **obrigatório** em toda entrega — deve ser verificado em **cada arquivo gerado ou modificado** antes de considerar a tarefa concluída.

### Código de Produção
- [ ] Nenhum método teve visibilidade alterada (`private` → `package-private`/`public`) para facilitar testes — métodos privados devem ser testados indiretamente através dos métodos públicos
- [ ] Nenhum campo (`private field`) não utilizado
- [ ] Nenhum import não utilizado
- [ ] Nenhum `TODO` comment pendente (resolver ou remover)
- [ ] `@Override` em todos os métodos que sobrescrevem superclasse/interface
- [ ] Nenhuma chamada a método deprecated marcado para remoção — buscar a API substituta
- [ ] Construtores privados em classes utilitárias/finais que não devem ser instanciadas (ex: classe `main`)
- [ ] Diamond operator (`<>`) em vez de tipos explícitos redundantes em construtores genéricos
- [ ] Nenhum `throws` de exceção que não pode ser lançada pelo corpo do método
- [ ] Nenhum bloco try-catch aninhado — extrair para método separado
- [ ] Nenhum try-catch silencioso (que apenas faz `log.error`/`log.warn` e engole a exceção) — exceções devem propagar para serem detectadas nos testes e nos mecanismos de erro do framework
- [ ] Nenhum parâmetro não utilizado em métodos
- [ ] Nenhum código duplicado (extrair para método ou constante)

### Código de Teste
- [ ] Nenhum import não utilizado
- [ ] Nenhum campo (`private field`) não utilizado
- [ ] Nenhum `throws Exception` desnecessário em métodos `@BeforeEach` ou `@Test` — só declarar `throws` quando o método chamado de fato declara exceções checked
- [ ] Diamond operator em construtores genéricos
- [ ] Nenhuma chamada a método/construtor deprecated — sempre migrar para a API substituta, nunca usar `@SuppressWarnings`
- [ ] Nenhuma assertion sem mensagem descritiva em testes complexos (opcional mas recomendado)

### Workflow de Verificação (executar ANTES de finalizar)

1. Para **cada arquivo** criado ou modificado, percorrer o checklist acima item a item
2. Verificar se métodos chamados dentro de `@BeforeEach`/`@Test` realmente declaram `throws` — se não declaram, remover o `throws Exception` do setup/test
3. Verificar se todos os imports estão sendo usados no código atual (imports podem ficar órfãos após refatorações)
4. Verificar se todos os campos declarados estão sendo referenciados
5. Se qualquer item falhar, corrigir **antes** de entregar

---

## Regras Gerais

- **Não usar `spring.main.allow-bean-definition-overriding=true`** ou outros artifícios para burlar comportamentos recomendados pelo Spring Framework. Se um bean precisa ser substituído, a solução correta é corrigir a origem do problema (ex: atualizar a biblioteca que define o bean) em vez de forçar override via configuração.
- **Arquivos `.yml` devem usar formato YAML indentado**, nunca formato flat de properties. Se encontrar um arquivo `.yml` com propriedades no formato `spring.datasource.url=valor` ou `spring.datasource.url: valor` (flat), converter para a estrutura hierárquica YAML:
  ```yaml
  # ❌ Errado (formato flat/properties dentro de .yml)
  spring.datasource.url: jdbc:h2:mem:testdb
  spring.datasource.driver-class-name: org.h2.Driver

  # ✅ Correto (formato YAML indentado)
  spring:
    datasource:
      url: jdbc:h2:mem:testdb
      driver-class-name: org.h2.Driver
  ```
