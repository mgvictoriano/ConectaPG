#!/usr/bin/env bash
SERVIDOR_API=$1
USUARIO=$2
UNIDADE_JUDICIAL=$3

############################### VALIDACOES #####################
if ! command -v jq --version; then
	echo "Dependência JQ não encontrada. Por favor, rode o seguinte comando antes de executar este .sh novamente. sudo apt install jq"
	exit
fi

if [ "$SERVIDOR_API" == "" ]; then
	echo "Por favor, informe o caminho do servidor como primeiro parâmetro."
	exit
fi

if [ "$USUARIO" == "" ]; then
	echo "Por favor, informe o usuário como segundo parâmetro."
	exit
fi

if [ "$UNIDADE_JUDICIAL" == "" ]; then
	echo "Por favor, informe a unidade judicial como terceiro parâmetro."
	exit
fi

############################### GERA TOKEN ACESSO #####################
SENHA=S@intBier

if [ "$USUARIO" == "fabiobct@hotmail.com" ]; then
    SENHA=Attornatus2019
fi

#echo "\nBuscando Token\n"
TOKEN=$(curl --request POST $SERVIDOR_API/uaa/oauth/token \
--header "Content-type: application/x-www-form-urlencoded" \
--header "Authorization: Basic QVRUT1JOQVRVUzoxMjM0NTY3ODk=" \
--data "grant_type=password&username=$USUARIO&password=$SENHA&client_id=ATTORNATUS")

TOKEN=$(echo $TOKEN | cut -d'"' -f 4)

############################### DOWNLOAD ARQUIVOS #####################
RESOURCE_URI=$SERVIDOR_API/integrajud/integracoes/processo/$UNIDADE_JUDICIAL/
QUERY_PARAMS="?"

FILE="tipos_documento.csv"
while IFS=";" read CODIGO DESCRICAO
do
	if [ $QUERY_PARAMS == "?" ]; then
		QUERY_PARAMS+="tipoDocumento=$CODIGO"
	else 
		QUERY_PARAMS+="&tipoDocumento=$CODIGO"
	fi
done <"$FILE"

# PERCORRE LISTA DE PROCESSOS E REALIZA O DOWNLOAD DOS ARQUIVOS QUE BATEM COM A LISTA DE TIPOS DE DOCUMENTOS
FILE="lista_processos.csv"
while IFS= read NUMERO_PROCESSO
do
	echo "Consultando dados para o processo $NUMERO_PROCESSO"
	DOCUMENTO=$(curl $RESOURCE_URI$NUMERO_PROCESSO/documentos$QUERY_PARAMS \
					    --header "Content-type: application/json" \
					    --header "Authorization: Bearer $TOKEN") 
    if [[ $DOCUMENTO == *'"status" : 500'* ]]; then
    	echo $DOCUMENTO
	else
		# CONVERTE JSON PARA TSV, DECODIFICA O BASE64 E SALVA EM DISCO
		echo $DOCUMENTO | jq -r '.[] | [.id,.tipoDocumento.id,.arquivos[].nome,.arquivos[].bytes] | @tsv' |
		  while IFS=$'\t' read -r ID TIPO NOME CONTEUDO; do
			echo "Criando diretório $TIPO caso não exista..."
			mkdir $TIPO -p
			echo "Criando arquivo $NOME_$ID.txt...".
			echo $CONTEUDO | base64 --decode > $TIPO/$NOME_$ID.txt
			echo "Arquivo $NOME_$ID.txt criado.".
		  done
	fi
	sleep 3s
done <"$FILE"