\name{relatorio_conformidade}
\alias{relatorio_conformidade}
\title{Relatório de Conformidade}
\description{
Gera um relatório completo de conformidade com os limites CONAMA
para todos os metais monitorados.
}
\usage{
relatorio_conformidade(dados)
}
\arguments{
\item{dados}{Data.frame retornado por carregar_dados_imasul().}
}
\value{
Lista com relatório completo de conformidade.
}
\examples{
\dontrun{
dados <- carregar_dados_imasul()
relatorio <- relatorio_conformidade(dados)
print(relatorio$resumo_geral)
}
}
