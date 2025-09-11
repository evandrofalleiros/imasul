#' @importFrom magrittr %>%
#' @export
magrittr::`%>%`

#' Dados de Monitoramento de Metais em Águas - Mato Grosso do Sul
#'
#' Esta função carrega os dados brutos de monitoramento de metais em águas
#' superficiais coletados pelo Instituto de Meio Ambiente de Mato Grosso do Sul (IMASUL).
#'
#' @param caminho_arquivo Caminho para o arquivo CSV dos dados (opcional).
#'   Se não fornecido, tenta carregar dos dados incluídos no pacote.
#' @param incluir_coordenadas Logical. Se TRUE, inclui dados geográficos dos pontos.
#' @param limpar_dados Logical. Se TRUE, realiza limpeza básica dos dados.
#' @return Um data.frame com os dados de monitoramento.
#' @examples
#' \dontrun{
#' # Carregar dados incluídos no pacote
#' dados <- carregar_dados_imasul()
#'
#' # Carregar com coordenadas dos pontos
#' dados_completos <- carregar_dados_imasul(incluir_coordenadas = TRUE)
#'
#' # Visualizar estrutura dos dados
#' str(dados)
#' head(dados)
#' }
#' @export
carregar_dados_imasul <- function(caminho_arquivo = NULL, incluir_coordenadas = TRUE, limpar_dados = TRUE) {
  
  # Carregar dados de monitoramento
  if (is.null(caminho_arquivo)) {
    # Tentar carregar do pacote primeiro
    caminho_arquivo <- system.file("csv", "resultados_metais_2011_2022.csv", package = "imasul")
    
    if (!file.exists(caminho_arquivo)) {
      # Fallback para caminho local
      caminho_arquivo <- file.path("csv", "resultados_metais_2011_2022.csv")
    }
  }
  
  if (!file.exists(caminho_arquivo)) {
    stop("Arquivo de dados não encontrado: ", caminho_arquivo)
  }
  
  # Carregar dados principais
  dados <- readr::read_csv(
    caminho_arquivo,
    col_types = readr::cols(
      regiao_hidrografica = readr::col_character(),
      codigo_imasul = readr::col_character(),
      data_coleta = readr::col_date(format = "%d/%m/%Y"),
      hora = readr::col_time(format = "%H:%M"),
      .default = readr::col_character()
    ),
    locale = readr::locale(encoding = "UTF-8")
  )
  
  # Carregar dados dos pontos se solicitado
  if (incluir_coordenadas) {
    caminho_pontos <- system.file("csv", "pontos_resultados_metais.csv", package = "imasul")
    
    if (!file.exists(caminho_pontos)) {
      caminho_pontos <- file.path("csv", "pontos_resultados_metais.csv")
    }
    
    if (file.exists(caminho_pontos)) {
      pontos <- readr::read_csv(
        caminho_pontos,
        col_types = readr::cols(
          CODIGO_DO_PONTO = readr::col_character(),
          LATITUDE = readr::col_double(),
          LONGITUDE = readr::col_double(),
          DESCRICAO_DO_LOCAL = readr::col_character(),
          REGIAO_HIDROGRAFICA = readr::col_character()
        ),
        locale = readr::locale(encoding = "UTF-8")
      )
      
      # Fazer join com os dados principais
      dados <- dados %>%
        dplyr::left_join(
          pontos,
          by = c("codigo_imasul" = "CODIGO_DO_PONTO")
        )
    } else {
      warning("Arquivo de pontos não encontrado. Coordenadas não incluídas.")
    }
  }
  
  # Limpeza dos dados
  if (limpar_dados) {
    dados <- dados %>%
      dplyr::mutate(
        # Garantir que data_coleta seja Date
        data_coleta = as.Date(data_coleta),
        
        # Remover espaços em branco das colunas de texto
        dplyr::across(where(is.character), ~trimws(.)),
        
        # Converter valores de metais para numérico, tratando <LQ e N/A
        dplyr::across(
          dplyr::contains("_total_mg_L"), 
          ~dplyr::case_when(
            . %in% c("<LQ", "N/A", "") ~ NA_real_,
            TRUE ~ as.numeric(.)
          )
        )
      ) %>%
      # Remover linhas completamente vazias
      dplyr::filter(!is.na(codigo_imasul))
  }

  message("Dados carregados com sucesso! ", nrow(dados), " registros encontrados.")
  return(dados)
}

