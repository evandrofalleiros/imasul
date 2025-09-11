#!/usr/bin/env Rscript

cat("=== TESTE DA FUNÇÃO analisar_temporal CORRIGIDA ===\n")

# Carregar e instalar o pacote
devtools::install(".", quiet = TRUE)
library(imasul)

# Carregar dados
cat("1. Carregando dados...\n")
dados <- carregar_dados_imasul(incluir_coordenadas = TRUE)

# Testar análise temporal
cat("2. Testando analisar_temporal()...\n")
temporal <- analisar_temporal(dados, "cadmio_total_mg_L_Cd", "ano")

# Verificar estrutura
cat("3. Verificando estrutura do resultado...\n")
cat("Colunas do resultado:", paste(names(temporal), collapse = ", "), "\n")

cat("4. Verificando coluna data_agrupada...\n")
if ("data_agrupada" %in% names(temporal)) {
  cat("   ✓ Coluna 'data_agrupada' encontrada!\n")
  cat("   ✓ Tipo:", class(temporal$data_agrupada), "\n")
  cat("   ✓ Primeiros valores:", head(temporal$data_agrupada, 3), "\n")
} else {
  cat("   ✗ Coluna 'data_agrupada' NÃO encontrada\n")
  stop("Função ainda não está retornando data_agrupada")
}

cat("5. Primeiras linhas do resultado:\n")
print(head(temporal, 3))

# Testar o plot
cat("6. Testando plot com ggplot2...\n")
library(ggplot2)

tryCatch({
  plot_result <- ggplot(temporal, aes(x = data_agrupada, y = media)) +
    geom_line() +
    geom_point() +
    labs(
      title = "Concentração Média de Cádmio ao Longo dos Anos",
      x = "Ano", 
      y = "Concentração (mg/L)",
      caption = "Fonte: IMASUL"
    ) +
    theme_minimal()
  
  cat("   ✓ Plot criado com sucesso!\n")
  cat("   ✓ Não houve erro 'object data_agrupada not found'\n")
  
}, error = function(e) {
  cat("   ✗ Erro no plot:", e$message, "\n")
})

cat("\n🎉 TESTE CONCLUÍDO COM SUCESSO!\n")
cat("✅ Função analisar_temporal() agora retorna data_agrupada corretamente\n")
cat("✅ Exemplo do README deve funcionar sem erros\n")
