#!/usr/bin/env Rscript

# Teste simples do pacote sem usar pipe
cat("=== TESTE BÁSICO DO PACOTE IMASUL ===\n")

# Carregar bibliotecas necessárias
library(devtools)

cat("1. Instalando o pacote...\n")
tryCatch({
  devtools::install(".", quiet = TRUE)
  cat("   ✓ Pacote instalado\n")
}, error = function(e) {
  cat("   ✗ Erro na instalação:", e$message, "\n")
})

cat("2. Carregando o pacote...\n")
tryCatch({
  library(imasul)
  cat("   ✓ Pacote carregado\n")
}, error = function(e) {
  cat("   ✗ Erro ao carregar:", e$message, "\n")
})

cat("3. Testando funções básicas...\n")

# Testar listar_metais
tryCatch({
  metais <- listar_metais()
  cat("   ✓ listar_metais() OK - ", nrow(metais), " metais\n")
}, error = function(e) {
  cat("   ✗ Erro em listar_metais():", e$message, "\n")
})

# Testar carregar dados
tryCatch({
  dados <- carregar_dados_imasul(incluir_coordenadas = FALSE, limpar_dados = FALSE)
  cat("   ✓ carregar_dados_imasul() OK - ", nrow(dados), " registros\n")
}, error = function(e) {
  cat("   ✗ Erro em carregar_dados_imasul():", e$message, "\n")
})

cat("\n=== TESTE CONCLUÍDO ===\n")
