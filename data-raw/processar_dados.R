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

# Limpar dados de metais
resultados_metais <- resultados_metais %>%
  mutate(
    # Remover espaços em branco das colunas de texto
    across(where(is.character), ~trimws(.)),
    
    # Converter valores de metais para numérico, tratando <LQ e N/A
    across(
      contains("_total_mg_L"), 
      ~case_when(
        . %in% c("<LQ", "N/A", "") ~ NA_real_,
        TRUE ~ as.numeric(.)
      )
    )
  ) %>%
  # Remover linhas completamente vazias
  filter(!is.na(codigo_imasul))

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
