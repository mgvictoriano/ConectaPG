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
source ./auxiliares/qualidade.sh

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
AUTH_HEADER='Basic '

if [[ $AMBIENTE =~ "dev.attornatus" ]]; then
	SERVIDOR_PROCESSO='https://dev.attornatus.com.br/processo'
	SERVIDOR_UAA='https://dev.attornatus.com.br/uaa'
	SERVIDOR_DEMANDA='https://dev.attornatus.com.br/demanda'
	SERVIDOR_ADMIN='https://dev.attornatus.com.br/admin'
	SERVIDOR_PESSOA='https://dev.attornatus.com.br/pessoa'
	SERVIDOR_DIVIDA='https://dev.attornatus.com.br/divida'
	SERVIDOR_DOCUMENTO='https://dev.attornatus.com.br/documento'
	SERVIDOR_DISTRIBUICAO='https://dev.attornatus.com.br/distribuicao'
	SERVIDOR_INTEGRAJUD='https://dev.attornatus.com.br/integrajud'
	AUTH_HEADER='Basic QVRUT1JOQVRVUzpCeC8iUWM/OHt+PjdYTnYn'
fi

if [[ $AMBIENTE =~ "dev.attus.ai" ]]; then
	SERVIDOR_PROCESSO='https://dev.attus.ai/processo'
	SERVIDOR_UAA='https://dev.attus.ai/uaa'
	SERVIDOR_DEMANDA='https://dev.attus.ai/demanda'
	SERVIDOR_ADMIN='https://dev.attus.ai/admin'
	SERVIDOR_PESSOA='https://dev.attus.ai/pessoa'
	SERVIDOR_DIVIDA='https://dev.attus.ai/divida'
	SERVIDOR_DOCUMENTO='https://dev.attus.ai/documento'
	SERVIDOR_DISTRIBUICAO='https://dev.attus.ai/distribuicao'
	SERVIDOR_INTEGRAJUD='https://dev.attus.ai/integrajud'
	AUTH_HEADER='Basic QVRUT1JOQVRVUzpCeC8iUWM/OHt+PjdYTnYn'
fi

if [[ $AMBIENTE =~ "pgesp.attus.ai" ]]; then
	SERVIDOR_PROCESSO='https://pgesp.attus.ai/processo'
	SERVIDOR_UAA='https://pgesp.attus.ai/uaa'
	SERVIDOR_DEMANDA='https://pgesp.attus.ai/demanda'
	SERVIDOR_ADMIN='https://pgesp.attus.ai/admin'
	SERVIDOR_PESSOA='https://pgesp.attus.ai/pessoa'
	SERVIDOR_DIVIDA='https://pgesp.attus.ai/divida'
	SERVIDOR_DOCUMENTO='https://pgesp.attus.ai/documento'
	SERVIDOR_DISTRIBUICAO='https://pgesp.attus.ai/distribuicao'
	SERVIDOR_INTEGRAJUD='https://pgesp.attus.ai/integrajud'
	AUTH_HEADER='Basic QVRUT1JOQVRVUzpqJyo1TjxBbkNGLVdkWDZL'
fi

if [[ $AMBIENTE =~ "localhost" ]]; then
	SERVIDOR_PROCESSO='http://localhost:8082/processo'
	SERVIDOR_UAA='http://localhost:9999/uaa'
	SERVIDOR_DEMANDA='http://localhost:8085/demanda'
	SERVIDOR_ADMIN='http://localhost:8000/admin'
	SERVIDOR_PESSOA='http://localhost:8083/pessoa'
	SERVIDOR_DIVIDA='http://localhost:8084/divida'
	SERVIDOR_DOCUMENTO='http://localhost:8081/documento'
	SERVIDOR_DISTRIBUICAO='http://localhost:8087/distribuicao'
	SERVIDOR_INTEGRAJUD='http://localhost:8088/integrajud'
	AUTH_HEADER='Basic QVRUT1JOQVRVUzpFOSU7fnJBcTQ2Wkx1KEA6'
fi

if [[ $AMBIENTE =~ "hml.attornatus" ]]; then
	SERVIDOR_PROCESSO='https://hml.attornatus.com.br/processo'
	SERVIDOR_UAA='https://hml.attornatus.com.br/uaa'
	SERVIDOR_DEMANDA='https:/hml.attornatus.com.br/demanda'
	SERVIDOR_ADMIN='https://hml.attornatus.com.br/admin'
	SERVIDOR_PESSOA='https://hml.attornatus.com.br/pessoa'
	SERVIDOR_DIVIDA='https://hml.attornatus.com.br/divida'
	SERVIDOR_DOCUMENTO='https://hml.attornatus.com.br/documento'
	SERVIDOR_DISTRIBUICAO='https://hml.attornatus.com.br/distribuicao'
	SERVIDOR_INTEGRAJUD='https://hml.attornatus.com.br/integrajud'
	AUTH_HEADER='Basic QVRUT1JOQVRVUzpOWzRHUmpnQy9yOFE6Yj1x'
fi

if [[ $AMBIENTE =~ "dev.pgeweb" ]]; then
	SERVIDOR_PROCESSO='https://dev.pgeweb.sp.gov.br/processo'
	SERVIDOR_UAA='https://dev.pgeweb.sp.gov.br/uaa'
	SERVIDOR_DEMANDA='https://dev.pgeweb.sp.gov.br/demanda'
	SERVIDOR_ADMIN='https://dev.pgeweb.sp.gov.br/admin'
	SERVIDOR_PESSOA='https://dev.pgeweb.sp.gov.br/pessoa'
	SERVIDOR_DIVIDA='https://dev.pgeweb.sp.gov.br/divida'
	SERVIDOR_DOCUMENTO='https://dev.pgeweb.sp.gov.br/documento'
	SERVIDOR_DISTRIBUICAO='https://dev.pgeweb.sp.gov.br/distribuicao'
	SERVIDOR_INTEGRAJUD='https://dev.pgeweb.sp.gov.br/integrajud'
	AUTH_HEADER='Basic QVRUT1JOQVRVUzpULkQ8dXs0NjVoO1lAWnFf'
fi

if [[ $AMBIENTE =~ "app.attus.ai" ]]; then
	SERVIDOR_PROCESSO='https://app.attus.ai/processo'
	SERVIDOR_UAA='https://app.attus.ai/uaa'
	SERVIDOR_DEMANDA='https:/app.attus.ai/demanda'
	SERVIDOR_ADMIN='https://app.attus.ai/admin'
	SERVIDOR_PESSOA='https://app.attus.ai/pessoa'
	SERVIDOR_DIVIDA='https://app.attus.ai/divida'
	SERVIDOR_DOCUMENTO='https://app.attus.ai/documento'
	SERVIDOR_DISTRIBUICAO='https://app.attus.ai/distribuicao'
	SERVIDOR_INTEGRAJUD='https://app.attus.ai/integrajud'
	AUTH_HEADER='Basic QVRUT1JOQVRVUzp5V3BfW1Q2ckFHZUBRfnZz'
fi

if [[ $AMBIENTE =~ "qualidade.attus" ]]; then
	SERVIDOR_PROCESSO='https://qualidade.attus.ai/processo'
	SERVIDOR_UAA='https://qualidade.attus.ai/uaa'
	SERVIDOR_DEMANDA='https://qualidade.attus.ai/demanda'
	SERVIDOR_ADMIN='https://qualidade.attus.ai/admin'
	SERVIDOR_PESSOA='https://qualidade.attus.ai/pessoa'
	SERVIDOR_DIVIDA='https://qualidade.attus.ai/divida'
	SERVIDOR_DOCUMENTO='https://qualidade.attus.ai/documento'
	SERVIDOR_DISTRIBUICAO='https://qualidade.attus.ai/distribuicao'
	SERVIDOR_INTEGRAJUD='https://qualidade.attus.ai/integrajud'
	AUTH_HEADER='Basic QVRUT1JOQVRVUzpCeC8iUWM/OHt+PjdYTnYn'
fi

if [[ $AMBIENTE =~ "apidev.attus.ai" ]]; then
	SERVIDOR_PROCESSO='https://apidev.attus.ai/processo'
	SERVIDOR_UAA='https://apidev.attus.ai/uaa'
	SERVIDOR_DEMANDA='https://apidev.attus.ai/demanda'
	SERVIDOR_ADMIN='https://apidev.attus.ai/admin'
	SERVIDOR_PESSOA='https://apidev.attus.ai/pessoa'
	SERVIDOR_DIVIDA='https://apidev.attus.ai/divida'
	SERVIDOR_DOCUMENTO='https://apidev.attus.ai/documento'
	SERVIDOR_DISTRIBUICAO='https://apidev.attus.ai/distribuicao'
	SERVIDOR_INTEGRAJUD='https://apidev.attus.ai/integrajud'
	AUTH_HEADER='Basic QVRUT1JOQVRVUzpCNXJWOHlUM25MN3FKMndL'
fi

if [[ $AMBIENTE =~ "trn.attus.ai" ]]; then
	SERVIDOR_PROCESSO='https://trn.attus.ai/processo'
	SERVIDOR_UAA='https://trn.attus.ai/uaa'
	SERVIDOR_DEMANDA='https://trn.attus.ai/demanda'
	SERVIDOR_ADMIN='https://trn.attus.ai/admin'
	SERVIDOR_PESSOA='https://trn.attus.ai/pessoa'
	SERVIDOR_DIVIDA='https://trn.attus.ai/divida'
	SERVIDOR_DOCUMENTO='https://trn.attus.ai/documento'
	SERVIDOR_DISTRIBUICAO='https://trn.attus.ai/distribuicao'
	SERVIDOR_INTEGRAJUD='https://trn.attus.ai/integrajud'
	AUTH_HEADER='Basic QVRUT1JOQVRVUzpWYVYlbiZVSnJPWnRVfTBE'
fi

