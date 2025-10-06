#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @export
magrittr::`%>%`

#' Listar Metais Disponíveis
#'
#' Retorna uma lista dos metais disponíveis no dataset com seus nomes
#' padronizados e códigos das colunas.
#'
#' @return Um data.frame com informações dos metais disponíveis.
#' @examples
#' \dontrun{
#' metais <- listar_metais()
#' print(metais)
#' }
#' @export
listar_metais <- function() {
  data.frame(
    simbolo = c("Al", "Ba", "Cd", "Pb", "Cu", "Cr", "Fe", "Mn", "Hg", "Ni", "Zn"),
    nome = c("Alumínio", "Bário", "Cádmio", "Chumbo", "Cobre", 
             "Cromo", "Ferro", "Manganês", "Mercúrio", "Níquel", "Zinco"),
    coluna_dados = c("aluminio_total_mg_L_Al", "bario_total_mg_L_Ba",
                    "cadmio_total_mg_L_Cd", "chumbo_total_mg_L_Pb",
                    "cobre_total_mg_L_Cu", "cromo_total_mg_L_Cr",
                    "ferro_total_mg_L_Fe", "manganes_total_mg_L_Mn",
                    "mercurio_total_mg_L_Hg", "niquel_total_mg_L_Ni",
                    "zinco_total_mg_L_Zn"),
    stringsAsFactors = FALSE
  )
}

#' Estatísticas Resumidas por Região
#'
#' Calcula estatísticas resumidas dos metais agrupadas por região hidrográfica.
#'
#' @param dados Data.frame retornado por carregar_dados_imasul().
#' @param metal Nome da coluna do metal para análise.
#' @return Data.frame com estatísticas por região.
#' @examples
#' \dontrun{
#' dados <- carregar_dados_imasul()
#' stats_regiao <- estatisticas_por_regiao(dados, "cadmio_total_mg_L_Cd")
#' print(stats_regiao)
#' }
#' @export
estatisticas_por_regiao <- function(dados, metal) {
  
  if (!metal %in% colnames(dados)) {
    stop("Coluna ", metal, " não encontrada nos dados.")
  }
  
  resultado <- dados %>%
    dplyr::filter(!is.na(.data[[metal]])) %>%
    dplyr::group_by(regiao_hidrografica) %>%
    dplyr::summarise(
      n_amostras = dplyr::n(),
      n_pontos = dplyr::n_distinct(codigo_imasul),
      media = mean(.data[[metal]], na.rm = TRUE),
      mediana = stats::median(.data[[metal]], na.rm = TRUE),
      desvio_padrao = stats::sd(.data[[metal]], na.rm = TRUE),
      minimo = min(.data[[metal]], na.rm = TRUE),
      maximo = max(.data[[metal]], na.rm = TRUE),
      percentil_95 = stats::quantile(.data[[metal]], 0.95, na.rm = TRUE),
      .groups = "drop"
    )
  
  # Adicionar análise de conformidade
  limites <- limites_conama()
  limite <- limites$limite_mg_L[limites$coluna_dados == metal]
  
  if (length(limite) > 0) {
    dados_conforme <- dados %>%
      dplyr::filter(!is.na(.data[[metal]])) %>%
      dplyr::group_by(regiao_hidrografica) %>%
      dplyr::summarise(
        amostras_acima_limite = sum(.data[[metal]] > limite),
        percentual_acima_limite = (sum(.data[[metal]] > limite) / dplyr::n()) * 100,
        .groups = "drop"
      )
    
    resultado <- resultado %>%
      dplyr::left_join(dados_conforme, by = "regiao_hidrografica") %>%
      dplyr::mutate(limite_conama = limite)
  }
  
  return(resultado)
}

