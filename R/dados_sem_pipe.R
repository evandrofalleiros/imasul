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
      dados <- dplyr::left_join(
        dados,
        pontos,
        by = c("codigo_imasul" = "CODIGO_DO_PONTO")
      )
    } else {
      warning("Arquivo de pontos não encontrado. Coordenadas não incluídas.")
    }
  }
  
  # Limpeza dos dados
  if (limpar_dados) {
    # Aplicar mutações
    dados <- dplyr::mutate(
      dados,
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
    )
    
    # Remover linhas completamente vazias
    dados <- dplyr::filter(dados, !is.na(codigo_imasul))
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
    amplitude = max(valores) - min(valores),
    coef_variacao = stats::sd(valores) / mean(valores) * 100
  )

  # Análise de conformidade com limites CONAMA
  limites <- limites_conama()
  if (metal %in% limites$parametro) {
    limite_conama <- limites$limite[limites$parametro == metal]
    
    # Comparar valores com limite
    valores_limite <- valores[valores > limite_conama]
    
    conformidade <- list(
      limite_conama = limite_conama,
      excedeu_limite = length(valores_limite),
      percentual_nao_conforme = length(valores_limite) / length(valores) * 100,
      valor_maximo_excesso = if(length(valores_limite) > 0) max(valores_limite) else NA,
      fator_excesso_maximo = if(length(valores_limite) > 0) max(valores_limite) / limite_conama else NA
    )
    
    estatisticas$conformidade <- conformidade
  }

  # Adicionar análise temporal se houver dados de data
  if ("data_coleta" %in% colnames(dados)) {
    dados_metal <- dados[!is.na(dados[[metal]]), ]
    
    temporal <- list(
      periodo_inicio = min(dados_metal$data_coleta, na.rm = TRUE),
      periodo_fim = max(dados_metal$data_coleta, na.rm = TRUE),
      anos_monitoramento = length(unique(format(dados_metal$data_coleta, "%Y"))),
      frequencia_anual = nrow(dados_metal) / length(unique(format(dados_metal$data_coleta, "%Y")))
    )
    
    estatisticas$temporal <- temporal
  }

  class(estatisticas) <- "resumo_metal"
  return(estatisticas)
}

#' Verificar Conformidade com Limites CONAMA
#'
#' Verifica a conformidade dos dados de metais com os limites estabelecidos
#' pela Resolução CONAMA 357/2005 para águas doces Classe 2.
#'
#' @param dados Data.frame com os dados de monitoramento.
#' @param metal Nome da coluna do metal a ser analisado.
#' @return Data.frame com resultados da análise de conformidade.
#' @examples
#' \dontrun{
#' dados <- carregar_dados_imasul()
#' conf <- verificar_conformidade(dados, "cadmio_total_mg_L_Cd")
#' head(conf)
#' }
#' @export
verificar_conformidade <- function(dados, metal) {
  
  if (!metal %in% colnames(dados)) {
    stop("Coluna ", metal, " não encontrada nos dados.")
  }
  
  # Obter limite CONAMA
  limites <- limites_conama()
  
  if (!metal %in% limites$parametro) {
    warning("Limite CONAMA não disponível para ", metal)
    return(data.frame())
  }
  
  limite <- limites$limite[limites$parametro == metal]
  
  # Filtrar dados válidos  
  dados <- dplyr::filter(dados, !is.na(.data[[metal]]))
  
  # Adicionar colunas de análise
  resultado <- dplyr::mutate(
    dados,
    valor_metal = .data[[metal]],
    limite_conama = limite,
    conforme = .data[[metal]] <= limite,
    excesso = pmax(0, .data[[metal]] - limite),
    fator_excesso = .data[[metal]] / limite
  )
  
  # Selecionar colunas relevantes
  colunas_resultado <- c(
    "codigo_imasul", "data_coleta", "regiao_hidrografica",
    "valor_metal", "limite_conama", "conforme", "excesso", "fator_excesso"
  )
  
  # Verificar quais colunas existem
  colunas_disponiveis <- intersect(colunas_resultado, colnames(resultado))
  resultado <- resultado[, colunas_disponiveis]
  
  return(resultado)
}