#' Resumo Estatístico dos Dados de Metais
#'
#' Fornece um resumo estatístico completo dos dados de monitoramento de metais.
#'
#' @param dados Data.frame retornado por carregar_dados_imasul().
#' @param metal Nome da coluna do metal para análise (ex: "cadmio_total_mg_L_Cd").
#' @return Uma lista com estatísticas descritivas e análise de conformidade.
#' @examples
#' \dontrun{
#' dados <- carregar_dados_imasul()
#' resumo <- resumo_metal(dados, "cadmio_total_mg_L_Cd")
#' print(resumo)
#' }
#' @export
resumo_metal <- function(dados, metal) {

  if (!metal %in% colnames(dados)) {
    stop("Coluna ", metal, " não encontrada nos dados.")
  }

  valores <- dados[[metal]]
  valores <- valores[!is.na(valores)]

  if (length(valores) == 0) {
    stop("Nenhum valor válido encontrado para ", metal)
  }

  # Estatísticas básicas
  estatisticas <- list(
    metal = metal,
    n_amostras = length(valores),
    n_pontos = length(unique(dados$codigo_imasul[!is.na(dados[[metal]])])),
    media = mean(valores),
    mediana = stats::median(valores),
    desvio_padrao = stats::sd(valores),
    minimo = min(valores),
    maximo = max(valores),
    percentil_25 = stats::quantile(valores, 0.25),
    percentil_75 = stats::quantile(valores, 0.75),
    percentil_95 = stats::quantile(valores, 0.95),
    assimetria = moments::skewness(valores),
    curtose = moments::kurtosis(valores)
  )

  # Análise de conformidade CONAMA
  limites <- limites_conama()
  limite_conama <- limites$limite_mg_L[limites$coluna_dados == metal]

  if (length(limite_conama) > 0) {
    estatisticas$limite_conama <- limite_conama
    estatisticas$amostras_acima_limite <- sum(valores > limite_conama)
    estatisticas$percentual_acima_limite <- (estatisticas$amostras_acima_limite / length(valores)) * 100
    estatisticas$conforme_conama <- estatisticas$percentual_acima_limite <= 10  # Critério básico
  }

  return(estatisticas)
}

#' Limites CONAMA para Metais
#'
#' Retorna os limites estabelecidos pela Resolução CONAMA nº 357/2005
#' para metais em águas doces classe 1.
#'
#' @return Um data.frame com os limites por metal.
#' @examples
#' \dontrun{
#' limites <- limites_conama()
#' print(limites)
#' View(limites)
#' }
#' @export
limites_conama <- function() {

  limites <- data.frame(
    metal = c("alumínio", "bário", "cádmio", "chumbo", "cobre",
              "cromo", "ferro", "manganes", "mercurio",
              "níquel", "zinco"),
    coluna_dados = c("aluminio_total_mg_L_Al", "bario_total_mg_L_Ba",
                    "cadmio_total_mg_L_Cd", "chumbo_total_mg_L_Pb",
                    "cobre_total_mg_L_Cu", "cromo_total_mg_L_Cr",
                    "ferro_total_mg_L_Fe", "manganes_total_mg_L_Mn",
                    "mercurio_total_mg_L_Hg", "niquel_total_mg_L_Ni",
                    "zinco_total_mg_L_Zn"),
    limite_mg_L = c(0.1, 0.7, 0.001, 0.01, 0.009, 0.05, 0.3, 0.1, 0.0002, 0.025, 0.18),
    classe_agua = rep("Doce Classe 1", 11),
    resolucao = rep("CONAMA 357/2005", 11)
  )

  return(limites)
}

