# Padrões de Nomenclatura — Java

Guia de nomenclatura para código Java conforme Constituição v1.4.0.

## Princípio Fundamental

**Idioma padrão: Português (PT-BR)** para nomes de classes, métodos e variáveis de negócio.

Termos técnicos (frameworks, patterns, libraries) mantêm-se em inglês.

---

## Backend (Java)

### Classes e Interfaces

| Tipo | Padrão | Exemplo |
|------|--------|---------|
| Interface Service | `DominioService` | `UsuarioService`, `PessoaService` |
| Implementação Service | `DominioServiceImpl` | `UsuarioServiceImpl` |
| Controller | `DominioController` | `UsuarioController` |
| Component | `DominioComponent` | `UsuarioComponent`, `DemandaComponent` |
| Repository | `EntidadeRepository` | `UsuarioRepository`, `PessoaRepository` |
| Mapper | `EntidadeMapper` | `UsuarioMapper`, `PessoaMapper` |
| DTOs | `DominioDto` | `UsuarioDto`, `PessoaDto` |
| Entidade | `PascalCase` (substantivo) | `Usuario`, `Pessoa`, `Divida` |
| Enum | `PascalCase` | `StatusUsuario`, `TipoDocumento` |
| Exception | `NomeException` | `UsuarioNaoEncontradoException` |
| Listener | `AcaoListener` | `AuditoriaListener` |
| Consumer | `TopicoConsumer` | `ProcessoConsumer` |
| Feign Client | `ServicoService` | `PessoaService`, `SmsService` |

### Métodos

**camelCase, verbos ou locuções verbais em português, SEMPRE no infinitivo**

> **Regra obrigatória:** verbos em nomes de métodos devem estar no **infinitivo** (-ar, -er, -ir), **nunca** conjugados na 3ª pessoa do presente. Isso vale para todos os métodos (públicos, protected e privados).

❌ **Errado** — verbo conjugado (3ª pessoa do presente):
```java
removeFormatacao()     // conjugado
preencheComZeros()     // conjugado
trocaAbreviacoes()     // conjugado
pegaDiaMesAno()        // conjugado
```

✅ **Correto** — verbo no infinitivo:
```java
removerFormatacao()    // infinitivo
preencherComZeros()    // infinitivo
trocarAbreviacoes()    // infinitivo
pegarDiaMesAno()       // infinitivo (ou buscarDiaMesAno)
```

Tabela de conjugações erradas frequentes:

| ❌ Conjugado (3ª pessoa) | ✅ Infinitivo |
|--------------------------|---------------|
| `remove` | `remover` |
| `preenche` | `preencher` |
| `troca` | `trocar` |
| `pega` | `pegar` / `buscar` |
| `busca` | `buscar` |
| `ajusta` | `ajustar` |
| `adiciona` | `adicionar` |
| `ignora` | `ignorar` |
| `converte` | `converter` |
| `existe` | `existir` (ou manter `existe` como predicado: `existePorCpf`) |

| Operação | Padrão | Exemplos |
|----------|--------|----------|
| Buscar um | `buscarPor{campo}` | `buscarPorId()`, `buscarPorEmail()` |
| Buscar lista | `listar{condicao}` | `listarAtivos()`, `listarPorPerfil()` |
| Salvar | `salvar` | `salvar(dto)`, `salvar(lista)` |
| Excluir | `excluir` | `excluir(id)` |
| Validar | `validar`, `existe` | `validarEmail()`, `existePorCpf()` |
| Calcular/Derivar | `calcular` | `calcularToken()`, `calcularInstituicaoId()`, `calcularUsuario()`, `calcularTotal()` |
| Executar (Actions) | `executar` | `executar()` — apenas em classes Action |
| Converter | `to{Entidade}Dto`, `to{Entidade}Entity` | `toUsuarioDto()`, `toUsuarioEntity()` |

### Métodos de Mapper — Sufixo Obrigatório

