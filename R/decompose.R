#' Decomposition using a `prcalc` object.
#' @param x a `prcalc` object.
#' @param as_disprop If `TRUE`, `alpha` must be larger than `0`. Default is `TRUE`.
#' @param alpha Default is `2` and it must be larger than `0`.
#' @param special a character. names of special district. If it is defined, three-step decomposition is conducted.
#' @param ... ignored
#'
#' @return
#' a `prcalc_decomposition` object.
#'
#' @import dplyr
#'
#' @rdname decompose
#'
#' @export
#'
#' @seealso
#' \code{\link{decompose2}}, \code{\link{decompose3}}
#'
#' @references
#' \itemize{
#' \item{Yuta, Kamahara. "The Desired Political Entropy as the Measure of Unequal Representation: Disproportionality and Malapportionment". Working paper.}
#' }
#'
decompose <- function(x,
                      as_disprop = TRUE,
                      alpha      = 2,
                      special    = NULL,
                      ...) {
  UseMethod("decompose")
}

#' @rdname decompose
#'
#' @export
#'
#' @examples
#' # two-step decomposition (example 1)
#' data("jp_lower_2021")
#'
#' obj <- prcalc(jp_lower_2021,
#'               m = c(8, 14, 20, 21, 17, 11, 21, 30, 11, 6, 21),
#'               method = "hare")
#'
#' decompose(obj)
#'
#' # two-step decomposition (example 2)
#' data("au_district_2010")
#'
#' au_data <- au_district_2010 |>
#'   as_prcalc(region     = "region",
#'             district   = "district",
#'             population = "electorates",
#'             magnitude  = "magnitude")
#'
#' decompose(au_data, alpha = 0, as_disprop = FALSE)
#'
#' # three-step decomposition
#' data("nz_district")
#'
#' nz_district |>
#'   dplyr::filter(year == 2011) |>
#'   as_prcalc(region     = "region",
#'             district   = "district",
#'             population = "electorates",
#'             magnitude  = "magnitude") |>
#'   decompose(alpha = 0, as_disprop = FALSE, special = "Maori")

decompose.prcalc <- function(x,
                             as_disprop = TRUE,
                             alpha      = 2,
                             special    = NULL,
                             ...) {

  if (is.null(special)) {
    result <- decompose2(x,
                         as_disprop = as_disprop,
                         alpha      = alpha)
  } else {
    result <- decompose3(x,
                         special    = special,
                         as_disprop = as_disprop,
                         alpha      = alpha)
  }

  result
}