#' Verificar Conformidade com CONAMA
#'
#' Verifica se os valores de um metal estão em conformidade com os limites CONAMA
#' e adiciona colunas de análise ao data.frame.
#'
#' @param dados Data.frame retornado por carregar_dados_imasul().
#' @param metal Nome da coluna do metal.
#' @return Data.frame com colunas adicionais de conformidade.
#' @examples
#' \dontrun{
#' dados <- carregar_dados_imasul()
#' dados_conforme <- verificar_conformidade(dados, "cadmio_total_mg_L_Cd")
#' table(dados_conforme$status_conama)
#' }
#' @export
verificar_conformidade <- function(dados, metal) {

  limites <- limites_conama()
  limite <- limites$limite_mg_L[limites$coluna_dados == metal]

  if (length(limite) == 0) {
    stop("Limite CONAMA não encontrado para ", metal)
  }

  dados <- dados %>%
    dplyr::mutate(
      !!paste0("limite_", metal) := limite,
      !!paste0("status_", metal) := dplyr::case_when(
        is.na(.data[[metal]]) ~ "Não analisado",
        .data[[metal]] <= limite ~ "Conforme",
        .data[[metal]] > limite ~ "Não conforme"
      ),
      !!paste0("excesso_", metal) := dplyr::case_when(
        is.na(.data[[metal]]) ~ NA_real_,
        .data[[metal]] > limite ~ .data[[metal]] - limite,
        TRUE ~ 0
      )
    )

  return(dados)
}

#' Análise Temporal de Metais
#'
#' Realiza análise temporal dos dados de metais, incluindo tendências e sazonalidade.
#'
#' @param dados Data.frame retornado por carregar_dados_imasul().
#' @param metal Nome da coluna do metal.
#' @param agrupamento Tipo de agrupamento temporal ("mes", "ano", "semestre").
#' @return Data.frame com análise temporal.
#' @examples
#' \dontrun{
#' dados <- carregar_dados_imasul()
#' temporal <- analisar_temporal(dados, "cadmio_total_mg_L_Cd", "ano")
#' plot(temporal$data_agrupada, temporal$media, type = "l")
#' }
#' @export
analisar_temporal <- function(dados, metal, agrupamento = "mes") {

  if (!metal %in% colnames(dados)) {
    stop("Coluna ", metal, " não encontrada nos dados.")
  }

  # Criar coluna de agrupamento temporal
  dados_temp <- dados %>%
    dplyr::mutate(
      ano = lubridate::year(data_coleta),
      mes = lubridate::month(data_coleta),
      semestre = dplyr::case_when(
        mes <= 6 ~ 1,
        TRUE ~ 2
      )
    )

  # Definir agrupamento
  if (agrupamento == "ano") {
    grupo <- "ano"
  } else if (agrupamento == "mes") {
    grupo <- c("ano", "mes")
  } else if (agrupamento == "semestre") {
    grupo <- c("ano", "semestre")
  } else {
    stop("Agrupamento deve ser 'ano', 'mes' ou 'semestre'")
  }

  # Agregar dados
  resultado <- dados_temp %>%
    dplyr::group_by(dplyr::across(dplyr::all_of(grupo))) %>%
    dplyr::summarise(
      media = mean(.data[[metal]], na.rm = TRUE),
      mediana = stats::median(.data[[metal]], na.rm = TRUE),
      maximo = max(.data[[metal]], na.rm = TRUE),
      minimo = min(.data[[metal]], na.rm = TRUE),
      n_amostras = sum(!is.na(.data[[metal]])),
      n_pontos = dplyr::n_distinct(codigo_imasul[!is.na(.data[[metal]])]),
      .groups = "drop"
    )

  # Adicionar data agrupada para plotagem
  if (agrupamento == "ano") {
    resultado <- resultado %>%
      dplyr::mutate(data_agrupada = as.Date(paste0(ano, "-01-01")))
  } else if (agrupamento == "mes") {
    resultado <- resultado %>%
      dplyr::mutate(data_agrupada = as.Date(paste(ano, mes, "01", sep = "-")))
  } else {
    resultado <- resultado %>%
      dplyr::mutate(data_agrupada = as.Date(paste0(ano, "-", ifelse(semestre == 1, "01", "07"), "-01")))
  }

  return(resultado)
}

