#!/usr/bin/env Rscript

# Teste do pipe no pacote imasul
cat("=== TESTE DO PACOTE IMASUL ===\n")

# Tentar carregar o pacote
cat("1. Carregando o pacote...\n")
tryCatch({
  library(imasul)
  cat("   ✓ Pacote carregado com sucesso\n")
}, error = function(e) {
  cat("   ✗ Erro ao carregar pacote:", e$message, "\n")
  quit(status = 1)
})

# Testar função sem pipe
cat("2. Testando listar_metais()...\n")
tryCatch({
  metais <- listar_metais()
  cat("   ✓ listar_metais() funcionou -", nrow(metais), "metais encontrados\n")
}, error = function(e) {
  cat("   ✗ Erro em listar_metais():", e$message, "\n")
})

# Testar função que usa pipes internamente
cat("3. Testando estatisticas_por_regiao() (usa pipes)...\n")
tryCatch({
  # Criar dados de teste simples
  dados_teste <- data.frame(
    codigo_imasul = c("A001", "A002", "B001"),
    regiao_hidrografica = c("PARANA", "PARANA", "PARAGUAI"),
    ferro_total_mg_L_Fe = c(0.1, 0.5, 0.2)
  )
  
  stats <- estatisticas_por_regiao(dados_teste, "ferro_total_mg_L_Fe")
  cat("   ✓ estatisticas_por_regiao() funcionou -", nrow(stats), "regiões analisadas\n")
}, error = function(e) {
  cat("   ✗ Erro em estatisticas_por_regiao():", e$message, "\n")
})

# Testar o operador pipe diretamente
cat("4. Testando operador %>% diretamente...\n")
tryCatch({
  resultado <- c(1,2,3) %>% length()
  cat("   ✓ Operador %>% funcionou - resultado:", resultado, "\n")
}, error = function(e) {
  cat("   ✗ Erro no operador %>%:", e$message, "\n")
})

cat("\n=== TESTE CONCLUÍDO ===\n")
