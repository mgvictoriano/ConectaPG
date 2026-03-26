#!/usr/bin/env bash

############################## Apagar distribuições #################################
fn_apagar_distribuicoes() {
	echo Excluindo distribuições

	curl --request DELETE "$SERVIDOR_DISTRIBUICAO/apresentacao/distribuicoes" \
		--header "Content-type: application/json" \
		--header "Authorization: Bearer $TOKEN"
}

############################## Apagar todos resumos recebimento #################################
fn_apagar_resumo_recebimento() {
	echo Elasticsearch: excluindo Lotações dos usuários em Distribuição...

	curl --request DELETE "$SERVIDOR_DISTRIBUICAO/apresentacao/resumosrecebimento" \
		--header "Content-type: application/json" \
		--header "Authorization: Bearer $TOKEN"
}

############################## Atualizar resumos recebimento #################################
fn_atualizar_resumo_recebimento() {
	echo Elasticsearch: atualizando Lotações dos usuários em Distribuição...

	curl --request POST "$SERVIDOR_DISTRIBUICAO/apresentacao/atualizar-resumosrecebimento" \
		--header "Content-type: application/json" \
		--header "Authorization: Bearer $TOKEN"

}

fn_incluir_titularidade() {
	echo -e "\nInserindo titularidade em mesa"
	dataInicioPrazo=$(TZ="America/Sao_Paulo" date +"%Y-%m-%dT%H:%M:%S%:z")

	titularidade=$(
		cat <<EOF
{
    "local": {
      "id": $MESA_ID,
      "nome": "$NOME_MESA",
      "tipoLocal": {
        "id": 2
      },
      "mesa": true
    },
    "responsavel": {
      "username": "$RESPONSAVEL_USERNAME",
      "pessoa": {
        "id": 154,
        "juridica": false,
        "participacaoSomenteEmProcessosSigilosos": false
      },
      "nome": "$RESPONSAVEL_NOME",
      "enabled": true
    },
    "dataInicial": "$dataInicioPrazo",
    "papel": {
      "id": 2,
      "tipo": "TITULARIDADE",
      "nome": "Procurador Titular"
    },
    "vaga": false,
    "version": 0,
    "usuarioAusente": false
}
EOF
	)

	curl -s -X POST "$SERVIDOR_DISTRIBUICAO/titularidades" \
		-H "Authorization: Bearer $TOKEN" \
		-H "Content-Type: application/json" \
		-d "$titularidade"
}

fn_is_mesa_existe() {
	local nome_mesa="$1"
	local unidade_id="$2"

	response=$(curl -s -X GET "$SERVIDOR_DISTRIBUICAO/resumosrecebimentos/mesas/?localDistribuicaoId=${unidade_id}&tipoObjeto=PROCESSO" \
		-H "Authorization: Bearer $TOKEN" \
		-H "Content-Type: application/json")

	local resultado=$(jq -e --arg nome "$nome_mesa" '
    .content // []
    | any(
        .local.nome and
        (.local.nome | ascii_downcase) == ($nome | ascii_downcase)
      )
  ' <<<"$response")

	if [ "$resultado" = "true" ]; then
		return 0
	else
		return 1
	fi
}
