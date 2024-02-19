#' @param x a \code{prcalc} object.
#' @param ... ignored
#'
#' @rdname decompose
#'
#' @export
#'
decompose <- function(x, ...) {
  UseMethod("decompose")
}

#' Decompsition
#'
#' @param x a \code{prcalc} object.
#' @param alpha Default is `2`.
#' @param ... ignored
#'
#' @rdname decompose
#'
#' @import dplyr
#'
#' @return
#' a \code{list} object.
#' @export
#'
#' @references
#' \itemize{
#' \item{Laakso, Markku and Rein Taagepera. 1979. ""Effective" Number of Parties: A Measure with Application to West Europe". Comparative Political Studies. 12 (1): 3–27.}
#' }
#'
#' @examples
#' data(jp_upper_2019)
#'
#' pr_obj <- prcalc(jp_upper_2019, m = 50, method = "dt")
#'
#' index(pr_obj)

decompose.prcalc <- function(x,
                             alpha = 2,
                             ...) {

  if (!inherits(x, "prcalc")) stop("Error!")

}