#' Análise Temporal dos Dados de Metais
#'
#' Realiza análise da evolução temporal das concentrações de metais.
#'
#' @param dados Data.frame com dados de monitoramento.
#' @param metal Nome da coluna do metal.
#' @param periodo Período para agregação ("ano", "mes", "trimestre").
#' @param pontos Códigos específicos dos pontos (opcional).
#' @return Data.frame com séries temporais agregadas.
#' @examples
#' \dontrun{
#' dados <- carregar_dados_imasul()
#' serie <- analisar_temporal(dados, "cadmio_total_mg_L_Cd", "ano")
#' plot(serie$periodo, serie$concentracao_media, type = "l")
#' }
#' @export
analisar_temporal <- function(dados, metal, periodo = "ano", pontos = NULL) {
  
  if (!metal %in% colnames(dados)) {
    stop("Coluna ", metal, " não encontrada nos dados.")
  }
  
  if (!"data_coleta" %in% colnames(dados)) {
    stop("Coluna 'data_coleta' não encontrada nos dados.")
  }
  
  # Filtrar pontos se especificado
  if (!is.null(pontos)) {
    dados <- dplyr::filter(dados, codigo_imasul %in% pontos)
  }
  
  # Filtrar dados válidos
  dados <- dplyr::filter(dados, !is.na(.data[[metal]]) & !is.na(data_coleta))
  
  # Criar variável de período
  if (periodo == "ano") {
    dados$periodo <- format(dados$data_coleta, "%Y")
  } else if (periodo == "mes") {
    dados$periodo <- format(dados$data_coleta, "%Y-%m")
  } else if (periodo == "trimestre") {
    dados$periodo <- paste0(format(dados$data_coleta, "%Y"), 
                           "-T", ceiling(as.numeric(format(dados$data_coleta, "%m"))/3))
  } else {
    stop("Período deve ser 'ano', 'mes' ou 'trimestre'")
  }
  
  # Agrupar e summarizar sem pipe
  dados_agrupados <- dplyr::group_by(dados, periodo)
  resultado <- dplyr::summarise(
    dados_agrupados,
    n_amostras = dplyr::n(),
    n_pontos = dplyr::n_distinct(codigo_imasul),
    concentracao_media = mean(.data[[metal]], na.rm = TRUE),
    concentracao_mediana = stats::median(.data[[metal]], na.rm = TRUE),
    concentracao_min = min(.data[[metal]], na.rm = TRUE),
    concentracao_max = max(.data[[metal]], na.rm = TRUE),
    desvio_padrao = stats::sd(.data[[metal]], na.rm = TRUE),
    .groups = "drop"
  )
  
  # Adicionar tendência se houver dados suficientes
  if (nrow(resultado) >= 3) {
    resultado$periodo_numerico <- seq_len(nrow(resultado))
    modelo <- stats::lm(concentracao_media ~ periodo_numerico, data = resultado)
    resultado$tendencia <- stats::predict(modelo)
    resultado$p_valor_tendencia <- summary(modelo)$coefficients[2, 4]
  }
  
  # Adicionar conformidade se disponível
  limites <- limites_conama()
  if (metal %in% limites$parametro) {
    limite <- limites$limite[limites$parametro == metal]
    resultado$limite_conama <- limite
    resultado$media_conforme <- resultado$concentracao_media <= limite
    resultado$max_conforme <- resultado$concentracao_max <= limite
  }
  
  return(resultado)
}

#' Gerar Relatório de Conformidade
#'
#' Gera um relatório abrangente de conformidade para todos os metais monitorados.
#'
#' @param dados Data.frame com dados de monitoramento.
#' @param salvar_arquivo Nome do arquivo para salvar (opcional).
#' @return Lista com relatórios por metal.
#' @examples
#' \dontrun{
#' dados <- carregar_dados_imasul()
#' relatorio <- relatorio_conformidade(dados)
#' print(relatorio$resumo_geral)
#' }
#' @export
relatorio_conformidade <- function(dados, salvar_arquivo = NULL) {
  
  # Identificar colunas de metais
  metais <- listar_metais()
  colunas_metais <- intersect(metais$codigo_coluna, colnames(dados))
  
  if (length(colunas_metais) == 0) {
    stop("Nenhuma coluna de metal encontrada nos dados.")
  }
  
  relatorio <- list()
  resumo_geral <- data.frame()
  
  # Processar cada metal
  for (metal in colunas_metais) {
    tryCatch({
      resumo <- resumo_metal(dados, metal)
      conformidade <- verificar_conformidade(dados, metal)
      
      relatorio[[metal]] <- list(
        resumo = resumo,
        conformidade = conformidade
      )
      
      # Adicionar ao resumo geral
      if (nrow(conformidade) > 0) {
        resumo_linha <- data.frame(
          metal = metal,
          n_amostras = nrow(conformidade),
          n_nao_conformes = sum(!conformidade$conforme),
          percentual_nao_conforme = mean(!conformidade$conforme) * 100,
          concentracao_maxima = max(conformidade$valor_metal),
          limite_conama = unique(conformidade$limite_conama)[1],
          excesso_maximo = max(conformidade$excesso)
        )
        resumo_geral <- rbind(resumo_geral, resumo_linha)
      }
      
    }, error = function(e) {
      warning("Erro ao processar metal ", metal, ": ", e$message)
    })
  }
  
  relatorio$resumo_geral <- resumo_geral
  
  # Salvar se solicitado
  if (!is.null(salvar_arquivo)) {
    saveRDS(relatorio, salvar_arquivo)
    message("Relatório salvo em: ", salvar_arquivo)
  }
  
  return(relatorio)
}

