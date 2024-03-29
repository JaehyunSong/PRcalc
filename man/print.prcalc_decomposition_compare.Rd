% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/print.R
\name{print.prcalc_decomposition_compare}
\alias{print.prcalc_decomposition_compare}
\title{Printing a \code{prcalc_decomposition_compare} object.}
\usage{
\method{print}{prcalc_decomposition_compare}(x, use_gt = FALSE, digits = 3, ...)
}
\arguments{
\item{x}{a \code{prcalc_decomposition_compare} object.}

\item{use_gt}{Use {gt} package? Default is \code{FALSE}.}

\item{digits}{the number of decimal places. Default is 3.}

\item{...}{ignored.}
}
\description{
Printing a \code{prcalc_decomposition_compare} object.
}
\examples{
data(jp_lower_2021)

obj <- prcalc(jp_lower_2021[1:9, ],
              m = c(8, 14, 20, 21, 17, 11, 21, 30, 11, 6, 21),
              method = "hare")

decompose(obj)
}
