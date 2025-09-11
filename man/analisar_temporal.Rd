\name{analisar_temporal}
\alias{analisar_temporal}
\title{Análise Temporal de Metais}
\description{
Realiza análise temporal dos dados de metais, incluindo tendências e sazonalidade.
}
\usage{
analisar_temporal(dados, metal, agrupamento = "mes")
}
\arguments{
\item{dados}{Data.frame retornado por carregar_dados_imasul().}
\item{metal}{Nome da coluna do metal.}
\item{agrupamento}{Tipo de agrupamento temporal ("mes", "ano", "semestre").}
}
\value{
Data.frame com análise temporal.
}
\examples{
\dontrun{
dados <- carregar_dados_imasul()
temporal <- analisar_temporal(dados, "cadmio_total_mg_L_Cd", "ano")
plot(temporal$data_agrupada, temporal$media, type = "l")
}
}
