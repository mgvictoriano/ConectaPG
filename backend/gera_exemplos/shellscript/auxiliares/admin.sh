#!/usr/bin/env bash

fn_identifica_dados_basicos() {
  echo Identificando Dados básicos ...

  GERA_EXEMPLOS_HABILITADO=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=GERA_EXEMPLOS_HABILITADO" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  echo $GERA_EXEMPLOS_HABILITADO
  GERA_EXEMPLOS_HABILITADO=$(echo $GERA_EXEMPLOS_HABILITADO | cut -d'"' -f 20)
  echo Gera exemplos habilitado?: $GERA_EXEMPLOS_HABILITADO

  if [ "$GERA_EXEMPLOS_HABILITADO" != "true" ]; then
    echo Gera exemplos não está habilitado para esta instituição $TENANT
    exit 0
  fi

  MATERIA_EF=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=MATERIA_EXECUCAO_FISCAL" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  MATERIA_EF=$(echo $MATERIA_EF | cut -d'"' -f 20)
  echo Matéria EF: $MATERIA_EF

  MATERIA_FISCAL_TRIBUTARIO=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=MATERIA_FISCAL_TRIBUTARIO" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  MATERIA_FISCAL_TRIBUTARIO=$(echo $MATERIA_FISCAL_TRIBUTARIO | cut -d'"' -f 20)
  echo Matéria fiscal tributário: $MATERIA_FISCAL_TRIBUTARIO

MATERIA_CONSULTIVO=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=GERA_EXEMPLOS_MATERIA_CONSULTIVO" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  MATERIA_CONSULTIVO=$(echo $MATERIA_CONSULTIVO | cut -d'"' -f 20)
  echo Matéria Consultivo: $MATERIA_CONSULTIVO



  ASSUNTO_INSTITUICAO_EF=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=GERA_EXEMPLOS_ASSUNTO_INSTITUICAO_EF" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  ASSUNTO_INSTITUICAO_EF=$(echo $ASSUNTO_INSTITUICAO_EF | cut -d'"' -f 20)
  echo Assunto instituição EF: $ASSUNTO_INSTITUICAO_EF

  ASSUNTO_AGUARDANDO_CONFERENCIA=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=ASSUNTO_AGUARDANDO_CONFERENCIA" \
      --header "Content-type: application/json" \
      --header "Authorization: Bearer $TOKEN")
  ASSUNTO_AGUARDANDO_CONFERENCIA=$(echo $ASSUNTO_AGUARDANDO_CONFERENCIA | cut -d'"' -f 20)
  echo Assunto aguardando conferência: $ASSUNTO_AGUARDANDO_CONFERENCIA

  ASSUNTO_INSTITUICAO_CONTENCIOSO=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=GERA_EXEMPLOS_ASSUNTO_INSTITUICAO_CONTENCIOSO" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  ASSUNTO_INSTITUICAO_CONTENCIOSO=$(echo $ASSUNTO_INSTITUICAO_CONTENCIOSO | cut -d'"' -f 20)
  echo Assunto instituição contencioso: $ASSUNTO_INSTITUICAO_CONTENCIOSO

  ASSUNTO_INSTITUICAO_CONTENCIOSO_2=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=GERA_EXEMPLOS_ASSUNTO_INSTITUICAO_CONTENCIOSO_2" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  ASSUNTO_INSTITUICAO_CONTENCIOSO_2=$(echo $ASSUNTO_INSTITUICAO_CONTENCIOSO_2 | cut -d'"' -f 20)
  echo Assunto instituição contencioso: $ASSUNTO_INSTITUICAO_CONTENCIOSO_2

  ASSUNTO_INSTITUICAO_CONTENCIOSO_3=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=GERA_EXEMPLOS_ASSUNTO_INSTITUICAO_CONTENCIOSO_3" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  ASSUNTO_INSTITUICAO_CONTENCIOSO_3=$(echo $ASSUNTO_INSTITUICAO_CONTENCIOSO_3 | cut -d'"' -f 20)
  echo Assunto instituição contencioso: $ASSUNTO_INSTITUICAO_CONTENCIOSO_3

    ASSUNTO_INSTITUICAO_CONTENCIOSO_4=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=GERA_EXEMPLOS_ASSUNTO_INSTITUICAO_CONTENCIOSO_4" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  ASSUNTO_INSTITUICAO_CONTENCIOSO_4=$(echo $ASSUNTO_INSTITUICAO_CONTENCIOSO_4 | cut -d'"' -f 20)
  echo Assunto instituição contencioso: $ASSUNTO_INSTITUICAO_CONTENCIOSO_4

  ASSUNTO_INSTITUICAO_JUIZADO_ESPECIAL=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=GERA_EXEMPLOS_ASSUNTO_INSTITUICAO_JE" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  ASSUNTO_INSTITUICAO_JUIZADO_ESPECIAL=$(echo $ASSUNTO_INSTITUICAO_JUIZADO_ESPECIAL | cut -d'"' -f 20)
  echo Assunto instituição JE: $ASSUNTO_INSTITUICAO_JUIZADO_ESPECIAL


  ASSUNTO_INSTITUICAO_CONSULTIVO=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=GERA_EXEMPLOS_ASSUNTO_INSTITUICAO_CONSULTIVO" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  ASSUNTO_INSTITUICAO_CONSULTIVO=$(echo $ASSUNTO_INSTITUICAO_CONSULTIVO | cut -d'"' -f 20)
  echo Assunto instituição Consultivo: $ASSUNTO_INSTITUICAO_CONSULTIVO

  ASSUNTO_INSTITUICAO_CONSULTIVO_2=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=GERA_EXEMPLOS_ASSUNTO_INSTITUICAO_CONSULTIVO_2" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  ASSUNTO_INSTITUICAO_CONSULTIVO_2=$(echo $ASSUNTO_INSTITUICAO_CONSULTIVO_2 | cut -d'"' -f 20)
  echo Assunto instituição Consultivo: $ASSUNTO_INSTITUICAO_CONSULTIVO_2

  ASSUNTO_INSTITUICAO_CONSULTIVO_3=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=GERA_EXEMPLOS_ASSUNTO_INSTITUICAO_CONSULTIVO_3" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  ASSUNTO_INSTITUICAO_CONSULTIVO_3=$(echo $ASSUNTO_INSTITUICAO_CONSULTIVO_3 | cut -d'"' -f 20)
  echo Assunto instituição Consultivo: $ASSUNTO_INSTITUICAO_CONSULTIVO_3

  ASSUNTO_INSTITUICAO_CONSULTIVO_4=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=GERA_EXEMPLOS_ASSUNTO_INSTITUICAO_CONSULTIVO_4" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  ASSUNTO_INSTITUICAO_CONSULTIVO_4=$(echo $ASSUNTO_INSTITUICAO_CONSULTIVO_4 | cut -d'"' -f 20)
  echo Assunto instituição Consultivo: $ASSUNTO_INSTITUICAO_CONSULTIVO_4


  TIPO_PARTICIPACAO_PARTE_CONTRARIA_EXECUCAO_FISCAL=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=TIPO_PARTICIPACAO_PARTE_CONTRARIA_EXECUCAO_FISCAL" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  TIPO_PARTICIPACAO_PARTE_CONTRARIA_EXECUCAO_FISCAL=$(echo $TIPO_PARTICIPACAO_PARTE_CONTRARIA_EXECUCAO_FISCAL | cut -d'"' -f 20)
  echo Tipo de participação contrária EF: $TIPO_PARTICIPACAO_PARTE_CONTRARIA_EXECUCAO_FISCAL

  TIPO_PARTICIPACAO_PARTE_REPRESENTADA_EXECUCAO_FISCAL=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=TIPO_PARTICIPACAO_PARTE_REPRESENTADA_EXECUCAO_FISCAL" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  TIPO_PARTICIPACAO_PARTE_REPRESENTADA_EXECUCAO_FISCAL=$(echo $TIPO_PARTICIPACAO_PARTE_REPRESENTADA_EXECUCAO_FISCAL | cut -d'"' -f 20)
  echo Tipo de participação representada EF: $TIPO_PARTICIPACAO_PARTE_REPRESENTADA_EXECUCAO_FISCAL

  TIPO_PARTICIPACAO_EMBARGANTE=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=TIPO_PARTICIPACAO_EMBARGANTE" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  TIPO_PARTICIPACAO_EMBARGANTE=$(echo $TIPO_PARTICIPACAO_EMBARGANTE | cut -d'"' -f 20)
  echo Tipo de participação embargante: $TIPO_PARTICIPACAO_EMBARGANTE

  TIPO_PARTICIPACAO_EMBARGADO=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=TIPO_PARTICIPACAO_EMBARGADO" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  TIPO_PARTICIPACAO_EMBARGADO=$(echo $TIPO_PARTICIPACAO_EMBARGADO | cut -d'"' -f 20)
  echo Tipo de participação embargado: $TIPO_PARTICIPACAO_EMBARGADO

  TIPO_ANDAMENTO_PETICAO_INICIAL=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=TIPO_ANDAMENTO_PETICAO_INICIAL" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  TIPO_ANDAMENTO_PETICAO_INICIAL=$(echo $TIPO_ANDAMENTO_PETICAO_INICIAL | cut -d'"' -f 20)
  echo Tipo de andamento inicial de EF: $TIPO_ANDAMENTO_PETICAO_INICIAL

  TIPO_ANDAMENTO_INTIMACAO_NAO_CATEGORIZADA=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=TIPO_ANDAMENTO_INTIMACAO_NAO_CATEGORIZADA" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  TIPO_ANDAMENTO_INTIMACAO_NAO_CATEGORIZADA=$(echo $TIPO_ANDAMENTO_INTIMACAO_NAO_CATEGORIZADA | cut -d'"' -f 20)
  echo Tipo de andamento TIPO_ANDAMENTO_INTIMACAO_NAO_CATEGORIZADA: $TIPO_ANDAMENTO_INTIMACAO_NAO_CATEGORIZADA

  TIPO_ANDAMENTO_CITACAO_NAO_CATEGORIZADA=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=TIPO_ANDAMENTO_CITACAO_NAO_CATEGORIZADA" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  TIPO_ANDAMENTO_CITACAO_NAO_CATEGORIZADA=$(echo $TIPO_ANDAMENTO_CITACAO_NAO_CATEGORIZADA | cut -d'"' -f 20)
  echo Tipo de andamento TIPO_ANDAMENTO_CITACAO_NAO_CATEGORIZADA: $TIPO_ANDAMENTO_CITACAO_NAO_CATEGORIZADA

  TIPO_ANDAMENTO_PEDIDO_PROSSEGUIMENTO_FEITO=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=TIPO_ANDAMENTO_PEDIDO_PROSSEGUIMENTO_FEITO" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  TIPO_ANDAMENTO_PEDIDO_PROSSEGUIMENTO_FEITO=$(echo $TIPO_ANDAMENTO_PEDIDO_PROSSEGUIMENTO_FEITO | cut -d'"' -f 20)
  echo Tipo de andamento TIPO_ANDAMENTO_PEDIDO_PROSSEGUIMENTO_FEITO: $TIPO_ANDAMENTO_PEDIDO_PROSSEGUIMENTO_FEITO

  TIPO_ANDAMENTO_EXCECAO_PRE_EXECUTIVIDADE=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=TIPO_ANDAMENTO_EXCECAO_PRE_EXECUTIVIDADE" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  TIPO_ANDAMENTO_EXCECAO_PRE_EXECUTIVIDADE=$(echo $TIPO_ANDAMENTO_EXCECAO_PRE_EXECUTIVIDADE | cut -d'"' -f 20)
  echo Tipo de andamento TIPO_ANDAMENTO_EXCECAO_PRE_EXECUTIVIDADE: $TIPO_ANDAMENTO_EXCECAO_PRE_EXECUTIVIDADE

  GERA_EXEMPLOS_TIPO_ANDAMENTO_DIVIDA_PAGA=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=GERA_EXEMPLOS_TIPO_ANDAMENTO_DIVIDA_PAGA" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  GERA_EXEMPLOS_TIPO_ANDAMENTO_DIVIDA_PAGA=$(echo $GERA_EXEMPLOS_TIPO_ANDAMENTO_DIVIDA_PAGA | cut -d'"' -f 20)
  echo Tipo de andamento GERA_EXEMPLOS_TIPO_ANDAMENTO_DIVIDA_PAGA: $GERA_EXEMPLOS_TIPO_ANDAMENTO_DIVIDA_PAGA

  GERA_EXEMPLOS_TIPO_ANDAMENTO_DIVIDA_PARCELADA=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=GERA_EXEMPLOS_TIPO_ANDAMENTO_DIVIDA_PARCELADA" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  GERA_EXEMPLOS_TIPO_ANDAMENTO_DIVIDA_PARCELADA=$(echo $GERA_EXEMPLOS_TIPO_ANDAMENTO_DIVIDA_PARCELADA | cut -d'"' -f 20)
  echo Tipo de andamento GERA_EXEMPLOS_TIPO_ANDAMENTO_DIVIDA_PARCELADA: $GERA_EXEMPLOS_TIPO_ANDAMENTO_DIVIDA_PARCELADA

  GERA_EXEMPLOS_TIPO_ANDAMENTO_PARCELAMENTO_ROMPIDO=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=GERA_EXEMPLOS_TIPO_ANDAMENTO_PARCELAMENTO_ROMPIDO" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  GERA_EXEMPLOS_TIPO_ANDAMENTO_PARCELAMENTO_ROMPIDO=$(echo $GERA_EXEMPLOS_TIPO_ANDAMENTO_PARCELAMENTO_ROMPIDO | cut -d'"' -f 20)
  echo Tipo de andamento GERA_EXEMPLOS_TIPO_ANDAMENTO_PARCELAMENTO_ROMPIDO: $GERA_EXEMPLOS_TIPO_ANDAMENTO_PARCELAMENTO_ROMPIDO

  GERA_EXEMPLOS_TIPO_ANDAMENTO_CDA_CANCELADA=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=GERA_EXEMPLOS_TIPO_ANDAMENTO_CDA_CANCELADA" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  GERA_EXEMPLOS_TIPO_ANDAMENTO_CDA_CANCELADA=$(echo $GERA_EXEMPLOS_TIPO_ANDAMENTO_CDA_CANCELADA | cut -d'"' -f 20)
  echo Tipo de andamento GERA_EXEMPLOS_TIPO_ANDAMENTO_CDA_CANCELADA: $GERA_EXEMPLOS_TIPO_ANDAMENTO_CDA_CANCELADA

  TIPO_ANDAMENTO_CITACAO=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=TIPO_ANDAMENTO_CITACAO" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  TIPO_ANDAMENTO_CITACAO=$(echo $TIPO_ANDAMENTO_CITACAO | cut -d'"' -f 20)
  echo Tipo de andamento TIPO_ANDAMENTO_CITACAO: $TIPO_ANDAMENTO_CITACAO


  TIPO_ANDAMENTO_AVALIACAO_PARECER_REQUERIDA=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=TIPO_ANDAMENTO_AVALIACAO_PARECER_REQUERIDA" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  TIPO_ANDAMENTO_AVALIACAO_PARECER_REQUERIDA=$(echo $TIPO_ANDAMENTO_AVALIACAO_PARECER_REQUERIDA | cut -d'"' -f 20)
  echo Tipo de andamento TIPO_ANDAMENTO_AVALIACAO_PARECER_REQUERIDA: $TIPO_ANDAMENTO_AVALIACAO_PARECER_REQUERIDA

  TIPO_ANDAMENTO_CITACAO_TUTELA=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=TIPO_ANDAMENTO_CITACAO_TUTELA" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  TIPO_ANDAMENTO_CITACAO_TUTELA=$(echo $TIPO_ANDAMENTO_CITACAO_TUTELA | cut -d'"' -f 20)
  echo Tipo de andamento TIPO_ANDAMENTO_CITACAO_TUTELA: $TIPO_ANDAMENTO_CITACAO_TUTELA

  TIPO_ANDAMENTO_CITACAO_INTIMACAO_PREVIA=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=TIPO_ANDAMENTO_CITACAO_INTIMACAO_PREVIA" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  TIPO_ANDAMENTO_CITACAO_INTIMACAO_PREVIA=$(echo $TIPO_ANDAMENTO_CITACAO_INTIMACAO_PREVIA | cut -d'"' -f 20)
  echo Tipo de andamento TIPO_ANDAMENTO_CITACAO_INTIMACAO_PREVIA: $TIPO_ANDAMENTO_CITACAO_INTIMACAO_PREVIA

  TIPO_ANDAMENTO_CONTESTACAO=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=TIPO_ANDAMENTO_CONTESTACAO" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  TIPO_ANDAMENTO_CONTESTACAO=$(echo $TIPO_ANDAMENTO_CONTESTACAO | cut -d'"' -f 20)
  echo Tipo de andamento TIPO_ANDAMENTO_CONTESTACAO: $TIPO_ANDAMENTO_CONTESTACAO

  TIPO_ANDAMENTO_SENTENCA_DESFAVORAVEL=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=TIPO_ANDAMENTO_SENTENCA_DESFAVORAVEL" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  TIPO_ANDAMENTO_SENTENCA_DESFAVORAVEL=$(echo $TIPO_ANDAMENTO_SENTENCA_DESFAVORAVEL | cut -d'"' -f 20)
  echo Tipo de andamento TIPO_ANDAMENTO_SENTENCA_DESFAVORAVEL: $TIPO_ANDAMENTO_SENTENCA_DESFAVORAVEL

  TIPO_ANDAMENTO_EMBARGO_EXECUCAO_FISCAL=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=TIPO_ANDAMENTO_EMBARGO_EXECUCAO_FISCAL" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  TIPO_ANDAMENTO_EMBARGO_EXECUCAO_FISCAL=$(echo $TIPO_ANDAMENTO_EMBARGO_EXECUCAO_FISCAL | cut -d'"' -f 20)
  echo Tipo de andamento TIPO_ANDAMENTO_EMBARGO_EXECUCAO_FISCAL: $TIPO_ANDAMENTO_EMBARGO_EXECUCAO_FISCAL

  MATERIA_AGUARDANDO_CONFERENCIA=$(curl --request GET "$SERVIDOR_ADMIN/parametros?parametro=MATERIA_AGUARDANDO_CONFERENCIA" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN")
  MATERIA_AGUARDANDO_CONFERENCIA=$(echo $MATERIA_AGUARDANDO_CONFERENCIA | cut -d'"' -f 20)
  echo Matéria Ag Conferencia: MATERIA_AGUARDANDO_CONFERENCIA

DIVIDA_TIPO_SITUACAO_ABERTA=1
DIVIDA_TIPO_SITUACAO_PARCELADA=4
DIVIDA_TIPO_SITUACAO_PARCELAMENTO_ATIVO=1
PROCESSO_UNIDADE_JUDICIAL_CAPITAL_FAZENDA_PUBLICA=8260053
PROCESSO_UNIDADE_JUDICIAL_CAPITAL_EXECUCAO_FISCAL=8260090
DIVIDA_ORGAO_ORIGEM_ID=10
TIPO_ANDAMENTO_PETICAO_EXCECAO_PRE_EXECUTIVIDADE=336
VARA_DA_FAZENDA_PUBLICA=254
TIPO_PARTICIPACAO_REU=43
TIPO_PARTICIPACAO_AUTOR=42
TIPO_ANDAMENTO_PROCURACAO=900000028
ASSUNTO_CNJ=6004
TIPO_PARTICIPACAO_INTERESSADO=258
LOCAL_ORIGEM=1002

if [ "$TENANT" == "PGEBA" ]; then
    DIVIDA_TIPO_SITUACAO_ABERTA=2
    DIVIDA_TIPO_SITUACAO_PARCELADA=53
    DIVIDA_TIPO_SITUACAO_PARCELAMENTO_ATIVO=2
    DIVIDA_ORGAO_ORIGEM_ID=1
    TIPO_ANDAMENTO_EXCECAO_PRE_EXECUTIVIDADE=6009991483
    TIPO_ANDAMENTO_CITACAO=6000001466
    TIPO_ANDAMENTO_CITACAO_TUTELA=6000001469
    TIPO_ANDAMENTO_CITACAO_INTIMACAO_PREVIA=6000001469
    TIPO_ANDAMENTO_SENTENCA_DESFAVORAVEL=10
    TIPO_ANDAMENTO_EMBARGO_EXECUCAO_FISCAL=6010000048
    TIPO_ANDAMENTO_INTIMACAO_NAO_CATEGORIZADA=6000001113
    TIPO_ANDAMENTO_CITACAO_NAO_CATEGORIZADA=6000001521
    MATERIA_FISCAL_TRIBUTARIO=1012
    MATERIA_EF=1012
    PROCESSO_UNIDADE_JUDICIAL_CAPITAL_FAZENDA_PUBLICA=8050001
    PROCESSO_UNIDADE_JUDICIAL_CAPITAL_EXECUCAO_FISCAL=8050001
    ASSUNTO_INSTITUICAO_CONTENCIOSO=12108
    ASSUNTO_INSTITUICAO_JUIZADO_ESPECIAL=11953
    TIPO_ANDAMENTO_PETICAO_INICIAL=319
    ASSUNTO_INSTITUICAO_CONTENCIOSO_2=11953
    ASSUNTO_INSTITUICAO_CONTENCIOSO_3=11953
    ASSUNTO_INSTITUICAO_CONTENCIOSO_4=11953
    DIVIDA_ENDERECO_UF=BA
    DIVIDA_ENDERCO_MUNICIPIO_ID=2927408
fi

if [ "$TENANT" == "ATTORNATUS" ]; then
    ASSUNTO_INSTITUICAO_EF=216
    TIPO_ANDAMENTO_EXCECAO_PRE_EXECUTIVIDADE=51
    TIPO_ANDAMENTO_PETICAO_EXCECAO_PRE_EXECUTIVIDADE=1034
    VARA_DA_FAZENDA_PUBLICA=1
    TIPO_PARTICIPACAO_REU=2
    TIPO_PARTICIPACAO_AUTOR=1
    TIPO_ANDAMENTO_PROCURACAO=900001206
    TIPO_PARTICIPACAO_INTERESSADO=4
    LOCAL_ORIGEM=72
fi

if [[ $AMBIENTE =~ "dev.pgeweb" ]]; then
  ASSUNTO_INSTITUICAO_EF=1480
fi

}

############################## Apagar cahe parametros instituição #################################
fn_apagar_cache_parametro_instituicao() {
  echo Redis: Limpando caches parametro instituicao...

  curl --request DELETE "$SERVIDOR_ADMIN/parametros/limpar-cache-parametro-instituicao" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN"

}

############################## Apagar caches #################################
fn_apagar_caches_dados() {
  echo Redis: Limpando caches...

  curl --request DELETE "$SERVIDOR_ADMIN/parametros/limpar-cache-todos-parametros" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN"

}