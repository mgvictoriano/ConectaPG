#!/usr/bin/env bash

fn_apagar_process_instaces() {
  echo Limpando process instances

  curl --request DELETE "$SERVIDOR_DEMANDA/apresentacao/process-instances" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN"

}

fn_sincronizar_tudo() {
  echo Sincronizando demandas

  curl --request POST "$SERVIDOR_DEMANDA/demandas/sincronizar-tudo" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN"

}

################ Atualizar data de entrada das demandas
fn_demanda_ajustar_data_entrada() {
  echo Atualizando data de entrada

  curl --request POST "$SERVIDOR_DEMANDA/apresentacao/dataentradademanda" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN"
}

##################################################################### Excluir histórico de distribuição de demanda para dia de hoje
fn_demanda_excluir_historico_distribuicao() {
  echo -e "\n\n" Excluindo histórico de distribuição de demanda...

  curl --request DELETE "$SERVIDOR_DEMANDA/apresentacao/historicodistribuicaohoje" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN"
}

fn_demanda_criar_peticao() {
    estrategiaAcaoExecucao=$(
        cat <<EOF
{
  "modelo": {
    "id": "$MODELO"
  },
  "usuarioSolicitante": "jmfilho@sp.gov.br",
  "processos": $PROCESSOS,
  "action": "CRIAR_PETICAO"
}
EOF
    )
    response=$(curl --request POST "$SERVIDOR_DEMANDA/demandas/execucao-acao?action=CRIAR_PETICAO" \
        --header "Accept: application/json" \
        --header "Content-type: application/json" \
        --header "Authorization: Bearer $TOKEN" \
        --data "$estrategiaAcaoExecucao")
    RESULTADO=$(jq -r '.content.id' <<< "$response")
    echo "$RESULTADO"
}

fn_demanda_encontrar_demandas_por_pasta() {
  pastaId=$(jq -r '.numero' <<< "$PASTA")
  demandas=$(curl --request GET "$SERVIDOR_DEMANDA/demandas?numeropasta=$pastaId" \
  --header "Content-type: application/json" \
  --header "Authorization: Bearer $TOKEN")
  echo "$demandas"
}

fn_demanda_elaborar_requerimento() {
  manifestacao=$(jq -r '.content[0].id' <<< "$MANIFESTACOES")

    modelo=$(
        cat <<EOF
{
  "modelo": "$MODELO"
}
EOF
    )
    curl --request POST "$SERVIDOR_DEMANDA/demandas/$manifestacao/manifestacoes/documentos" \
        --header "Content-type: application/json" \
        --header "Authorization: Bearer $TOKEN" \
        --data "$modelo"

  echo "$manifestacao"
}

fn_demanda_incluir_manifestacao() {
  manifestacaoId=$(jq -r '.content[0].id' <<< "$MANIFESTACOES")
  dataInicioPrazo=$(TZ="America/Sao_Paulo" date +"%Y-%m-%dT%H:%M:%S%:z")
  manifestacao=$(
  cat <<EOF
{
      "dataInicioPrazo": "$dataInicioPrazo",
      "documento": {
        "tipoDocumento": {
          "id": $TIPO_DOCUMENTO_ID,
          "instancias": ["PRIMEIRA", "SEGUNDA"],
          "manifestacaoJudicial": $IS_MANIFESTACAO_JUDICIAL,
          "nome": "$TIPO_DOCUMENTO_NOME"
        }
      },
      "tipoDemanda": "$TIPO_DEMANDA"
}
EOF
  )

  curl --request POST "$SERVIDOR_DEMANDA/demandas/$manifestacaoId/manifestacoes" \
        --header "Content-type: application/json" \
        --header "Authorization: Bearer $TOKEN" \
        --data "$manifestacao"

  echo -e "\n************************ Inserindo $TIPO_DOCUMENTO_NOME ******************* \n"

  fn_demanda_elaborar_documento $manifestacaoId $MODELO

  echo -e "\n manifestacao id $manifestacaoId"
}