Métodos de conversão em classes Mapper **DEVEM** incluir o sufixo `Dto` ou `Entity` no nome do método, indicando o tipo de retorno:

| Direção | Padrão | Exemplo |
|---------|--------|---------|
| Entity/DTO → DTO | `to{Nome}Dto` | `toUsuarioDto(Usuario entity)`, `toProcessoDto(Processo entity)` |
| DTO → Entity/Objeto | `to{Nome}Entity` | `toUsuarioEntity(UsuarioDto dto)`, `toCriteriosCobrancaEntity(JobDto dto)` |
| Lista Entity → Lista DTO | `to{Nome}DtoList` | `toUsuarioDtoList(List<Usuario> entities)` |

❌ **Errado** — sem sufixo:
```java
toUsuario(UsuarioDto dto)       // Ambíguo: retorna Entity ou DTO?
toCriteriosCobranca(JobDto dto) // Ambíguo
toRelatorio(String label)       // Ambíguo
```

✅ **Correto** — com sufixo explícito:
```java
toUsuarioEntity(UsuarioDto dto)
toCriteriosCobrancaEntity(JobDto dto)
toRelatorioDto(String label, String uri, String description)
```

### Pacotes

**lowercase**, separados por contexto de negócio:

```
ai.attus.{servico}.{contexto}
```

Exemplos:
- `ai.attus.security.domain.usuario`
- `ai.attus.pessoa.service`
- `ai.attus.divida.repository`

### Variáveis

**camelCase**, em português:

```java
private final UsuarioRepository usuarioRepository;
private final UsuarioMapper usuarioMapper;
private Usuario usuario;
private List<UsuarioDto> usuariosAtivos;
```

### Constantes

**UPPER_SNAKE_CASE**, e o nome **deve refletir exatamente o conteúdo/significado** — nunca usar nomes genéricos que se tornam ambíguos quando há mais de uma constante do mesmo tipo na classe ou no projeto.

```java
public static final int MAX_TENTATIVAS_LOGIN = 3;
public static final String TOPICO_AUDITORIA = "attornatus.auditoria.0";
public static final Duration TTL_OTP = Duration.ofMinutes(5);
```

❌ **Errado** — nome genérico que se torna ambíguo:
```java
public static final String HEADER_DECISAO = "X-Decisao_reabertura_conta";  // qual decisão?
public static final String TOPICO = "attornatus.auditoria.0";              // qual tópico?
public static final String ENTIDADE = "conta";                              // qual entidade?
public static final int LIMITE = 10;                                        // limite de quê?
```

✅ **Correto** — nome específico que reflete o conteúdo:
```java
public static final String HEADER_DECISAO_REABERTURA_CONTA = "X-Decisao_reabertura_conta";
public static final String TOPICO_AUDITORIA = "attornatus.auditoria.0";
public static final String ENTIDADE_CONTA = "conta";
public static final int LIMITE_TENTATIVAS_LOGIN = 10;
```

> **Teste mental:** se amanhã alguém adicionar outra constante do mesmo tipo (outro header, outro tópico, outro limite), o nome atual ficaria ambíguo? Se sim, o nome está genérico demais.

### Exceções Permitidas para Inglês

Apenas os seguintes casos são aceitos em inglês:

| Caso | Exemplo | Motivo |
|------|---------|--------|
| Prefixos `get`, `set`, `is`, `has`, `to`, `equals` — em **qualquer classe** | `getNome`, `setNome`, `isAtivo`, `hasPermissao`, `getDataAtual`, `toMap`, `toOffsetDateTime`, `equalsIgnoreTime` | Convenções universais do Java |
| Query derivation (Repository) | `findByNome`, `deleteById`, `existsByEmail` | Convenção Spring Data |
| Termos técnicos de framework sem tradução consagrada | `getPersister`, `unwrap`, `flush` | Vocabulário do framework |
| Anotações e callbacks de framework | `@Override`, `@PostConstruct`, `setup()` em testes | Exigência do framework |

