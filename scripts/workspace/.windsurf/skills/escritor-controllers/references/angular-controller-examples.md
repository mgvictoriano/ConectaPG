# Exemplos de Controllers Angular

## Controller Básico

```typescript
import { Injectable } from '@angular/core';
import { Classe } from '@modules/processo/models/classe.model';
import { ControllerBase } from '@shared/controller/core/controller.impl';
import { Controller } from '@shared/controller/shared/controller';

@Injectable({ providedIn: 'root' })
export class ClasseController extends Controller.Admin<Classe> {
  protected readonly recurso = 'classes';
  protected readonly mapper = Classe.mapper;
}
```

## Controller com Endpoints Customizados

```typescript
import { Injectable } from '@angular/core';
import { Parametro, ConfiguracaoParametro } from '@modules/admin/models';
import { Id } from '@shared';
import { ControllerBase } from '@shared/controller/core/controller.impl';
import { Controller } from '@shared/controller/shared/controller';
import { catchError, Observable, of, throwError } from 'rxjs';

export interface ParametroControllerChilds {
  forConfiguracaoParametro: () => ControllerBase<ConfiguracaoParametro>;
}

@Injectable({ providedIn: 'root' })
export class ParametroController extends Controller.Admin<Parametro> {
  protected readonly recurso = 'parametros';
  protected readonly mapper = Parametro.mapper;

  useChild(): ParametroControllerChilds {
    return {
      forConfiguracaoParametro: () => this.forChild<ConfiguracaoParametro>('', 'configuracao-parametro')
    };
  }

  buscarPorId = (parametro: Parametro.Identificador): Observable<Parametro> => 
    this.get('', { params: { parametro } });

  atualizarParaLocal(parametro: Parametro): Observable<Parametro> {
    return this.put('local', parametro);
  }

  excluirParaLocal(parametro: Parametro, localId: Id): Observable<Parametro> {
    return this.delete(`${parametro.id}/local`, { 
      params: { local: localId }, 
      responseType: this.responseType.JSON 
    });
  }

  getConfiguracaoParametro(parametro: Parametro.Identificador, local?: Id): Observable<ConfiguracaoParametro> {
    return this.get<ConfiguracaoParametro>('', { 
      params: { parametro, buscarConfiguracao: 'true', local } 
    }).pipe(
      catchError(erro => {
        const fallback = Parametro.getConfiguracaoParametroFallback(parametro, local);
        return fallback ? of(fallback) : throwError(() => erro);
      })
    );
  }
}
```

## Controller com Sub-recursos (Child Resources)

```typescript
import { Injectable } from '@angular/core';
import { Usuario, Lotacao } from '@modules/security/models';
import { Id } from '@shared';
import { ControllerBase } from '@shared/controller/core/controller.impl';
import { Controller } from '@shared/controller/shared/controller';
import { Observable } from 'rxjs';

export interface UsuarioControllerChilds {
  forLotacoes: (usuarioId: Id) => ControllerBase<Lotacao>;
}

@Injectable({ providedIn: 'root' })
export class UsuarioController extends Controller.Admin<Usuario> {
  protected readonly recurso = 'usuarios';
  protected readonly mapper = Usuario.mapper;

  useChild(): UsuarioControllerChilds {
    return {
      forLotacoes: (usuarioId) => this.forChild<Lotacao>(usuarioId, 'lotacoes')
    };
  }

  listarLotacoesPorUsuario(usuarioId: Id, page: number, size: number): Observable<Page<Lotacao>> {
    const lotacaoController = this.useChild().forLotacoes(usuarioId);
    return lotacaoController.listarPagina(page, size);
  }

  incluirLotacao(usuarioId: Id, lotacao: Lotacao): Observable<Lotacao> {
    const lotacaoController = this.useChild().forLotacoes(usuarioId);
    return lotacaoController.adicionar(lotacao);
  }

  atualizarLotacao(usuarioId: Id, lotacaoId: Id, lotacao: Lotacao): Observable<Lotacao> {
    const lotacaoController = this.useChild().forLotacoes(usuarioId);
    return lotacaoController.atualizar(lotacaoId, lotacao);
  }
}
```

## Controller com Upload/Download

```typescript
import { Injectable } from '@angular/core';
import { Documento } from '@modules/documento/models';
import { ControllerBase, RequestProgressResponse } from '@shared/controller/core/controller.impl';
import { Controller } from '@shared/controller/shared/controller';
import { Observable } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class DocumentoController extends Controller.Admin<Documento> {
  protected readonly recurso = 'documentos';
  protected readonly mapper = Documento.mapper;

  uploadArquivo(arquivo: File, metadados: Documento.Metadados): Observable<RequestProgressResponse<Documento>> {
    const formData = new FormData();
    formData.append('arquivo', arquivo);
    formData.append('metadados', JSON.stringify(metadados));
    
    return this.upload('upload', formData as unknown as Documento);
  }

  downloadArquivo(id: number): Observable<RequestProgressResponse<Blob>> {
    return this.download(`${id}/download`);
  }
}
```

