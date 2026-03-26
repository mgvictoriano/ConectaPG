#!/usr/bin/env bash

############################## Apagar todos andamentos do integrajud #################################
fn_exclusao_andamentos_mocks() {
  echo Excluindo andamento ${ORIGEM_ANDAMENTO_ID} da emulação

  curl --request DELETE "$SERVIDOR_INTEGRAJUD/apresentacao/andamento?origemId=$ORIGEM_ANDAMENTO_ID" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN"

}