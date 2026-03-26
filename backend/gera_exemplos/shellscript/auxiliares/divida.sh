#!/usr/bin/env bash

############################### Função para Inserir Divida vinculada a uma EF ##################
fn_inserir_divida_para_ajuizamento() {
  echo -e "INSERINDO DIVIDA PARA AJUIZAMENTO"

  divida=$(
    cat <<EOF
{
  "numero": "$DIVIDA_NUMERO",
  "dataBase" : "$ANO",
  "livro": "1",
  "folha": "1",
  "exercicios": [
      {
          "ano": $ANO,
          "vencimento": "$ANO-$MES-$DIA$()T03:00:00"
      }
  ],
  "tributo": {
              "identificadorNoCliente": 1
          },
  "composicoes": [
      {
          "valor": "$PROCESSO_VALOR.0",
          "valorTotalFato": $PROCESSO_VALOR.0,
          "valorTotalAtual": $PROCESSO_VALOR.0,
          "valorJurosAtual": 0.0,
          "valorMultaFato": 0.0,
          "indiceCalculo" : "0.0",
          "parcela": "1",
          "dataVencimentoFato": "$DIVIDA_DATA_VENCIMENTO_COMPOSICAO",
          "numero": "$DIVIDA_NUMERO",
          "tributo": {
              "identificadorNoCliente": 1,
              "nome": "IPTU"
          },
          "situacaoAtual": {
                "tipo": {
                    "nome": "Aberto",
                    "id": $DIVIDA_TIPO_SITUACAO_ABERTA
                }
            }
      }
  ],
  "fato": "INTERPRETAÇÃO DO CÁLCULO DA DÍVIDA ATIVA",
  "dataInscricao": "$ANO-$MES-$DIA$()T03:00:00",
  "dataAtualizacaoValores": "$DIVIDA_DATA_ATUALIZACAO_VALORES",
  "dataCienciaFato": "$ANO-$MES-$DIA$()T03:00:00",
  "valorTotalFato": $PROCESSO_VALOR.0,
  "valorTotalAtual": $PROCESSO_VALOR.0,
  "valorMultaAtual": 0.0,
  "valorJurosAtual": 0.0,
  "valorTotalInscricao": 0.0,
  "valorCorrecaoAtual": 0.0,
  "valorCorrecaoFato": 0.0,
  "valorCorrecaoImpostoAtual": 0.0,
  "valorCorrecaoImpostoFato": 0.0,
  "valorCorrecaoImpostoInscricao": 0.0,
  "valorCorrecaoInscricao": 0.0,
  "valorCorrecaoMultaAtual": 0.0,
  "valorCorrecaoMultaFato": 0.0,
  "valorCorrecaoMultaInscricao": 0.0,
  "valorImpostoAtual": 0.0,
  "valorImpostoFato": 0.0,
  "valorImpostoInscricao": 0.0,
  "valorJurosFato": 0.0,
  "valorJurosImpostoAtual": 0.0,
  "valorJurosImpostoFato": 0.0,
  "valorJurosImpostoInscricao": 0.0,
  "valorJurosInscricao": 0.0,
  "valorJurosMultaAtual": 0.0,
  "valorJurosMultaFato": 0.0,
  "valorJurosMultaInscricao": 0.0,
  "valorMultaFato": 0.0,
  "valorMultaInscricao": 0.0,
  "identificador": "$DIVIDA_IDENTIFICADOR",
  "categoria": {
      "id": 1,
      "nome": "Imobiliário Tributário",
      "identificadorNoCliente": 1
  },
   "endereco": {
      "logradouro": "$DIVIDA_ENDERECO_LOGRADOURO",
      "numero": "$DIVIDA_ENDERECO_NUMERO",
      "bairro": "$DIVIDA_ENDERECO_BAIRRO",
      "cep": "$DIVIDA_ENDERECO_CEP",
      "uf": "$DIVIDA_ENDERECO_UF",
      "municipio": {
          "id": $DIVIDA_ENDERCO_MUNICIPIO_ID
      },
      "higienizado": false,
      "enriquecido": false,
      "origem": "DIVIDA_ATIVA",
      "qualificacao": "NAO_PESQUISADO"
  },
  "devedor": {
      "nomeIntegracao": {
                          "nome": "$PROCESSO_NOME_PARTE_CONTRARIA"
                        },
      "documentoPrincipal": {
          "tipo": "CPF",
          "numero": "$PROCESSO_CPF_PARTE_CONTRARIA"
      },
      "possuiCnpjCpf": true,
      "cpfCnpjValido": true,
      "juridica": false,
      "enderecoValidoParaCitacao": false,
      "enderecoPassivelAjuizamento": false,
      "version": 1
  },
  "situacaoAtual": {
      "tipo": {
          "id": $DIVIDA_TIPO_SITUACAO_ABERTA,
          "nome": "Aberta",
          "categoria": "ABERTA"
      },
      "dataSituacao": "$ANO-$MES-$DIA$()T03:00:00",
      "mensagemId": 1
  },
  "aberta": false,
  "ajuizamentoFazenda": true,
  "orgaoOrigemId": $DIVIDA_ORGAO_ORIGEM_ID
}
EOF
  )

  echo $divida >>divida.json
  STATUS=$(curl -s -o response.txt -w "%{http_code}" --request POST "$SERVIDOR_DIVIDA/dividas" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN" \
    --data @divida.json)

  if [ $STATUS -ne 200 ]; then
    echo "******* Erro ao inserir divida $DIVIDA_NUMERO ******** \n"
    echo "$(cat response.txt)"
    curl --request POST "$SERVIDOR_DIVIDA/dividas" \
      --header "Content-type: application/json" \
      --header "Authorization: Bearer $TOKEN" \
      --data @divida.json
    exit 1
  fi
  rm -f divida.json

}

############################### Função para Inserir Divida vinculada a uma EF ##################
fn_inserir_divida() {
  echo -e "INSERINDO DIVIDA"

  divida=$(
    cat <<EOF
{
  "numero": "$DIVIDA_NUMERO",
  "dataBase" : "$ANO",
  "livro": "1",
  "folha": "1",
  "ajuizamento": {
      "numeroJudicial": "$PROCESSO_NUMERO"
  },
  "exercicios": [
      {
          "ano": $ANO,
          "vencimento": "$ANO-$MES-$DIA$()T03:00:00"
      }
  ],
  "tributo": {
              "identificadorNoCliente": 1
          },
  "composicoes": [
      {
          "valor": "$PROCESSO_VALOR.0",
          "valorTotalFato": $PROCESSO_VALOR.0,
          "valorTotalAtual": $PROCESSO_VALOR.0,
          "valorJurosAtual": 0.0,
          "valorMultaFato": 0.0,
          "indiceCalculo" : "0.0",
          "parcela": "1",
          "dataVencimentoFato": "$DIVIDA_DATA_VENCIMENTO_COMPOSICAO",
          "numero": "$DIVIDA_NUMERO",
          "tributo": {
              "identificadorNoCliente": 1,
              "nome": "IPTU"
          },
          "situacaoAtual": {
                "tipo": {
                    "nome": "Aberto",
                    "id": $DIVIDA_TIPO_SITUACAO_ABERTA
                }
            }
      }
  ],
  "fato": "INTERPRETAÇÃO DO CÁLCULO DA DÍVIDA ATIVA",
  "dataInscricao": "$ANO-$MES-$DIA$()T03:00:00",
  "dataAtualizacaoValores": "$DIVIDA_DATA_ATUALIZACAO_VALORES",
  "dataCienciaFato": "$ANO-$MES-$DIA$()T03:00:00",
  "valorTotalFato": $PROCESSO_VALOR.0,
  "valorTotalAtual": $PROCESSO_VALOR.0,
  "valorMultaAtual": 0.0,
  "valorJurosAtual": 0.0,
  "valorTotalInscricao": 0.0,
  "valorCorrecaoAtual": 0.0,
  "valorCorrecaoFato": 0.0,
  "valorCorrecaoImpostoAtual": 0.0,
  "valorCorrecaoImpostoFato": 0.0,
  "valorCorrecaoImpostoInscricao": 0.0,
  "valorCorrecaoInscricao": 0.0,
  "valorCorrecaoMultaAtual": 0.0,
  "valorCorrecaoMultaFato": 0.0,
  "valorCorrecaoMultaInscricao": 0.0,
  "valorImpostoAtual": 0.0,
  "valorImpostoFato": 0.0,
  "valorImpostoInscricao": 0.0,
  "valorJurosFato": 0.0,
  "valorJurosImpostoAtual": 0.0,
  "valorJurosImpostoFato": 0.0,
  "valorJurosImpostoInscricao": 0.0,
  "valorJurosInscricao": 0.0,
  "valorJurosMultaAtual": 0.0,
  "valorJurosMultaFato": 0.0,
  "valorJurosMultaInscricao": 0.0,
  "valorMultaFato": 0.0,
  "valorMultaInscricao": 0.0,
  "identificador": "$DIVIDA_IDENTIFICADOR",
  "categoria": {
      "id": 1,
      "nome": "Imobiliário Tributário",
      "identificadorNoCliente": 1
  },
   "endereco": {
      "logradouro": "$DIVIDA_ENDERECO_LOGRADOURO",
      "numero": "$DIVIDA_ENDERECO_NUMERO",
      "bairro": "$DIVIDA_ENDERECO_BAIRRO",
      "cep": "$DIVIDA_ENDERECO_CEP",
      "uf": "$DIVIDA_ENDERECO_UF",
      "municipio": {
          "id": $DIVIDA_ENDERCO_MUNICIPIO_ID
      },
      "higienizado": false,
      "enriquecido": false,
      "origem": "DIVIDA_ATIVA",
      "qualificacao": "NAO_PESQUISADO"
  },
  "devedor": {
      "nomeIntegracao": {
                          "nome": "$PROCESSO_NOME_PARTE_CONTRARIA"
                        },
      "documentoPrincipal": {
          "tipo": "CPF",
          "numero": "$PROCESSO_CPF_PARTE_CONTRARIA"
      },
      "possuiCnpjCpf": true,
      "cpfCnpjValido": true,
      "juridica": false,
      "enderecoValidoParaCitacao": false,
      "enderecoPassivelAjuizamento": false,
      "version": 1
  },
  "situacaoAtual": {
      "tipo": {
          "id": $DIVIDA_TIPO_SITUACAO_ABERTA,
          "nome": "Aberta",
          "categoria": "ABERTA"
      },
      "dataSituacao": "$ANO-$MES-$DIA$()T03:00:00",
      "mensagemId": 1
  },
  "aberta": false,
  "ajuizamentoFazenda": true,
  "orgaoOrigemId": $DIVIDA_ORGAO_ORIGEM_ID
}
EOF
  )

  echo $divida >>divida.json
  STATUS=$(curl -s -o response.txt -w "%{http_code}" --request POST "$SERVIDOR_DIVIDA/dividas" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN" \
    --data @divida.json)

  if [ $STATUS -ne 200 ]; then
    echo "******* Erro ao inserir divida para o processo $PROCESSO_NUMERO ******** \n"
    echo "$(cat response.txt)"
    curl --request POST "$SERVIDOR_DIVIDA/dividas" \
      --header "Content-type: application/json" \
      --header "Authorization: Bearer $TOKEN" \
      --data @divida.json
    exit 1
  fi
  rm -f divida.json

  echo -e "VINCULADO DIVIDA AO PROCESSO"

  STATUS=$(curl -s -o /dev/null -w "%{http_code}" --request POST "$SERVIDOR_DIVIDA/dividas/processo-legado?numeroJudicial=$PROCESSO_NUMERO" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")

}

############################### Função para Parcelamento da divida vinculada a uma EF ##################
fn_inserir_parcelamento() {
  echo -e "INSERINDO PARCELAMENTO DA DIVIDA"

  divida=$(
    cat <<EOF
{
  "numero": "$DIVIDA_NUMERO",
  "dataBase" : "$ANO",
  "livro": "1",
  "folha": "1",
  "ajuizamento": {
      "numeroJudicial": "$PROCESSO_NUMERO"
  },
  "tributo": {
              "identificadorNoCliente": 1
          },
  "exercicios": [
      {
          "ano": $ANO,
          "vencimento": "$ANO-$MES-$DIA$()T03:00:00"
      }
  ],
  "composicoes": [
      {
          "valor": "$PROCESSO_VALOR.0",
          "valorTotalFato": $PROCESSO_VALOR.0,
          "valorTotalAtual": $PROCESSO_VALOR.0,
          "valorJurosAtual": 0.0,
          "valorMultaFato": 0.0,
          "indiceCalculo" : "0.0",
          "parcela": "1",
          "dataVencimentoFato": "$DIVIDA_DATA_VENCIMENTO_COMPOSICAO",
          "numero": "$DIVIDA_NUMERO",
          "tributo": {
              "identificadorNoCliente": 1
          },
          "situacaoAtual": {
                "tipo": {
                    "nome": "Aberto",
                    "id": $DIVIDA_TIPO_SITUACAO_ABERTA
                }
            }
      }
  ],
  "fato": "INTERPRETAÇÃO DO CÁLCULO DA DÍVIDA ATIVA",
  "dataInscricao": "$ANO-$MES-$DIA$()T03:00:00",
  "dataAtualizacaoValores": "$DIVIDA_DATA_ATUALIZACAO_VALORES",
  "dataCienciaFato": "$ANO-$MES-$DIA$()T03:00:00",
  "valorTotalFato": $PROCESSO_VALOR.0,
  "valorTotalAtual": $PROCESSO_VALOR.0,
  "valorMultaAtual": 0.0,
  "valorJurosAtual": 0.0,
  "valorTotalInscricao": 0.0,
  "valorCorrecaoAtual": 0.0,
  "valorCorrecaoFato": 0.0,
  "valorCorrecaoImpostoAtual": 0.0,
  "valorCorrecaoImpostoFato": 0.0,
  "valorCorrecaoImpostoInscricao": 0.0,
  "valorCorrecaoInscricao": 0.0,
  "valorCorrecaoMultaAtual": 0.0,
  "valorCorrecaoMultaFato": 0.0,
  "valorCorrecaoMultaInscricao": 0.0,
  "valorImpostoAtual": 0.0,
  "valorImpostoFato": 0.0,
  "valorImpostoInscricao": 0.0,
  "valorJurosFato": 0.0,
  "valorJurosImpostoAtual": 0.0,
  "valorJurosImpostoFato": 0.0,
  "valorJurosImpostoInscricao": 0.0,
  "valorJurosInscricao": 0.0,
  "valorJurosMultaAtual": 0.0,
  "valorJurosMultaFato": 0.0,
  "valorJurosMultaInscricao": 0.0,
  "valorMultaFato": 0.0,
  "valorMultaInscricao": 0.0,
  "orgaoOrigemId": $DIVIDA_ORGAO_ORIGEM_ID,
  "identificador": "$DIVIDA_IDENTIFICADOR",
  "categoria": {
      "id": 1,
      "nome": "Imobiliário Tributário",
      "identificadorNoCliente": 1
  },
   "endereco": {
      "logradouro": "$DIVIDA_ENDERECO_LOGRADOURO",
      "numero": "$DIVIDA_ENDERECO_NUMERO",
      "bairro": "$DIVIDA_ENDERECO_BAIRRO",
      "cep": "$DIVIDA_ENDERECO_CEP",
      "uf": "$DIVIDA_ENDERECO_UF",
      "municipio": {
          "id": $DIVIDA_ENDERCO_MUNICIPIO_ID
      },
      "higienizado": false,
      "enriquecido": false,
      "origem": "DIVIDA_ATIVA",
      "qualificacao": "NAO_PESQUISADO"
  },
  "devedor": {
      "nomeIntegracao": {
                          "nome": "$PROCESSO_NOME_PARTE_CONTRARIA"
                        },
      "documentoPrincipal": {
          "tipo": "CPF",
          "numero": "$PROCESSO_CPF_PARTE_CONTRARIA"
      },
      "possuiCnpjCpf": true,
      "cpfCnpjValido": true,
      "juridica": false,
      "enderecoValidoParaCitacao": false,
      "enderecoPassivelAjuizamento": false,
      "version": 1
  },
  "situacaoAtual": {
      "tipo": {
          "id": $DIVIDA_TIPO_SITUACAO_PARCELADA,
          "nome": "Parcelada",
          "categoria": "PARCELADA"
      },
      "dataSituacao": "$ANO-$MES-$DIA$()T03:00:00",
      "mensagemId": 1
  },
  "parcelamento": {
      "identificador": "$PARCELAMENTO_IDENTIFICADOR",
      "numero": "$PARCELAMENTO_NUMERO",
      "dataConcessao": "$ANO-$MES-$DIA$()T03:00:00",
      "dataUltimoPagamento": "$ANO-$MES-$DIA$()T03:00:00",
      "tipo": "INCENTIVADO",
      "valorParcelamento": $PROCESSO_VALOR.0,
      "valorSaldo": 0.0,
      "valorPago": 0.0,
      "parcelas": $PARCELAMENTO_PARCELAS,
      "parcelasEmAtraso": 0,
      "situacaoAtual": {
          "tipo": {
              "identificadorNoCliente": "$DIVIDA_TIPO_SITUACAO_PARCELAMENTO_ATIVO"
          },
          "mensagemId": 1
      }
  }
}
EOF
  )

  echo $divida >>divida.json
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" --request POST "$SERVIDOR_DIVIDA/dividas" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN" \
    --data @divida.json)

  if [ $STATUS -ne 200 ]; then
    echo "******* Erro ao inserir parcelamento da divida para o processo $PROCESSO_NUMERO ******** \n"
    curl --request POST "$SERVIDOR_DIVIDA/dividas" \
      --header "Content-type: application/json" \
      --header "Authorization: Bearer $TOKEN" \
      --data @divida.json
    exit 1
  fi
  rm -f divida.json
}

############################## Apaga dividas geradas anteriormente por este script #################################
fn_excluir_dividas_gera_exemplos() {
  echo Excluindo dívidas do gera exemplos...

  DIVIDA_ID_CLIENTE_APAGAR="1501006"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1501007"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1501008"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1501007-2"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1501001"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1501002"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1501003"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1501004"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1501005"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1501006"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1501007"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1501008"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1501009"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1501010"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1502001"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1502002"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1502003"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1502004"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1502005"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1502006"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1502007"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1502008"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1502009"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1502010"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1502011"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1502012"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1502013"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1502014"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1502015"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1502016"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1502017"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1502018"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1502019"
  fn_excluir_divida

  DIVIDA_ID_CLIENTE_APAGAR="1502020"
  fn_excluir_divida


}

fn_excluir_divida() {
  echo Excluindo dívida com idCliente: $DIVIDA_ID_CLIENTE_APAGAR...
  curl --request DELETE "$SERVIDOR_DIVIDA/apresentacao/dividas?idCliente=$DIVIDA_ID_CLIENTE_APAGAR" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN"
}

############################## Apaga hash dividas #################################
fn_apagar_hash_dividas() {
  echo Limpando hashes das dívidas...
  curl --request DELETE "$SERVIDOR_DIVIDA/apresentacao/hashs-dividas" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN"
}

##################################################################### Encerra execuções lote processamento
fn_divida_encerrar_lote_processamento() {
  echo -e "\n\n" LoteProcessamento: encerrando...

  curl --request POST "$SERVIDOR_DIVIDA/lotesprocessamento/encerrar-execucoes" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN"
}
