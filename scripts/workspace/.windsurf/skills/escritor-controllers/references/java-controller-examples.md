# Exemplos de Controllers Java

## Controller Básico Completo

```java
package br.com.attornatus.admin.controller;

import br.com.attornatus.admin.domain.dto.AlertaDto;
import br.com.attornatus.admin.domain.alerta.AlertaComponent;
import br.com.attornatus.core.exception.RegistroNaoEncontradoException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;

@Slf4j
@RestController
@RequestMapping("/alertas")
public class AlertaController {

    private final AlertaComponent alertaComponent;

    @Autowired
    public AlertaController(AlertaComponent alertaComponent) {
        this.alertaComponent = alertaComponent;
    }

    @GetMapping("/{id}")
    public AlertaDto buscarPorId(@PathVariable Long id) {
        log.debug("[buscarPorId] id: {}", id);
        return alertaComponent.buscarAlertaPorId(id);
    }

    @GetMapping
    public Page<AlertaDto> listarPagina(@PageableDefault(size = 10) Pageable pageable) {
        return alertaComponent.listarPagina(pageable);
    }

    @GetMapping("/ativos-usuario")
    public Page<AlertaDto> listarPorUsuario(@PageableDefault(size = 10) Pageable pageable) {
        return alertaComponent.listarPorUsuario(pageable);
    }

    @PostMapping
    public AlertaDto salvar(@Valid @RequestBody AlertaDto alertaDto) {
        return alertaComponent.salvar(alertaDto);
    }

    @PostMapping("/{id}/encerramento")
    public AlertaDto encerrar(@PathVariable Long id, @RequestBody AlertaDto alertaDto) {
        return alertaComponent.encerrar(id, alertaDto);
    }

    @PutMapping("/{id}")
    public AlertaDto atualizar(@PathVariable Long id, @Valid @RequestBody AlertaDto alertaDto) {
        return alertaComponent.atualizar(id, alertaDto);
    }

    @DeleteMapping("/{id}")
    public void excluir(@PathVariable Long id) {
        alertaComponent.excluir(id);
    }
}
```

## Controller com Service e Mapper

```java
package br.com.attornatus.processo.controller;

import br.com.attornatus.core.exception.RegistroNaoEncontradoException;
import br.com.attornatus.processo.domain.classe.Classe;
import br.com.attornatus.processo.domain.classe.ClasseMapper;
import br.com.attornatus.processo.domain.classe.ClasseService;
import br.com.attornatus.processo.domain.processo.dto.ClasseDto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.web.bind.annotation.*;

import static java.util.Objects.isNull;

@RestController
@RequestMapping("/classes")
public class ClasseController {

    private final ClasseMapper classeMapper;
    private final ClasseService classeService;

    public ClasseController(ClasseMapper classeMapper, ClasseService classeService) {
        this.classeMapper = classeMapper;
        this.classeService = classeService;
    }

    @GetMapping("/{id}")
    public ClasseDto buscarPorId(@PathVariable Long id) {
        return classeService.buscarPorId(id)
                .map(classeMapper::toClasseDto)
                .orElseThrow(() -> new RegistroNaoEncontradoException("Classe", id));
    }

    @GetMapping
    public Page<ClasseDto> listarClasses(@RequestParam(value = "search", required = false) String search,
                                         @PageableDefault() Pageable pageable) {
        Page<Classe> page = isNull(search)
                ? classeService.listarPagina(pageable)
                : classeService.listarPorSpecification(search, pageable);
        return page.map(classeMapper::toClasseDto);
    }

    @PostMapping("/atualizarclassecnj")
    public Classe atualizarAssuntoCnj(@RequestBody ClasseDto classeDto) {
        return classeService.salvar(classeMapper.toEntity(classeDto));
    }

    @GetMapping("/{id}/incidenterecurso")
    public boolean isClasseIncidenteRecurso(@PathVariable Long id) {
        return classeService.isClasseIncidenteRecurso(id);
    }
}
```

## Controller com Facade e Query Params Complexos

