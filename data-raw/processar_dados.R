# Script para processar e incluir dados no pacote

library(readr)
library(dplyr)
library(usethis)

# Carregar dados brutos
resultados_metais <- read_csv(
  "inst/csv/resultados_metais_2011_2022.csv",
  col_types = cols(
    regiao_hidrografica = col_character(),
    codigo_imasul = col_character(),
    data_coleta = col_date(format = "%d/%m/%Y"),
    hora = col_time(format = "%H:%M"),
    .default = col_character()
  ),
  locale = locale(encoding = "UTF-8")
)

pontos_metais <- read_csv(
  "inst/csv/pontos_resultados_metais.csv",
  col_types = cols(
    CODIGO_DO_PONTO = col_character(),
    LATITUDE = col_double(),
    LONGITUDE = col_double(),
    DESCRICAO_DO_LOCAL = col_character(),
    REGIAO_HIDROGRAFICA = col_character()
  ),
  locale = locale(encoding = "UTF-8")
)

# Definir limites de quantificação (LQ) para cada metal
# Baseado na análise dos menores valores válidos consistentes
limites_lq <- list(
  "aluminio_total_mg_L_Al" = 0.1,
  "bario_total_mg_L_Ba" = 0.7,      # Baseado no limite CONAMA (conservador)
  "cadmio_total_mg_L_Cd" = 0.005,
  "chumbo_total_mg_L_Pb" = 0.02,
  "cobre_total_mg_L_Cu" = 0.009,    # Baseado no limite CONAMA
  "cromo_total_mg_L_Cr" = 0.05,     # Baseado no limite CONAMA
  "ferro_total_mg_L_Fe" = 0.1,
  "manganes_total_mg_L_Mn" = 0.1,
  "mercurio_total_mg_L_Hg" = 0.0002, # Baseado no limite CONAMA
  "niquel_total_mg_L_Ni" = 0.025,   # Baseado no limite CONAMA
  "zinco_total_mg_L_Zn" = 0.18      # Baseado no limite CONAMA
)

# Limpar dados de metais
resultados_metais <- resultados_metais %>%
  mutate(
    # Remover espaços em branco das colunas de texto
    across(where(is.character), ~trimws(.))
  ) %>%
  # Remover linhas completamente vazias
  filter(!is.na(codigo_imasul))

# Aplicar tratamento específico para cada metal
for (metal_col in names(limites_lq)) {
  if (metal_col %in% colnames(resultados_metais)) {
    lq_limite <- limites_lq[[metal_col]]
    
    resultados_metais[[metal_col]] <- case_when(
      # Valores <LQ: substituir por LQ/√2 (abordagem estatisticamente robusta)
      resultados_metais[[metal_col]] == "<LQ" ~ lq_limite / sqrt(2),
      # Valores N/A ou vazios: converter para NA
      resultados_metais[[metal_col]] %in% c("N/A", "", NA) ~ NA_real_,
      # Outros valores: converter para numérico
      TRUE ~ as.numeric(resultados_metais[[metal_col]])
    )
    
    # Adicionar atributos para documentar o tratamento
    attr(resultados_metais[[metal_col]], "limite_lq") <- lq_limite
    attr(resultados_metais[[metal_col]], "tratamento_lq") <- "lq_sqrt2"
    attr(resultados_metais[[metal_col]], "valor_substituicao") <- lq_limite / sqrt(2)
  }
}

# Criar dataset integrado
dados_imasul <- resultados_metais %>%
  left_join(
    pontos_metais,
    by = c("codigo_imasul" = "CODIGO_DO_PONTO")
  )

# Salvar datasets no pacote
usethis::use_data(resultados_metais, overwrite = TRUE)
usethis::use_data(pontos_metais, overwrite = TRUE) 
usethis::use_data(dados_imasul, overwrite = TRUE)

message("Datasets criados com sucesso!")
message("- resultados_metais: ", nrow(resultados_metais), " registros")
message("- pontos_metais: ", nrow(pontos_metais), " pontos")
message("- dados_imasul: ", nrow(dados_imasul), " registros integrados")

# Relatório do tratamento de <LQ
message("\n=== TRATAMENTO DE VALORES <LQ ===")
message("Método aplicado: LQ/√2 (estatisticamente robusto)")
message("Valores de substituição por metal:")

for (metal_col in names(limites_lq)) {
  if (metal_col %in% colnames(resultados_metais)) {
    lq_original <- limites_lq[[metal_col]]
    valor_subst <- lq_original / sqrt(2)
    message(sprintf("- %s: <LQ substituído por %.6f mg/L (LQ=%.6f)", 
                   gsub("_total_mg_L_.*", "", metal_col), valor_subst, lq_original))
  }
}
