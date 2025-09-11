# Exemplo de Uso do Pacote imasul
# Este script demonstra as principais funcionalidades do pacote

# Carregar bibliotecas necessárias
library(imasul)
library(dplyr)
library(ggplot2)

# ==============================================================================
# 1. CARREGAMENTO DOS DADOS
# ==============================================================================

cat("=== CARREGAMENTO DOS DADOS ===\n")

# Carregar dados com coordenadas geográficas
dados <- carregar_dados_imasul(incluir_coordenadas = TRUE)

# Visualizar estrutura dos dados
cat("Estrutura dos dados:\n")
str(dados)

cat("\nResumo básico:\n")
cat("Período:", as.character(min(dados$data_coleta, na.rm = TRUE)), 
    "a", as.character(max(dados$data_coleta, na.rm = TRUE)), "\n")
cat("Pontos de monitoramento:", length(unique(dados$codigo_imasul)), "\n")
cat("Total de amostras:", nrow(dados), "\n")
cat("Regiões:", paste(unique(dados$regiao_hidrografica), collapse = ", "), "\n")

# ==============================================================================
# 2. CONSULTA DE METAIS DISPONÍVEIS
# ==============================================================================

cat("\n=== METAIS DISPONÍVEIS ===\n")
metais <- listar_metais()
print(metais)

# ==============================================================================
# 3. LIMITES CONAMA
# ==============================================================================

cat("\n=== LIMITES CONAMA ===\n")
limites <- limites_conama()
print(limites)

# ==============================================================================
# 4. ANÁLISE ESTATÍSTICA DETALHADA
# ==============================================================================

cat("\n=== ANÁLISE ESTATÍSTICA - FERRO ===\n")

# Resumo estatístico do ferro
resumo_fe <- resumo_metal(dados, "ferro_total_mg_L_Fe")

cat("Estatísticas do Ferro:\n")
cat("Amostras válidas:", resumo_fe$n_amostras, "\n")
cat("Pontos monitorados:", resumo_fe$n_pontos, "\n")
cat("Média:", round(resumo_fe$media, 3), "mg/L\n")
cat("Mediana:", round(resumo_fe$mediana, 3), "mg/L\n")
cat("Máximo:", round(resumo_fe$maximo, 3), "mg/L\n")
cat("Limite CONAMA:", resumo_fe$limite_conama, "mg/L\n")
cat("Amostras acima do limite:", resumo_fe$amostras_acima_limite, 
    "(", round(resumo_fe$percentual_acima_limite, 1), "%)\n")
cat("Conforme CONAMA:", resumo_fe$conforme_conama, "\n")

# ==============================================================================
# 5. VERIFICAÇÃO DE CONFORMIDADE
# ==============================================================================

cat("\n=== VERIFICAÇÃO DE CONFORMIDADE - CÁDMIO ===\n")

# Verificar conformidade para cádmio
dados_cd <- verificar_conformidade(dados, "cadmio_total_mg_L_Cd")

# Resumir status
status_cd <- table(dados_cd$status_cadmio_total_mg_L_Cd)
cat("Status de conformidade do Cádmio:\n")
print(status_cd)

# ==============================================================================
# 6. RELATÓRIO COMPLETO DE CONFORMIDADE
# ==============================================================================

cat("\n=== RELATÓRIO COMPLETO DE CONFORMIDADE ===\n")

relatorio <- relatorio_conformidade(dados)

cat("Resumo Geral:\n")
cat("Total de metais:", relatorio$resumo_geral$total_metais, "\n")
cat("Metais conformes:", relatorio$resumo_geral$metais_conformes, "\n")
cat("Metais não conformes:", relatorio$resumo_geral$metais_nao_conformes, "\n")
cat("Percentual de conformidade:", 
    round(relatorio$resumo_geral$percentual_conformidade, 1), "%\n")

# ==============================================================================
# 7. ANÁLISE TEMPORAL
# ==============================================================================

cat("\n=== ANÁLISE TEMPORAL - FERRO ===\n")

# Análise temporal anual
temporal_fe <- analisar_temporal(dados, "ferro_total_mg_L_Fe", "ano")

cat("Tendência anual do ferro:\n")
print(temporal_fe[, c("ano", "media", "n_amostras")])

# ==============================================================================
# 8. ESTATÍSTICAS POR REGIÃO
# ==============================================================================

cat("\n=== ESTATÍSTICAS POR REGIÃO - FERRO ===\n")

