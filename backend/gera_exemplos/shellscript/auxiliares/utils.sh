#!/usr/bin/env bash

######################## Função para obter data atual #############################
fn_data_atual() {
  HORA=$(date +%H)
  MINUTO=$(date +%M)
  SEGUNDO=$(date +%S)
  NANOSEGUNDO=$(date +%N)
  ANO=$(date +%Y)
  MES=$(date +%m)

  let dia=10\#$(date +%d)

  if (($dia < 10)); then
    j=0$dia
  else
    j=$dia
  fi
  DIA=$j
  j=""
  DIA_SEMANA=$(date +%w)
  DATA_ATUAL_COMPLETA=$ANO-$MES-$DIA$HORA-$MINUTO-$SEGUNDO-${NANOSEGUNDO:1:3}
}

######################## Função para reduzir data #############################
fn_reduz_dias() {
  if [ $DIA -le 0 ]; then
    MES=$(expr $MES - 1)
    if [ $MES -lt 10 ]; then
      j=0$MES
    else
      j=$MES
    fi
    MES=$j

    if [ $MES -le 0 ]; then
      MES=$(expr 12 - $MES)
      ANO=$(expr $ANO - 1)
    fi
    DIA_TMP=$(cal $MES $ANO)
    DIA_TMP=$(echo $DIA_TMP | awk '{ print $NF }')
    DIA=$(expr $DIA_TMP + $DIA)
    if [ $DIA -le 0 ]; then
      fn_reduz_dias
    fi
  fi
}

###################### Função para calcular data anterior #############################
fn_data_anterior() {
  DIA_DESTINO=$(expr $DIA - $DIAS_REDUZIR)
  QTDE_SEMANAS_DESTINO=$(expr $DIAS_REDUZIR / 7)
  DIA_REDUZIR_TMP=$(expr $QTDE_SEMANAS_DESTINO \* 7)
  DIA_DESTINO_TMP=$(expr $DIA - $DIA_REDUZIR_TMP)
  DIFERENCA_DIAS=$(expr $DIA_DESTINO_TMP - $DIA_DESTINO)
  DIA_SEMANA=$(expr $DIA_SEMANA - $DIFERENCA_DIAS)

  DIA_ORIGEM=$DIA
  DIA=$(expr $DIA - $DIAS_REDUZIR)

  fn_reduz_dias

  if [ $DIA_SEMANA -eq 0 ]; then
    DIAS_REDUZIR=2
    fn_data_anterior
  fi

  if [ $DIA_SEMANA -eq -1 ]; then
    DIAS_REDUZIR=1
    fn_data_anterior
  fi

  DIA=$(expr $DIA + 0) #apenas para converter para numero
  if [ $DIA -ge 10 ]; then
    j=$DIA
  else
    j=0$DIA
  fi
  DIA=$j
}

######################## Função para aumentar data #############################
fn_aumenta_dias() {

  DIA_MAX_MES=$(cal $MES $ANO)
  DIA_MAX_MES=$(echo $DIA_MAX_MES | awk '{ print $NF }')

  if [ $DIA -gt $DIA_MAX_MES ]; then

    DIA=$(expr $DIA - $DIA_MAX_MES)
    MES=$(expr $MES + 1)

    if [ $MES -gt 12 ]; then
      MES=$(expr $MES - 12)
      ANO=$(expr $ANO + 1)
    fi

    if [ $MES -lt 10 ]; then
      j=0$MES
    else
      j=$MES
    fi
    MES=$j

    DIA_MAX_MES=$(cal $MES $ANO)
    DIA_MAX_MES=$(echo $DIA_MAX_MES | awk '{ print $NF }')

    if [ $DIA -gt $DIA_MAX_MES ]; then
      fn_aumenta_dias
    fi
  fi
}


###################### Função para calcular data futura #############################
fn_data_futura() {
  DIA_DESTINO=$(expr $DIA + $DIAS_AUMENTAR)
  QTDE_SEMANAS_DESTINO=$(expr $DIAS_AUMENTAR / 7)
  DIA_AUMENTAR_TMP=$(expr $QTDE_SEMANAS_DESTINO \* 7)
  DIA_DESTINO_TMP=$(expr $DIA + $DIA_AUMENTAR_TMP)
  DIFERENCA_DIAS=$(expr $DIA_DESTINO - $DIA_DESTINO_TMP)
  DIA_SEMANA=$(expr $DIA_SEMANA + $DIFERENCA_DIAS)

  DIA_ORIGEM=$DIA
  DIA=$(expr $DIA + $DIAS_AUMENTAR)

  fn_aumenta_dias

  if [ $DIA_SEMANA -eq 7 ]; then
    DIAS_AUMENTAR=1
    fn_data_futura
  fi

  if [ $DIA_SEMANA -eq 6 ]; then
    DIAS_AUMENTAR=2
    fn_data_futura
  fi

  DIA=$(expr $DIA + 0) #apenas para converter para numero
  if [ $DIA -ge 10 ]; then
    j=$DIA
  else
    j=0$DIA
  fi
  DIA=$j
}