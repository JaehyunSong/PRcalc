#' Summrizing a `prcalc` object.
#'
#' @method summary prcalc
#'
#' @param object a `prcalc` object.
#' @param prop If `TRUE`, voteshare and seatshare are displayed. Default is `FALSE`.
#' @param use_gt If `TRUE`, a table is rendered using `{gt}` package. Default is `FALSE`.
#' @param digits the number of decimal places. Default is 3.
#' @param ... ignored.
#'
#' @import dplyr
#' @import gt
#'
#' @seealso
#' \code{\link{print.prcalc}}
#'
#' @export
#'
#' @examples
#' data(jp_upper_2019)
#' jp2019 <- prcalc(jp_upper_2019, m = 50, method = "dt")
#'
#' summary(jp2019)
#'

summary.prcalc <- function(object,
                           prop   = FALSE,
                           use_gt = FALSE,
                           digits = 3,
                           ...) {
  raw_total <- object$raw |>
    mutate(Raw = rowSums(as_tibble(object$raw)[, -1]))

  dist_total <- object$dist |>
    mutate(Dist = rowSums(as_tibble(object$dist)[, -1]))

  result <- raw_total[, c(1, ncol(raw_total))] |>
    left_join(dist_total[, c(1, ncol(dist_total))],
              by = names(raw_total)[1])

  if (prop) {
    result <- result |>
      mutate(across(-1, ~(.x / sum(.x))))
  }

  if (use_gt) {
    if (prop) {
      gt(result) |>
        fmt_number(columns = -1, decimals = digits)
    } else {
      gt(result)
    }
  } else {
    print(result, digits = {if (prop) {digits}})
  }

}