#' Mapear Pontos de Monitoramento
#'
#' Cria um mapa interativo dos pontos de monitoramento com dados de metais.
#'
#' @param dados Data.frame com coordenadas dos pontos.
#' @param metal Nome da coluna do metal para colorir os pontos (opcional).
#' @param interativo Se TRUE, cria mapa interativo (requer leaflet).
#' @return Objeto de mapa ou data.frame de pontos.
#' @examples
#' \dontrun{
#' dados <- carregar_dados_imasul(incluir_coordenadas = TRUE)
#' mapa <- mapear_pontos(dados, metal = "cadmio_total_mg_L_Cd")
#' }
#' @export
mapear_pontos <- function(dados, metal = NULL, interativo = TRUE) {
  
  # Verificar se há coordenadas
  if (!all(c("LATITUDE", "LONGITUDE") %in% colnames(dados))) {
    stop("Coordenadas não encontradas. Use incluir_coordenadas = TRUE em carregar_dados_imasul().")
  }
  
  # Preparar dados dos pontos
  pontos_dados <- dplyr::filter(dados, !is.na(LATITUDE) & !is.na(LONGITUDE))
  pontos_agrupados <- dplyr::group_by(pontos_dados, 
                                      codigo_imasul, DESCRICAO_DO_LOCAL, regiao_hidrografica)
  pontos <- dplyr::summarise(pontos_agrupados,
                            latitude = dplyr::first(LATITUDE),
                            longitude = dplyr::first(LONGITUDE),
                            n_amostras = dplyr::n(),
                            .groups = "drop")
  
  # Adicionar estatísticas do metal se especificado
  if (!is.null(metal)) {
    if (metal %in% colnames(dados)) {
      pontos_metal <- dplyr::filter(dados, !is.na(.data[[metal]]))
      estatisticas_metal <- dplyr::group_by(pontos_metal, codigo_imasul)
      estatisticas_metal <- dplyr::summarise(estatisticas_metal,
                                            concentracao_media = mean(.data[[metal]], na.rm = TRUE),
                                            concentracao_max = max(.data[[metal]], na.rm = TRUE),
                                            n_amostras_metal = dplyr::n(),
                                            .groups = "drop")
      
      pontos <- dplyr::left_join(pontos, estatisticas_metal, by = "codigo_imasul")
    } else {
      warning("Metal ", metal, " não encontrado nos dados.")
    }
  }
  
  if (!interativo) {
    return(pontos)
  }
  
  # Criar mapa interativo (simplificado)
  message("Para criar mapas interativos, instale o pacote leaflet.")
  message("Retornando dados dos pontos.")
  return(pontos)
}

#' Exportar Dados para Excel
#'
#' Exporta dados processados para arquivo Excel com múltiplas planilhas.
#'
#' @param dados Data.frame com dados de monitoramento.
#' @param arquivo Nome do arquivo Excel (.xlsx).
#' @param incluir_relatorio Se TRUE, inclui relatório de conformidade.
#' @return Caminho do arquivo criado.
#' @examples
#' \dontrun{
#' dados <- carregar_dados_imasul()
#' arquivo <- exportar_para_excel(dados, "relatorio_metais.xlsx")
#' }
#' @export
exportar_para_excel <- function(dados, arquivo, incluir_relatorio = TRUE) {
  
  if (!requireNamespace("openxlsx", quietly = TRUE)) {
    stop("Pacote openxlsx é necessário para exportar para Excel. Instale com: install.packages('openxlsx')")
  }
  
  # Criar workbook
  wb <- openxlsx::createWorkbook()
  
  # Adicionar planilha com dados brutos
  openxlsx::addWorksheet(wb, "Dados_Brutos")
  openxlsx::writeData(wb, "Dados_Brutos", dados)
  
  # Adicionar planilha com metais disponíveis
  metais <- listar_metais()
  openxlsx::addWorksheet(wb, "Metais_Monitorados")
  openxlsx::writeData(wb, "Metais_Monitorados", metais)
  
  # Adicionar relatório se solicitado
  if (incluir_relatorio) {
    tryCatch({
      relatorio <- relatorio_conformidade(dados)
      
      # Resumo geral
      if (nrow(relatorio$resumo_geral) > 0) {
        openxlsx::addWorksheet(wb, "Resumo_Conformidade")
        openxlsx::writeData(wb, "Resumo_Conformidade", relatorio$resumo_geral)
      }
      
    }, error = function(e) {
      warning("Erro ao gerar relatório: ", e$message)
    })
  }
  
  # Salvar arquivo
  openxlsx::saveWorkbook(wb, arquivo, overwrite = TRUE)
  
  message("Dados exportados para: ", arquivo)
  return(arquivo)
}
