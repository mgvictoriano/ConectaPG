# Scripts

Scripts utilitários compartilhados do workspace.

## Pré-requisitos

- **yq** — necessário para parsing do catálogo YAML (usado por `clone-all.sh`)
  ```bash
  sudo snap install yq
  ```

## Estrutura de projetos clonados

Todos os projetos são clonados **flat** em `projetos/`, sem hierarquia de grupo ou diretório.
A organização por grupos/diretórios existe apenas em `catalogo/services.yaml` para montar as URLs de clone.

```
projetos/
├── admin/
├── agendador/
├── calculo/
├── lib-core/
├── scripts/
├── sda/
└── ...
```

## Scripts de Git (`scripts/git/`)

Todos os scripts aceitam `--filter nome1,nome2` para operar em projetos específicos.

### `clone-all.sh`
Clona todos os projetos listados em `catalogo/services.yaml`.

```bash
./scripts/git/clone-all.sh                          # Clona todos
./scripts/git/clone-all.sh --filter admin,security   # Clona apenas os especificados
```

### `pull-all.sh`
Executa `git pull --rebase` em todos os projetos clonados.

```bash
./scripts/git/pull-all.sh                            # Atualiza todos
./scripts/git/pull-all.sh --filter demanda,processo  # Atualiza apenas os especificados
```

### `switch-branch.sh`
Troca a branch de todos os projetos. Tenta checkout local primeiro, depois tracking remoto.

```bash
./scripts/git/switch-branch.sh develop                   # Troca todos para develop
./scripts/git/switch-branch.sh feature/x --filter admin  # Troca apenas admin
```

### `status-all.sh`
Exibe uma tabela resumida com branch atual e status de cada projeto.

```bash
./scripts/git/status-all.sh
```

Saída exemplo:
```
PROJETO                        BRANCH                    STATUS       PENDÊNCIAS
-------                        ------                    ------       ----------
admin                          develop                   limpo        -
demanda                        feature/nova-tela         modificado   3 arquivo(s)
sda                            develop                   limpo        -
lib-core                       main                      limpo        -
```
