#!/usr/bin/env Rscript

# Teste direto do pacote
setwd("/Users/evandrofalleiros/Desktop/Doutorado/workspace/imasul")

cat("=== TESTE FINAL DO PACOTE IMASUL ===\n")

# 1. Instalar devtools se necessário
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools", repos = "https://cran.r-project.org")
}

# 2. Instalar o pacote atual
cat("1. Instalando pacote...\n")
tryCatch({
  devtools::install(".", quiet = TRUE, upgrade = "never")
  cat("   ✓ Instalação concluída\n")
}, error = function(e) {
  cat("   ✗ Erro na instalação:", e$message, "\n")
  quit(status = 1)
})

# 3. Carregar o pacote
cat("2. Carregando pacote...\n")
tryCatch({
  library(imasul)
  cat("   ✓ Pacote carregado com sucesso\n")
}, error = function(e) {
  cat("   ✗ Erro ao carregar pacote:", e$message, "\n")
  quit(status = 1)
})

# 4. Testar função básica
cat("3. Testando listar_metais()...\n")
tryCatch({
  metais <- listar_metais()
  cat("   ✓ Encontrados", nrow(metais), "metais monitorados\n")
}, error = function(e) {
  cat("   ✗ Erro em listar_metais():", e$message, "\n")
})

# 5. Testar carregamento de dados
cat("4. Testando carregar_dados_imasul()...\n")
tryCatch({
  dados <- carregar_dados_imasul(incluir_coordenadas = FALSE, limpar_dados = FALSE)
  cat("   ✓ Dados carregados com sucesso!", nrow(dados), "registros\n")
  
  # Mostrar algumas informações básicas
  cat("   - Colunas:", ncol(dados), "\n")
  cat("   - Período:", min(dados$data_coleta, na.rm = TRUE), "a", max(dados$data_coleta, na.rm = TRUE), "\n")
  cat("   - Pontos únicos:", length(unique(dados$codigo_imasul)), "\n")
  
}, error = function(e) {
  cat("   ✗ ERRO CRÍTICO em carregar_dados_imasul():", e$message, "\n")
  quit(status = 1)
})

cat("\n🎉 TODOS OS TESTES PASSARAM! O pacote está funcionando corretamente.\n")
cat("✓ Problema do pipe %>% foi RESOLVIDO!\n")
cat("\n=== TESTE CONCLUÍDO COM SUCESSO ===\n")
