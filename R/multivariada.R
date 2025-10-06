#' Preparar dados para análise multivariada (PCA/MANOVA)
#'
#' Função utilitária para preparar a matriz de metais e o vetor de grupos
#' a partir do data.frame unificado retornado por `carregar_dados_imasul()`.
#'
#' Operações realizadas:
#' - Seleção das colunas de metais
#' - Tratamento de "<LQ" como NA (caso ainda existam valores textuais)
#' - Conversão segura para numérico
#' - Agregação por ponto (média por `col_codigo`), preservando `col_regiao`
#' - Filtro de linhas com muitos NAs em metais
#' - Imputação simples (opcional) por média ou mediana da coluna
#'
#' @param dados Data.frame com dados unificados (ex.: `carregar_dados_imasul(...)`).
#' @param metais Vetor com nomes de colunas dos metais. Padrão: `listar_metais()$coluna_dados`.
#' @param col_codigo Nome da coluna com o identificador do ponto (default `"codigo_imasul"`).
#' @param col_regiao Nome da coluna com a região/grupo (default `"regiao_hidrografica"`).
#' @param max_na_metais Máximo de NAs permitidos por linha (default: 5).
#' @param imputacao Estratégia de imputação: `"media"`, `"mediana"` ou `NULL` para não imputar.
#'
#' @return Lista com:
#' - `dados`: data.frame preparado e (se aplicável) agregado por ponto
#' - `matriz`: data.frame apenas com as colunas de metais; rownames = ponto
#' - `grupos`: fator com os grupos (regiões)
#' - `metais`: vetor de colunas de metais efetivamente usadas
#'
#' @examples
#' \dontrun{
#' dados <- carregar_dados_imasul(incluir_coordenadas = TRUE)
#' prep <- preparar_dados_multivariados(dados, col_codigo = "codigo_imasul", col_regiao = "REGIAO_HIDROGRAFICA")
#' str(prep)
#' }
#' @export
preparar_dados_multivariados <- function(
  dados,
  metais = NULL,
  col_codigo = "codigo_imasul",
  col_regiao = "regiao_hidrografica",
  max_na_metais = 5,
  imputacao = c("media", "mediana", NULL)
) {
  stopifnot(is.data.frame(dados))
  if (is.null(metais)) {
    metais <- tryCatch(listar_metais()$coluna_dados, error = function(...) NULL)
  }
  metais <- intersect(metais %||% character(), names(dados))
  if (length(metais) == 0) stop("Nenhuma coluna de metais encontrada nos dados.")
  if (!col_codigo %in% names(dados)) stop("Coluna de código não encontrada: ", col_codigo)
  if (!col_regiao %in% names(dados)) stop("Coluna de região não encontrada: ", col_regiao)

  # Tratar "<LQ" como NA e converter para numérico, sem sobrescrever tratamentos prévios numéricos
  dados[metais] <- lapply(dados[metais], function(x) {
    if (is.character(x)) {
      x[x == "<LQ"] <- NA
      suppressWarnings(as.numeric(x))
    } else {
      as.numeric(x)
    }
  })

  # Agregar por ponto caso existam múltiplas amostras por código
  multi_por_ponto <- any(table(dados[[col_codigo]]) > 1)
  if (multi_por_ponto) {
    dados <- dplyr::group_by(dados, .data[[col_codigo]])
    dados <- dplyr::summarise(
      dados,
      dplyr::across(dplyr::all_of(metais), ~mean(.x, na.rm = TRUE)),
      !!col_regiao := dplyr::first(.data[[col_regiao]]),
      .groups = "drop"
    )
  }

  # Filtrar linhas com muitos NAs em metais e sem região
  keep_mask <- rowSums(is.na(dados[, metais, drop = FALSE])) < max_na_metais & !is.na(dados[[col_regiao]]) & dados[[col_regiao]] != ""
  dados <- dados[keep_mask, , drop = FALSE]

  # Imputação simples
  imputacao <- match.arg(as.character(imputacao), c("media", "mediana"), several.ok = FALSE)
  if (!is.na(imputacao)) {
    for (m in metais) {
      if (imputacao == "media") {
        val <- mean(dados[[m]], na.rm = TRUE)
      } else if (imputacao == "mediana") {
        val <- stats::median(dados[[m]], na.rm = TRUE)
      }
      dados[[m]][is.na(dados[[m]])] <- val
    }
  }

  # Construir matriz e grupos
  matriz <- dados[, metais, drop = FALSE]
  rownames(matriz) <- dados[[col_codigo]]
  grupos <- factor(dados[[col_regiao]])

  list(dados = dados, matriz = matriz, grupos = grupos, metais = metais)
}

`%||%` <- function(a, b) if (!is.null(a)) a else b