#' Mapear Pontos de Monitoramento
#'
#' Prepara dados para mapeamento dos pontos de monitoramento.
#'
#' @param dados Data.frame retornado por carregar_dados_imasul(incluir_coordenadas = TRUE).
#' @param metal Nome da coluna do metal (opcional, para incluir estatísticas).
#' @return Data.frame com coordenadas e estatísticas por ponto.
#' @examples
#' \dontrun{
#' dados <- carregar_dados_imasul(incluir_coordenadas = TRUE)
#' pontos <- mapear_pontos(dados, "cadmio_total_mg_L_Cd")
#' # Usar com sf ou leaflet para visualização
#' }
#' @export
mapear_pontos <- function(dados, metal = NULL) {
  
  # Verificar se coordenadas estão disponíveis
  if (!all(c("LATITUDE", "LONGITUDE") %in% colnames(dados))) {
    stop("Dados não contêm coordenadas. Use carregar_dados_imasul(incluir_coordenadas = TRUE)")
  }
  
  # Agrupar por ponto
  pontos <- dados %>%
    dplyr::filter(!is.na(LATITUDE) & !is.na(LONGITUDE)) %>%
    dplyr::group_by(codigo_imasul, DESCRICAO_DO_LOCAL, regiao_hidrografica) %>%
    dplyr::summarise(
      latitude = dplyr::first(LATITUDE),
      longitude = dplyr::first(LONGITUDE),
      n_amostras = dplyr::n(),
      data_primeira = min(data_coleta, na.rm = TRUE),
      data_ultima = max(data_coleta, na.rm = TRUE),
      .groups = "drop"
    )

  # Adicionar estatísticas do metal se especificado
  if (!is.null(metal) && metal %in% colnames(dados)) {
    estatisticas_metal <- dados %>%
      dplyr::filter(!is.na(.data[[metal]])) %>%
      dplyr::group_by(codigo_imasul) %>%
      dplyr::summarise(
        !!paste0("media_", metal) := mean(.data[[metal]], na.rm = TRUE),
        !!paste0("mediana_", metal) := median(.data[[metal]], na.rm = TRUE),
        !!paste0("min_", metal) := min(.data[[metal]], na.rm = TRUE),
        !!paste0("max_", metal) := max(.data[[metal]], na.rm = TRUE),
        !!paste0("n_amostras_", metal) := dplyr::n(),
        .groups = "drop"
      )

    pontos <- pontos %>%
      dplyr::left_join(estatisticas_metal, by = "codigo_imasul")
  }

  return(pontos)
}

#' Relatório de Conformidade
#'
#' Gera um relatório completo de conformidade com os limites CONAMA
#' para todos os metais monitorados.
#'
#' @param dados Data.frame retornado por carregar_dados_imasul().
#' @return Lista com relatório completo de conformidade.
#' @examples
#' \dontrun{
#' dados <- carregar_dados_imasul()
#' relatorio <- relatorio_conformidade(dados)
#' print(relatorio$resumo_geral)
#' }
#' @export
relatorio_conformidade <- function(dados) {

  limites <- limites_conama()
  metais_analisados <- limites$coluna_dados[limites$coluna_dados %in% colnames(dados)]

  relatorio <- list()
  relatorio$metais_analisados <- metais_analisados
  relatorio$data_geracao <- Sys.Date()

  # Análise por metal
  analises <- list()
  for (metal in metais_analisados) {
    valores <- dados[[metal]]
    valores <- valores[!is.na(valores)]

    if (length(valores) > 0) {
      limite <- limites$limite_mg_L[limites$coluna_dados == metal]
      acima_limite <- sum(valores > limite)
      percentual_acima <- (acima_limite / length(valores)) * 100

      analises[[metal]] <- list(
        metal = metal,
        n_amostras = length(valores),
        limite_conama = limite,
        amostras_acima = acima_limite,
        percentual_acima = percentual_acima,
        conforme = percentual_acima <= 10,
        media = mean(valores),
        maximo = max(valores)
      )
    }
  }

  relatorio$analises_por_metal <- analises

  # Resumo geral
  relatorio$resumo_geral <- list(
    total_metais = length(metais_analisados),
    metais_conformes = sum(sapply(analises, function(x) x$conforme)),
    metais_nao_conformes = sum(!sapply(analises, function(x) x$conforme)),
    percentual_conformidade = (sum(sapply(analises, function(x) x$conforme)) / length(analises)) * 100
  )

  return(relatorio)
}
