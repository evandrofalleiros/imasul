#!/usr/bin/env Rscript

# Script para investigar o tratamento dos valores <LQ
library(imasul)

cat("=== INVESTIGAÇÃO DOS VALORES <LQ ===\n\n")

# Carregar os dados processados
dados <- carregar_dados_imasul(incluir_coordenadas = TRUE)

# Obter lista de metais
metais <- c("ferro_total_mg_L_Fe", "cadmio_total_mg_L_Cd", "chumbo_total_mg_L_Pb", 
            "aluminio_total_mg_L_Al", "manganes_total_mg_L_Mn")

cat("Total de registros nos dados:", nrow(dados), "\n\n")

# 1. Verificar se há valores <LQ ainda presentes como texto
cat("=== 1. VERIFICAÇÃO DE VALORES <LQ COMO TEXTO ===\n")
encontrou_lq_texto <- FALSE

for(metal in metais) {
  if(metal %in% colnames(dados)) {
    valores_unicos <- unique(as.character(dados[[metal]]))
    valores_lq <- grep("<LQ|<|LQ|menor|abaixo", valores_unicos, value = TRUE, ignore.case = TRUE)
    
    if(length(valores_lq) > 0) {
      cat("Metal:", metal, "\n")
      cat("Valores <LQ encontrados:", paste(valores_lq, collapse = ", "), "\n\n")
      encontrou_lq_texto <- TRUE
    }
  }
}

if(!encontrou_lq_texto) {
  cat("Nenhum valor <LQ encontrado como texto nos dados processados.\n\n")
}

# 2. Análise detalhada de valores muito pequenos
cat("=== 2. ANÁLISE DE VALORES MUITO PEQUENOS ===\n")

for(metal in metais) {
  if(metal %in% colnames(dados)) {
    valores_numericos <- dados[[metal]][!is.na(dados[[metal]])]
    valores_na <- sum(is.na(dados[[metal]]))
    total <- length(dados[[metal]])
    
    cat("Metal:", gsub("_total_mg_L_.*", "", metal), "\n")
    cat("  Total de registros:", total, "\n")
    cat("  Valores NA:", valores_na, "(", round(valores_na/total*100, 1), "%)\n")
    cat("  Valores válidos:", length(valores_numericos), "\n")
    
    if(length(valores_numericos) > 0) {
      # Contar valores em diferentes faixas
      valores_zero <- sum(valores_numericos == 0, na.rm = TRUE)
      muito_pequenos_1e4 <- sum(valores_numericos < 1e-4, na.rm = TRUE)
      muito_pequenos_1e3 <- sum(valores_numericos < 1e-3, na.rm = TRUE)
      pequenos_01 <- sum(valores_numericos < 0.01, na.rm = TRUE)
      
      cat("  Valores = 0:", valores_zero, "\n")
      cat("  Valores < 1e-4 (0.0001):", muito_pequenos_1e4, "\n")
      cat("  Valores < 1e-3 (0.001):", muito_pequenos_1e3, "\n")
      cat("  Valores < 0.01:", pequenos_01, "\n")
      cat("  Mínimo:", min(valores_numericos, na.rm = TRUE), "\n")
      cat("  Máximo:", max(valores_numericos, na.rm = TRUE), "\n")
      
      # Mostrar os 15 menores valores
      menores <- head(sort(valores_numericos), 15)
      cat("  15 menores valores:", paste(menores, collapse = ", "), "\n")
    }
    cat("\n")
  }
}

# 3. Verificar dados brutos se disponíveis
cat("=== 3. VERIFICAÇÃO DOS DADOS BRUTOS ===\n")

# Tentar encontrar arquivo CSV original
possiveis_caminhos <- c(
  "inst/csv/resultados_metais_2011_2022.csv",
  "csv/resultados_metais_2011_2022.csv",
  "data-raw/resultados_metais_2011_2022.csv",
  "inst/csv/pontos_resultados_metais.csv",
  "csv/pontos_resultados_metais.csv"
)

arquivo_encontrado <- NULL
for(caminho in possiveis_caminhos) {
  if(file.exists(caminho)) {
    arquivo_encontrado <- caminho
    break
  }
}

if(!is.null(arquivo_encontrado)) {
  cat("Arquivo de dados brutos encontrado:", arquivo_encontrado, "\n")
  
  # Ler apenas algumas linhas para verificar
  dados_brutos <- read.csv(arquivo_encontrado, stringsAsFactors = FALSE, nrows = 100)
  cat("Dimensões da amostra:", nrow(dados_brutos), "x", ncol(dados_brutos), "\n")
  
  # Verificar colunas de metais
  colunas_metais <- grep("mg_L|_Fe|_Cd|_Pb|_Al|_Mn", colnames(dados_brutos), value = TRUE)
  cat("Colunas de metais encontradas:", paste(head(colunas_metais, 5), collapse = ", "), "\n\n")
  
  # Verificar valores <LQ nas primeiras 3 colunas de metais
  for(coluna in head(colunas_metais, 3)) {
    valores_unicos <- unique(dados_brutos[[coluna]])
    # Remover NAs para análise
    valores_unicos <- valores_unicos[!is.na(valores_unicos)]
    
    cat("Coluna:", coluna, "\n")
    cat("Valores únicos (primeiros 15):", paste(head(valores_unicos, 15), collapse = ", "), "\n")
    
    # Procurar padrões <LQ
    valores_lq <- grep("<LQ|<|LQ|N/A|n/a|menor|abaixo", valores_unicos, value = TRUE, ignore.case = TRUE)
    if(length(valores_lq) > 0) {
      cat("Valores <LQ/N/A encontrados:", paste(valores_lq, collapse = ", "), "\n")
    }
    
    # Verificar se são todos numéricos
    numericos <- suppressWarnings(as.numeric(valores_unicos))
    nao_numericos <- valores_unicos[is.na(numericos)]
    if(length(nao_numericos) > 0) {
      cat("Valores não numéricos:", paste(head(nao_numericos, 10), collapse = ", "), "\n")
    }
    cat("\n")
  }
} else {
  cat("Nenhum arquivo de dados brutos encontrado nos caminhos verificados.\n")
  cat("Caminhos testados:\n")
  for(caminho in possiveis_caminhos) {
    cat("  -", caminho, "\n")
  }
}

# 4. Verificar arquivo de processamento
cat("\n=== 4. VERIFICAÇÃO DO SCRIPT DE PROCESSAMENTO ===\n")

script_processamento <- "data-raw/processar_dados.R"
if(file.exists(script_processamento)) {
  cat("Script de processamento encontrado:", script_processamento, "\n")
  cat("Verificando tratamento de <LQ...\n")
  
  # Ler o script e procurar por tratamento de <LQ
  linhas <- readLines(script_processamento)
  linhas_lq <- grep("<LQ|LQ|gsub|sub|str_replace", linhas, ignore.case = TRUE)
  
  if(length(linhas_lq) > 0) {
    cat("Linhas relacionadas ao tratamento de <LQ:\n")
    for(i in linhas_lq) {
      cat("Linha", i, ":", linhas[i], "\n")
    }
  } else {
    cat("Nenhuma linha explícita de tratamento de <LQ encontrada.\n")
  }
} else {
  cat("Script de processamento não encontrado em:", script_processamento, "\n")
}

cat("\n=== CONCLUSÃO DA INVESTIGAÇÃO ===\n")
cat("Investigação concluída. Analise os resultados acima para entender\n")
cat("como os valores <LQ foram tratados nos dados.\n")
