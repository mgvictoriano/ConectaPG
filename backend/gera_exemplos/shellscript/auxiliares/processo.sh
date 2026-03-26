#!/usr/bin/env bash

###################### Função para inserir Execução Fiscal #############################
fn_inserir_EF() {
  echo -e "\nINSERINDO EF $PROCESSO_NUMERO \n"

  processo=$(
    cat <<EOF
{
  "numero": "$PROCESSO_NUMERO",
  "juizadoEspecial": false,
  "eletronicoJudiciario": true,
  "segredoJustica": false,
  "dataAjuizamento": "$DATA_AJUIZAMENTO",
  "tipoProcesso": "JUDICIAL",
  "valor": $PROCESSO_VALOR,
  "assuntosCnj":[{"id":5952}],
  "pasta": {
    "materia": {
      "id": $MATERIA_EF
    },
    "assuntosInstituicao": [{
      "id": $ASSUNTO_INSTITUICAO_EF
    }],
    "situacoes" :[{"tipoSituacaoPasta":{"id":"CADASTRADA"}, "dataSituacao": "$ANO-$MES-$DIA$()T03:00:00.396"}]
  },
  "classe": {
    "id": 1116
  },
  "unidadeJudicial": {
    "id": $PROCESSO_UNIDADE_JUDICIAL_CAPITAL_EXECUCAO_FISCAL
  },
  "juizo": {
    "id": 598
  },
  "participacaoContraria": {
    "tipoParticipacao": {
      "id": $TIPO_PARTICIPACAO_PARTE_CONTRARIA_EXECUCAO_FISCAL
    },
    "pessoa": {
      "nomeIntegracao": {
        "nome": "$PROCESSO_NOME_PARTE_CONTRARIA"
      },
      "documentoPrincipal": {
        "tipo": "$TIPO_DOCUMENTO_PESSOA",
        "numero": "$PROCESSO_CPF_PARTE_CONTRARIA"
      },
      "enderecoPrincipal": {
        "logradouro": "Rua Silva Paes",
        "numero": 30,
        "bairro": "Centro",
        "cep": "88888-888",
        "municipioNome": "São Paulo",
        "uf": "SP"
      }
    }
  },
  "participacaoRepresentada": {
   "tipoParticipacao": {
      "id": $TIPO_PARTICIPACAO_PARTE_REPRESENTADA_EXECUCAO_FISCAL
    },
    "pessoa": $PESSOA_REPRESENTADA
  }
}
EOF
  )

  #  echo -e  "Json processo $processo \n"
  processo=$(curl --request POST $SERVIDOR_PROCESSO/processos/salvarsenaoexistir \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN" \
    --data "$processo")

  fn_calcular_id_processo_ou_mostrar_excecao

  # Inicial e CDA
  fn_inserir_andamento_inicial_EF
}

###################### Função para inserir Embargos a Execução Fiscal #############################
fn_inserir_embargos_EF() {
  echo -e "\nINSERINDO EMBARGO $PROCESSO_NUMERO \n"

  processo=$(
    cat <<EOF
{
  "numero": "$PROCESSO_NUMERO",
  "eletronicoJudiciario": true,
  "segredoJustica": false,
  "dataAjuizamento": "$DATA_AJUIZAMENTO",
  "processoPai": $processo,
  "tipoProcesso": "JUDICIAL",
  "assuntosCnj":[{"id":5952}],
  "classe": {
    "id": 1118
  },
  "unidadeJudicial": {
    "id": $PROCESSO_UNIDADE_JUDICIAL_CAPITAL_EXECUCAO_FISCAL
  },
  "juizadoEspecial": false,
  "juizo": {
    "id": 598
  },
  "participacaoContraria": {
    "tipoParticipacao": {
      "id": $TIPO_PARTICIPACAO_EMBARGANTE
    },
    "pessoa": {
      "nomeIntegracao": {
              "nome": "$PROCESSO_NOME_PARTE_CONTRARIA"
            },
      "documentoPrincipal": {
        "tipo": "CPF",
        "numero": "$PROCESSO_CPF_PARTE_CONTRARIA"
      },
      "enderecoPrincipal": {
        "logradouro": "Rua Silva Paes",
        "numero": 30,
        "bairro": "Centro",
        "cep": "88888-888",
        "municipioNome": "São Paulo",
        "uf": "SP"
      }
    }
  },
  "participacaoRepresentada": {
   "tipoParticipacao": {
      "id": $TIPO_PARTICIPACAO_EMBARGADO
    },
    "pessoa": $PESSOA_REPRESENTADA
  }
}
EOF
  )

  processo=$(curl --request POST $SERVIDOR_PROCESSO/processos/salvarsenaoexistir \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN" \
    --data "$processo")
  fn_calcular_id_processo_ou_mostrar_excecao

  # Intimacão Embargo
  fn_inserir_andamento_embargos_EF
}

###################### Função para inserir Contencioso #############################
fn_inserir_contencioso() {
  echo -e "\nINSERINDO CONTENCIOSO $PROCESSO_NUMERO \n"

  processo=$(
    cat <<EOF
{
  "numero": "$PROCESSO_NUMERO",
  "eletronicoJudiciario": true,
  "segredoJustica": false,
  "dataAjuizamento": "$DATA_AJUIZAMENTO",
  "juizadoEspecial": false,
  "tipoProcesso": "JUDICIAL",
  "assuntosCnj":[{"id":$ASSUNTO_CNJ}],
  "valor": $PROCESSO_VALOR,
  "pasta": {
    "materia": {
      "id": $MATERIA
    },
    "assuntosInstituicao": [{
      "id": $ASSUNTO
    }],
    "situacoes" :[{"tipoSituacaoPasta":{"id":"CADASTRADA"}, "dataSituacao": "$ANO-$MES-$DIA$()T03:00:00"}]
  },
  "classe": {
    "id": 7
  },
  "unidadeJudicial": {
    "id": $PROCESSO_UNIDADE_JUDICIAL_CAPITAL_FAZENDA_PUBLICA
  },
  "juizo": {
    "id": $VARA_DA_FAZENDA_PUBLICA
  },
  "participacaoContraria": {
    "tipoParticipacao": {
      "id": $TIPO_PARTICIPACAO_AUTOR
    },
    "pessoa": {
      "nomeIntegracao": {
                    "nome": "$PROCESSO_NOME_PARTE_CONTRARIA"
                  },
      "documentoPrincipal": {
        "tipo": "CPF",
        "numero": "$PROCESSO_CPF_PARTE_CONTRARIA"
      },
      "enderecoPrincipal": {
        "logradouro": "Rua Silva Paes",
        "numero": 30,
        "bairro": "Centro",
        "cep": "88888-888",
        "municipioNome": "São Paulo",
        "uf": "SP"
      }
    }
  },
  "participacaoRepresentada": {
   "tipoParticipacao": {
      "id": $TIPO_PARTICIPACAO_REU
    },
    "pessoa": $PESSOA_REPRESENTADA
  }
}
EOF
  )

  processo=$(curl --request POST $SERVIDOR_PROCESSO/processos/salvarsenaoexistir \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN" \
    --data "$processo")
  fn_calcular_id_processo_ou_mostrar_excecao
}


###################### Função para inserir Consultivo #############################
fn_inserir_consultivo() {
  echo -e "\nINSERINDO CONSULTIVO $PROCESSO_NUMERO \n"

  processo=$(
    cat <<EOF
{
  "numero": "$PROCESSO_NUMERO",
  "eletronicoJudiciario": true,
  "segredoJustica": false,
  "dataAjuizamento": "$DATA_AJUIZAMENTO",
  "juizadoEspecial": false,
  "tipoProcesso": "ADMINISTRATIVO",
  "valor": $PROCESSO_VALOR,
  "pasta": {
    "materia": {
      "id": $MATERIA
    },
    "assuntosInstituicao": [{
      "id": $ASSUNTO
    }],
    "situacoes" :[{"tipoSituacaoPasta":{"id":"CADASTRADA"}, "dataSituacao": "$ANO-$MES-$DIA$()T03:00:00"}]
  },
  "classe": {
    "id": 1298
  },
  "localOrigem": {
    "id": $LOCAL_ORIGEM
  },
  "participacaoContraria": {
    "tipoParticipacao": {
      "id": $TIPO_PARTICIPACAO_INTERESSADO
    },
    "pessoa": {
      "nomeIntegracao": {
                    "nome": "$PROCESSO_NOME_PARTE_CONTRARIA"
                  },
      "documentoPrincipal": {
        "tipo": "CPF",
        "numero": "$PROCESSO_CPF_PARTE_CONTRARIA"
      },
      "enderecoPrincipal": {
        "logradouro": "Rua Silva Paes",
        "numero": 30,
        "bairro": "Centro",
        "cep": "88888-888",
        "municipioNome": "São Paulo",
        "uf": "SP"
      }
    }
  }
}
EOF
  )

  processo=$(curl --request POST $SERVIDOR_PROCESSO/processos/salvarsenaoexistir \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN" \
    --data "$processo")
  fn_calcular_id_processo_ou_mostrar_excecao
}



#################### Função para calcular o id do processo ou mostrar exceção #############
fn_calcular_id_processo_ou_mostrar_excecao() {
  processoId=$(echo $processo | cut -f1 -d",")
  processoId=$(echo $processoId | cut -f2 -d":")
  processoId=${processoId//[[:blank:]]/}

  if [[ $processoId =~ ^[0-9]+$ ]]; then
    echo -e "\n************** Processo $PROCESSO_NUMERO cadastrado com Id $processoId *************\n"
  else
    echo $processo
    exit 1
  fi
}

###################### Função para inserir Juizado Especial #############################
fn_inserir_contenciosoJEF() {
  echo -e "\nINSERINDO CONTENCIOSO $PROCESSO_NUMERO \n"

  processo=$(
    cat <<EOF
{
  "numero": "$PROCESSO_NUMERO",
  "eletronicoJudiciario": true,
  "segredoJustica": false,
  "dataAjuizamento": "$DATA_AJUIZAMENTO",
  "juizadoEspecial": true,
  "tipoProcesso": "JUDICIAL",
  "assuntosCnj":[{"id":5952}],
  "valor": $PROCESSO_VALOR,
  "pasta": {
    "materia": {
      "id": $MATERIA_FISCAL_TRIBUTARIO
    },
    "assuntosInstituicao": [{
      "id": $ASSUNTO_INSTITUICAO_JUIZADO_ESPECIAL
    }],
    "situacoes" :[{"tipoSituacaoPasta":{"id":"CADASTRADA"}, "dataSituacao": "$ANO-$MES-$DIA$()T03:00:00"}]
  },
  "classe": {
    "id": 7
  },
  "unidadeJudicial": {
    "id": $PROCESSO_UNIDADE_JUDICIAL_CAPITAL_FAZENDA_PUBLICA
  },
  "juizo": {
    "id": 533
  },
  "participacaoContraria": {
    "tipoParticipacao": {
      "id": $TIPO_PARTICIPACAO_AUTOR
    },
    "pessoa": {
      "nomeIntegracao": {
                    "nome": "$PROCESSO_NOME_PARTE_CONTRARIA"
                  },
      "documentoPrincipal": {
        "tipo": "CPF",
        "numero": "$PROCESSO_CPF_PARTE_CONTRARIA"
      },
      "enderecoPrincipal": {
        "logradouro": "Rua Silva Paes",
        "numero": 30,
        "bairro": "Centro",
        "cep": "88888-888",
        "municipioNome": "São Paulo",
        "uf": "SP"
      }
    }
  },
  "participacaoRepresentada": {
   "tipoParticipacao": {
      "id": $TIPO_PARTICIPACAO_REU
    },
    "pessoa": $PESSOA_REPRESENTADA
  }
}
EOF
  )

  echo -e "\nProcesso a ser cadastrado $pocesso \n"
  processo=$(curl --request POST $SERVIDOR_PROCESSO/processos/salvarsenaoexistir \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN" \
    --data "$processo")
  fn_calcular_id_processo_ou_mostrar_excecao
}

########################z####### Função para Inserir Andamento com documento e anexo ##################
fn_inserir_andamento_com_documento_e_anexo() {
  echo -e "\nINSERINDO ANDAMENTO COM ANEXO E DOCUMENTO"

  arquivo=$(cat $ANDAMENTO_ARQUIVO_PRINCIPAL | base64)
  anexo=$(cat $ANDAMENTO_ARQUIVO_ANEXO | base64)

  documento=$(
    cat <<EOF
{
  "tipoAndamento":{"id":$ANDAMENTO_TIPO},
  "idOrigem":$ID_ORIGEM,
  "dataDisponibilizacao":"$ANO-$MES-$DIA$()T03:00:00",
  "dataAndamento":"$ANO-$MES-$DIA",
  "dataCiencia": "$ANO-$MES-$DIA$()T03:00:00",
  "complemento": " ",
  "processo": $processo,
  "origem": "$ANDAMENTO_ORIGEM",
  "origemClassificacao": "CONFIG",
  "documento": {
          "extensao":"PDF",
          "especie": "IMPORTADO",
          "nome":"$ANDAMENTO_NOME_DOCUMENTO",
          "totalSpace":289559,
          "arquivos":[{"totalSpace":289559,"bytes": "$arquivo"}],
          "anexos":[{
            "especie": "IMPORTADO",
            "tipoDocumento": {
                "id": 11
            },
            "extensao": "PDF",
            "nome": "Anexo",
            "totalSpace": 289559,
            "arquivos": [{
                "totalSpace": 289559,
                "bytes": "$anexo"
            }]
          }]
     }
}
EOF
  )
}

############################### Função para Inserir Andamento com documento e anexos com extensoes diferentes de .pdf ##################
fn_inserir_andamento_com_documento_e_anexos_adicionais() {
  echo -e "\nINSERINDO ANDAMENTO COM ANEXO ADICIONAIS E DOCUMENTO"

  arquivo=$(cat $ANDAMENTO_ARQUIVO_PRINCIPAL | base64)
  anexo_imagem=$(cat $ANDAMENTO_ARQUIVO_ANEXO_IMAGEM | base64)
  anexo_txt=$(cat $ANDAMENTO_ARQUIVO_ANEXO_TEXTO | base64)
  anexo_video=$(cat $ANDAMENTO_ARQUIVO_ANEXO_VIDEO | base64)

  documento=$(
    cat <<EOF
{
  "tipoAndamento":{"id":$ANDAMENTO_TIPO},
  "idOrigem":$ID_ORIGEM,
  "dataDisponibilizacao":"$ANO-$MES-$DIA$()T03:00:00",
  "dataAndamento":"$ANO-$MES-$DIA",
  "dataCiencia": "$ANO-$MES-$DIA$()T03:00:00",
  "complemento": " ",
  "processo": $processo,
  "origem": "$ANDAMENTO_ORIGEM",
  "origemClassificacao": "CONFIG",
  "documento": {
          "extensao":"PDF",
          "especie": "IMPORTADO",
          "nome":"$ANDAMENTO_NOME_DOCUMENTO",
          "arquivos":[{"bytes": "$arquivo"}],
          "anexos":[
            {
              "especie": "IMPORTADO",
              "tipoDocumento": {"id": 11},
              "extensao": "PNG",
              "nome": "Exemplo anexo imagem",
              "arquivos": [{"bytes": "$anexo_imagem"}]
            },
            {
              "especie": "IMPORTADO",
              "tipoDocumento": {"id": 11},
              "extensao": "TXT",
              "nome": "Exemplo anexo txt",
              "arquivos": [{"bytes": "$anexo_txt"}]
            },
            {
              "especie": "IMPORTADO",
              "tipoDocumento": {"id": 11},
              "extensao": "MP4",
              "nome": "Exemplo anexo video",
              "arquivos": [{"bytes": "$anexo_video"}]
            }
          ]
     }
}
EOF
  )

  ANDAMENTO_ARQUIVO_ANEXO_IMAGEM=""
  ANDAMENTO_ARQUIVO_ANEXO_TEXTO=""
  ANDAMENTO_ARQUIVO_ANEXO_VIDEO=""
  INCLUIR_ANEXOS_ADICIONAIS=false
}

############################### Função para Inserir Andamento com documento sem anexo ##################
fn_inserir_andamento_com_documento_sem_anexo() {
  echo -e "\nINSERINDO ANDAMENTO COM DOCUMENTO SEM ANEXO"

  arquivo=$(cat $ANDAMENTO_ARQUIVO_PRINCIPAL | base64)

  documento=$(
    cat <<EOF
{
  "tipoAndamento":{"id":$ANDAMENTO_TIPO},
  "idOrigem":$ID_ORIGEM,
  "dataDisponibilizacao":"$ANO-$MES-$DIA$()T03:00:00",
  "dataAndamento":"$ANO-$MES-$DIA",
  "dataCiencia": "$ANO-$MES-$DIA$()T03:00:00",
  "complemento": " ",
  "processo": $processo,
  "origem": "$ANDAMENTO_ORIGEM",
  "origemClassificacao": "CONFIG",
  "documento": {
      "extensao":"PDF",
      "nome":"$ANDAMENTO_NOME_DOCUMENTO",
      "especie":"IMPORTADO",
      "totalSpace":289559,
      "arquivos":[{"totalSpace":289559,"bytes": "$arquivo"}]
  }
}
EOF
  )

}

############################### Função para Inserir Andamento sem documento ##################
fn_inserir_andamento_sem_documento() {
  echo -e "\nINSERINDO ANDAMENTO SEM DOCUMENTO"

  documento=$(
    cat <<EOF
{
  "tipoAndamento":{"id":$ANDAMENTO_TIPO},
  "idOrigem":$ID_ORIGEM,
  "dataDisponibilizacao":"$ANO-$MES-$DIA$()T03:00:00",
  "dataAndamento":"$ANO-$MES-$DIA",
  "dataCiencia": "$ANO-$MES-$DIA$()T03:00:00",
  "complemento": " ",
  "processo": $processo,
  "origem": "$ANDAMENTO_ORIGEM",
  "origemClassificacao": "CONFIG"
}
EOF
  )
    echo "$documento"
}

############################### Função para Inserir Andamento ##################
fn_inserir_andamento() {
  ID_ORIGEM=$((ID_ORIGEM + 1))

  if [[ $ANDAMENTO_TIPO =~ ^[0-9]+$ ]]; then
    echo -e "\n************** TIPO DE ANDAMENTO $ANDAMENTO_TIPO *************\n"
  else
    echo Tipo de andamento inválido $ANDAMENTO_TIPO
    exit 1
  fi

  echo -e "ANDAMENTO_ARQUIVO_PRINCIPAL $ANDAMENTO_ARQUIVO_PRINCIPAL"
  echo -e "ANDAMENTO_ARQUIVO_ANEXO $ANDAMENTO_ARQUIVO_ANEXO"

  if [ "$INCLUIR_ANEXOS_ADICIONAIS" = true ]; then
    fn_inserir_andamento_com_documento_e_anexos_adicionais
  elif [ -e "$ANDAMENTO_ARQUIVO_PRINCIPAL" ] && [ -e "$ANDAMENTO_ARQUIVO_ANEXO" ]; then
    fn_inserir_andamento_com_documento_e_anexo
  elif [ -e "$ANDAMENTO_ARQUIVO_PRINCIPAL" ]; then
    fn_inserir_andamento_com_documento_sem_anexo
  else
    fn_inserir_andamento_sem_documento
  fi

  echo -e $documento >>documento.json

  STATUS=$(curl -s -o response.txt -w "%{http_code}" --request POST "$SERVIDOR_DEMANDA/bpm/andamentorecebido" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN" \
    --data @documento.json)

  if [ $STATUS -ne 200 ]; then
    echo -e "\n******* Erro ao inserir andamento recebido para o processo $PROCESSO_NUMERO ******** \n"
    echo "$(cat response.txt)"
    curl --request POST "$SERVIDOR_DEMANDA/bpm/andamentorecebido" \
      --header "Content-type: application/json" \
      --header "Authorization: Bearer $TOKEN" \
      --data @documento.json
    exit 1
  fi
  rm -f documento.json

  ANDAMENTO_ARQUIVO_PRINCIPAL=""
  ANDAMENTO_ARQUIVO_ANEXO=""
}

############################### Função para Inserir Andamento Inicial de EF##################
fn_inserir_andamento_inicial_EF() {
  echo -e "\nINSERINDO ANDAMENTO INICIAL EF"
  ANDAMENTO_NOME_DOCUMENTO="Inicial de execução fiscal"
  ANDAMENTO_TIPO=$TIPO_ANDAMENTO_PETICAO_INICIAL
  ANDAMENTO_ORIGEM="INTERNA"
  ANDAMENTO_ARQUIVO_PRINCIPAL="./documentos/$PROCESSO_NUMERO$()_inicial.pdf"
  ANDAMENTO_ARQUIVO_ANEXO="./documentos/$PROCESSO_NUMERO$()_CDA.pdf"
  echo $ANDAMENTO_ARQUIVO_PRINCIPAL
  echo $ANDAMENTO_ARQUIVO_ANEXO
  echo Tipo de andamento $ANDAMENTO_TIPO
  fn_inserir_andamento
}

############################### Função para Inserir Andamento Exceção pré-executividade ##################
fn_inserir_andamento_excecao_pre() {
  echo -e "\nINSERINDO ANDAMENTO EXCEÇÃO DE PRÉ-EXECUTIVIDADE"
  ANDAMENTO_NOME_DOCUMENTO="Intimaçao Exceção de Pré-executividade"
  ANDAMENTO_TIPO=$([ "$USAR_WATSON" = true ] && echo $TIPO_ANDAMENTO_INTIMACAO_NAO_CATEGORIZADA || echo $TIPO_ANDAMENTO_EXCECAO_PRE_EXECUTIVIDADE)
  echo tipo andamento $ANDAMENTO_TIPO
  ANDAMENTO_ORIGEM="MANUAL"

  ANDAMENTO_ARQUIVO_PRINCIPAL="./documentos/$PROCESSO_NUMERO$()_intimacao-excecao-de-pre-executividade.pdf"
  ANDAMENTO_ARQUIVO_ANEXO="./documentos/$PROCESSO_NUMERO$()_inicial-excecao-de-pre-executividade.pdf"
  fn_inserir_andamento
}

############################### Função para Inserir Andamento Dívida Paga ##################
fn_inserir_andamento_divida_paga() {
  echo -e "\nINSERINDO ANDAMENTO DÍVIDA PAGA"
  ANDAMENTO_TIPO=$GERA_EXEMPLOS_TIPO_ANDAMENTO_DIVIDA_PAGA
  ANDAMENTO_ORIGEM="MANUAL"
  fn_inserir_andamento
}

############################### Função para Inserir Andamento Parcelamento concedido ##################
fn_inserir_andamento_divida_parcelada() {
  echo -e "\nINSERINDO ANDAMENTO DÍVIDA PARCELADA"
  ANDAMENTO_TIPO=$GERA_EXEMPLOS_TIPO_ANDAMENTO_DIVIDA_PARCELADA
  ANDAMENTO_ORIGEM="INTEGRACAO_FAZENDA"
  fn_inserir_andamento
}

############################### Função para Inserir Andamento Parcelamento Rompido ##################
fn_inserir_andamento_parcelamento_rompido() {
  echo -e "\nINSERINDO ANDAMENTO PARCELAMENTO ROMPIDO"
  ANDAMENTO_TIPO=$GERA_EXEMPLOS_TIPO_ANDAMENTO_PARCELAMENTO_ROMPIDO
  ANDAMENTO_ORIGEM="INTEGRACAO_FAZENDA"
  fn_inserir_andamento
}

############################### Função para Inserir Andamento Dívida Cancelada ##################
fn_inserir_andamento_divida_cancelada() {
  echo -e "\nINSERINDO ANDAMENTO DÍVIDA CANCELADA"
  ANDAMENTO_TIPO=$GERA_EXEMPLOS_TIPO_ANDAMENTO_CDA_CANCELADA
  ANDAMENTO_ORIGEM="INTEGRACAO_FAZENDA"
  fn_inserir_andamento
}

############################### Função para Inserir Andamento Embargos a Execução Fiscal ##################
fn_inserir_andamento_embargos_EF() {
  echo -e "\nINSERINDO ANDAMENTO EMBARGOS EF"
  ANDAMENTO_NOME_DOCUMENTO="Intimaçao Embargos"
  ANDAMENTO_TIPO=$([ "$USAR_WATSON" = true ] && echo $TIPO_ANDAMENTO_INTIMACAO_NAO_CATEGORIZADA || echo $TIPO_ANDAMENTO_EMBARGO_EXECUCAO_FISCAL)
  ANDAMENTO_ORIGEM="MANUAL"
  ANDAMENTO_ARQUIVO_PRINCIPAL="./documentos/$PROCESSO_NUMERO$()_intimacao-embargos-ef.pdf"
  ANDAMENTO_ARQUIVO_ANEXO="./documentos/$PROCESSO_NUMERO$()_inicial-embargos-ef.pdf"
  fn_inserir_andamento
}

############################### Função para Inserir Andamento Citação ##################
fn_inserir_andamento_citacao() {
  echo -e "\nINSERINDO ANDAMENTO CITAÇÃO"
  ANDAMENTO_NOME_DOCUMENTO="Citação"
  ANDAMENTO_TIPO=$([ "$USAR_WATSON" = true ] && echo $TIPO_ANDAMENTO_CITACAO_NAO_CATEGORIZADA || echo $TIPO_ANDAMENTO_CITACAO)
  ANDAMENTO_ORIGEM="MANUAL"
  ANDAMENTO_ARQUIVO_PRINCIPAL="./documentos/$PROCESSO_NUMERO$()_citacao.pdf"
  ANDAMENTO_ARQUIVO_ANEXO="./documentos/$PROCESSO_NUMERO$()_inicial.pdf"
  fn_inserir_andamento
}

############################### Função para Inserir Andamento Citação com tutela ##################
fn_inserir_andamento_citacao_tutela() {
  echo -e "\nINSERINDO ANDAMENTO CITAÇÃO COM TUTELA"
  ANDAMENTO_NOME_DOCUMENTO="Citação com tutela antecipada"
  ANDAMENTO_TIPO=$([ "$USAR_WATSON" = true ] && echo $TIPO_ANDAMENTO_CITACAO_NAO_CATEGORIZADA || echo $TIPO_ANDAMENTO_CITACAO_TUTELA)
  ANDAMENTO_ORIGEM="MANUAL"
  ANDAMENTO_ARQUIVO_PRINCIPAL="./documentos/$PROCESSO_NUMERO$()_citacao.pdf"
  ANDAMENTO_ARQUIVO_ANEXO="./documentos/$PROCESSO_NUMERO$()_inicial.pdf"
  fn_inserir_andamento
}

############################### Função para Inserir Andamento Citação com tutela e manifestação prévia ##################
fn_inserir_andamento_citacao_tutela_previa() {
  echo -e "\nINSERINDO ANDAMENTO CITAÇÃO COM TUTELA E MANIFESTAÇÃO PRÉVIA"
  ANDAMENTO_NOME_DOCUMENTO="Citação com tutela antecipada"
  ANDAMENTO_TIPO=$([ "$USAR_WATSON" = true ] && echo $TIPO_ANDAMENTO_CITACAO_NAO_CATEGORIZADA || echo $TIPO_ANDAMENTO_CITACAO_INTIMACAO_PREVIA)
  ANDAMENTO_ORIGEM="MANUAL"
  ANDAMENTO_ARQUIVO_PRINCIPAL="./documentos/$PROCESSO_NUMERO$()_citacao.pdf"
  ANDAMENTO_ARQUIVO_ANEXO="./documentos/$PROCESSO_NUMERO$()_inicial.pdf"
  fn_inserir_andamento
}

############################### Função para Inserir Andamento Contestacao ##################
fn_inserir_andamento_contestacao() {
  echo -e "\nINSERINDO ANDAMENTO CONTESTACAO"
  ANDAMENTO_NOME_DOCUMENTO="Contestacao"
  ANDAMENTO_TIPO=$TIPO_ANDAMENTO_CONTESTACAO
  ANDAMENTO_ORIGEM="INTERNA"
  ANDAMENTO_ARQUIVO_PRINCIPAL="./documentos/$PROCESSO_NUMERO$()_contestacao.pdf"

  if [ "$INCLUIR_ANEXOS_ADICIONAIS" = true ]; then
    ANDAMENTO_ARQUIVO_ANEXO_IMAGEM="./documentos/exemplo_anexo_imagem.png"
    ANDAMENTO_ARQUIVO_ANEXO_TEXTO="./documentos/exemplo_anexo_texto.txt"
    ANDAMENTO_ARQUIVO_ANEXO_VIDEO="./documentos/exemplo_anexo_video.mp4"
  fi

  fn_inserir_andamento
}

############################### Função para Inserir Andamento Sentença ##################
fn_inserir_andamento_sentenca() {
  echo -e "\nINSERINDO ANDAMENTO SENTENCA"
  ANDAMENTO_NOME_DOCUMENTO="Sentença"
  ANDAMENTO_TIPO=$([ "$USAR_WATSON" = true ] && echo $TIPO_ANDAMENTO_INTIMACAO_NAO_CATEGORIZADA || echo $TIPO_ANDAMENTO_SENTENCA_DESFAVORAVEL)
  ANDAMENTO_ORIGEM="MANUAL"
  ANDAMENTO_ARQUIVO_PRINCIPAL="./documentos/$PROCESSO_NUMERO$()_sentenca.pdf"
  fn_inserir_andamento
}

############################### Função para Inserir Andamento Audiência Designada ##################
fn_inserir_andamento_audiencia() {
  echo -e "\nINSERINDO ANDAMENTO AUDIENCIA"
  ANDAMENTO_NOME_DOCUMENTO="Audiência"
  ANDAMENTO_TIPO=$([ "$USAR_WATSON" = true ] && echo $TIPO_ANDAMENTO_INTIMACAO_NAO_CATEGORIZADA || echo $TIPO_ANDAMENTO_SENTENCA_DESFAVORAVEL)
  ANDAMENTO_ORIGEM="MANUAL"
  ANDAMENTO_ARQUIVO_PRINCIPAL="./documentos/$PROCESSO_NUMERO$()_audienciadesignada.pdf"
  fn_inserir_andamento
}

############################### Função para Inserir Andamento Avaliação de Parecer Jurídico requerida ##################
fn_inserir_andamento_avaliacao_parecer_requerida() {
  echo -e "\nINSERINDO ANDAMENTO DE AVALIÇÃO DE PARECER JURÍDICO REQUERIDA"
  ANDAMENTO_NOME_DOCUMENTO="Avaliação de Parecer Jurídico requerida"
  ANDAMENTO_TIPO=$TIPO_ANDAMENTO_AVALIACAO_PARECER_REQUERIDA
  ANDAMENTO_ORIGEM="MANUAL"
  ANDAMENTO_ARQUIVO_PRINCIPAL="./documentos/$PROCESSO_NUMERO$()_processo.pdf"

  fn_inserir_andamento
}

############################## Apagar processos #################################
fn_apagar_processos() {

  echo Apagando processos...

  PROCESSO_EXCLUIDO=$(curl --request DELETE $SERVIDOR_PROCESSO/processos/qualquer \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")

  while [[ $PROCESSO_EXCLUIDO == *"@"* ]]; do
    echo -e "\nexcluiu o processo : $PROCESSO_EXCLUIDO"
    PROCESSO_EXCLUIDO=$(curl --request DELETE $SERVIDOR_PROCESSO/processos/qualquer \
      --header "Content-type: application/json" \
      --header "Authorization: Bearer $TOKEN")
  done

  if [ "$PROCESSO_EXCLUIDO" != "" ]; then
    echo -e Erro ao excluir processos \n
    echo -e $PROCESSO_EXCLUIDO
    exit 1
  fi
}

fn_processo_buscar_processo_por_numero(){
     response=$(curl --request GET "$SERVIDOR_PROCESSO/processos?search=_all%3D%3D%27*$PROCESSO_NUMERO*%27" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")

    listaProcessos=$(jq -r '.content' <<< "$response")
    echo "$listaProcessos"
}

fn_processo_buscar_pasta_digital_por_numero_processo(){
  pastaNumero=$(jq -r '.[0].pasta.numero' <<< "$PROCESSOS")
  pastaDto=$(curl --request GET "$SERVIDOR_PROCESSO/pastadigital?numero=$pastaNumero" \
        --header "Content-type: application/json" \
        --header "Authorization: Bearer $TOKEN")

    echo "$pastaDto"
}