#!/usr/bin/env bash

fn_elaborar_documentos_para_publicar() {
	echo -e "\n************************ Elaborando documentos para publicação ************************\n"

	######################## Elaborando Requerimento de dispensa de recurso/manifestação
	PROCESSO_NUMERO="1501021-21.2018.8.26.0053"
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	PASTA=$(fn_processo_buscar_pasta_digital_por_numero_processo)
	MANIFESTACOES=$(fn_demanda_encontrar_demandas_por_pasta)
	MODELO="222"
	fn_demanda_elaborar_requerimento

	PROCESSO_NUMERO="1501026-26.2018.8.26.0053"
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	PASTA=$(fn_processo_buscar_pasta_digital_por_numero_processo)
	MANIFESTACOES=$(fn_demanda_encontrar_demandas_por_pasta)
	MODELO="222"
	fn_demanda_elaborar_requerimento

	PROCESSO_NUMERO="1501028-28.2018.8.26.0053"
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	PASTA=$(fn_processo_buscar_pasta_digital_por_numero_processo)
	MANIFESTACOES=$(fn_demanda_encontrar_demandas_por_pasta)
	MODELO="222"
	fn_demanda_elaborar_requerimento

	PROCESSO_NUMERO="1501029-29.2018.8.26.0053"
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	PASTA=$(fn_processo_buscar_pasta_digital_por_numero_processo)
	MANIFESTACOES=$(fn_demanda_encontrar_demandas_por_pasta)
	MODELO="222"
	fn_demanda_elaborar_requerimento

	PROCESSO_NUMERO="1501030-30.2018.8.26.0053"
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	PASTA=$(fn_processo_buscar_pasta_digital_por_numero_processo)
	MANIFESTACOES=$(fn_demanda_encontrar_demandas_por_pasta)
	MODELO="222"
	MANIFESTACAO=$(fn_demanda_elaborar_requerimento)
	TIPO_ANDAMENTO_ID=323
	fn_publicar_documento

	############################## Elaborando Requerimento de redistribuição de demanda
	PROCESSO_NUMERO="1501030-30.2017.8.26.0053"
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	PASTA=$(fn_processo_buscar_pasta_digital_por_numero_processo)
	MANIFESTACOES=$(fn_demanda_encontrar_demandas_por_pasta)
	MODELO="228"
	fn_demanda_elaborar_requerimento

	PROCESSO_NUMERO="1501030-30.2017.9.26.0053"
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	PASTA=$(fn_processo_buscar_pasta_digital_por_numero_processo)
	MANIFESTACOES=$(fn_demanda_encontrar_demandas_por_pasta)
	MODELO="228"
	fn_demanda_elaborar_requerimento

	############################### Elaborando Requerimento de redistribuição de processo
	PROCESSO_NUMERO="1501015-15.2018.8.26.0090"
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	PASTA=$(fn_processo_buscar_pasta_digital_por_numero_processo)
	MANIFESTACOES=$(fn_demanda_encontrar_demandas_por_pasta)
	MODELO="227"
	fn_demanda_elaborar_requerimento
}

