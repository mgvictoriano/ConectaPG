#!/usr/bin/env bash
#### SETA VALORES PADRÃO ######
USAR_WATSON=false
AMBIENTE=$1
USUARIO=$2
PASSWORD=$3

source ./auxiliares/admin.sh
source ./auxiliares/demanda.sh
source ./auxiliares/distribuicao.sh
source ./auxiliares/divida.sh
source ./auxiliares/documento.sh
source ./auxiliares/integrajud.sh
source ./auxiliares/pessoa.sh
source ./auxiliares/processo.sh
source ./auxiliares/security.sh
source ./auxiliares/utils.sh

#### BUSCA VALORES DOS PARAMETROS ######
while getopts ":a:u:p:w:" opt; do
  case $opt in
  a)
    AMBIENTE=$OPTARG
    ;;
  u)
    USUARIO=$OPTARG
    ;;
  p)
    PASSWORD=$OPTARG
    ;;
  w)
    if [ "$OPTARG" = true ] || [ "$OPTARG" = false ]; then
      USAR_WATSON=$OPTARG
    fi
    ;;
  \?)
    echo "Opção inválida: -$OPTARG" >&3
    exit 1
    ;;
  esac
done

echo "AMBIENTE: $AMBIENTE"
echo "USUARIO: $USUARIO"
echo "USAR WATSON? $USAR_WATSON"

ID_ORIGEM=0
SERVIDOR_PROCESSO=$AMBIENTE'/processo'
SERVIDOR_UAA=$AMBIENTE'/uaa'
SERVIDOR_DEMANDA=$AMBIENTE'/demanda'
SERVIDOR_ADMIN=$AMBIENTE'/admin'
SERVIDOR_PESSOA=$AMBIENTE'/pessoa'
SERVIDOR_DIVIDA=$AMBIENTE'/divida'
SERVIDOR_DOCUMENTO=$AMBIENTE'/documento'
SERVIDOR_DISTRIBUICAO=$AMBIENTE'/distribuicao'
SERVIDOR_INTEGRAJUD=$AMBIENTE'/integrajud'

if [ $AMBIENTE == "developer" ]; then
  SERVIDOR_PROCESSO='http://192.168.1.28:31087/processo';
  SERVIDOR_UAA='http://192.168.1.28:31087/uaa';
  SERVIDOR_DEMANDA='http://192.168.1.28:31087/demanda';
  SERVIDOR_ADMIN='http://192.168.1.28:31087/admin';
  SERVIDOR_PESSOA='http://192.168.1.28:31087/pessoa';
  SERVIDOR_DIVIDA='http://192.168.1.28:31087/divida';
  SERVIDOR_DOCUMENTO='http://192.168.1.28:31087/documento';
  SERVIDOR_DISTRIBUICAO='http://192.168.1.28:31087/distribuicao';
  SERVIDOR_INTEGRAJUD='http://192.168.1.28:31087/integrajud';
fi

if [ $AMBIENTE == "localhost" ]; then
  SERVIDOR_PROCESSO='http://localhost:8082/processo'
  SERVIDOR_UAA='http://localhost:9999/uaa'
  SERVIDOR_DEMANDA='http://localhost:8085/demanda'
  SERVIDOR_ADMIN='http://localhost:8000/admin'
  SERVIDOR_PESSOA='http://localhost:8083/pessoa'
  SERVIDOR_DIVIDA='http://localhost:8084/divida'
  SERVIDOR_DOCUMENTO='http://localhost:8081/documento'
  SERVIDOR_DISTRIBUICAO='http://localhost:8087/distribuicao'
  SERVIDOR_INTEGRAJUD='http://localhost:8088/integrajud'
fi

INCLUIR_ANEXOS_ADICIONAIS=false

############################### PRINCIPAL #####################
rm -f *.json

fn_data_atual
DIAS_REDUZIR=50
fn_data_anterior

echo $ANO-$MES-$DIA