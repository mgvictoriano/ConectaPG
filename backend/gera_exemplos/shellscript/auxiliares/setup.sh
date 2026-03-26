#!/usr/bin/env bash
#### SETA VALORES PADRÃO ######
AMBIENTE=$1
USUARIO=$2
PASSWORD=$3

source ./auxiliares/admin.sh
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
AUTH_HEADER='Basic ';

if [[ $AMBIENTE =~ "dev.attornatus" ]]; then
  SERVIDOR_PROCESSO='https://dev.attornatus.com.br/processo';
  SERVIDOR_UAA='https://dev.attornatus.com.br/uaa';
  SERVIDOR_DEMANDA='https://dev.attornatus.com.br/demanda';
  SERVIDOR_ADMIN='https://dev.attornatus.com.br/admin';
  SERVIDOR_PESSOA='https://dev.attornatus.com.br/pessoa';
  SERVIDOR_DIVIDA='https://dev.attornatus.com.br/divida';
  SERVIDOR_DOCUMENTO='https://dev.attornatus.com.br/documento';
  SERVIDOR_DISTRIBUICAO='https://dev.attornatus.com.br/distribuicao';
  SERVIDOR_INTEGRAJUD='https://dev.attornatus.com.br/integrajud';
  AUTH_HEADER='Basic QVRUT1JOQVRVUzpCeC8iUWM/OHt+PjdYTnYn';
fi

if [[ $AMBIENTE =~ "dev.attus.ai" ]]; then
  SERVIDOR_PROCESSO='https://dev.attus.ai/processo';
  SERVIDOR_UAA='https://dev.attus.ai/uaa';
  SERVIDOR_DEMANDA='https://dev.attus.ai/demanda';
  SERVIDOR_ADMIN='https://dev.attus.ai/admin';
  SERVIDOR_PESSOA='https://dev.attus.ai/pessoa';
  SERVIDOR_DIVIDA='https://dev.attus.ai/divida';
  SERVIDOR_DOCUMENTO='https://dev.attus.ai/documento';
  SERVIDOR_DISTRIBUICAO='https://dev.attus.ai/distribuicao';
  SERVIDOR_INTEGRAJUD='https://dev.attus.ai/integrajud';
  AUTH_HEADER='Basic QVRUT1JOQVRVUzpCeC8iUWM/OHt+PjdYTnYn';
fi

if [[ $AMBIENTE =~ "pgesp.attus.ai" ]]; then
  SERVIDOR_PROCESSO='https://pgesp.attus.ai/processo';
  SERVIDOR_UAA='https://pgesp.attus.ai/uaa';
  SERVIDOR_DEMANDA='https://pgesp.attus.ai/demanda';
  SERVIDOR_ADMIN='https://pgesp.attus.ai/admin';
  SERVIDOR_PESSOA='https://pgesp.attus.ai/pessoa';
  SERVIDOR_DIVIDA='https://pgesp.attus.ai/divida';
  SERVIDOR_DOCUMENTO='https://pgesp.attus.ai/documento';
  SERVIDOR_DISTRIBUICAO='https://pgesp.attus.ai/distribuicao';
  SERVIDOR_INTEGRAJUD='https://pgesp.attus.ai/integrajud';
  AUTH_HEADER='Basic QVRUT1JOQVRVUzpqJyo1TjxBbkNGLVdkWDZL';
fi

if [[ $AMBIENTE =~ "localhost" ]]; then
  SERVIDOR_PROCESSO='http://localhost:8082/processo';
  SERVIDOR_UAA='http://localhost:9999/uaa';
  SERVIDOR_DEMANDA='http://localhost:8085/demanda';
  SERVIDOR_ADMIN='http://localhost:8000/admin';
  SERVIDOR_PESSOA='http://localhost:8083/pessoa';
  SERVIDOR_DIVIDA='http://localhost:8084/divida';
  SERVIDOR_DOCUMENTO='http://localhost:8081/documento';
  SERVIDOR_DISTRIBUICAO='http://localhost:8087/distribuicao';
  SERVIDOR_INTEGRAJUD='http://localhost:8088/integrajud';
  AUTH_HEADER='Basic QVRUT1JOQVRVUzpFOSU7fnJBcTQ2Wkx1KEA6';
fi

if [[ $AMBIENTE =~ "hml.attornatus" ]]; then
  SERVIDOR_PROCESSO='https://hml.attornatus.com.br/processo';
  SERVIDOR_UAA='https://hml.attornatus.com.br/uaa';
  SERVIDOR_DEMANDA='https:/hml.attornatus.com.br/demanda';
  SERVIDOR_ADMIN='https://hml.attornatus.com.br/admin';
  SERVIDOR_PESSOA='https://hml.attornatus.com.br/pessoa';
  SERVIDOR_DIVIDA='https://hml.attornatus.com.br/divida';
  SERVIDOR_DOCUMENTO='https://hml.attornatus.com.br/documento';
  SERVIDOR_DISTRIBUICAO='https://hml.attornatus.com.br/distribuicao';
  SERVIDOR_INTEGRAJUD='https://hml.attornatus.com.br/integrajud';
  AUTH_HEADER='Basic QVRUT1JOQVRVUzpOWzRHUmpnQy9yOFE6Yj1x';
