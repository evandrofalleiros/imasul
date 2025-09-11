\name{limites_conama}
\alias{limites_conama}
\title{Limites de Qualidade da Água segundo CONAMA 357/2005}
\description{
Retorna os limites de concentração máxima permitida para metais em águas doces classe 1
segundo a Resolução CONAMA 357/2005.
}
\usage{
limites_conama()
}
\value{
Um data.frame com os limites por metal.
}
\examples{
\dontrun{
limites <- limites_conama()
print(limites)
View(limites)
}
}
