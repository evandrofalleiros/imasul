#!/usr/bin/env Rscript

cat("=== TESTE DA FUNÇÃO analisar_temporal ===\n")

devtools::install(".", quiet = TRUE)
library(imasul)

dados <- carregar_dados_imasul()
temporal <- analisar_temporal(dados, "ferro_total_mg_L_Fe", "ano")

cat("Colunas no resultado:", paste(names(temporal), collapse = ", "), "\n")

if ("data_agrupada" %in% names(temporal)) {
  cat("✓ Coluna 'data_agrupada' encontrada!\n")
  cat("✓ Função está funcionando corretamente\n")
} else {
  cat("✗ Coluna 'data_agrupada' NÃO encontrada\n")
  cat("Colunas disponíveis:", paste(names(temporal), collapse = ", "), "\n")
}