```java
package br.com.attornatus.admin.controller;

import br.com.attornatus.admin.domain.dto.ConfiguracaoParametroDto;
import br.com.attornatus.admin.domain.dto.ParametroDto;
import br.com.attornatus.admin.domain.parametro.ConfiguracaoParametroService;
import br.com.attornatus.admin.domain.parametro.ParametroFacade;
import br.com.attornatus.admin.domain.parametro.ParametroMapper;
import br.com.attornatus.admin.messageria.MessageService;
import br.com.attornatus.core.exception.RegistroNaoEncontradoException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;

@Slf4j
@RestController
@RequestMapping("/parametros")
public class ParametroController {

    private final ParametroFacade parametroFacade;
    private final MessageService messageService;
    private final ParametroMapper parametroMapper;
    private final ConfiguracaoParametroService configuracaoParametroService;

    @Autowired
    public ParametroController(ParametroFacade parametroFacade,
                               MessageService messageService, ParametroMapper parametroMapper,
                               ConfiguracaoParametroService configuracaoParametroService) {
        this.parametroFacade = parametroFacade;
        this.messageService = messageService;
        this.parametroMapper = parametroMapper;
        this.configuracaoParametroService = configuracaoParametroService;
    }

    @GetMapping(params = {"parametro"})
    public ParametroDto buscarMaisEspecifico(@RequestParam("parametro") String parametro,
                                             @RequestParam(value = "instituicao", required = false) String instituicao,
                                             @RequestParam(value = "usuario", required = false) String usuario,
                                             @RequestParam(value = "local", required = false) Long local,
                                             @RequestParam(value = "materia", required = false) Long materia,
                                             @RequestParam(value = "complemento", required = false) String complemento,
                                             @RequestParam(value = "orDefault", defaultValue = "false") boolean orDefault) {
        log.debug("[buscarMaisEspecifico] inicio execucao");
        return parametroFacade.buscarMaisEspecifico(parametro, instituicao, usuario, local, materia, complemento, orDefault);
    }

    @GetMapping(params = {"funcionalidade"})
    public Page<ParametroDto> listarPorFuncionalidadeELocal(@RequestParam(value = "local", required = false) Long local,
                                                            @RequestParam(value = "funcionalidade") Long funcionalidade,
                                                            @PageableDefault(page = 0, size = 10) Pageable pageable) {
        return parametroFacade.listarPorFuncionalidadeELocal(local, funcionalidade, pageable);
    }

    @PutMapping("/local")
    public ParametroDto atualizarNoLocal(@Valid @RequestBody ParametroDto parametroDto) {
        return parametroFacade.atualizarNoLocal(parametroDto);
    }

    @PostMapping("/configuracao-parametro")
    public ConfiguracaoParametroDto atualizaIncluiSeNaoExistir(@Valid @RequestBody ConfiguracaoParametroDto configuracaoParametro) {
        return parametroMapper.toConfiguracaoParametroDto(parametroFacade.incluirSeNaoExistir(configuracaoParametro));
    }
}
```

## Controller com Sub-recursos (Nested)

```java
package br.com.attornatus.security.controller;

import br.com.attornatus.core.exception.RegistroNaoEncontradoException;
import br.com.attornatus.core.support.MessageBundle;
import br.com.attornatus.security.domain.local.LocalMapper;
import br.com.attornatus.security.domain.local.LocalService;
import br.com.attornatus.security.domain.lotacao.Lotacao;
import br.com.attornatus.security.domain.lotacao.LotacaoDto;
import br.com.attornatus.security.domain.lotacao.LotacaoService;
import br.com.attornatus.security.domain.usuario.Usuario;
import br.com.attornatus.security.domain.usuario.UsuarioMapper;
import br.com.attornatus.security.domain.usuario.UsuarioService;
import br.com.attornatus.security.exception.UsuarioNaoEncontradoException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.web.bind.annotation.*;

import java.util.Objects;

@RestController
@RequestMapping("/usuarios")
public class UsuarioLotacaoController {

    private final LocalService localService;
    private final LotacaoService lotacaoService;
    private final LocalMapper localMapper;
    private final UsuarioService usuarioService;
    private final UsuarioMapper usuarioMapper;

    @Autowired
    public UsuarioLotacaoController(LocalService localService,
                                    LotacaoService lotacaoService,
                                    LocalMapper localMapper,
                                    UsuarioService usuarioService,
                                    UsuarioMapper usuarioMapper) {
        this.localService = localService;
        this.lotacaoService = lotacaoService;
        this.localMapper = localMapper;
        this.usuarioService = usuarioService;
        this.usuarioMapper = usuarioMapper;
    }

    @GetMapping("/{username}/lotacoes")
    public Page<LotacaoDto> listarPorUsuario(@PathVariable("username") String username,
                                               @PageableDefault(size = 10) Pageable pageable) {
        var usuario = usuarioService.buscarPorId(username)
                .orElseThrow(() -> new UsuarioNaoEncontradoException(username));
        return localMapper.toPageLotacaoDto(usuario.getLotacoesVigentesEFuturas(), pageable);
    }

    @PostMapping("/{username}/lotacoes")
    public LotacaoDto incluir(@PathVariable("username") String username,
                              @RequestBody LotacaoDto lotacao) {
        Objects.requireNonNull(lotacao.getLocal(),
                MessageBundle.getMessage(MessageBundle.OBJETO_REQUERIDO, "local"));
        Usuario usuarioLotado = usuarioService.buscarPorId(username)
                .orElseThrow(() -> new UsuarioNaoEncontradoException(username));
        lotacao.setUsuarioLotado(usuarioMapper.toUsuarioDto(usuarioLotado));
        return localMapper.toLotacaoDto(localService.salvarLotacao(lotacao.getLocal().getId(),
                localMapper.toLotacaoEntity(lotacao)));
    }

    @PutMapping("/{username}/lotacoes/{id}")
    public LotacaoDto atualizar(@PathVariable("username") String username,
                                @PathVariable Long id,
                                @RequestBody LotacaoDto lotacaoDto) {
        if (!lotacaoService.existe(id)) {
            throw new RegistroNaoEncontradoException(Lotacao.class.getSimpleName(), id);
        }
        return localMapper.toLotacaoDto(lotacaoService
                .salvar(localMapper.toLotacaoEntity(lotacaoDto, id, username)));
    }

    @DeleteMapping("/lotacoes/{id}")
    public void excluir(@PathVariable Long id) {
        lotacaoService.excluir(id);
    }
}
```

