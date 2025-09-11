\name{carregar_dados_imasul}
\alias{carregar_dados_imasul}
\title{Dados de Monitoramento de Metais em Águas - Mato Grosso do Sul}
\description{
Esta função carrega os dados brutos de monitoramento de metais em águas
superficiais coletados pelo Instituto de Meio Ambiente de Mato Grosso do Sul (IMASUL).
}
\usage{
carregar_dados_imasul(caminho_arquivo = NULL, limpar_dados = TRUE)
}
\arguments{
\item{caminho_arquivo}{Caminho para o arquivo CSV dos dados (opcional).
Se não fornecido, tenta carregar dos dados incluídos no pacote.}
\item{limpar_dados}{Logical. Se TRUE, realiza limpeza básica dos dados.}
}
\value{
Um data.frame com os dados de monitoramento.
}
\examples{
\dontrun{
# Carregar dados incluídos no pacote
dados <- carregar_dados_imasul()

# Carregar de arquivo externo
dados <- carregar_dados_imasul("caminho/para/dados_processados.csv")

# Visualizar estrutura dos dados
str(dados)
head(dados)
}
}