if [[ $AMBIENTE =~ "desenvolvimento.attus.pge.sp.gov.br" ]]; then
	SERVIDOR_PROCESSO='https://desenvolvimento.attus.pge.sp.gov.br/processo'
	SERVIDOR_UAA='https://desenvolvimento.attus.pge.sp.gov.br/uaa'
	SERVIDOR_DEMANDA='https://desenvolvimento.attus.pge.sp.gov.br/demanda'
	SERVIDOR_ADMIN='https://desenvolvimento.attus.pge.sp.gov.br/admin'
	SERVIDOR_PESSOA='https://desenvolvimento.attus.pge.sp.gov.br/pessoa'
	SERVIDOR_DIVIDA='https://desenvolvimento.attus.pge.sp.gov.br/divida'
	SERVIDOR_DOCUMENTO='https://desenvolvimento.attus.pge.sp.gov.br/documento'
	SERVIDOR_DISTRIBUICAO='https://desenvolvimento.attus.pge.sp.gov.br/distribuicao'
	SERVIDOR_INTEGRAJUD='https://desenvolvimento.attus.pge.sp.gov.br/integrajud'
	AUTH_HEADER='Basic QVRUT1JOQVRVUzpULkQ8dXs0NjVoO1lAWnFf'
fi

echo "TOKEN HEADER: $AUTH_HEADER"

INCLUIR_ANEXOS_ADICIONAIS=false

############################### PRINCIPAL #####################
rm -f *.json

fn_autenticar

fn_identifica_dados_basicos
echo iniciando...

echo "Excluido ciações eletrônicas..."

ORIGEM_ANDAMENTO_ID="1050575"
fn_exclusao_andamentos_mocks

ORIGEM_ANDAMENTO_ID="1057831"
fn_exclusao_andamentos_mocks

ORIGEM_ANDAMENTO_ID="1011710"
fn_exclusao_andamentos_mocks

ORIGEM_ANDAMENTO_ID="1045636"
fn_exclusao_andamentos_mocks

ORIGEM_ANDAMENTO_ID="1500087"
fn_exclusao_andamentos_mocks

ORIGEM_ANDAMENTO_ID="1016962"
fn_exclusao_andamentos_mocks

ORIGEM_ANDAMENTO_ID="1042825"
fn_exclusao_andamentos_mocks

echo "Excluido intimações eletrônicas"

ORIGEM_ANDAMENTO_ID="1556851"
fn_exclusao_andamentos_mocks

ORIGEM_ANDAMENTO_ID="1532123"
fn_exclusao_andamentos_mocks

ORIGEM_ANDAMENTO_ID="1501003"
fn_exclusao_andamentos_mocks

ORIGEM_ANDAMENTO_ID="1551253"
fn_exclusao_andamentos_mocks

ORIGEM_ANDAMENTO_ID="1558015"
fn_exclusao_andamentos_mocks

ORIGEM_ANDAMENTO_ID="1558483"
fn_exclusao_andamentos_mocks

ORIGEM_ANDAMENTO_ID="1566890"
fn_exclusao_andamentos_mocks

ORIGEM_ANDAMENTO_ID="1584307"
fn_exclusao_andamentos_mocks

ORIGEM_ANDAMENTO_ID="1501019"
fn_exclusao_andamentos_mocks

ORIGEM_ANDAMENTO_ID="1501018"
fn_exclusao_andamentos_mocks

ORIGEM_ANDAMENTO_ID="1501020"
fn_exclusao_andamentos_mocks

ORIGEM_ANDAMENTO_ID="1042825198"
fn_exclusao_andamentos_mocks

ORIGEM_ANDAMENTO_ID="1050575198"
fn_exclusao_andamentos_mocks

ORIGEM_ANDAMENTO_ID="1016962198"
fn_exclusao_andamentos_mocks

ORIGEM_ANDAMENTO_ID="1501027460"
fn_exclusao_andamentos_mocks

fn_excluir_documentos_com_processo

fn_excluir_dividas_gera_exemplos

fn_apagar_hash_dividas

fn_apagar_documentos_aguardando_vinculacao_processo

fn_parte_representada

fn_apagar_distribuicoes

fn_apagar_processos

fn_apagar_process_instaces

fn_demanda_excluir_historico_distribuicao

<<COMENTARIO_DE_BLOCO
COMENTARIO_DE_BLOCO

fn_excluir_enderecos_citacao_negativa

fn_apagar_cache_parametro_instituicao

fn_apagar_caches_dados

fn_apagar_lotacoes_e_inserir_mesa_vaga FIS-002

fn_apagar_lotacoes_e_inserir_mesa_vaga FIS-003

# fn_apagar_resumo_recebimento

fn_atualizar_resumo_recebimento

##################################################################### Processo com PI sem distribuição - 01
fn_data_atual
DIAS_REDUZIR=30
fn_data_anterior
PROCESSO_NUMERO="1901001-01.2024.8.26.0053"
PROCESSO_VALOR=15945.69
PROCESSO_NOME_PARTE_CONTRARIA="Pedro Alvares da Silva"
PROCESSO_CPF_PARTE_CONTRARIA="332.620.380-24"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
MATERIA=$MATERIA_AGUARDANDO_CONFERENCIA # Aguardando conferência
ASSUNTO=$ASSUNTO_AGUARDANDO_CONFERENCIA # Requer conferência
ASSUNTO_CNJ=6060
fn_inserir_contencioso

ANDAMENTO_NOME_DOCUMENTO="Petição inicial"
ANDAMENTO_TIPO=$TIPO_ANDAMENTO_PETICAO_INICIAL
ANDAMENTO_ORIGEM="AUTOS_JUDICIARIO"
ANDAMENTO_ARQUIVO_PRINCIPAL="./documentos/$PROCESSO_NUMERO$()_peticao-Inicial.pdf"
DIAS_REDUZIR=50
fn_data_anterior
fn_inserir_andamento

##################################################################### Processo com PI sem distribuição - 02
fn_data_atual
DIAS_REDUZIR=30
fn_data_anterior
PROCESSO_NUMERO="1901002-02.2024.8.26.0053"
PROCESSO_VALOR=11400.00
PROCESSO_NOME_PARTE_CONTRARIA="Valter Gomes Pereira"
PROCESSO_CPF_PARTE_CONTRARIA="295.042.360-49"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
MATERIA=$MATERIA_AGUARDANDO_CONFERENCIA # Aguardando conferência
ASSUNTO=$ASSUNTO_AGUARDANDO_CONFERENCIA # Requer conferência
ASSUNTO_CNJ=12484
fn_inserir_contencioso

ANDAMENTO_NOME_DOCUMENTO="Petição inicial"
ANDAMENTO_TIPO=$TIPO_ANDAMENTO_PETICAO_INICIAL
ANDAMENTO_ORIGEM="AUTOS_JUDICIARIO"
ANDAMENTO_ARQUIVO_PRINCIPAL="./documentos/$PROCESSO_NUMERO$()_peticao-Inicial.pdf"
DIAS_REDUZIR=50
fn_data_anterior
fn_inserir_andamento

##################################################################### Processo com PI sem distribuição - 03
fn_data_atual
DIAS_REDUZIR=30
fn_data_anterior
PROCESSO_NUMERO="1901003-03.2024.8.26.0053"
PROCESSO_VALOR=13915.20
PROCESSO_NOME_PARTE_CONTRARIA="Gisele da Silva Gonçalves"
PROCESSO_CPF_PARTE_CONTRARIA="542.481.920-63"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
MATERIA=$MATERIA_AGUARDANDO_CONFERENCIA # Aguardando conferência
ASSUNTO=$ASSUNTO_AGUARDANDO_CONFERENCIA # Requer conferência
ASSUNTO_CNJ=12484
fn_inserir_contencioso

ANDAMENTO_NOME_DOCUMENTO="Petição inicial"
ANDAMENTO_TIPO=$TIPO_ANDAMENTO_PETICAO_INICIAL
ANDAMENTO_ORIGEM="AUTOS_JUDICIARIO"
ANDAMENTO_ARQUIVO_PRINCIPAL="./documentos/$PROCESSO_NUMERO$()_peticao-Inicial.pdf"
DIAS_REDUZIR=50
fn_data_anterior
fn_inserir_andamento

##################################################################### Processo com PI sem distribuição - 04
fn_data_atual
DIAS_REDUZIR=30
fn_data_anterior
PROCESSO_NUMERO="1901004-04.2024.8.26.0053"
PROCESSO_VALOR=24228.22
PROCESSO_NOME_PARTE_CONTRARIA="Katia Joana dos Santos"
PROCESSO_CPF_PARTE_CONTRARIA="974.564.920-18"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
MATERIA=$MATERIA_AGUARDANDO_CONFERENCIA # Aguardando conferência
ASSUNTO=$ASSUNTO_AGUARDANDO_CONFERENCIA # Requer conferência
ASSUNTO_CNJ=12484
fn_inserir_contencioso

ANDAMENTO_NOME_DOCUMENTO="Petição inicial"
ANDAMENTO_TIPO=$TIPO_ANDAMENTO_PETICAO_INICIAL
ANDAMENTO_ORIGEM="AUTOS_JUDICIARIO"
ANDAMENTO_ARQUIVO_PRINCIPAL="./documentos/$PROCESSO_NUMERO$()_peticao-Inicial.pdf"
DIAS_REDUZIR=50
fn_data_anterior
fn_inserir_andamento

##################################################################### Processo com PI sem distribuição - 05
fn_data_atual
DIAS_REDUZIR=30
fn_data_anterior
PROCESSO_NUMERO="1901005-05.2024.8.26.0053"
PROCESSO_VALOR=16023.75
PROCESSO_NOME_PARTE_CONTRARIA="Jackson Cardoso"
PROCESSO_CPF_PARTE_CONTRARIA="792.718.190-47"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
MATERIA=$MATERIA_AGUARDANDO_CONFERENCIA # Aguardando conferência
ASSUNTO=$ASSUNTO_AGUARDANDO_CONFERENCIA # Requer conferência
ASSUNTO_CNJ=6060
fn_inserir_contencioso

ANDAMENTO_NOME_DOCUMENTO="Petição inicial"
ANDAMENTO_TIPO=$TIPO_ANDAMENTO_PETICAO_INICIAL
ANDAMENTO_ORIGEM="AUTOS_JUDICIARIO"
ANDAMENTO_ARQUIVO_PRINCIPAL="./documentos/$PROCESSO_NUMERO$()_peticao-Inicial.pdf"
DIAS_REDUZIR=50
fn_data_anterior
fn_inserir_andamento