fn_elaborar_documentos_para_protocolar() {
	echo -e "\n************************ Elaborando documentos para protocolação ************************\n"

	###################################### Elaborando Contestação 1º grau

	PROCESSO_NUMERO="1501021-21.2018.8.26.0053"
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	MODELO="211"
	fn_demanda_criar_peticao

	PROCESSO_NUMERO="1501024-24.2018.8.26.0053"
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	MODELO="211"
	fn_demanda_criar_peticao

	PROCESSO_NUMERO="1501030-30.2025.9.26.0053"
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	MODELO="211"
	fn_demanda_criar_peticao

	PROCESSO_NUMERO="1501026-26.2018.8.26.0053"
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	MODELO="211"
	fn_demanda_criar_peticao

	################################### DOCUMENTOS Contestação 1º grau COM ANEXO

	PROCESSO_NUMERO="1501030-30.2017.5.24.0053"
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	MODELO="211"
	fn_demanda_criar_peticao
	NOME_DEMANDA="Contestação 1º grau Elaborada"
	fn_anexar_documento

	PROCESSO_NUMERO="1501030-30.2019.9.20.0053"
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	MODELO="211"
	fn_demanda_criar_peticao
	NOME_DEMANDA="Contestação 1º grau Elaborada"
	fn_anexar_documento

	###################################### Elaborando Ato ordinatório

	PROCESSO_NUMERO="1501026-26.2018.8.26.0053"
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	MODELO=$MODELO_ATO_ORDINATORIO
	echo -e "Modelo $MODELO"
	fn_demanda_criar_peticao

	PROCESSO_NUMERO="1501030-30.2025.9.26.0053"
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	MODELO=$MODELO_ATO_ORDINATORIO
	fn_demanda_criar_peticao

	PROCESSO_NUMERO="1501024-24.2018.8.26.0053"
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	MODELO=$MODELO_ATO_ORDINATORIO
	fn_demanda_criar_peticao

	###################################### Elaborando Acordo
	PROCESSO_NUMERO="1501026-26.2018.8.26.0053"
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	MODELO=$MODELO_ACORDO
	MANIFESTACAO_ID=$(fn_demanda_criar_peticao)
	fn_incluir_observacao "$PROCESSOS"

	PROCESSO_NUMERO="1501021-21.2018.8.26.0053"
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	MODELO=$MODELO_ACORDO
	MANIFESTACAO_ID=$(fn_demanda_criar_peticao)
	fn_incluir_observacao "$PROCESSOS"

	############################ Elaborando Manifestação prévia

	# PROCESSO_NUMERO="1501074-23.2023.8.26.0053"
	# PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	# PASTA=$(fn_processo_buscar_pasta_digital_por_numero_processo)
	# MANIFESTACOES=$(fn_demanda_encontrar_demandas_por_pasta)
	# TIPO_DOCUMENTO_ID=1169
	# IS_MANIFESTACAO_JUDICIAL=true
	# TIPO_DOCUMENTO_NOME="Manifestação prévia"
	# TIPO_DEMANDA="MANIFESTACAO"
	# MODELO=$MODELO_MANIFESTACAO_PREVIA
	# fn_demanda_incluir_manifestacao

	PROCESSO_NUMERO="1501030-30.2024.7.26.0053"
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	PASTA=$(fn_processo_buscar_pasta_digital_por_numero_processo)
	MANIFESTACOES=$(fn_demanda_encontrar_demandas_por_pasta)
	TIPO_DOCUMENTO_ID=1169
	IS_MANIFESTACAO_JUDICIAL=true
	TIPO_DOCUMENTO_NOME="Manifestação prévia"
	TIPO_DEMANDA="MANIFESTACAO"
	MODELO=$MODELO_MANIFESTACAO_PREVIA
	fn_demanda_incluir_manifestacao

	PROCESSO_NUMERO="1501030-30.2017.7.26.0053"
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	PASTA=$(fn_processo_buscar_pasta_digital_por_numero_processo)
	MANIFESTACOES=$(fn_demanda_encontrar_demandas_por_pasta)
	TIPO_DOCUMENTO_ID=1169
	IS_MANIFESTACAO_JUDICIAL=true
	TIPO_DOCUMENTO_NOME="Manifestação prévia"
	TIPO_DEMANDA="MANIFESTACAO"
	MODELO=$MODELO_MANIFESTACAO_PREVIA
	fn_demanda_incluir_manifestacao

	PROCESSO_NUMERO="1501030-30.2017.9.24.0053"
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	PASTA=$(fn_processo_buscar_pasta_digital_por_numero_processo)
	MANIFESTACOES=$(fn_demanda_encontrar_demandas_por_pasta)
	TIPO_DOCUMENTO_ID=1169
	IS_MANIFESTACAO_JUDICIAL=true
	TIPO_DOCUMENTO_NOME="Manifestação prévia"
	TIPO_DEMANDA="MANIFESTACAO"
	MODELO=$MODELO_MANIFESTACAO_PREVIA
	fn_demanda_incluir_manifestacao
}

fn_encontrar_demanda() {
	demandas=$(fn_processo_buscar_pasta_digital_por_numero_processo | jq -c '.demandas[]')

	while IFS= read -r demanda; do
		nome=$(jq -r '.nome' <<<"$demanda")
		if [[ "$nome" == $NOME_DEMANDA ]]; then
			manifestacaoId=$(jq -r '.id' <<<"$demanda")
			echo "$manifestacaoId"
			return 0
		fi
	done <<<"$demandas"

	echo "Nenhuma demanda encontrada com o nome especificado."
	return 1
}

fn_encontrar_documento_id_por_demandas() {
	demandas=$(fn_processo_buscar_pasta_digital_por_numero_processo | jq -c '.demandas[]')

	while IFS= read -r demanda; do
		nome=$(jq -r '.nome' <<<"$demanda")
		if [[ "$nome" == $NOME_DEMANDA ]]; then
			documento_id=$(jq -r '.documento.id' <<<"$demanda")
			echo "$documento_id"
			return 0
		fi
	done <<<"$demandas"

	echo "Nenhuma demanda encontrada com o nome especificado."
	return 1
}

fn_anexar_documento() {
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)

	DOCUMENTO_PAI_ID=$(fn_encontrar_documento_id_por_demandas)
	if ! [[ "$DOCUMENTO_PAI_ID" =~ ^[0-9]+$ ]]; then
		echo "❌ Erro: DOCUMENTO_PAI_ID inválido — valor obtido: $DOCUMENTO_PAI_ID"
		return 1
	fi
	PATH_DOCUMENTO="./documentos/1501024-24.2018.8.26.0053_citacao_citacao.pdf"
	fn_documento_upload_anexo_multipart
}

