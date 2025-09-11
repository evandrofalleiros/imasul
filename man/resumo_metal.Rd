\name{resumo_metal}
\alias{resumo_metal}
\title{Resumo Estatístico dos Dados de Metais}
\description{
Fornece um resumo estatístico completo dos dados de monitoramento de metais.
}
\usage{
resumo_metal(dados, metal)
}
\arguments{
\item{dados}{Data.frame retornado por carregar_dados_imasul().}
\item{metal}{Nome da coluna do metal para análise (ex: "cadmio_total_mg_L_Cd").}
}
\value{
Uma lista com estatísticas descritivas e análise de conformidade.
}
\examples{
\dontrun{
dados <- carregar_dados_imasul()
resumo <- resumo_metal(dados, "cadmio_total_mg_L_Cd")
print(resumo)
}
}
