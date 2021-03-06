% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{descale}
\alias{descale}
\title{Restore a scaled matrix to a matrix with original parameters.}
\usage{
descale(X, scaled)
}
\arguments{
\item{X}{a matrix or a data.frame to be restored}

\item{scaled}{a scaled matrixa or a scaled data.frame}
}
\value{
a tibble
}
\description{
Restore a scaled matrix to a matrix with original parameters.
}
\examples{
iris.scaled <- scale(iris[, -5])
descale(head(iris.scaled), iris.scaled)
head(iris)

}