##################################################################### Processo com PI sem distribuição - 06
fn_data_atual
DIAS_REDUZIR=30
fn_data_anterior
PROCESSO_NUMERO="1901006-06.2024.8.26.0053"
PROCESSO_VALOR=5000.00
PROCESSO_NOME_PARTE_CONTRARIA="Maria da Rosa Silva Pereira"
PROCESSO_CPF_PARTE_CONTRARIA="158.535.260-81"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
MATERIA=$MATERIA_AGUARDANDO_CONFERENCIA # Aguardando conferência
ASSUNTO=$ASSUNTO_AGUARDANDO_CONFERENCIA # Requer conferência
ASSUNTO_CNJ=5953
fn_inserir_contencioso

ANDAMENTO_NOME_DOCUMENTO="Petição inicial"
ANDAMENTO_TIPO=$TIPO_ANDAMENTO_PETICAO_INICIAL
ANDAMENTO_ORIGEM="AUTOS_JUDICIARIO"
ANDAMENTO_ARQUIVO_PRINCIPAL="./documentos/$PROCESSO_NUMERO$()_peticao-Inicial.pdf"
DIAS_REDUZIR=50
fn_data_anterior
fn_inserir_andamento

##################################################################### EF 01 - Exceção de Pré-executividade
fn_data_atual
DIAS_REDUZIR=54
fn_data_anterior
PROCESSO_NUMERO="1501001-01.2018.8.26.0090"
PROCESSO_VALOR=1542
PROCESSO_NOME_PARTE_CONTRARIA="Carlos Rosa Andrade"
PROCESSO_CPF_PARTE_CONTRARIA="123.456.789-99"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
fn_inserir_EF

# Intimação Exceção de Pré-executividade
fn_data_atual
fn_inserir_andamento_excecao_pre

ANDAMENTO_TIPO=$TIPO_ANDAMENTO_PETICAO_EXCECAO_PRE_EXECUTIVIDADE
ANDAMENTO_ORIGEM="AUTOS_JUDICIARIO"
ANDAMENTO_ARQUIVO_PRINCIPAL="./documentos/$PROCESSO_NUMERO$()_peticao-excecao-de-pre-executividade.pdf"
DIAS_REDUZIR=4
fn_data_anterior
fn_inserir_andamento

##################################################################### EF 02 - Exceção de Pré-executividade
fn_data_atual
DIAS_REDUZIR=50
fn_data_anterior
PROCESSO_NUMERO="1558483-77.2017.8.26.0090"
PROCESSO_VALOR=2742
PROCESSO_NOME_PARTE_CONTRARIA="Tadeu Kester"
PROCESSO_CPF_PARTE_CONTRARIA="909.212.234-78"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
fn_inserir_EF

##################################################################### EF 03 - Exceção de Pré-executividade
fn_data_atual
DIAS_REDUZIR=40
fn_data_anterior
PROCESSO_NUMERO="1501003-03.2018.8.26.0090"
PROCESSO_VALOR=3942
PROCESSO_NOME_PARTE_CONTRARIA="Pedro Gonzaga da Silva"
PROCESSO_CPF_PARTE_CONTRARIA="909.232.234-78"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
fn_inserir_EF

##################################################################### EF 04 - Exceção de Pré-executividade
fn_data_atual
DIAS_REDUZIR=30
fn_data_anterior
PROCESSO_NUMERO="1501004-04.2018.8.26.0090"
PROCESSO_VALOR=5142
PROCESSO_NOME_PARTE_CONTRARIA="João da Silva Pereira"
PROCESSO_CPF_PARTE_CONTRARIA="112.554.231-55"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
fn_inserir_EF

# Intimação Exceção de Pré-executividade
fn_data_atual
DIAS_REDUZIR=8
fn_data_anterior
fn_inserir_andamento_excecao_pre

##################################################################### EF 05 - Exceção de Pré-executividade
fn_data_atual
DIAS_REDUZIR=20
fn_data_anterior
PROCESSO_NUMERO="1501005-05.2018.8.26.0090"
PROCESSO_VALOR=6342
PROCESSO_NOME_PARTE_CONTRARIA="Jorge Melo Faraco"
PROCESSO_CPF_PARTE_CONTRARIA="887.111.234-78"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
fn_inserir_EF

# Intimação Exceção de Pré-executividade
fn_data_atual
DIAS_REDUZIR=7
fn_data_anterior
fn_inserir_andamento_excecao_pre

ANDAMENTO_NOME_DOCUMENTO="Exceção de Pré-executividade"
ANDAMENTO_TIPO=$TIPO_ANDAMENTO_PETICAO_EXCECAO_PRE_EXECUTIVIDADE
ANDAMENTO_ORIGEM="AUTOS_JUDICIARIO"
ANDAMENTO_ARQUIVO_PRINCIPAL="./documentos/$PROCESSO_NUMERO$()_peticao-excecao-de-pre-executividade.pdf"
DIAS_REDUZIR=13
fn_data_anterior
fn_inserir_andamento

##################################################################### EF 06 - Dívida Parcelada
fn_data_atual
DIAS_REDUZIR=100
fn_data_anterior
PROCESSO_NUMERO="1501006-06.2020.8.26.0090"
PROCESSO_VALOR=7542
PROCESSO_NOME_PARTE_CONTRARIA="Cristiano Lemos"
PROCESSO_CPF_PARTE_CONTRARIA="776.111.221-44"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
fn_inserir_EF

# Inserir Divida
fn_data_atual
DIVIDA_DATA_ATUALIZACAO_VALORES="$ANO-$MES-$DIA$()T03:00:00"
DIAS_REDUZIR=145
fn_data_anterior
DIVIDA_DATA_VENCIMENTO_COMPOSICAO="$ANO-$MES-$DIA$()T03:00:00"
fn_data_atual
DIAS_REDUZIR=115
fn_data_anterior
DIVIDA_NUMERO="1501006/2020"
DIVIDA_IDENTIFICADOR="1501006"
DIVIDA_ENDERECO_LOGRADOURO="Rua das Araras"
DIVIDA_ENDERECO_NUMERO="270"
DIVIDA_ENDERECO_BAIRRO="Centro"
DIVIDA_ENDERECO_CEP="01319-908"
DIVIDA_ENDERECO_UF="SP"
DIVIDA_ENDERCO_MUNICIPIO_ID=3550308
fn_inserir_divida

# Inserir Parcelamento
fn_data_atual
PARCELAMENTO_DATA_ULTIMO_PAGAMENTO="$ANO-$MES-$DIA$()T03:00:00"
DIAS_REDUZIR=92
fn_data_anterior
PARCELAMENTO_IDENTIFICADOR="000001501006"
PARCELAMENTO_NUMERO="000001501006"
PARCELAMENTO_PARCELAS=3
fn_inserir_parcelamento

##################################################################### EF 07 - Dívida Parcelada
fn_data_atual
DIAS_REDUZIR=30
fn_data_anterior
PROCESSO_NUMERO="1501007-07.2020.8.26.0090"
PROCESSO_VALOR=17984
PROCESSO_NOME_PARTE_CONTRARIA="Pedro Paulo Rodrigues"
PROCESSO_CPF_PARTE_CONTRARIA="112.222.221-44"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
fn_inserir_EF

# Inserir Divida
PROCESSO_VALOR=9242
fn_data_atual
DIVIDA_DATA_ATUALIZACAO_VALORES="$ANO-$MES-$DIA$()T03:00:00"
DIAS_REDUZIR=50
fn_data_anterior
DIVIDA_DATA_VENCIMENTO_COMPOSICAO="$ANO-$MES-$DIA$()T03:00:00"
fn_data_atual
DIAS_REDUZIR=40
fn_data_anterior
DIVIDA_NUMERO="1501007-2/2020"
DIVIDA_IDENTIFICADOR="1501007-2"
DIVIDA_ENDERECO_LOGRADOURO="Rua das Araras"
DIVIDA_ENDERECO_NUMERO="270"
DIVIDA_ENDERECO_BAIRRO="Centro"
DIVIDA_ENDERECO_CEP="01319-908"
DIVIDA_ENDERECO_UF="SP"
DIVIDA_ENDERCO_MUNICIPIO_ID=3550308
fn_inserir_divida

# Inserir Divida
PROCESSO_VALOR=8742
fn_data_atual
DIVIDA_DATA_ATUALIZACAO_VALORES="$ANO-$MES-$DIA$()T03:00:00"
DIAS_REDUZIR=65
fn_data_anterior
DIVIDA_DATA_VENCIMENTO_COMPOSICAO="$ANO-$MES-$DIA$()T03:00:00"
fn_data_atual
DIAS_REDUZIR=50
fn_data_anterior
DIVIDA_NUMERO="1501007/2020"
DIVIDA_IDENTIFICADOR="1501007"
DIVIDA_ENDERECO_LOGRADOURO="Rua das Araras"
DIVIDA_ENDERECO_NUMERO="270"
DIVIDA_ENDERECO_BAIRRO="Centro"
DIVIDA_ENDERECO_CEP="01319-908"
DIVIDA_ENDERECO_UF="SP"
DIVIDA_ENDERCO_MUNICIPIO_ID=3550308
fn_inserir_divida

# Inserir Parcelamento
fn_data_atual
PARCELAMENTO_DATA_ULTIMO_PAGAMENTO="$ANO-$MES-$DIA$()T03:00:00"
DIAS_REDUZIR=30
fn_data_anterior
PARCELAMENTO_IDENTIFICADOR="000001501007"
PARCELAMENTO_NUMERO="000001501007"
PARCELAMENTO_PARCELAS=3
fn_inserir_parcelamento

##################################################################### EF 08 - Dívida Parcelada
fn_data_atual
DIAS_REDUZIR=15
fn_data_anterior
PROCESSO_NUMERO="1501008-08.2020.8.26.0090"
PROCESSO_VALOR=9942
PROCESSO_NOME_PARTE_CONTRARIA="José da Costa Pereira"
PROCESSO_CPF_PARTE_CONTRARIA="098.211.883-22"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
fn_inserir_EF