**Tudo que tem tradução natural DEVE estar em português.** Tabela de traduções obrigatórias:

| Inglês | Português |
|--------|-----------|
| `extract` | `extrair` |
| `build` | `construir` / `calcular` |
| `format` | `formatar` |
| `publish` | `publicar` |
| `has` (fora de Entity) | `possui` / `tem` / `existe` |
| `concat` | `concatenar` |
| `validate` | `validar` |
| `convert` | `converter` |
| `process` | `processar` |
| `filter` | `filtrar` |
| `parse` | `interpretar` / `converter` |
| `create` | `criar` |
| `update` | `atualizar` |
| `delete` / `remove` | `excluir` / `remover` |
| `send` | `enviar` |
| `handle` | `tratar` / `processar` |
| `check` | `verificar` |
| `notify` | `notificar` |
| `generate` | `gerar` |
| `load` | `carregar` |
| `save` | `salvar` |
| `map` / `transform` | `mapear` / `transformar` |
| `merge` | `mesclar` |
| `split` | `dividir` |
| `sort` | `ordenar` |
| `replace` | `substituir` |
| `decode` | `decodificar` |
| `put` | `adicionar` / `inserir` |

### Checklist Mecânico de Verificação de Idioma (executar ANTES de finalizar)

> **OBRIGATÓRIO:** Esta verificação deve ser feita **método por método** para cada arquivo gerado ou modificado. Nunca confiar na impressão visual — percorrer cada método individualmente.

1. Para **cada arquivo** criado ou modificado, listar **todos** os métodos (públicos, protected E privados)
2. Para **cada método**, verificar se o nome está em português
3. Se o nome está em inglês, verificar se se enquadra em uma das exceções permitidas acima
4. Se **NÃO** se enquadra em nenhuma exceção → é uma **violação bloqueante** que deve ser reportada/corrigida
5. Consultar a tabela de traduções obrigatórias para encontrar o equivalente correto em português
6. **Verificar conjugação verbal**: se o verbo está em português mas conjugado na 3ª pessoa do presente (ex: `remove`, `preenche`, `troca`), corrigir para o **infinitivo** (ex: `remover`, `preencher`, `trocar`)

**Exemplo de verificação mecânica:**
```
Arquivo: EventoAuditoriaPublish.java
  ✅ publicarEvento(...)        → português, infinitivo
  ✅ fabricarAtributos(...)      → português, infinitivo
  ✅ fabricarAtributosCriacao(.) → português, infinitivo
  ✅ isEntidadeIgnorada(...)     → português
  ❌ extractPhysicalColumn(...)  → inglês → corrigir para extrairColunaFisica(...)
  ❌ hasCollectionChanged(...)   → inglês → corrigir para houveAlteracao(...)
  ❌ formatCollectionValue(...)  → inglês → corrigir para formatarValor(...)
  ✅ concatenarElementos(...)    → português, infinitivo
  ✅ safeToString(...)           → termo técnico (aceitável)

Arquivo: StringUtils.java
  ✅ removerAcentos(...)         → português, infinitivo
  ❌ removeAcentos(...)          → conjugado 3ª pessoa → corrigir para removerAcentos(...)
  ❌ preencheComZeros(...)       → conjugado 3ª pessoa → corrigir para preencherComZeros(...)
  ❌ trocaAbreviacoes(...)       → conjugado 3ª pessoa → corrigir para trocarAbreviacoes(...)
```

---

### Redundância de Tipo no Nome do Método

Nomes de métodos **NÃO devem repetir** informação que já está implícita no contexto — seja pelo tipo do parâmetro, pelo tipo de retorno ou pelo nome da classe onde o método reside. Se o contexto já deixa claro de que se trata, repetir no nome é redundância.