fi

if [[ $AMBIENTE =~ "dev.pgeweb" ]]; then
  SERVIDOR_PROCESSO='https://dev.pgeweb.sp.gov.br/processo';
  SERVIDOR_UAA='https://dev.pgeweb.sp.gov.br/uaa';
  SERVIDOR_DEMANDA='https://dev.pgeweb.sp.gov.br/demanda';
  SERVIDOR_ADMIN='https://dev.pgeweb.sp.gov.br/admin';
  SERVIDOR_PESSOA='https://dev.pgeweb.sp.gov.br/pessoa';
  SERVIDOR_DIVIDA='https://dev.pgeweb.sp.gov.br/divida';
  SERVIDOR_DOCUMENTO='https://dev.pgeweb.sp.gov.br/documento';
  SERVIDOR_DISTRIBUICAO='https://dev.pgeweb.sp.gov.br/distribuicao';
  SERVIDOR_INTEGRAJUD='https://dev.pgeweb.sp.gov.br/integrajud';
  AUTH_HEADER='Basic QVRUT1JOQVRVUzpULkQ8dXs0NjVoO1lAWnFf';
fi

if [[ $AMBIENTE =~ "app.attus.ai" ]]; then
  SERVIDOR_PROCESSO='https://app.attus.ai/processo';
  SERVIDOR_UAA='https://app.attus.ai/uaa';
  SERVIDOR_DEMANDA='https:/app.attus.ai/demanda';
  SERVIDOR_ADMIN='https://app.attus.ai/admin';
  SERVIDOR_PESSOA='https://app.attus.ai/pessoa';
  SERVIDOR_DIVIDA='https://app.attus.ai/divida';
  SERVIDOR_DOCUMENTO='https://app.attus.ai/documento';
  SERVIDOR_DISTRIBUICAO='https://app.attus.ai/distribuicao';
  SERVIDOR_INTEGRAJUD='https://app.attus.ai/integrajud';
  AUTH_HEADER='Basic QVRUT1JOQVRVUzp5V3BfW1Q2ckFHZUBRfnZz';
fi

if [[ $AMBIENTE =~ "qualidade.attus" ]]; then
  SERVIDOR_PROCESSO='https://qualidade.attus.ai/processo';
  SERVIDOR_UAA='https://qualidade.attus.ai/uaa';
  SERVIDOR_DEMANDA='https://qualidade.attus.ai/demanda';
  SERVIDOR_ADMIN='https://qualidade.attus.ai/admin';
  SERVIDOR_PESSOA='https://qualidade.attus.ai/pessoa';
  SERVIDOR_DIVIDA='https://qualidade.attus.ai/divida';
  SERVIDOR_DOCUMENTO='https://qualidade.attus.ai/documento';
  SERVIDOR_DISTRIBUICAO='https://qualidade.attus.ai/distribuicao';
  SERVIDOR_INTEGRAJUD='https://qualidade.attus.ai/integrajud';
  AUTH_HEADER='Basic QVRUT1JOQVRVUzpCeC8iUWM/OHt+PjdYTnYn';
fi

if [[ $AMBIENTE =~ "apidev.attus.ai" ]]; then
  SERVIDOR_PROCESSO='https://apidev.attus.ai/processo';
  SERVIDOR_UAA='https://apidev.attus.ai/uaa';
  SERVIDOR_DEMANDA='https://apidev.attus.ai/demanda';
  SERVIDOR_ADMIN='https://apidev.attus.ai/admin';
  SERVIDOR_PESSOA='https://apidev.attus.ai/pessoa';
  SERVIDOR_DIVIDA='https://apidev.attus.ai/divida';
  SERVIDOR_DOCUMENTO='https://apidev.attus.ai/documento';
  SERVIDOR_DISTRIBUICAO='https://apidev.attus.ai/distribuicao';
  SERVIDOR_INTEGRAJUD='https://apidev.attus.ai/integrajud';
  AUTH_HEADER='Basic QVRUT1JOQVRVUzpCNXJWOHlUM25MN3FKMndL';
fi

if [[ $AMBIENTE =~ "trn.attus.ai" ]]; then
  SERVIDOR_PROCESSO='https://trn.attus.ai/processo';
  SERVIDOR_UAA='https://trn.attus.ai/uaa';
  SERVIDOR_DEMANDA='https://trn.attus.ai/demanda';
  SERVIDOR_ADMIN='https://trn.attus.ai/admin';
  SERVIDOR_PESSOA='https://trn.attus.ai/pessoa';
  SERVIDOR_DIVIDA='https://trn.attus.ai/divida';
  SERVIDOR_DOCUMENTO='https://trn.attus.ai/documento';
  SERVIDOR_DISTRIBUICAO='https://trn.attus.ai/distribuicao';
  SERVIDOR_INTEGRAJUD='https://trn.attus.ai/integrajud';
  AUTH_HEADER='Basic QVRUT1JOQVRVUzpWYVYlbiZVSnJPWnRVfTBE';
fi

echo "TOKEN HEADER: $AUTH_HEADER"