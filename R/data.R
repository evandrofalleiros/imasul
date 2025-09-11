#' Dados de Monitoramento de Metais em Águas - MS (2011-2022)
#'
#' Dataset contendo os resultados de monitoramento de metais pesados em águas
#' superficiais coletados pelo Instituto de Meio Ambiente de Mato Grosso do Sul (IMASUL)
#' entre 2011 e 2022.
#'
#' @format Um data frame com 1300 observações e 12 variáveis:
#' \describe{
#'   \item{regiao_hidrografica}{Região hidrográfica (PARANÁ ou PARAGUAI)}
#'   \item{codigo_imasul}{Código único do ponto de monitoramento}
#'   \item{data_coleta}{Data da coleta da amostra (formato Date)}
#'   \item{hora}{Hora da coleta da amostra (formato hms)}
#'   \item{aluminio_total_mg_L_Al}{Concentração de alumínio total (mg/L)}
#'   \item{bario_total_mg_L_Ba}{Concentração de bário total (mg/L)}
#'   \item{cadmio_total_mg_L_Cd}{Concentração de cádmio total (mg/L)}
#'   \item{chumbo_total_mg_L_Pb}{Concentração de chumbo total (mg/L)}
#'   \item{cobre_total_mg_L_Cu}{Concentração de cobre total (mg/L)}
#'   \item{cromo_total_mg_L_Cr}{Concentração de cromo total (mg/L)}
#'   \item{ferro_total_mg_L_Fe}{Concentração de ferro total (mg/L)}
#'   \item{manganes_total_mg_L_Mn}{Concentração de manganês total (mg/L)}
#'   \item{mercurio_total_mg_L_Hg}{Concentração de mercúrio total (mg/L)}
#'   \item{niquel_total_mg_L_Ni}{Concentração de níquel total (mg/L)}
#'   \item{zinco_total_mg_L_Zn}{Concentração de zinco total (mg/L)}
#' }
#' @details
#' Os dados foram coletados em 65 pontos de monitoramento distribuídos nas bacias
#' hidrográficas do Paraná e Paraguai. Valores abaixo do limite de quantificação
#' foram convertidos para NA. As concentrações devem ser comparadas com os limites
#' estabelecidos pela Resolução CONAMA nº 357/2005 para águas doces classe 1.
#'
#' @source Instituto de Meio Ambiente de Mato Grosso do Sul (IMASUL)
#' @examples
#' \dontrun{
#' data(resultados_metais)
#' head(resultados_metais)
#' summary(resultados_metais)
#' }
"resultados_metais"

#' Coordenadas dos Pontos de Monitoramento de Metais
#'
#' Dataset contendo as coordenadas geográficas e descrições dos pontos de
#' monitoramento utilizados no programa de monitoramento de metais do IMASUL.
#'
#' @format Um data frame com 65 observações e 5 variáveis:
#' \describe{
#'   \item{CODIGO_DO_PONTO}{Código único do ponto de monitoramento}
#'   \item{LATITUDE}{Latitude do ponto em graus decimais (sistema WGS84)}
#'   \item{LONGITUDE}{Longitude do ponto em graus decimais (sistema WGS84)}
#'   \item{DESCRICAO_DO_LOCAL}{Descrição textual da localização do ponto}
#'   \item{REGIAO_HIDROGRAFICA}{Região hidrográfica (PARANÁ ou PARAGUAI)}
#' }
#' @details
#' Os pontos estão distribuídos nas principais bacias hidrográficas de Mato Grosso
#' do Sul, incluindo rios importantes como Paraguai, Paraná, Ivinhema, Dourados,
#' entre outros. As coordenadas estão no sistema de referência WGS84.
#'
#' @source Instituto de Meio Ambiente de Mato Grosso do Sul (IMASUL)
#' @examples
#' \dontrun{
#' data(pontos_metais)
#' head(pontos_metais)
#' # Visualizar pontos em mapa
#' library(sf)
#' pontos_sf <- st_as_sf(pontos_metais, 
#'                       coords = c("LONGITUDE", "LATITUDE"), 
#'                       crs = 4326)
#' plot(pontos_sf)
#' }
"pontos_metais"

#' Dados Integrados de Monitoramento (com Coordenadas)
#'
#' Dataset integrado contendo os dados de monitoramento de metais com as
#' coordenadas geográficas dos pontos de coleta.
#'
#' @format Um data frame com 1300 observações e 16 variáveis:
#' \describe{
#'   \item{regiao_hidrografica}{Região hidrográfica (PARANÁ ou PARAGUAI)}
#'   \item{codigo_imasul}{Código único do ponto de monitoramento}
#'   \item{data_coleta}{Data da coleta da amostra (formato Date)}
#'   \item{hora}{Hora da coleta da amostra (formato hms)}
#'   \item{aluminio_total_mg_L_Al}{Concentração de alumínio total (mg/L)}
#'   \item{bario_total_mg_L_Ba}{Concentração de bário total (mg/L)}
#'   \item{cadmio_total_mg_L_Cd}{Concentração de cádmio total (mg/L)}
#'   \item{chumbo_total_mg_L_Pb}{Concentração de chumbo total (mg/L)}
#'   \item{cobre_total_mg_L_Cu}{Concentração de cobre total (mg/L)}
#'   \item{cromo_total_mg_L_Cr}{Concentração de cromo total (mg/L)}
#'   \item{ferro_total_mg_L_Fe}{Concentração de ferro total (mg/L)}
#'   \item{manganes_total_mg_L_Mn}{Concentração de manganês total (mg/L)}
#'   \item{mercurio_total_mg_L_Hg}{Concentração de mercúrio total (mg/L)}
#'   \item{niquel_total_mg_L_Ni}{Concentração de níquel total (mg/L)}
#'   \item{zinco_total_mg_L_Zn}{Concentração de zinco total (mg/L)}
#'   \item{LATITUDE}{Latitude do ponto em graus decimais (sistema WGS84)}
#'   \item{LONGITUDE}{Longitude do ponto em graus decimais (sistema WGS84)}
#'   \item{DESCRICAO_DO_LOCAL}{Descrição textual da localização do ponto}
#' }
#' @details
#' Este dataset combina os dados de monitoramento com as coordenadas geográficas,
#' facilitando análises espaciais e criação de mapas. É o resultado do join entre
#' `resultados_metais` e `pontos_metais`.
#'
#' @source Instituto de Meio Ambiente de Mato Grosso do Sul (IMASUL)
#' @examples
#' \dontrun{
#' data(dados_imasul)
#' head(dados_imasul)
#' 
#' # Análise espacial básica
#' library(dplyr)
#' por_regiao <- dados_imasul %>%
#'   group_by(regiao_hidrografica) %>%
#'   summarise(
#'     n_pontos = n_distinct(codigo_imasul),
#'     n_amostras = n()
#'   )
#' print(por_regiao)
#' }
"dados_imasul"