❌ **Errado** — tipo redundante no nome:
```java
fabricarEventosCollection(CollectionPersister persister, ...)  // "Collection" já está implícito nos parâmetros
publishCollectionEvent(Operacao op, CollectionPersister ...)   // idem
fabricarEventoCollection(Operacao op, String tableName, ...)   // idem
salvarUsuarioEntity(Usuario entity)                            // "Entity" redundante — parâmetro já é Entity
listarDividaDtoList(List<Divida> dividas)                       // "DtoList" redundante no nome do método de serviço
```

✅ **Correto** — nome limpo, contexto resolve:
```java
fabricarEventos(CollectionPersister persister, ...)            // parâmetro já indica que é collection
publishEvent(Operacao op, CollectionPersister ...)             // overload de publishEvent — assinatura diferencia
fabricarEvento(Operacao op, String tableName, ...)             // overload de fabricarEvento
salvar(Usuario entity)                                         // tipo do parâmetro já indica
listar(List<Divida> dividas)                                   // retorno e parâmetro já indicam
```

> **Regra geral:** usar **overload** (mesmo nome, parâmetros diferentes) em vez de sufixos redundantes. Se dois métodos fazem a mesma operação para tipos diferentes, a assinatura os diferencia naturalmente.

---

## Anti-Padrões (Proibidos)

### Nomenclatura

❌ **Errado:**
```java
// Inglês para negócio
UserService, getUserById(), saveUser()

// Abreviações obscuras
usrSvc, getUsrById()

// Nomes genéricos
manager, handler, processData()

// Mix de idiomas
UsuarioService, getUsuarioById()

// Prefixos errados para derivação de valor
resolverToken(), obterInstituicaoId(), getUsuario()

// Redundância de tipo no nome
fabricarEventosCollection(), publishCollectionEvent(), salvarUsuarioEntity()
```

✅ **Correto:**
```java
// Português para negócio
UsuarioService, buscarPorId(), salvar()

// Nomes completos
usuarioService, buscarPorId()

// Nomes descritivos
usuarioComponent, processarDivida()

// Consistente em português
UsuarioService, buscarPorId(), salvarUsuario()

// Prefixo correto para derivação de valor
calcularToken(), calcularInstituicaoId(), calcularUsuario()

// Sem redundância — overload resolve
fabricarEventos(), publishEvent(), salvar()
```

---

## Exemplos Completos

### Backend - Fluxo de Usuário

```java
// Controller
@RestController
@RequestMapping("/api/usuarios")
public class UsuarioController {
    private final UsuarioComponent usuarioComponent;
    
    @GetMapping("/{id}")
    public UsuarioDto buscarPorId(@PathVariable Long id) { }
}

// Component
@Component
public class UsuarioComponent {
    private final UsuarioService usuarioService;
    private final UsuarioMapper usuarioMapper;
    
    public UsuarioDto buscarPorId(Long id) { }
    public List<UsuarioDto> listarAtivos() { }
}

// Service Interface
public interface UsuarioService {
    Usuario buscarPorId(Long id);
    List<Usuario> listarAtivos();
    Usuario salvar(Usuario usuario);
    void ativar(Long id);
}

// Service Impl
@Service
public class UsuarioServiceImpl implements UsuarioService {
    private final UsuarioRepository usuarioRepository;
    
    @Override
    public Usuario buscarPorId(Long id) { }
}

// Repository
@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {
    List<Usuario> findByAtivoTrue();
    boolean existsByEmail(String email);
}

// Mapper
@Component
public class UsuarioMapper {
    public UsuarioDto toUsuarioDto(Usuario usuario) { }
    public Usuario toUsuarioEntity(UsuarioDto dto) { }
}

// DTOs
public record UsuarioDto(Long id, String nome, String email, String perfil) { }

// Entity
@Entity
@Table(name = "usuarios")
public class Usuario {
    @Id
    private Long id;
    private String nome;
    private String email;
    private boolean ativo;
}
```