# Inserir Divida
fn_data_atual
DIVIDA_DATA_ATUALIZACAO_VALORES="$ANO-$MES-$DIA$()T03:00:00"
DIAS_REDUZIR=35
fn_data_anterior
DIVIDA_DATA_VENCIMENTO_COMPOSICAO="$ANO-$MES-$DIA$()T03:00:00"
fn_data_atual
DIAS_REDUZIR=25
fn_data_anterior
DIVIDA_NUMERO="1501008/2020"
DIVIDA_IDENTIFICADOR="1501008"
DIVIDA_ENDERECO_LOGRADOURO="Rua das Araras"
DIVIDA_ENDERECO_NUMERO="270"
DIVIDA_ENDERECO_BAIRRO="Centro"
DIVIDA_ENDERECO_CEP="01319-908"
DIVIDA_ENDERECO_UF="SP"
DIVIDA_ENDERCO_MUNICIPIO_ID=3550308
fn_inserir_divida

# Inserir Parcelamento
fn_data_atual
PARCELAMENTO_DATA_ULTIMO_PAGAMENTO="$ANO-$MES-$DIA$()T03:00:00"
DIAS_REDUZIR=10
fn_data_anterior
PARCELAMENTO_IDENTIFICADOR="000001501008"
PARCELAMENTO_NUMERO="000001501008"
PARCELAMENTO_PARCELAS=9
fn_inserir_parcelamento

##################################################################### EF 09 - Dívida Quitada
fn_data_atual
DIAS_REDUZIR=25
fn_data_anterior
PROCESSO_NUMERO="1501009-09.2018.8.26.0090"
PROCESSO_VALOR=11142
PROCESSO_NOME_PARTE_CONTRARIA="Gerson Warmeling"
PROCESSO_CPF_PARTE_CONTRARIA="498.991.883-22"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
fn_inserir_EF

# Evento Dívida Ativa
fn_data_atual
DIAS_REDUZIR=1
fn_data_anterior
fn_inserir_andamento_divida_paga

##################################################################### EF 10 - Dívida Quitada
fn_data_atual
DIAS_REDUZIR=38
fn_data_anterior
PROCESSO_NUMERO="1501010-10.2018.8.26.0090"
PROCESSO_VALOR=12342
PROCESSO_NOME_PARTE_CONTRARIA="Joelson Oliveira"
PROCESSO_CPF_PARTE_CONTRARIA="112.780.883-00"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
fn_inserir_EF

# Evento Dívida Ativa
fn_data_atual
DIAS_REDUZIR=1
fn_data_anterior
fn_inserir_andamento_divida_paga

##################################################################### EF 11 - Dívida Quitada
fn_data_atual
DIAS_REDUZIR=38
fn_data_anterior
PROCESSO_NUMERO="1501011-11.2018.8.26.0090"
PROCESSO_VALOR=13542
PROCESSO_NOME_PARTE_CONTRARIA="Jeones Kester Ceolin"
PROCESSO_CPF_PARTE_CONTRARIA="231.678.112-01"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
fn_inserir_EF

# Evento Dívida Ativa
fn_data_atual
DIAS_REDUZIR=1
fn_data_anterior
fn_inserir_andamento_divida_paga

##################################################################### EF 12 - Parcelamento rompido
fn_data_atual
DIAS_REDUZIR=35
fn_data_anterior
PROCESSO_NUMERO="1501012-12.2018.8.26.0090"
PROCESSO_VALOR=14742
PROCESSO_NOME_PARTE_CONTRARIA="Jarbas Vasconcelos"
PROCESSO_CPF_PARTE_CONTRARIA="982.678.112-22"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
fn_inserir_EF

# Evento Dívida Ativa
fn_data_atual
DIAS_REDUZIR=1
fn_data_anterior
fn_inserir_andamento_parcelamento_rompido

##################################################################### EF 13 - Parcelamento rompido
fn_data_atual
DIAS_REDUZIR=35
fn_data_anterior
PROCESSO_NUMERO="1501013-13.2018.8.26.0090"
PROCESSO_VALOR=15942
PROCESSO_NOME_PARTE_CONTRARIA="Teonônio Gonçalves"
PROCESSO_CPF_PARTE_CONTRARIA="989.241.112-12"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
fn_inserir_EF

# Evento Dívida Ativa
fn_data_atual
fn_inserir_andamento_parcelamento_rompido

##################################################################### EF 14 - Dívida cancelada
fn_data_atual
DIAS_REDUZIR=30
fn_data_anterior
PROCESSO_NUMERO="1501014-14.2018.8.26.0090"
PROCESSO_VALOR=17142
PROCESSO_NOME_PARTE_CONTRARIA="Karla Fonseca"
PROCESSO_CPF_PARTE_CONTRARIA="998.000.002-10"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
fn_inserir_EF

# Evento Dívida Ativa
fn_data_atual
DIAS_REDUZIR=1
fn_data_anterior
fn_inserir_andamento_divida_cancelada

##################################################################### EF 15 - Dívida cancelada
fn_data_atual
DIAS_REDUZIR=33
fn_data_anterior
PROCESSO_NUMERO="1501015-15.2018.8.26.0090"
PROCESSO_VALOR=18342
PROCESSO_NOME_PARTE_CONTRARIA="Cláudia Ramos da Silva"
PROCESSO_CPF_PARTE_CONTRARIA="818.099.002-12"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
fn_inserir_EF

# Evento Dívida Ativa
fn_data_atual
DIAS_REDUZIR=2
fn_data_anterior
fn_inserir_andamento_divida_cancelada

##################################################################### EF 16 - Embargos a Execução Fiscal
fn_data_atual
DIAS_REDUZIR=45
fn_data_anterior
PROCESSO_NUMERO="1500016-16.2018.8.26.0090"
PROCESSO_VALOR=19542
PROCESSO_NOME_PARTE_CONTRARIA="Guilherme Antunes"
PROCESSO_CPF_PARTE_CONTRARIA="008.099.002-12"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
fn_inserir_EF

# Embargos a EF
PROCESSO_NUMERO="1501016-16.2018.8.26.0090"
fn_data_atual
DIAS_REDUZIR=25
fn_data_anterior
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
fn_inserir_embargos_EF

##################################################################### EF 17 - Embargos a Execução Fiscal
fn_data_atual
DIAS_REDUZIR=45
fn_data_anterior
PROCESSO_NUMERO="1500017-17.2018.8.26.0090"
PROCESSO_VALOR=20742
PROCESSO_NOME_PARTE_CONTRARIA="Rodrigo Mendonça"
PROCESSO_CPF_PARTE_CONTRARIA="776.119.002-10"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
fn_inserir_EF

# Embargos a EF
PROCESSO_NUMERO="1501017-17.2018.8.26.0090"
fn_data_atual
DIAS_REDUZIR=25
fn_data_anterior
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
fn_inserir_embargos_EF

##################################################################### EF 18 - Citação
fn_data_atual
DIAS_REDUZIR=30
fn_data_anterior
PROCESSO_NUMERO="1501021-21.2018.8.26.0053"
PROCESSO_VALOR=8000
PROCESSO_NOME_PARTE_CONTRARIA="Pedro Schlickmann"
PROCESSO_CPF_PARTE_CONTRARIA="728.112.312-09"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

# Citação
fn_inserir_andamento_citacao

##################################################################### EF 19 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=43
fn_data_anterior
PROCESSO_NUMERO="1501022-22.2018.8.26.0053"
PROCESSO_VALOR=60000
PROCESSO_NOME_PARTE_CONTRARIA="Denis Fontana"
PROCESSO_CPF_PARTE_CONTRARIA="112.983.312-09"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

# Citação
fn_inserir_andamento_citacao_tutela

ANDAMENTO_NOME_DOCUMENTO="Petição inicial"
ANDAMENTO_TIPO=$TIPO_ANDAMENTO_PETICAO_INICIAL
ANDAMENTO_ORIGEM="AUTOS_JUDICIARIO"
ANDAMENTO_ARQUIVO_PRINCIPAL="./documentos/$PROCESSO_NUMERO$()_peticao-Inicial.pdf"
DIAS_REDUZIR=50
fn_data_anterior
fn_inserir_andamento

ANDAMENTO_NOME_DOCUMENTO="Procuração"
ANDAMENTO_TIPO=$TIPO_ANDAMENTO_PROCURACAO
ANDAMENTO_ORIGEM="AUTOS_JUDICIARIO"
ANDAMENTO_ARQUIVO_PRINCIPAL="./documentos/$PROCESSO_NUMERO$()_procuracao.pdf"
fn_inserir_andamento

##################################################################### EF 20 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=43
fn_data_anterior
PROCESSO_NUMERO="1501023-23.2018.8.26.0053"
PROCESSO_VALOR=55000
PROCESSO_NOME_PARTE_CONTRARIA="João Ceolin"
PROCESSO_CPF_PARTE_CONTRARIA="098.123.333-03"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

# Citação
fn_inserir_andamento_citacao_tutela

##################################################################### EF 21 - Citação com tutela e prévia
fn_data_atual
DIAS_REDUZIR=6
fn_data_anterior
PROCESSO_NUMERO="1501024-24.2018.8.26.0053"
PROCESSO_VALOR=105000
PROCESSO_NOME_PARTE_CONTRARIA="Matheus Kestering"
PROCESSO_CPF_PARTE_CONTRARIA="433.223.322-02"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

# Citação
fn_inserir_andamento_citacao_tutela_previa

##################################################################### EF 22 - Citação com tutela e prévia
fn_data_atual
DIAS_REDUZIR=7
fn_data_anterior
PROCESSO_NUMERO="1501025-25.2018.8.26.0053"
PROCESSO_VALOR=105000
PROCESSO_NOME_PARTE_CONTRARIA="Gabriela Ribeiro"
PROCESSO_CPF_PARTE_CONTRARIA="112.332.234-02"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

# Citação
fn_inserir_andamento_citacao_tutela_previa