#' Identificar Pontos Críticos
#'
#' Identifica pontos de monitoramento com maior frequência de não conformidade.
#'
#' @param dados Data.frame retornado por carregar_dados_imasul().
#' @param metal Nome da coluna do metal para análise.
#' @param percentual_minimo Percentual mínimo de não conformidade para ser considerado crítico.
#' @return Data.frame com pontos críticos identificados.
#' @examples
#' \dontrun{
#' dados <- carregar_dados_imasul()
#' criticos <- identificar_pontos_criticos(dados, "ferro_total_mg_L_Fe", 20)
#' print(criticos)
#' }
#' @export
identificar_pontos_criticos <- function(dados, metal, percentual_minimo = 20) {
  
  if (!metal %in% colnames(dados)) {
    stop("Coluna ", metal, " não encontrada nos dados.")
  }
  
  limites <- limites_conama()
  limite <- limites$limite_mg_L[limites$coluna_dados == metal]
  
  if (length(limite) == 0) {
    stop("Limite CONAMA não encontrado para ", metal)
  }
  
  criticos <- dados %>%
    dplyr::filter(!is.na(.data[[metal]])) %>%
    dplyr::group_by(codigo_imasul, regiao_hidrografica) %>%
    dplyr::summarise(
      n_amostras = dplyr::n(),
      media = mean(.data[[metal]], na.rm = TRUE),
      maximo = max(.data[[metal]], na.rm = TRUE),
      amostras_acima_limite = sum(.data[[metal]] > limite),
      percentual_nao_conforme = (sum(.data[[metal]] > limite) / dplyr::n()) * 100,
      data_primeira = min(data_coleta, na.rm = TRUE),
      data_ultima = max(data_coleta, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    dplyr::filter(
      percentual_nao_conforme >= percentual_minimo,
      n_amostras >= 3  # Mínimo de 3 amostras para ser considerado
    ) %>%
    dplyr::arrange(dplyr::desc(percentual_nao_conforme))
  
  # Adicionar coordenadas se disponíveis
  if (all(c("LATITUDE", "LONGITUDE", "DESCRICAO_DO_LOCAL") %in% colnames(dados))) {
    coord <- dados %>%
      dplyr::select(codigo_imasul, LATITUDE, LONGITUDE, DESCRICAO_DO_LOCAL) %>%
      dplyr::distinct()
    
    criticos <- criticos %>%
      dplyr::left_join(coord, by = "codigo_imasul")
  }
  
  criticos <- criticos %>%
    dplyr::mutate(
      limite_conama = limite,
      metal = metal,
      classificacao = dplyr::case_when(
        percentual_nao_conforme >= 50 ~ "Crítico",
        percentual_nao_conforme >= 30 ~ "Alto risco",
        TRUE ~ "Moderado"
      )
    )
  
  return(criticos)
}

#' Exportar Resultados para Excel
#'
#' Exporta os resultados de análise para um arquivo Excel com múltiplas abas.
#'
#' @param dados Data.frame retornado por carregar_dados_imasul().
#' @param arquivo_saida Caminho para o arquivo Excel de saída.
#' @param incluir_graficos Logical. Se TRUE, inclui gráficos básicos.
#' @return Invisível. Cria arquivo Excel com os resultados.
#' @examples
#' \dontrun{
#' dados <- carregar_dados_imasul()
#' exportar_para_excel(dados, "relatorio_imasul.xlsx")
#' }
#' @export
exportar_para_excel <- function(dados, arquivo_saida, incluir_graficos = FALSE) {
  
  if (!requireNamespace("openxlsx", quietly = TRUE)) {
    stop("Pacote 'openxlsx' é necessário para esta função. Instale com: install.packages('openxlsx')")
  }
  
  # Criar workbook
  wb <- openxlsx::createWorkbook()
  
  # Aba 1: Dados brutos
  openxlsx::addWorksheet(wb, "Dados_Brutos")
  openxlsx::writeData(wb, "Dados_Brutos", dados)
  
  # Aba 2: Limites CONAMA
  openxlsx::addWorksheet(wb, "Limites_CONAMA")
  limites <- limites_conama()
  openxlsx::writeData(wb, "Limites_CONAMA", limites)
  
  # Aba 3: Relatório de conformidade
  openxlsx::addWorksheet(wb, "Relatorio_Conformidade")
  relatorio <- relatorio_conformidade(dados)
  
  # Escrever resumo geral
  openxlsx::writeData(wb, "Relatorio_Conformidade", 
                      data.frame(
                        Metrica = names(relatorio$resumo_geral),
                        Valor = unlist(relatorio$resumo_geral)
                      ), startRow = 1)
  
  # Escrever análises por metal
  analises_df <- do.call(rbind, lapply(names(relatorio$analises_por_metal), function(metal) {
    info <- relatorio$analises_por_metal[[metal]]
    data.frame(
      Metal = metal,
      N_Amostras = info$n_amostras,
      Limite_CONAMA = info$limite_conama,
      Amostras_Acima = info$amostras_acima,
      Percentual_Acima = round(info$percentual_acima, 2),
      Conforme = info$conforme,
      Media = round(info$media, 4),
      Maximo = round(info$maximo, 4)
    )
  }))
  
  openxlsx::writeData(wb, "Relatorio_Conformidade", analises_df, startRow = 8)
  
  # Aba 4: Estatísticas por região (exemplo com ferro)
  if ("ferro_total_mg_L_Fe" %in% colnames(dados)) {
    openxlsx::addWorksheet(wb, "Stats_Por_Regiao")
    stats_regiao <- estatisticas_por_regiao(dados, "ferro_total_mg_L_Fe")
    openxlsx::writeData(wb, "Stats_Por_Regiao", stats_regiao)
  }
  
  # Salvar arquivo
  openxlsx::saveWorkbook(wb, arquivo_saida, overwrite = TRUE)
  
  message("Relatório Excel criado: ", arquivo_saida)
  invisible(arquivo_saida)
}
