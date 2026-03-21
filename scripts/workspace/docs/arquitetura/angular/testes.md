# Testes BDD Angular — Attus

Guia de testes Behavior Driven Development (BDD) para Angular (Jest).

---

## Estrutura BDD

Usar `describe` aninhados para hierarquia de cenários e nomenclatura em **PT-BR**.

## Template de Teste - Service

```typescript
import { TestBed } from '@angular/core/testing';
import { of, throwError } from 'rxjs';

import { UsuarioService } from './usuario.service';
import { UsuarioController } from './usuario.controller';

describe('UsuarioService', () => {
  let service: UsuarioService;
  let controller: jest.Mocked<UsuarioController>;

  beforeEach(() => {
    const controllerMock = {
      buscarPorId: jest.fn(),
      salvar: jest.fn(),
      listarAtivos: jest.fn()
    };

    TestBed.configureTestingModule({
      providers: [
        UsuarioService,
        { provide: UsuarioController, useValue: controllerMock }
      ]
    });

    service = TestBed.inject(UsuarioService);
    controller = TestBed.inject(UsuarioController) as jest.Mocked<UsuarioController>;
  });

  describe('Ao inicializar', () => {
    it('Deve ter lista de usuários vazia', () => {
      expect(service.usuarios()).toEqual([]);
    });

    it('Deve ter indicador de carregamento como falso', () => {
      expect(service.isCarregando()).toBe(false);
    });
  });

  describe('Quando buscar por ID', () => {
    describe('Dado que o usuário existe', () => {
      it('Deve retornar o usuário e atualizar o signal', () => {
        // arrange
        const usuario = { id: 1, nome: 'João' };
        controller.buscarPorId.mockReturnValue(of(usuario));

        // act
        service.buscarPorId(1);

        // assert
        expect(service.usuarioSelecionado()).toEqual(usuario);
        expect(controller.buscarPorId).toHaveBeenCalledWith(1);
      });
    });

    describe('Dado que ocorre erro', () => {
      it('Deve atualizar signal de erro', () => {
        // arrange
        controller.buscarPorId.mockReturnValue(throwError(() => new Error('Erro')));

        // act
        service.buscarPorId(1);

        // assert
        expect(service.erro()).toBe('Erro ao buscar usuário');
      });
    });
  });

  describe('Quando salvar usuário', () => {
    describe('Dado dados válidos', () => {
      it('Deve salvar e adicionar à lista', () => {
        // arrange
        const novoUsuario = { nome: 'João', email: 'joao@teste.com' };
        const usuarioSalvo = { id: 1, ...novoUsuario };
        controller.salvar.mockReturnValue(of(usuarioSalvo));

        // act
        service.salvar(novoUsuario);

        // assert
        expect(service.usuarios()).toContainEqual(usuarioSalvo);
      });
    });
  });
});
```

## Template de Teste - Component

```typescript
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { UsuarioListComponent } from './usuario-list.component';
import { UsuarioService } from './usuario.service';

// Mocks
const mockUsuarioService = {
  usuarios: jest.fn().mockReturnValue([]),
  isCarregando: jest.fn().mockReturnValue(false),
  carregarUsuarios: jest.fn()
};

describe('UsuarioListComponent', () => {
  let component: UsuarioListComponent;
  let fixture: ComponentFixture<UsuarioListComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [UsuarioListComponent],
      providers: [
        { provide: UsuarioService, useValue: mockUsuarioService }
      ]
    }).compileComponents();

    fixture = TestBed.createComponent(UsuarioListComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  describe('Ao inicializar', () => {
    it('Deve criar o componente', () => {
      expect(component).toBeTruthy();
    });

    it('Deve carregar usuários automaticamente', () => {
      expect(mockUsuarioService.carregarUsuarios).toHaveBeenCalled();
    });
  });

  describe('Quando clicar em novo usuário', () => {
    it('Deve abrir formulário', () => {
      // arrange
      const abrirSpy = jest.spyOn(component, 'abrirFormulario');

      // act
      component.onNovoUsuario();

      // assert
      expect(abrirSpy).toHaveBeenCalled();
    });
  });
});
```

## Nomenclatura de Testes

| Elemento | Padrão | Exemplo |
|----------|--------|---------|
| describe contexto | `Ao {acao}` ou `Dado {condicao}` | `Ao inicializar`, `Dado usuário logado` |
| describe ação | `Quando {acao}` | `Quando buscar por ID`, `Quando salvar` |
| it | `Deve {resultado}` | `Deve retornar o usuário`, `Deve lançar erro` |

## Padrão Arrange-Act-Assert

```typescript
// Arrange (preparação)
const dados = { ... };
mock.metodo.mockReturnValue(of(resultado));

// Act (ação)
service.metodo();

// Assert (verificação)
expect(service.signal()).toEqual(esperado);
```

---

## Cobertura de Testes

### Metas Attus

- **Frontend:** > 80% cobertura
- **Camadas obrigatórias:**
  - Service (regras de negócio)
  - Component (interações do usuário)

### O Que Testar

| Camada | Obrigatório | Prioridade |
|--------|-------------|------------|
| Service | Sim | Alta - regras de negócio |
| Component | Sim | Alta - interações |

### O Que NÃO Testar

- Frameworks (Angular)
- Configurações
- Métodos privados (testar via públicos)