##################################################################### EF 23 - Sentença
fn_data_atual
DIAS_REDUZIR=60
fn_data_anterior
PROCESSO_NUMERO="1501026-26.2018.8.26.0053"
PROCESSO_VALOR=80000
PROCESSO_NOME_PARTE_CONTRARIA="Carlos Rosa Marques"
PROCESSO_CPF_PARTE_CONTRARIA="992.352.312-09"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

# Citação
fn_inserir_andamento_citacao

fn_data_atual
DIAS_REDUZIR=30
fn_data_anterior
# Contestacao
fn_inserir_andamento_contestacao

fn_data_atual
DIAS_REDUZIR=14
fn_data_anterior
# Contestacao
fn_inserir_andamento_sentenca

##################################################################### EF 24 - Sentença
fn_data_atual
DIAS_REDUZIR=30
fn_data_anterior
PROCESSO_NUMERO="1501027-27.2018.8.26.0053"
PROCESSO_VALOR=80000
PROCESSO_NOME_PARTE_CONTRARIA="Robson Oliveira Pedroso"
PROCESSO_CPF_PARTE_CONTRARIA="074.234.312-09"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
fn_inserir_contenciosoJEF

# Citação
fn_inserir_andamento_citacao

fn_data_atual
DIAS_REDUZIR=15
fn_data_anterior
# Contestacao
INCLUIR_ANEXOS_ADICIONAIS=true
fn_inserir_andamento_contestacao

fn_data_atual
DIAS_REDUZIR=8
fn_data_anterior
# Contestacao
fn_inserir_andamento_sentenca

##################################################################### EF 25 - Audiência
fn_data_atual
DIAS_REDUZIR=60
fn_data_anterior
PROCESSO_NUMERO="1501028-28.2018.8.26.0053"
PROCESSO_VALOR=22300
PROCESSO_NOME_PARTE_CONTRARIA="Carlos Joaquim Pereira"
PROCESSO_CPF_PARTE_CONTRARIA="123.221.222-10"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

# Citação
fn_inserir_andamento_citacao

fn_data_atual
DIAS_REDUZIR=30
fn_data_anterior
# Contestacao
fn_inserir_andamento_contestacao

fn_data_atual
DIAS_REDUZIR=12
fn_data_anterior
# audiência
fn_inserir_andamento_audiencia

##################################################################### EF 26 - Audiência
fn_data_atual
DIAS_REDUZIR=55
fn_data_anterior
PROCESSO_NUMERO="1501029-29.2018.8.26.0053"
PROCESSO_VALOR=22300
PROCESSO_NOME_PARTE_CONTRARIA="Giovanna Costa e Silva"
PROCESSO_CPF_PARTE_CONTRARIA="221.231.887-33"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

# Citação
fn_inserir_andamento_citacao

fn_data_atual
DIAS_REDUZIR=25
fn_data_anterior
# Contestacao
fn_inserir_andamento_contestacao

fn_data_atual
DIAS_REDUZIR=12
fn_data_anterior
# audiência
fn_inserir_andamento_audiencia

##################################################################### EF 27 - Audiência
fn_data_atual
DIAS_REDUZIR=58
fn_data_anterior
PROCESSO_NUMERO="1501030-30.2018.8.26.0053"
PROCESSO_VALOR=22300
PROCESSO_NOME_PARTE_CONTRARIA="Claudio Warmeling Xavier"
PROCESSO_CPF_PARTE_CONTRARIA="221.231.887-33"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

# Citação
fn_inserir_andamento_citacao

fn_data_atual
DIAS_REDUZIR=28
fn_data_anterior
# Contestacao
fn_inserir_andamento_contestacao

fn_data_atual
DIAS_REDUZIR=10
fn_data_anterior
# audiência
fn_inserir_andamento_audiencia

##################################################################### EF 28 - EF para lançamento posterior da Citação negativa
fn_data_atual
DIAS_REDUZIR=60
fn_data_anterior
PROCESSO_NUMERO="1532123-37.2019.8.26.0090"
PROCESSO_VALOR=3321
PROCESSO_NOME_PARTE_CONTRARIA="Claudio Jose Ramos Silva"
PROCESSO_CPF_PARTE_CONTRARIA="250.365.038-48"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
fn_inserir_EF

##################################################################### EF 29 - EF para lançamento posterior da Citação negativa
fn_data_atual
DIAS_REDUZIR=70
fn_data_anterior
PROCESSO_NUMERO="1551253-13.2019.8.26.0090"
PROCESSO_VALOR=7335
PROCESSO_NOME_PARTE_CONTRARIA="Carla Cavalcante Pereira"
PROCESSO_CPF_PARTE_CONTRARIA="249.877.798-97"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
fn_inserir_EF

##################################################################### EF 30 - EF para lançamento posterior da Citação negativa
fn_data_atual
DIAS_REDUZIR=75
fn_data_anterior
PROCESSO_NUMERO="1584307-67.2019.8.26.0090"
PROCESSO_VALOR=22085
PROCESSO_NOME_PARTE_CONTRARIA="Oficina Mecanica de Compressores de Ar Arantes Ltda"
PROCESSO_CPF_PARTE_CONTRARIA="43.159.086/0001-02"
TIPO_DOCUMENTO_PESSOA="CNPJ"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
fn_inserir_EF

##################################################################### EF 31 - EF para lançamento posterior da Suspeita Prescrição
fn_data_atual
DIAS_REDUZIR=80
fn_data_anterior
PROCESSO_NUMERO="1558015-45.2019.8.26.0090"
PROCESSO_VALOR=4321
PROCESSO_NOME_PARTE_CONTRARIA="Jose Ricardo e Silva Ramos"
PROCESSO_CPF_PARTE_CONTRARIA="872.450.940-04"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="2019-04-12T21:00:00"
fn_inserir_EF

##################################################################### EF 32 - EF para lançamento posterior da Suspeita Prescrição
fn_data_atual
DIAS_REDUZIR=90
fn_data_anterior
PROCESSO_NUMERO="1556851-45.2019.8.26.0090"
PROCESSO_VALOR=2321
PROCESSO_NOME_PARTE_CONTRARIA="Carlos Antonio Perreira da Silva"
PROCESSO_CPF_PARTE_CONTRARIA="973.837.160-00"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="2018-12-31T22:00:00"
fn_inserir_EF

##################################################################### EF 33 - EF para lançamento posterior da Suspeita Prescrição
fn_data_atual
DIAS_REDUZIR=95
fn_data_anterior
PROCESSO_NUMERO="1566890-04.2019.8.26.0090"
PROCESSO_VALOR=3221
PROCESSO_NOME_PARTE_CONTRARIA="Pedro Paulo Silveira Motta"
PROCESSO_CPF_PARTE_CONTRARIA="997.009.710-58"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="2019-04-14T21:00:00"
fn_inserir_EF

########################## EF 34 - Execução Fiscal

fn_data_atual
DIAS_REDUZIR=45
fn_data_anterior
PROCESSO_NUMERO="1501018-18.2018.8.26.0090"
PROCESSO_VALOR=1350
PROCESSO_NOME_PARTE_CONTRARIA="William Brasil"
PROCESSO_CPF_PARTE_CONTRARIA="111.231.002-10"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
fn_inserir_EF

##################################################################### Processos para demosntração do Risco Fiscal #########################################

