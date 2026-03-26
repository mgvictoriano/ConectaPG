#!/usr/bin/env bash

fn_excluir_enderecos_citacao_negativa() {
  echo Excluindo endereços citação negativa...

  curl --request DELETE "$SERVIDOR_PESSOA/apresentacao/limpar-citacao-negativa?numerocnpjcpf=90923223478" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN"

  curl --request DELETE "$SERVIDOR_PESSOA/apresentacao/limpar-citacao-negativa?numerocnpjcpf=25036503848" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN"

  curl --request DELETE "$SERVIDOR_PESSOA/apresentacao/limpar-citacao-negativa?numerocnpjcpf=24987779897" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN"

  curl --request DELETE "$SERVIDOR_PESSOA/apresentacao/limpar-citacao-negativa?numerocnpjcpf=43159086000102" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN"

    curl --request DELETE "$SERVIDOR_PESSOA/apresentacao/limpar-citacao-negativa?numerocnpjcpf=26013968810" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN"

    curl --request DELETE "$SERVIDOR_PESSOA/apresentacao/limpar-citacao-negativa?numerocnpjcpf=91319218920" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN"

    curl --request DELETE "$SERVIDOR_PESSOA/apresentacao/limpar-citacao-negativa?numerocnpjcpf=44604006857" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN"

  curl --request DELETE "$SERVIDOR_PROCESSO/apresentacao/limpar-enderecos-citacao-negativa" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN"

}

############################## Obtem parte representada #################################
fn_parte_representada() {
  echo Obtendo a parte representada...
  echo $PESSOA_REPRESENTADA_PELA_INSTITUICAO

  PESSOA_REPRESENTADA=$(curl --request GET "$SERVIDOR_PESSOA/pessoas/representada-pela-instituicao" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")

  echo Pessoa $PESSOA_REPRESENTADA

}