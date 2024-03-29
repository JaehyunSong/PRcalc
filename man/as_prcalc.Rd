% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/as_prcalc.R
\name{as_prcalc}
\alias{as_prcalc}
\title{Transformation from \code{data.frame} to \code{prcalc}}
\usage{
as_prcalc(
  x,
  region = "region",
  district = "district",
  population = "electorates",
  magnitude = "magnitude",
  distinct_name = FALSE,
  ...
)
}
\arguments{
\item{x}{a \code{data.frame} or \code{tibble} object.}

\item{region}{a character (mandatory). A column name of region or state.}

\item{district}{a character (mandatory). A column name of district.}

\item{population}{a character (mandatory). A column name of population.}

\item{magnitude}{a character (optional). A column name of magnitude. If \code{NULL}, magnitudes of all districts are replaced by \code{1}.}

\item{distinct_name}{If \code{TRUE}, all district names are distinct. Default is \code{FALSE}.}

\item{...}{ignored}
}
\value{
a \code{prcalc} object.
}
\description{
Transformation from \code{data.frame} to \code{prcalc}
}
\details{
an object \code{x} must include three columns---region(state) name, district name, and population (number of electorates). A column of magnitude is optional.
}
\examples{
data(au_district_2010)

obj <- as_prcalc(au_district_2010,
                 region     = "region",
                 district   = "district",
                 population = "electorates",
                 magnitude  = "magnitude")
obj
}
\seealso{
\code{\link{read_prcalc}}
}