fn_definir_modelo_com_base_no_ambiente() {
	MODELO_MANIFESTACAO_PREVIA=4485
	MODELO_ATO_ORDINATORIO=125492
	MODELO_ACORDO=125493

	if [[ $AMBIENTE =~ "localhost" ]]; then
		MODELO_MANIFESTACAO_PREVIA=4487
	fi

	if [[ $AMBIENTE =~ "dev.attus.ai" ]]; then
		echo -e "Ambiente dev attus"
		MODELO_ATO_ORDINATORIO=82032
		MODELO_ACORDO=82033
	fi

	if [[ $AMBIENTE =~ "qualidade.attus" ]]; then
		echo -e "Ambiente qualidade"
		MODELO_ATO_ORDINATORIO=4486
		MODELO_ACORDO=4487
	fi
}

fn_incluir_observacao() {
	PROCESSO_ID=$(jq -r '.[0].id' <<<"$1")
	fn_demanda_incluir_observacao
}

fn_incluir_andamentos() {
	######################################################### PARECER 1
	echo -e "\nIncluindo andamentos"
	ANDAMENTO_NOME_DOCUMENTO="Parecer"
	ANDAMENTO_TIPO=1182
	ANDAMENTO_ORIGEM="MANUAL"
	PROCESSO_NUMERO="1501030-30.2024.7.26.0053"
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	processo=$(jq -r '.[0]' <<<"$PROCESSOS")
	PASTA=$(fn_processo_buscar_pasta_digital_por_numero_processo)
	fn_inserir_andamento
	sleep 5
	MANIFESTACOES=$(fn_demanda_encontrar_demandas_por_pasta)
	MODELO="235"

	ID=$(echo "$MANIFESTACOES" | jq -r '.content[] | select(.nome == "Intimação/Notificação de despacho - Para avaliação de processo administrativo") | .manifestacoes[0].id')
	fn_demanda_criar_documento_manifestacao "$ID"

	######################################################### PARECER 2
	echo -e "\nIncluindo andamentos"
	ANDAMENTO_NOME_DOCUMENTO="Parecer"
	ANDAMENTO_TIPO=1182
	ANDAMENTO_ORIGEM="MANUAL"
	PROCESSO_NUMERO="1501030-30.2017.7.26.0053"
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	processo=$(jq -r '.[0]' <<<"$PROCESSOS")
	PASTA=$(fn_processo_buscar_pasta_digital_por_numero_processo)
	fn_inserir_andamento
	sleep 5
	MANIFESTACOES=$(fn_demanda_encontrar_demandas_por_pasta)
	MODELO="235"

	ID=$(echo "$MANIFESTACOES" | jq -r '.content[] | select(.nome == "Intimação/Notificação de despacho - Para avaliação de processo administrativo") | .manifestacoes[0].id')
	fn_demanda_criar_documento_manifestacao "$ID"

	######################################################### PARECER 3
	echo -e "\nIncluindo andamentos"
	ANDAMENTO_NOME_DOCUMENTO="Parecer"
	ANDAMENTO_TIPO=1182
	ANDAMENTO_ORIGEM="MANUAL"
	PROCESSO_NUMERO="1501026-26.2018.8.26.0053"
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	processo=$(jq -r '.[0]' <<<"$PROCESSOS")
	PASTA=$(fn_processo_buscar_pasta_digital_por_numero_processo)
	fn_inserir_andamento
	sleep 5
	MANIFESTACOES=$(fn_demanda_encontrar_demandas_por_pasta)
	MODELO="235"

	ID=$(echo "$MANIFESTACOES" | jq -r '.content[] | select(.nome == "Intimação/Notificação de despacho - Para avaliação de processo administrativo") | .manifestacoes[0].id')
	fn_demanda_criar_documento_manifestacao "$ID"

	######################################################### PARECER 4
	echo -e "\nIncluindo andamentos"
	ANDAMENTO_NOME_DOCUMENTO="Parecer"
	ANDAMENTO_TIPO=1182
	ANDAMENTO_ORIGEM="MANUAL"
	PROCESSO_NUMERO="1501026-26.2018.8.26.0053"
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	processo=$(jq -r '.[0]' <<<"$PROCESSOS")
	PASTA=$(fn_processo_buscar_pasta_digital_por_numero_processo)
	fn_inserir_andamento
	sleep 5
	MANIFESTACOES=$(fn_demanda_encontrar_demandas_por_pasta)
	MODELO="235"

	ID=$(echo "$MANIFESTACOES" | jq -r '.content[] | select(.nome == "Intimação/Notificação de despacho - Para avaliação de processo administrativo") | .manifestacoes[0].id')
	fn_demanda_criar_documento_manifestacao "$ID"

	######################################################### PARECER 4
	echo -e "\nIncluindo andamentos"
	ANDAMENTO_NOME_DOCUMENTO="Parecer"
	ANDAMENTO_TIPO=1182
	ANDAMENTO_ORIGEM="MANUAL"
	PROCESSO_NUMERO="1501030-30.2017.8.26.0053"
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	processo=$(jq -r '.[0]' <<<"$PROCESSOS")
	PASTA=$(fn_processo_buscar_pasta_digital_por_numero_processo)
	fn_inserir_andamento
	sleep 5
	MANIFESTACOES=$(fn_demanda_encontrar_demandas_por_pasta)
	MODELO="235"

	ID=$(echo "$MANIFESTACOES" | jq -r '.content[] | select(.nome == "Intimação/Notificação de despacho - Para avaliação de processo administrativo") | .manifestacoes[0].id')
	fn_demanda_criar_documento_manifestacao "$ID"

	######################################################### Citação - Citação - Com intimação para manif. em 5 dias sobre tutela / liminar 1
	echo -e "\nIncluindo andamentos"
	ANDAMENTO_NOME_DOCUMENTO="Citação - Citação - Com intimação para manif. em 5 dias sobre tutela / liminar"
	ANDAMENTO_TIPO=988
	ANDAMENTO_ORIGEM="MANUAL"
	PROCESSO_NUMERO="1501026-26.2018.8.26.0053"
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	processo=$(jq -r '.[0]' <<<"$PROCESSOS")
	PASTA=$(fn_processo_buscar_pasta_digital_por_numero_processo)
	fn_inserir_andamento
	sleep 5

	######################################################### Redistribuição de processo requerida
	echo -e "\nIncluindo andamentos"
	ANDAMENTO_NOME_DOCUMENTO="Redistribuição de processo requerida"
	ANDAMENTO_TIPO=2005
	ANDAMENTO_ORIGEM="MANUAL"
	PROCESSO_NUMERO="1504787-25.2025.9.26.0053"
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	processo=$(jq -r '.[0]' <<<"$PROCESSOS")
	PASTA=$(fn_processo_buscar_pasta_digital_por_numero_processo)
	fn_inserir_andamento
	sleep 5
}

