\name{mapear_pontos}
\alias{mapear_pontos}
\title{Mapear Pontos de Monitoramento}
\description{
Prepara dados para mapeamento dos pontos de monitoramento.
}
\usage{
mapear_pontos(dados, metal = NULL)
}
\arguments{
\item{dados}{Data.frame retornado por carregar_dados_imasul().}
\item{metal}{Nome da coluna do metal (opcional, para incluir estatísticas).}
}
\value{
Data.frame com coordenadas e estatísticas por ponto.
}
\examples{
\dontrun{
dados <- carregar_dados_imasul()
pontos <- mapear_pontos(dados, "cadmio_total_mg_L_Cd")
# Usar com sf ou leaflet para visualização
}
}