fn_demanda_elaborar_documento(){
manifestacaoId=$1
modelo=$2

modelo=$(
  cat <<EOF
  {
    "modelo": "$modelo"
  }
EOF
)

curl --request POST "$SERVIDOR_DEMANDA/demandas/$manifestacaoId/manifestacoes/documentos" \
          --header "Content-type: application/json" \
          --header "Authorization: Bearer $TOKEN" \
          --data "$modelo"
echo -e "\n************************ Elaboração realizado em manifestação $manifestacaoId ******************* \n"

}

fn_demanda_criar_documento_manifestacao(){
manifestacaoId=$1

modelo=$(
  cat <<EOF
  {
    "modelo": $MODELO
  }
EOF
)

curl --request POST "$SERVIDOR_DEMANDA/demandas/$manifestacaoId/documentos" \
          --header "Content-type: application/json" \
          --header "Authorization: Bearer $TOKEN" \
          --data "$modelo"
echo -e "\n************************ Elaboração realizado em manifestação $manifestacaoId ******************* \n"

}

fn_demanda_incluir_observacao() {
  local INCLUIR_OBSERVACAO="INCLUIR_OBSERVACAO"

  estrategiaAcaoExecucao=$(jq -n \
    --arg action "$INCLUIR_OBSERVACAO" \
    --arg id "$MANIFESTACAO_ID" \
    --arg processoId "$PROCESSO_ID" \
    --arg observacoes "Teste de observacao" \
    '{
      action: $action,
      complementos: {
        OBSERVACOES: $observacoes
      },
      demandas: [
        {
          id: $id,
          processo: {
            id: $processoId,
            pasta: {}
          }
        }
      ]
    }'
  )

  curl --request POST "$SERVIDOR_DEMANDA/demandas/execucao-acao?action=$INCLUIR_OBSERVACAO" \
       --header "Content-Type: application/json" \
       --header "Authorization: Bearer $TOKEN" \
       --data "$estrategiaAcaoExecucao"
}

fn_encerrar_demanda(){
  local ENCERRAR="ENCERRAR"

    estrategiaAcaoExecucao=$(jq -n \
      --arg action "$ENCERRAR" \
      --arg id "$MANIFESTACAO_ID" \
      --arg processoId "$PROCESSO_ID" \
      --arg observacoes "Teste de observacao" \
      '{
        action: $action,
        confirmou: true,
        demandas: [
          {
            id: $id,
            processo: {
              id: $processoId,
              pasta: {}
            }
          }
        ]
      }'
    )

    curl --request POST "$SERVIDOR_DEMANDA/demandas/execucao-acao?action=$ENCERRAR" \
         --header "Content-Type: application/json" \
         --header "Authorization: Bearer $TOKEN" \
         --data "$estrategiaAcaoExecucao"
}


fn_publicar_documento(){
  local PUBLICAR_DOCUMENTO="PUBLICAR_DOCUMENTO"
  DEMANDA_ID=$(jq -r '.id' <<< "$MANIFESTACAO")
  PROCESSO_ID=$(jq -r '.processo.id' <<< "$MANIFESTACAO")

    estrategiaAcaoExecucao=$(jq -n \
      --arg action "$PUBLICAR_DOCUMENTO" \
      --arg id "$DEMANDA_ID" \
      --arg processoId "$PROCESSO_ID" \
      --arg tipoAndamentoId "$TIPO_ANDAMENTO_ID" \
      '{
        action: $action,
        tipoAndamentoId: $tipoAndamentoId,
        encerarDemanda: true,
        complementos: {
          MOTIVO_NAO_PROTOCOLO: "Motivo de teste",
          PERMITE_CONCLUSAO_DEMANDA_PAI: "true"
        },
        demandas: [
          {
            id: $id,
            processo: {
              id: $processoId,
              pasta: {}
            }
          }
        ]
      }'
    )

    curl --request POST "$SERVIDOR_DEMANDA/demandas/execucao-acao?action=$PUBLICAR_DOCUMENTO" \
         --header "Content-Type: application/json" \
         --header "Authorization: Bearer $TOKEN" \
         --data "$estrategiaAcaoExecucao"
}