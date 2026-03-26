#!/usr/bin/env bash

############################## Autenticação #################################
fn_autenticar() {
	echo "Buscando Token"
	TOKEN=$(curl --request POST $SERVIDOR_UAA/oauth/token \
		--header "Content-type: application/x-www-form-urlencoded" \
		--header "Authorization: $AUTH_HEADER" \
		--data "grant_type=password&username=$USUARIO&password=$PASSWORD&client_id=ATTORNATUS")

	TENANT=${TOKEN#*tenantId}
	TENANT=$(echo $TENANT | cut -d'"' -f 3)
	TOKEN=$(echo $TOKEN | cut -d'"' -f 4)
	echo $TENANT - $TOKEN

	if [ "$TOKEN" == "invalid_grant" ]; then
		echo "ERRO: >>>   Falha na geração de Token   <<<"
		echo "ERRO: >>> Usuario e/ou Senha incorretos <<<"
		exit 1
	fi

	if [ "$TOKEN" == "unauthorized" ]; then
		echo "ERRO: >>> Falha na geração de Token <<<"
		echo "ERRO: >>>  Usuario não autorizado   <<<"
		exit 1
	fi

}

############################## Apagar lotações e deixar mesa vaga #################################
fn_apagar_lotacoes_e_inserir_mesa_vaga() {
	nome_mesa=$1

	echo Reiniciando lotações da mesa $nome_mesa

	curl --request DELETE "$SERVIDOR_UAA/apresentacao/lotacoes/$nome_mesa" \
		--header "Content-type: application/json" \
		--header "Authorization: Bearer $TOKEN"
}

fn_is_usuario_equipe_qa() {
	local -a equipe_qa=("gustavo.acacio" "jovani.custodio" "roberto.perdona" "quezia.lima")
	for membro in "${equipe_qa[@]}"; do
		if [[ "$USUARIO" =~ $membro ]]; then
			return 0
		fi
	done

	return 1
}

fn_security_trocar_usuario() {
	resultado=$(echo "$USUARIO" | sed 's/:@.*//')
	USUARIO="$resultado :$NOVO_USUARIO"
	fn_autenticar
}

fn_inserir_lotacao() {
	echo -e "\n************************ Inserindo Lotação ************************\n"

	local LOCAL_ID="$1"
	local PAPEL_ID="$2"
	local USUARIO="$3"
	local DATA_BASE=$(TZ="America/Sao_Paulo" date +"%Y-%m-%dT%H:%M:%S%:z")

	local LOTACAO=$(
		cat <<EOF
{
  "local": {
    "id": "$LOCAL_ID"
  },
  "dataInicial": "$DATA_BASE",
  "usuarioLotado": {
    "username": "$USUARIO"
  },
  "papel": {
    "id": "$PAPEL_ID"
  },
  "isAfastado": false
}
EOF
	)

	curl --request POST "$SERVIDOR_UAA/lotacoes" \
		--header "Content-type: application/json" \
		--header "Authorization: Bearer $TOKEN" \
		--data-raw "$LOTACAO"

	echo -e "\n********* Lotação com papel $PAPEL_ID inserida para data $DATA_BASE no local $LOCAL_ID *********\n"
}

fn_inserir_lotacao_em_massa() {

	local page=0
	local size=10
	local sairLacoRepeticao=false

	while [[ "$sairLacoRepeticao" != true ]]; do
		echo "Consultando página $page..."

		response=$(curl --request GET "$SERVIDOR_UAA/locais?page=$page&search=(tipoLocal.id!='3')&size=$size&sort=nome,asc" \
			--header "Authorization: Bearer $TOKEN" \
			--header "Content-type: application/json")

		locais=$(echo "$response" | jq -c '.content[]?')
		if [[ -z "$locais" ]]; then
			echo -e "\n************************ Nenhum local encontrado. Encerrando ************************\n"
			sairLacoRepeticao=true
		fi

		echo "$response" | jq -r '.content[]?.id' | while read -r local_id; do
			fn_inserir_lotacao "$local_id" "13" "mhenarias@sp.gov.br"
		done

		last=$(echo "$response" | jq -r '.last')
		if [[ "$last" == "true" ]]; then
			echo -e "\n************************ Última página alcançada ************************\n"
			sairLacoRepeticao=true
		fi

		((page++))
	done
}

fn_criar_mesa_em_unidade() {
	LOCAL=$(
		cat <<EOF
  {
    "tipoLocal": {
      "id": "$TIPO_LOCAL_ID"
    },
    "nome": "$NOME_MESA"
  }
EOF
	)

	mesa=$(curl --request POST "$SERVIDOR_UAA/locais/$UNIDADE_ID/mesas" \
		--header "Content-type: application/json" \
		--header "Authorization: Bearer $TOKEN" \
		--data-raw "$LOCAL")

	mesaId=$(echo "$mesa" | jq -c '.id')
	echo "$mesaId"
}