## Controller com Ações Específicas

```typescript
import { Injectable } from '@angular/core';
import { Processo, Movimentacao } from '@modules/processo/models';
import { Id } from '@shared';
import { Controller } from '@shared/controller/shared/controller';
import { Observable } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class ProcessoController extends Controller.Admin<Processo> {
  protected readonly recurso = 'processos';
  protected readonly mapper = Processo.mapper;

  // Ação customizada - POST
  peticionarIntermediarias(id: Id, dados: Processo.Peticionamento): Observable<Processo> {
    return this.post(`${id}/peticionar-intermediarias`, dados);
  }

  // Ação customizada - PUT
  atualizarStatus(id: Id, status: Processo.Status): Observable<Processo> {
    return this.put(`${id}/status`, { status });
  }

  // Ação customizada - GET com params
  buscarPorNumero(numero: string, orgao: string): Observable<Processo> {
    return this.get('buscar', { params: { numero, orgao } });
  }

  // Listar com filtros
  listarPorFiltros(
    classeId: Id, 
    assuntoId: Id, 
    page: number, 
    size: number
  ): Observable<Page<Processo>> {
    return this.listarPagina(page, size, { classeId, assuntoId });
  }

  // Buscar movimentações do processo
  listarMovimentacoes(processoId: Id, page: number, size: number): Observable<Page<Movimentacao>> {
    return this.get<Page<Movimentacao>>(`${processoId}/movimentacoes`, { 
      params: { page, size } 
    });
  }
}
```

## Teste de Controller (Jest)

```typescript
import { TestBed } from '@angular/core/testing';
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';
import { ClasseController } from './classe.controller';
import { Classe } from '@modules/processo/models';
import { Page } from '@models';

describe('ClasseController', () => {
  let controller: ClasseController;
  let httpMock: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [ClasseController]
    });

    controller = TestBed.inject(ClasseController);
    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpMock.verify();
  });

  describe('Ao buscar uma classe', () => {
    it('Deve retornar a classe pelo ID', () => {
      const mockClasse = { id: 1, nome: 'Classe Teste' } as Classe;

      controller.buscarPorId(1).subscribe((classe) => {
        expect(classe).toEqual(mockClasse);
      });

      const req = httpMock.expectOne(expect.stringContaining('/classes/1'));
      expect(req.request.method).toBe('GET');
      req.flush(mockClasse);
    });
  });

  describe('Ao listar classes', () => {
    it('Deve retornar uma página de classes', () => {
      const mockPage: Page<Classe> = {
        content: [{ id: 1, nome: 'Classe 1' } as Classe],
        totalElements: 1,
        totalPages: 1,
        size: 10,
        number: 0
      };

      controller.listarPagina(0, 10).subscribe((page) => {
        expect(page.content.length).toBe(1);
        expect(page.content[0].nome).toBe('Classe 1');
      });

      const req = httpMock.expectOne(expect.stringContaining('/classes?page=0&size=10'));
      expect(req.request.method).toBe('GET');
      req.flush(mockPage);
    });
  });

  describe('Ao salvar uma classe', () => {
    it('Deve criar uma nova classe', () => {
      const novaClasse = { nome: 'Nova Classe' } as Classe;
      const classeCriada = { id: 1, nome: 'Nova Classe' } as Classe;

      controller.adicionar(novaClasse).subscribe((classe) => {
        expect(classe.id).toBe(1);
      });

      const req = httpMock.expectOne(expect.stringContaining('/classes'));
      expect(req.request.method).toBe('POST');
      req.flush(classeCriada);
    });
  });

  describe('Ao atualizar uma classe', () => {
    it('Deve atualizar a classe existente', () => {
      const classeAtualizada = { id: 1, nome: 'Classe Atualizada' } as Classe;

      controller.atualizar(1, classeAtualizada).subscribe((classe) => {
        expect(classe.nome).toBe('Classe Atualizada');
      });

      const req = httpMock.expectOne(expect.stringContaining('/classes/1'));
      expect(req.request.method).toBe('PUT');
      req.flush(classeAtualizada);
    });
  });

  describe('Ao excluir uma classe', () => {
    it('Deve excluir a classe pelo ID', () => {
      controller.excluir(1).subscribe((resultado) => {
        expect(resultado).toBe(true);
      });

      const req = httpMock.expectOne(expect.stringContaining('/classes/1'));
      expect(req.request.method).toBe('DELETE');
      req.flush(true);
    });
  });
});
```