## Teste de Controller (JUnit 5 + Mockito)

```java
package br.com.attornatus.admin.controller;

import br.com.attornatus.admin.domain.alerta.Alerta;
import br.com.attornatus.admin.domain.alerta.AlertaComponent;
import br.com.attornatus.admin.domain.dto.AlertaDto;
import br.com.attornatus.admin.server.AdminServerTest;
import br.com.attornatus.core.exception.RegistroNaoEncontradoException;
import br.com.attornatus.core.tenant.TenantContextHolder;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.*;
import org.mockito.Mock;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.web.PageableHandlerMethodArgumentResolver;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;

import java.util.Collections;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.test.web.servlet.setup.MockMvcBuilders.standaloneSetup;

@DisplayNameGeneration(DisplayNameGenerator.ReplaceUnderscores.class)
@WithMockUser(username = "usuario@teste.com", authorities = {"ROLE_USUARIO", TenantContextHolder.TENANT_KEY + "~" + "ATTORNATUS"})
class AlertaControllerTest extends AdminServerTest {

    private MockMvc mockMvc;

    @Mock
    private AlertaComponent alertaComponent;

    @Autowired
    private ObjectMapper objectMapper;

    @BeforeEach
    void setUp() {
        this.mockMvc = standaloneSetup(new AlertaController(alertaComponent))
                .setCustomArgumentResolvers(new PageableHandlerMethodArgumentResolver())
                .build();
    }

    @Nested
    class Dado_um_alerta_ainda_nao_salvo extends AdminServerTest {

        final AlertaDto alertaSalvo = AlertaDto.builder().build();

        @BeforeEach
        private void setup() {
            when(alertaComponent.salvar(any())).thenReturn(alertaSalvo);
        }

        @Nested
        class Quando_chamado_o_metodo_POST extends AdminServerTest {

            @Test
            void Entao_deve_retornar_status_ok() throws Exception {
                mockMvc.perform(post("/alertas")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(alertaSalvo))
                                .accept(MediaType.APPLICATION_JSON))
                        .andExpect(status().isOk());
            }
        }
    }

    @Nested
    class Dado_um_alerta_ja_salvo extends AdminServerTest {

        private static final Long ALERTA_SALVO_ID = 1L;
        private final AlertaDto alertaDto = AlertaDto.builder().build();

        @Nested
        class Quando_chamado_o_metodo_GET_com_id_existente extends AdminServerTest {

            @BeforeEach
            private void setup() {
                when(alertaComponent.buscarAlertaPorId(any())).thenReturn(alertaDto);
            }

            @Test
            void Entao_deve_retornar_status_ok() throws Exception {
                mockMvc.perform(get("/alertas/" + ALERTA_SALVO_ID)
                                .contentType(MediaType.APPLICATION_JSON)
                                .accept(MediaType.APPLICATION_JSON))
                        .andExpect(status().isOk());
            }
        }

        @Nested
        class Quando_listar_pagina extends AdminServerTest {

            ResultActions resultActions;

            @BeforeEach
            private void setup() throws Exception {
                when(alertaComponent.listarPagina(any(), any())).thenReturn(new PageImpl<>(Collections.singletonList(alertaDto)));
                resultActions = mockMvc.perform(get("/alertas"));
            }

            @Test
            void Entao_deve_retornar_status_ok() throws Exception {
                resultActions.andExpect(status().isOk());
            }
        }
    }
}
```