##################################################################### Processo  35 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
fn_data_anterior
PROCESSO_NUMERO="1501035-23.2023.8.26.0053"
PROCESSO_VALOR=10000000
PROCESSO_NOME_PARTE_CONTRARIA="Joaquim da Silva Ramos Xavier"
PROCESSO_CPF_PARTE_CONTRARIA="489.074.580-73"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  36 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
fn_data_anterior
PROCESSO_NUMERO="1501036-23.2023.8.26.0053"
PROCESSO_VALOR=11000200
PROCESSO_NOME_PARTE_CONTRARIA="Edson Lima de Araújo"
PROCESSO_CPF_PARTE_CONTRARIA="402.558.200-70"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  37 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
fn_data_anterior
PROCESSO_NUMERO="1501037-23.2023.8.26.0053"
PROCESSO_VALOR=3000100
PROCESSO_NOME_PARTE_CONTRARIA="Carlos Drumond de Andrade"
PROCESSO_CPF_PARTE_CONTRARIA="125.971.900-64"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  38 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
fn_data_anterior
PROCESSO_NUMERO="1501038-23.2023.8.26.0053"
PROCESSO_VALOR=942000
PROCESSO_NOME_PARTE_CONTRARIA="Pedro Alvares Cabral"
PROCESSO_CPF_PARTE_CONTRARIA="778.649.850-84"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  39 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
fn_data_anterior
PROCESSO_NUMERO="1501039-23.2023.8.26.0053"
PROCESSO_VALOR=983000
PROCESSO_NOME_PARTE_CONTRARIA="Teotonio Villela"
PROCESSO_CPF_PARTE_CONTRARIA="892.354.410-80"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  40 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
fn_data_anterior
PROCESSO_NUMERO="1501040-23.2023.8.26.0053"
PROCESSO_VALOR=184200
PROCESSO_NOME_PARTE_CONTRARIA="Francisca Costa Ramos"
PROCESSO_CPF_PARTE_CONTRARIA="529.251.970-78"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  41 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
fn_data_anterior
PROCESSO_NUMERO="1501041-23.2023.8.26.0053"
PROCESSO_VALOR=984234
PROCESSO_NOME_PARTE_CONTRARIA="Terezinha Prudencio"
PROCESSO_CPF_PARTE_CONTRARIA="606.770.250-92"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  42 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
fn_data_anterior
PROCESSO_NUMERO="1501042-23.2023.8.26.0053"
PROCESSO_VALOR=875200
PROCESSO_NOME_PARTE_CONTRARIA="Ana Maria da Rosa Lemos"
PROCESSO_CPF_PARTE_CONTRARIA="360.525.870-08"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  43 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
fn_data_anterior
PROCESSO_NUMERO="1501043-23.2023.8.26.0053"
PROCESSO_VALOR=346150
PROCESSO_NOME_PARTE_CONTRARIA="Eduardo Simplorio Lima"
PROCESSO_CPF_PARTE_CONTRARIA="051.747.220-14"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  44 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
fn_data_anterior
PROCESSO_NUMERO="1501044-23.2023.8.26.0053"
PROCESSO_VALOR=288700
PROCESSO_NOME_PARTE_CONTRARIA="Géssica Silva Andrade"
PROCESSO_CPF_PARTE_CONTRARIA="646.481.960-74"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  45 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
fn_data_anterior
PROCESSO_NUMERO="1501040-23.2023.8.26.0053"
PROCESSO_VALOR=15830
PROCESSO_NOME_PARTE_CONTRARIA="Edvalva Lira"
PROCESSO_CPF_PARTE_CONTRARIA="584.189.390-44"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  46 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO_2
fn_data_anterior
PROCESSO_NUMERO="1501046-23.2023.8.26.0053"
PROCESSO_VALOR=90432
PROCESSO_NOME_PARTE_CONTRARIA="João Lucas da Silva"
PROCESSO_CPF_PARTE_CONTRARIA="249.805.250-08"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  47 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO_2
fn_data_anterior
PROCESSO_NUMERO="1501047-23.2023.8.26.0053"
PROCESSO_VALOR=10000
PROCESSO_NOME_PARTE_CONTRARIA="Pedro Carvalho Lima"
PROCESSO_CPF_PARTE_CONTRARIA="201.754.060-90"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  48 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO_2
fn_data_anterior
PROCESSO_NUMERO="1501048-23.2023.8.26.0053"
PROCESSO_VALOR=100992
PROCESSO_NOME_PARTE_CONTRARIA="Carlos da Silva Pedreira"
PROCESSO_CPF_PARTE_CONTRARIA="045.035.860-76"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  49 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO_2
fn_data_anterior
PROCESSO_NUMERO="1501049-23.2023.8.26.0053"
PROCESSO_VALOR=999223
PROCESSO_NOME_PARTE_CONTRARIA="Rubens Prates"
PROCESSO_CPF_PARTE_CONTRARIA="134.675.860-31"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  50 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO_2
fn_data_anterior
PROCESSO_NUMERO="1501050-23.2023.8.26.0053"
PROCESSO_VALOR=777335
PROCESSO_NOME_PARTE_CONTRARIA="Lucas Campos"
PROCESSO_CPF_PARTE_CONTRARIA="350.490.140-34"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  51 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO_2
fn_data_anterior
PROCESSO_NUMERO="1501051-23.2023.8.26.0053"
PROCESSO_VALOR=673440
PROCESSO_NOME_PARTE_CONTRARIA="Maria Gabriela Lima"
PROCESSO_CPF_PARTE_CONTRARIA="496.432.550-42"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  52 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO_2
fn_data_anterior
PROCESSO_NUMERO="1501052-23.2023.8.26.0053"
PROCESSO_VALOR=88244
PROCESSO_NOME_PARTE_CONTRARIA="Douglas Gabriel Andrade"
PROCESSO_CPF_PARTE_CONTRARIA="369.691.040-60"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  53 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO_2
fn_data_anterior
PROCESSO_NUMERO="1501053-23.2023.8.26.0053"
PROCESSO_VALOR=7223
PROCESSO_NOME_PARTE_CONTRARIA="Lucas Estevão Gomes"
PROCESSO_CPF_PARTE_CONTRARIA="592.596.790-95"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  54 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO_2
fn_data_anterior
PROCESSO_NUMERO="1501054-23.2023.8.26.0053"
PROCESSO_VALOR=95723
PROCESSO_NOME_PARTE_CONTRARIA="Joana Prado Gomes"
PROCESSO_CPF_PARTE_CONTRARIA="727.206.860-42"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  55 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO_3
fn_data_anterior
PROCESSO_NUMERO="1501055-23.2023.8.26.0053"
PROCESSO_VALOR=1642800
PROCESSO_NOME_PARTE_CONTRARIA="Leonardo Costa Silva"
PROCESSO_CPF_PARTE_CONTRARIA="817.100.340-09"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  56 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO_3
fn_data_anterior
PROCESSO_NUMERO="1501056-23.2023.8.26.0053"
PROCESSO_VALOR=834900
PROCESSO_NOME_PARTE_CONTRARIA="Tiburcio da Rosa"
PROCESSO_CPF_PARTE_CONTRARIA="699.685.220-07"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  57 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO_3
fn_data_anterior
PROCESSO_NUMERO="1501050-23.2023.8.26.0053"
PROCESSO_VALOR=8827742
PROCESSO_NOME_PARTE_CONTRARIA="Jeison Douglas Carreira"
PROCESSO_CPF_PARTE_CONTRARIA="748.527.570-46"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  58 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO_3
fn_data_anterior
PROCESSO_NUMERO="1501058-23.2023.8.26.0053"
PROCESSO_VALOR=999300
PROCESSO_NOME_PARTE_CONTRARIA="Fernando Lima Sobrinho"
PROCESSO_CPF_PARTE_CONTRARIA="912.451.430-69"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  59 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO_3
fn_data_anterior
PROCESSO_NUMERO="1501050-23.2023.8.26.0053"
PROCESSO_VALOR=1589342
PROCESSO_NOME_PARTE_CONTRARIA="Tania da Silva Lima"
PROCESSO_CPF_PARTE_CONTRARIA="884.984.350-05"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  60 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO_3
fn_data_anterior
PROCESSO_NUMERO="1501060-23.2023.8.26.0053"
PROCESSO_VALOR=2874000
PROCESSO_NOME_PARTE_CONTRARIA="Jonas Silva Campos"
PROCESSO_CPF_PARTE_CONTRARIA="437.154.710-93"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  61 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO_3
fn_data_anterior
PROCESSO_NUMERO="1501061-23.2023.8.26.0053"
PROCESSO_VALOR=10872998
PROCESSO_NOME_PARTE_CONTRARIA="Petrúcio Soares"
PROCESSO_CPF_PARTE_CONTRARIA="505.926.920-51"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  62 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO_3
fn_data_anterior
PROCESSO_NUMERO="1501062-23.2023.8.26.0053"
PROCESSO_VALOR=144422
PROCESSO_NOME_PARTE_CONTRARIA="Andre de Lima Gomes"
PROCESSO_CPF_PARTE_CONTRARIA="350.635.720-49"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  63 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO_3
fn_data_anterior
PROCESSO_NUMERO="1501063-23.2023.8.26.0053"
PROCESSO_VALOR=987300
PROCESSO_NOME_PARTE_CONTRARIA="Jeise Gama Costa"
PROCESSO_CPF_PARTE_CONTRARIA="689.733.660-25"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  64 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO_3
fn_data_anterior
PROCESSO_NUMERO="1501064-23.2023.8.26.0053"
PROCESSO_VALOR=89543
PROCESSO_NOME_PARTE_CONTRARIA="Catia Ferreira"
PROCESSO_CPF_PARTE_CONTRARIA="287.486.020-43"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  65 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO_3
fn_data_anterior
PROCESSO_NUMERO="1501065-23.2023.8.26.0053"
PROCESSO_VALOR=87543
PROCESSO_NOME_PARTE_CONTRARIA="Eduardo Costa Lima Cunha"
PROCESSO_CPF_PARTE_CONTRARIA="891.840.720-32"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  66 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO_3
fn_data_anterior
PROCESSO_NUMERO="1501066-23.2023.8.26.0053"
PROCESSO_VALOR=90773
PROCESSO_NOME_PARTE_CONTRARIA="Dario Gomes"
PROCESSO_CPF_PARTE_CONTRARIA="330.328.910-78"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  67 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO_4
fn_data_anterior
PROCESSO_NUMERO="1501067-23.2023.8.26.0053"
PROCESSO_VALOR=102774
PROCESSO_NOME_PARTE_CONTRARIA="Lucas Andrade Farias"
PROCESSO_CPF_PARTE_CONTRARIA="037.475.330-00"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  68 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO_4
fn_data_anterior
PROCESSO_NUMERO="1501068-23.2023.8.26.0053"
PROCESSO_VALOR=140872
PROCESSO_NOME_PARTE_CONTRARIA="Katia Ferreira da Silva"
PROCESSO_CPF_PARTE_CONTRARIA="544.399.450-66"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  69 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO_4
fn_data_anterior
PROCESSO_NUMERO="1501069-23.2023.8.26.0053"
PROCESSO_VALOR=293999
PROCESSO_NOME_PARTE_CONTRARIA="Eduardo da Silva Gomes"
PROCESSO_CPF_PARTE_CONTRARIA="414.483.850-16"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  70 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO_4
fn_data_anterior
PROCESSO_NUMERO="1501070-23.2023.8.26.0053"
PROCESSO_VALOR=85887
PROCESSO_NOME_PARTE_CONTRARIA="João Paulo Farias"
PROCESSO_CPF_PARTE_CONTRARIA="961.131.950-90"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  71 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO_4
fn_data_anterior
PROCESSO_NUMERO="1501071-23.2023.8.26.0053"
PROCESSO_VALOR=183760
PROCESSO_NOME_PARTE_CONTRARIA="José da Silva Soares"
PROCESSO_CPF_PARTE_CONTRARIA="949.923.780-13"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  72 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO_4
fn_data_anterior
PROCESSO_NUMERO="1501072-23.2023.8.26.0053"
PROCESSO_VALOR=34800
PROCESSO_NOME_PARTE_CONTRARIA="João das Dores Lira"
PROCESSO_CPF_PARTE_CONTRARIA="447.060.720-77"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  73 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO_4
fn_data_anterior
PROCESSO_NUMERO="1501073-23.2023.8.26.0053"
PROCESSO_VALOR=739021
PROCESSO_NOME_PARTE_CONTRARIA="Daniel da Silva Kaus"
PROCESSO_CPF_PARTE_CONTRARIA="916.467.510-60"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

##################################################################### Processo  74 - Citação com tutela
fn_data_atual
DIAS_REDUZIR=0
ASSUNTO_INSTITUICAO_CONTENCIOSO=$ASSUNTO_INSTITUICAO_CONTENCIOSO_4
fn_data_anterior
PROCESSO_NUMERO="1501074-23.2023.8.26.0053"
PROCESSO_VALOR=463100
PROCESSO_NOME_PARTE_CONTRARIA="Maria da Silva Pereira"
PROCESSO_CPF_PARTE_CONTRARIA="746.923.980-43"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_CONSULTIVO
fn_inserir_contencioso

