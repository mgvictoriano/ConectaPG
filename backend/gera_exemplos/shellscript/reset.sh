#!/usr/bin/env bash

# Script idêntico ao gera_exemplos.sh, com a diferença que não inclui processos
# Útil para as instituições fora PGESP quando queremos só sincronizar resumos, modelos e excluir dados antigos.

source ./auxiliares/admin.sh
source ./auxiliares/demanda.sh
source ./auxiliares/distribuicao.sh
source ./auxiliares/divida.sh
source ./auxiliares/documento.sh
source ./auxiliares/integrajud.sh
source ./auxiliares/pessoa.sh
source ./auxiliares/processo.sh
source ./auxiliares/security.sh
source ./auxiliares/setup.sh
source ./auxiliares/utils.sh
source ./auxiliares/qualidade.sh

############################### PRINCIPAL #####################
rm -f *.json

fn_autenticar

fn_identifica_dados_basicos
echo iniciando...

fn_excluir_documentos_com_processo

fn_excluir_dividas_gera_exemplos

fn_apagar_hash_dividas

fn_apagar_documentos_aguardando_vinculacao_processo

fn_parte_representada

fn_apagar_distribuicoes

fn_apagar_processos

fn_apagar_process_instaces

fn_demanda_excluir_historico_distribuicao

fn_excluir_enderecos_citacao_negativa

fn_apagar_cache_parametro_instituicao

fn_apagar_caches_dados

fn_apagar_lotacoes_e_inserir_mesa_vaga FIS-002

fn_apagar_lotacoes_e_inserir_mesa_vaga FIS-003

# fn_apagar_resumo_recebimento

fn_atualizar_resumo_recebimento

fn_demanda_ajustar_data_entrada

fn_documento_atualizar_modelos_elasticsearch

fn_divida_encerrar_lote_processamento

fn_sincronizar_tudo

echo -e "\n\nReset concluído."