fn_criar_mesa() {
	local nome_mesa="$1"
	local username="$2"
	local unidadeId="$3"

	UNIDADE_ID=$unidadeId
	TIPO_LOCAL_ID=2
	NOME_MESA="$nome_mesa"
	RESPONSAVEL_NOME="$nome_mesa"
	RESPONSAVEL_USERNAME="$username"

	MESA_ID=$(fn_criar_mesa_em_unidade)
	fn_incluir_titularidade
}

fn_configurar_mesas_a_serem_criadas() {
	local unidade_id=1000082

	declare -A usuarios_e_mesas=(
		["jmfilho@sp.gov.br"]="Mesa Jorge Miguel Filho"
		["jcandidosilva@sp.gov.br"]="Mesa José Carlos Candido da Silva"
		["mhenarias@sp.gov.br"]="Mesa Maurício de Almeida Henárias"
	)

	for username in "${!usuarios_e_mesas[@]}"; do
		local nome_mesas="${usuarios_e_mesas[$username]}"

		if ! fn_is_mesa_existe "$nome_mesas" "$unidade_id"; then
			echo "Mesa '$nome_mesas' não existe — criando mesa para usuário '$username'"
			fn_criar_mesa "$nome_mesas" "$username" "$unidade_id"
		else
			echo "Mesa '$nome_mesas' já existente"
		fi
	done
}

fn_concluir_demanda() {
	echo -e "\nConcluindo demanda"
	PROCESSO_NUMERO="1501022-22.2018.8.26.0053"
	PROCESSOS=$(fn_processo_buscar_processo_por_numero)
	PASTA=$(fn_processo_buscar_pasta_digital_por_numero_processo)
	MANIFESTACOES=$(fn_demanda_encontrar_demandas_por_pasta)
	MANIFESTACAO_ID=$(jq -r '.content[0].id' <<<"$MANIFESTACOES")
	PROCESSO_ID=$(jq -r '.[0].id' <<<"$PROCESSOS")
	fn_encerrar_demanda
}

fn_preparar_dados_para_testes() {
	fn_configurar_mesas_a_serem_criadas
	fn_inserir_lotacao_em_massa
	fn_definir_modelo_com_base_no_ambiente
	USUARIO="jmfilho@sp.gov.br"
	PASSWORD="C@mabirEla2019"
	fn_autenticar
	fn_elaborar_documentos_para_publicar
	fn_elaborar_documentos_para_protocolar
	fn_incluir_andamentos
	fn_concluir_demanda
}