#####################################################################  Processo 75 - Consultivo
fn_data_atual
DIAS_REDUZIR=0
fn_data_anterior
PROCESSO_NUMERO="0715.004307.00048.2024-90"
PROCESSO_VALOR=150000
PROCESSO_NOME_PARTE_CONTRARIA="Departamento de Tecnologia da Informação"
PROCESSO_CPF_PARTE_CONTRARIA="01.908.381/0001-31"
TIPO_DOCUMENTO_PESSOA="CNPJ"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONSULTIVO
MATERIA=$MATERIA_CONSULTIVO
fn_inserir_consultivo
fn_inserir_andamento_avaliacao_parecer_requerida

#####################################################################  Processo 76 - Consultivo
fn_data_atual
DIAS_REDUZIR=0
fn_data_anterior
PROCESSO_NUMERO="0039.013795.00140.2024-51"
PROCESSO_VALOR=150000
PROCESSO_NOME_PARTE_CONTRARIA="Hospital Municipal de São Paulo"
PROCESSO_CPF_PARTE_CONTRARIA="01.222.333/0001-31"
TIPO_DOCUMENTO_PESSOA="CNPJ"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONSULTIVO_2
MATERIA=$MATERIA_CONSULTIVO
fn_inserir_consultivo
fn_inserir_andamento_avaliacao_parecer_requerida

#####################################################################  Processo 77 - Consultivo
##fn_data_atual
##DIAS_REDUZIR=0
##fn_data_anterior
##PROCESSO_NUMERO="0038.013321.00063.2024-24"
##PROCESSO_VALOR=150000
##PROCESSO_NOME_PARTE_CONTRARIA="Departamento de Tecnologia da Informação"
##PROCESSO_CPF_PARTE_CONTRARIA="01.908.381/0001-31"
##TIPO_DOCUMENTO_PESSOA="CNPJ"
##DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
##ASSUNTO=$ASSUNTO_INSTITUICAO_CONSULTIVO_3
##MATERIA=$MATERIA_CONSULTIVO
##fn_inserir_consultivo
##fn_inserir_andamento_avaliacao_parecer_requerida

#####################################################################  Processo 78 - Consultivo
fn_data_atual
DIAS_REDUZIR=0
fn_data_anterior
PROCESSO_NUMERO="0064.006532.00059.2023-17"
PROCESSO_VALOR=150000
PROCESSO_NOME_PARTE_CONTRARIA="Guarda Civil Metropolitana de São Paulo"
PROCESSO_CPF_PARTE_CONTRARIA="01.111.222/0001-31"
TIPO_DOCUMENTO_PESSOA="CNPJ"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONSULTIVO_3
MATERIA=$MATERIA_CONSULTIVO
fn_inserir_consultivo
fn_inserir_andamento_avaliacao_parecer_requerida

############################### Documentos aguardando vinculação de processo ######################################

NOME_DOCUMENTO="1532123-37.2019.8.26.0090"
NOME_ARQUIVO="./documentos/1532123-37.2019.8.26.0090_intimacao-citacao-negativa.pdf"
fn_upload_documento
NOME_DOCUMENTO="1551253-13.2019.8.26.0090"
NOME_ARQUIVO="./documentos/1551253-13.2019.8.26.0090_intimacao-citacao-negativa.pdf"
fn_upload_documento
NOME_DOCUMENTO="1558483-77.2017.8.26.0090"
NOME_ARQUIVO="./documentos/1558483-77.2017.8.26.0090_intimacao_acolhendo_excecao.pdf"
fn_upload_documento
NOME_DOCUMENTO="1501003-03.2018.8.26.0090"
NOME_ARQUIVO="./documentos/1501003-03.2018.8.26.0090_intimacao_rejeitando_excecao.pdf"
fn_upload_documento
NOME_DOCUMENTO="1556851-45.2019.8.26.0090"
NOME_ARQUIVO="./documentos/1556851-45.2019.8.26.0090_suspeita_prescricao.pdf"
fn_upload_documento
NOME_DOCUMENTO="1558015-45.2019.8.26.0090"
NOME_ARQUIVO="./documentos/1558015-45.2019.8.26.0090_suspeita_prescricao.pdf"
fn_upload_documento
NOME_DOCUMENTO="1566890-04.2019.8.26.0090"
NOME_ARQUIVO="./documentos/1566890-04.2019.8.26.0090_suspeita_prescricao.pdf"
fn_upload_documento
NOME_DOCUMENTO="1584307-67.2019.8.26.0090"
NOME_ARQUIVO="./documentos/1584307-67.2019.8.26.0090_suspeita_prescricao.pdf"
fn_upload_documento
NOME_DOCUMENTO="1042697-93.2019.8.26.0053"
NOME_ARQUIVO="./documentos/1042697-93.2019.8.26.0053_devolucao_carta_citacao.pdf"
fn_upload_documento
NOME_DOCUMENTO="1049750-28.2019.8.26.0053"
NOME_ARQUIVO="./documentos/1049750-28.2019.8.26.0053_devolucao_carta_citacao.pdf"
fn_upload_documento
NOME_DOCUMENTO="1056567-11.2019.8.26.0053"
NOME_ARQUIVO="./documentos/1056567-11.2019.8.26.0053_devolucao_carta_citacao.pdf"
fn_upload_documento

# Adicionar abaixo novos documentos
# Preencher nome do documento, nome do arquivo e chamar a função fn_upload_documento
# Documentos estória AT-4086
# https://attornatus.atlassian.net/browse/AT-4086

NOME_DOCUMENTO="1501013-13.2018.8.26.0090"
NOME_ARQUIVO="./documentos/1501013-13.2018.8.26.0090_intimacao-manifestacao-providencias-10dias.pdf"
fn_upload_documento

NOME_DOCUMENTO="1501021-21.2018.8.26.0053"
NOME_ARQUIVO="./documentos/1501021-21.2018.8.26.0053_despacho-audiencia-designada.pdf"
fn_upload_documento

NOME_DOCUMENTO="1501021-21.2018.8.26.0053"
NOME_ARQUIVO="./documentos/1501021-21.2018.8.26.0053_intimacao-manifestacao-providencias-10dias.pdf"
fn_upload_documento

NOME_DOCUMENTO="1501024-24.2018.8.26.0053"
NOME_ARQUIVO="./documentos/1501024-24.2018.8.26.0053_despacho-audiencia-designada.pdf"
fn_upload_documento

NOME_DOCUMENTO="1501025-25.2018.8.26.0053"
NOME_ARQUIVO="./documentos/1501025-25.2018.8.26.0053_despacho-audiencia-designada.pdf"
fn_upload_documento

NOME_DOCUMENTO="1558015-45.2019.8.26.0090"
NOME_ARQUIVO="./documentos/1558015-45.2019.8.26.0090_intimacao-manifestacao-providencias-10dias.pdf"

fn_upload_documento

fn_demanda_ajustar_data_entrada

fn_documento_atualizar_modelos_elasticsearch

fn_divida_encerrar_lote_processamento

fn_sincronizar_tudo

DIVIDA_NUMERO="2023/35320001"
DIVIDA_IDENTIFICADOR="202335320001"
PROCESSO_NOME_PARTE_CONTRARIA="Maurício Fernandes"
PROCESSO_CPF_PARTE_CONTRARIA="957.047.680-08"
DIVIDA_ENDERECO_CEP="41745-003"
DIVIDA_ENDERECO_LOGRADOURO="Santa Terezinha"
DIVIDA_ENDERECO_NUMERO="3456"
DIVIDA_ENDERECO_BAIRRO="Vila Yara"
fn_inserir_divida_para_ajuizamento

DIVIDA_NUMERO="2023/35320002"
DIVIDA_IDENTIFICADOR="202335320002"
PROCESSO_NOME_PARTE_CONTRARIA="Elza Custódio de Oliveira"
PROCESSO_CPF_PARTE_CONTRARIA="625.387.770-46"
DIVIDA_ENDERECO_CEP="45020-800"
DIVIDA_ENDERECO_LOGRADOURO="Centro"
DIVIDA_ENDERECO_NUMERO="73456"
DIVIDA_ENDERECO_BAIRRO="Vila Yara"
fn_inserir_divida_para_ajuizamento

DIVIDA_NUMERO="2023/35320003"
DIVIDA_IDENTIFICADOR="202335320003"
PROCESSO_NOME_PARTE_CONTRARIA="Marta da Silva"
PROCESSO_CPF_PARTE_CONTRARIA="278.944.130-89"
DIVIDA_ENDERECO_CEP="41630-700"
DIVIDA_ENDERECO_LOGRADOURO="Centro"
DIVIDA_ENDERECO_NUMERO="345"
DIVIDA_ENDERECO_BAIRRO="Vila Yara"
fn_inserir_divida_para_ajuizamento

DIVIDA_NUMERO="2023/35320004"
DIVIDA_IDENTIFICADOR="202335320004"
PROCESSO_NOME_PARTE_CONTRARIA="Caio Torres"
PROCESSO_CPF_PARTE_CONTRARIA="187.049.600-09"
DIVIDA_ENDERECO_CEP="40352-000"
DIVIDA_ENDERECO_LOGRADOURO="Centro"
DIVIDA_ENDERECO_NUMERO="435"
DIVIDA_ENDERECO_BAIRRO="Vila Yara"
fn_inserir_divida_para_ajuizamento

DIVIDA_NUMERO="2023/35320005"
DIVIDA_IDENTIFICADOR="202335320005"
PROCESSO_NOME_PARTE_CONTRARIA="Barbara Torres"
PROCESSO_CPF_PARTE_CONTRARIA="187.044.490-61"
DIVIDA_ENDERECO_CEP="44097-324"
DIVIDA_ENDERECO_LOGRADOURO="Centro"
DIVIDA_ENDERECO_NUMERO="2345"
DIVIDA_ENDERECO_BAIRRO="Vila Yara"
fn_inserir_divida_para_ajuizamento

