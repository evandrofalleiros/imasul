\name{verificar_conformidade}
\alias{verificar_conformidade}
\title{Verificar Conformidade com CONAMA}
\description{
Verifica se os valores de um metal estão em conformidade com os limites CONAMA
e adiciona colunas de análise ao data.frame.
}
\usage{
verificar_conformidade(dados, metal)
}
\arguments{
\item{dados}{Data.frame retornado por carregar_dados_imasul().}
\item{metal}{Nome da coluna do metal.}
}
\value{
Data.frame com colunas adicionais de conformidade.
}
\examples{
\dontrun{
dados <- carregar_dados_imasul()
dados_conforme <- verificar_conformidade(dados, "cadmio_total_mg_L_Cd")
table(dados_conforme$status_conama)
}
}