stats_regiao <- estatisticas_por_regiao(dados, "ferro_total_mg_L_Fe")
print(stats_regiao)

# ==============================================================================
# 9. IDENTIFICAÇÃO DE PONTOS CRÍTICOS
# ==============================================================================

cat("\n=== PONTOS CRÍTICOS - FERRO ===\n")

# Identificar pontos com >30% de não conformidade
criticos_fe <- identificar_pontos_criticos(dados, "ferro_total_mg_L_Fe", 30)

if (nrow(criticos_fe) > 0) {
  cat("Pontos críticos identificados:\n")
  print(criticos_fe[, c("codigo_imasul", "regiao_hidrografica", 
                        "percentual_nao_conforme", "classificacao")])
} else {
  cat("Nenhum ponto crítico identificado com o critério estabelecido.\n")
}

# ==============================================================================
# 10. MAPEAMENTO
# ==============================================================================

cat("\n=== PREPARAÇÃO PARA MAPEAMENTO ===\n")

# Preparar dados para mapeamento
pontos_mapa <- mapear_pontos(dados, "ferro_total_mg_L_Fe")

cat("Pontos preparados para mapeamento:", nrow(pontos_mapa), "\n")
cat("Colunas disponíveis:\n")
print(names(pontos_mapa))

# ==============================================================================
# 11. VISUALIZAÇÕES BÁSICAS
# ==============================================================================

cat("\n=== GERANDO VISUALIZAÇÕES ===\n")

# Gráfico temporal
p1 <- ggplot(temporal_fe, aes(x = data_agrupada, y = media)) +
  geom_line(color = "blue", size = 1) +
  geom_point(color = "red", size = 2) +
  geom_hline(yintercept = 0.3, color = "red", linetype = "dashed") +
  labs(
    title = "Concentração Média de Ferro ao Longo dos Anos",
    subtitle = "Linha tracejada: Limite CONAMA (0,3 mg/L)",
    x = "Ano",
    y = "Concentração (mg/L)"
  ) +
  theme_minimal()

# Salvar gráfico
ggsave("temporal_ferro.png", p1, width = 10, height = 6, dpi = 300)
cat("Gráfico temporal salvo: temporal_ferro.png\n")

# Boxplot por região
dados_plot <- dados %>%
  filter(!is.na(ferro_total_mg_L_Fe))

p2 <- ggplot(dados_plot, aes(x = regiao_hidrografica, y = ferro_total_mg_L_Fe)) +
  geom_boxplot(fill = "lightblue", alpha = 0.7) +
  geom_hline(yintercept = 0.3, color = "red", linetype = "dashed") +
  scale_y_log10() +
  labs(
    title = "Distribuição de Ferro por Região Hidrográfica",
    subtitle = "Escala logarítmica - Linha tracejada: Limite CONAMA",
    x = "Região Hidrográfica",
    y = "Concentração de Ferro (mg/L)"
  ) +
  theme_minimal()

ggsave("boxplot_ferro_regiao.png", p2, width = 8, height = 6, dpi = 300)
cat("Boxplot por região salvo: boxplot_ferro_regiao.png\n")

# ==============================================================================
# 12. EXPORTAÇÃO PARA EXCEL (OPCIONAL)
# ==============================================================================

cat("\n=== EXPORTAÇÃO PARA EXCEL ===\n")

# Verificar se openxlsx está disponível
if (requireNamespace("openxlsx", quietly = TRUE)) {
  exportar_para_excel(dados, "relatorio_imasul.xlsx")
  cat("Relatório exportado: relatorio_imasul.xlsx\n")
} else {
  cat("Pacote 'openxlsx' não disponível. Pulando exportação para Excel.\n")
  cat("Para instalar: install.packages('openxlsx')\n")
}

# ==============================================================================
# FINALIZAÇÃO
# ==============================================================================

cat("\n=== ANÁLISE CONCLUÍDA ===\n")
cat("Todos os exemplos foram executados com sucesso!\n")
cat("Arquivos gerados:\n")
cat("- temporal_ferro.png\n")
cat("- boxplot_ferro_regiao.png\n")
if (requireNamespace("openxlsx", quietly = TRUE)) {
  cat("- relatorio_imasul.xlsx\n")
}

cat("\nPara mais informações, consulte:\n")
cat("- help(package = 'imasul')\n")
cat("- vignette('introducao', package = 'imasul')\n")