DIVIDA_NUMERO="2023/35320006"
DIVIDA_IDENTIFICADOR="202335320006"
PROCESSO_NOME_PARTE_CONTRARIA="Jessica Amaral"
PROCESSO_CPF_PARTE_CONTRARIA="494.409.330-62"
DIVIDA_ENDERECO_CEP="40025-001"
DIVIDA_ENDERECO_LOGRADOURO="Jardim Sandra Maria"
DIVIDA_ENDERECO_NUMERO="223"
DIVIDA_ENDERECO_BAIRRO="Vila Yara"
fn_inserir_divida_para_ajuizamento

DIVIDA_NUMERO="2023/35320007"
DIVIDA_IDENTIFICADOR="202335320007"
PROCESSO_NOME_PARTE_CONTRARIA="Talita de Jesus"
PROCESSO_CPF_PARTE_CONTRARIA="219.950.660-60"
DIVIDA_ENDERECO_CEP="41745-003"
DIVIDA_ENDERECO_LOGRADOURO="Jardim Sandra Maria"
DIVIDA_ENDERECO_NUMERO="789"
DIVIDA_ENDERECO_BAIRRO="Vila Yara"
fn_inserir_divida_para_ajuizamento

DIVIDA_NUMERO="2023/35320008"
DIVIDA_IDENTIFICADOR="202335320008"
PROCESSO_NOME_PARTE_CONTRARIA="Aldo Feijó"
PROCESSO_CPF_PARTE_CONTRARIA="293.321.980-80"
DIVIDA_ENDERECO_CEP="40157-151"
DIVIDA_ENDERECO_LOGRADOURO="Santa Terezinha"
DIVIDA_ENDERECO_NUMERO="2039"
DIVIDA_ENDERECO_BAIRRO="Vila Yara"
fn_inserir_divida_para_ajuizamento

DIVIDA_NUMERO="2023/35320009"
DIVIDA_IDENTIFICADOR="202335320009"
PROCESSO_NOME_PARTE_CONTRARIA="Jean Martins"
PROCESSO_CPF_PARTE_CONTRARIA="638.114.040-24"
DIVIDA_ENDERECO_CEP="41820-020"
DIVIDA_ENDERECO_LOGRADOURO="Jardim Sandra Maria"
DIVIDA_ENDERECO_NUMERO="67677"
DIVIDA_ENDERECO_BAIRRO="Vila Yara"
fn_inserir_divida_para_ajuizamento

DIVIDA_NUMERO="2023/35320010"
DIVIDA_IDENTIFICADOR="202335320010"
PROCESSO_NOME_PARTE_CONTRARIA="Mônica Tartari"
PROCESSO_CPF_PARTE_CONTRARIA="924.760.390-04"
DIVIDA_ENDERECO_CEP="41745-003"
DIVIDA_ENDERECO_LOGRADOURO="Santa Terezinha"
DIVIDA_ENDERECO_NUMERO="123"
DIVIDA_ENDERECO_BAIRRO="Vila Yara"
fn_inserir_divida_para_ajuizamento

##################################################################### EF 79 - Audiência
fn_data_atual
DIAS_REDUZIR=58
fn_data_anterior
PROCESSO_NUMERO="1501030-30.2017.8.26.0053"
PROCESSO_VALOR=22300
PROCESSO_NOME_PARTE_CONTRARIA="Claudio Warmeling Xavier"
PROCESSO_CPF_PARTE_CONTRARIA="352.431.960-29"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

# Citação
fn_inserir_andamento_citacao

fn_data_atual
DIAS_REDUZIR=28
fn_data_anterior
# Contestacao
fn_inserir_andamento_contestacao

fn_data_atual
DIAS_REDUZIR=10
fn_data_anterior
# audiência
fn_inserir_andamento_audiencia

##################################################################### EF 80 - Audiência
fn_data_atual
DIAS_REDUZIR=58
fn_data_anterior
PROCESSO_NUMERO="1501030-30.2017.7.26.0053"
PROCESSO_VALOR=22300
PROCESSO_NOME_PARTE_CONTRARIA="Claudio Warmeling Xavier"
PROCESSO_CPF_PARTE_CONTRARIA="670.148.460-35"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

# Citação
fn_inserir_andamento_citacao

fn_data_atual
DIAS_REDUZIR=28
fn_data_anterior
# Contestacao
fn_inserir_andamento_contestacao

fn_data_atual
DIAS_REDUZIR=10
fn_data_anterior
# audiência
fn_inserir_andamento_audiencia

##################################################################### EF 81 - Audiência
fn_data_atual
DIAS_REDUZIR=58
fn_data_anterior
PROCESSO_NUMERO="1501030-30.2017.9.24.0053"
PROCESSO_VALOR=22300
PROCESSO_NOME_PARTE_CONTRARIA="Claudio Warmeling Xavier"
PROCESSO_CPF_PARTE_CONTRARIA="769.603.720-03"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

# Citação
fn_inserir_andamento_citacao

fn_data_atual
DIAS_REDUZIR=28
fn_data_anterior
# Contestacao
fn_inserir_andamento_contestacao

fn_data_atual
DIAS_REDUZIR=10
fn_data_anterior
# audiência
fn_inserir_andamento_audiencia

##################################################################### EF 82 - Audiência
fn_data_atual
DIAS_REDUZIR=58
fn_data_anterior
PROCESSO_NUMERO="1501030-30.2017.5.24.0053"
PROCESSO_VALOR=22300
PROCESSO_NOME_PARTE_CONTRARIA="Claudio Warmeling Xavier"
PROCESSO_CPF_PARTE_CONTRARIA="818.121.380-75"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

# Citação
fn_inserir_andamento_citacao

fn_data_atual
DIAS_REDUZIR=28
fn_data_anterior
# Contestacao
fn_inserir_andamento_contestacao

fn_data_atual
DIAS_REDUZIR=10
fn_data_anterior
# audiência
fn_inserir_andamento_audiencia

##################################################################### EF 83 - Audiência
fn_data_atual
DIAS_REDUZIR=58
fn_data_anterior
PROCESSO_NUMERO="1501030-30.2019.9.20.0053"
PROCESSO_VALOR=22300
PROCESSO_NOME_PARTE_CONTRARIA="Ana Maria da Rosa Lemos"
PROCESSO_CPF_PARTE_CONTRARIA="305.817.410-13"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

# Citação
fn_inserir_andamento_citacao

fn_data_atual
DIAS_REDUZIR=28
fn_data_anterior
# Contestacao
fn_inserir_andamento_contestacao

fn_data_atual
DIAS_REDUZIR=10
fn_data_anterior
# audiência
fn_inserir_andamento_audiencia

##################################################################### EF 84 - Audiência
fn_data_atual
DIAS_REDUZIR=58
fn_data_anterior
PROCESSO_NUMERO="1501030-30.2017.9.26.0053"
PROCESSO_VALOR=22300
PROCESSO_NOME_PARTE_CONTRARIA="Claudio Warmeling Xavier"
PROCESSO_CPF_PARTE_CONTRARIA="352.431.960-29"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

# Citação
fn_inserir_andamento_citacao

fn_data_atual
DIAS_REDUZIR=28
fn_data_anterior
# Contestacao
fn_inserir_andamento_contestacao

fn_data_atual
DIAS_REDUZIR=10
fn_data_anterior
# audiência
fn_inserir_andamento_audiencia

##################################################################### EF 85 - Audiência
fn_data_atual
DIAS_REDUZIR=58
fn_data_anterior
PROCESSO_NUMERO="1501030-30.2025.9.26.0053"
PROCESSO_VALOR=22300
PROCESSO_NOME_PARTE_CONTRARIA="Claudio Warmeling Xavier"
PROCESSO_CPF_PARTE_CONTRARIA="352.431.960-29"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

# Citação
fn_inserir_andamento_citacao

fn_data_atual
DIAS_REDUZIR=28
fn_data_anterior
# Contestacao
fn_inserir_andamento_contestacao

fn_data_atual
DIAS_REDUZIR=10
fn_data_anterior
# audiência
fn_inserir_andamento_audiencia

##################################################################### EF 86 - Audiência
fn_data_atual
DIAS_REDUZIR=58
fn_data_anterior
PROCESSO_NUMERO="1501030-30.2024.7.26.0053"
PROCESSO_VALOR=22300
PROCESSO_NOME_PARTE_CONTRARIA="Claudio Warmeling Xavier"
PROCESSO_CPF_PARTE_CONTRARIA="670.148.460-35"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

# Citação
fn_inserir_andamento_citacao

fn_data_atual
DIAS_REDUZIR=28
fn_data_anterior
# Contestacao
fn_inserir_andamento_contestacao

fn_data_atual
DIAS_REDUZIR=10
fn_data_anterior
# audiência
fn_inserir_andamento_audiencia

##################################################################### EF 87 - Audiência
fn_data_atual
DIAS_REDUZIR=58
fn_data_anterior
PROCESSO_NUMERO="1504811-25.2025.9.26.0053"
PROCESSO_VALOR=480000
PROCESSO_NOME_PARTE_CONTRARIA="Claudio Warmeling Xavier"
PROCESSO_CPF_PARTE_CONTRARIA="352.431.960-29"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

# Citação
fn_inserir_andamento_citacao

##################################################################### EF 88 - Audiência
fn_data_atual
DIAS_REDUZIR=58
fn_data_anterior
PROCESSO_NUMERO="1504787-25.2025.9.26.0053"
PROCESSO_VALOR=56000
PROCESSO_NOME_PARTE_CONTRARIA="Claudio Warmeling Xavier"
PROCESSO_CPF_PARTE_CONTRARIA="352.431.960-29"
TIPO_DOCUMENTO_PESSOA="CPF"
DATA_AJUIZAMENTO="$ANO-$MES-$DIA$()T03:00:00.396"
ASSUNTO=$ASSUNTO_INSTITUICAO_CONTENCIOSO
MATERIA=$MATERIA_FISCAL_TRIBUTARIO
fn_inserir_contencioso

# Citação
fn_inserir_andamento_citacao

################################################ Iniciando inserção de dados
fn_preparar_dados_para_testes
