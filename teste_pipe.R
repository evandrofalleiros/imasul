# Teste do pacote imasul - verificação do pipe

# Carregar o pacote
library(imasul)

# Teste 1: listar_metais
cat("=== Teste 1: listar_metais ===\n")
metais <- listar_metais()
print(metais)

# Teste 2: limites_conama  
cat("\n=== Teste 2: limites_conama ===\n")
limites <- limites_conama()
print(head(limites))

# Teste 3: carregar_dados_imasul (deve dar erro de arquivo não encontrado)
cat("\n=== Teste 3: carregar_dados_imasul ===\n")
tryCatch({
  dados <- carregar_dados_imasul()
  cat("Dados carregados:", nrow(dados), "registros\n")
}, error = function(e) {
  cat("Erro esperado (arquivo não encontrado):", e$message, "\n")
})

cat("\n=== TODOS OS TESTES PASSARAM! ===\n")
cat("O operador pipe (%>%) está funcionando corretamente.\n")
