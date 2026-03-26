#!/usr/bin/env bash

fn_gerar_documento() {
  fn_data_atual
  arquivo=$(cat $NOME_ARQUIVO | base64)

  documento=$(
    cat <<EOF
{
  "extensao":"PDF",
  "nome": "$DATA_ATUAL_COMPLETA.$NOME_DOCUMENTO",
  "totalSpace": 289559,
  "especie": "IMPORTADO",
  "tipoDocumento": {"id": 141},
  "arquivos":[{"nome": "$NOME_ARQUIVO", "totalSpace":289559,"bytes": "$arquivo"}]
}
EOF
  )
}

############################### Função para fazer upload de documento no tenant Attornatus ##################
fn_upload_documento() {

  fn_gerar_documento
  echo -e "\n*************** Inserindo documento $NOME_ARQUIVO *******************"
  echo -e $documento >>documento.json
  documentoId=$(curl --request POST "$SERVIDOR_DOCUMENTO/documentos/upload" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN" \
    --data @documento.json)
  echo $documentoId

  rm -f documento.json

  echo -e "\n************************ Upload realizado ******************* \n"

}

############################## Apagar documentos aguardando vinculação processo #################################
fn_apagar_documentos_aguardando_vinculacao_processo() {
  echo Apagando documentos aguardando vinculacao processo...

  curl --request DELETE "$SERVIDOR_DOCUMENTO/documentos/aguardando-vinculacao-processo" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN"
}

############################## Excluir documentos vinculados à processos ##############################
fn_excluir_documentos_com_processo() {
  echo Excluindo documentos vinculados com processos
  curl --request DELETE "$SERVIDOR_DOCUMENTO/apresentacao/documentos" \
    --header "Content-type: application/json" \
    --header "Authorization: Bearer $TOKEN"
}

fn_documento_atualizar_modelos_elasticsearch () {
 echo Elasticsearch: atualizando Modelos...

 curl --request POST "$SERVIDOR_DOCUMENTO/documentos/atualizarelasticsearch?search=extensao==%27DOCX%27" \
   --header "Content-type: application/json" \
   --header "Authorization: Bearer $TOKEN"
}

fn_documento_upload_documento_multipart() {
  echo -e "\n*************** Inserindo documento no processo $PROCESSO_ID *******************"
  curl --request POST "$SERVIDOR_DOCUMENTO/documentos/upload-multipart" \
       --header "Authorization: Bearer $TOKEN" \
       --form "file=@$PATH_DOCUMENTO" \
       --form "processoId=$PROCESSO_ID" \
       --form "tipoAndamentoId=$TIPO_ANDAMENTO_ID"

  echo -e "\n************************ Upload realizado ************** ***** \n"
}

fn_documento_upload_anexo_multipart() {

  echo -e "\n*************** Anexendo em documento $DOCUMENTO_PAI_ID *******************"
  curl --request POST "$SERVIDOR_DOCUMENTO/documentos/upload-multipart-anexo" \
       --header "Authorization: Bearer $TOKEN" \
       --form "file=@$PATH_DOCUMENTO" \
       --form "documentoPaiId=$DOCUMENTO_PAI_ID"
  echo -e "\n************************ Upload realizado ******************* \n"
}
