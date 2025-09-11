#' Funções para Gerenciamento e Manipulação de Dados
#'
#' Este arquivo contém funções relacionadas ao gerenciamento e manipulação dos dados que serão utilizados no pacote.
#' 
#' @name data
#' @import dplyr
#' @import tidyr
#' @export
#'
#' @examples
#' # Exemplo de uso das funções
#' dados <- carregar_dados("caminho/para/o/arquivo.csv")
#' dados_processados <- processar_dados(dados)

carregar_dados <- function(caminho) {
  # Função para carregar dados de um arquivo CSV
  dados <- read.csv(caminho)
  return(dados)
}

processar_dados <- function(dados) {
  # Função para processar dados
  dados_processados <- dados %>%
    filter(!is.na(coluna_de_interesse)) %>%
    mutate(nova_coluna = coluna_existente * 2)
  return(dados_processados)
}