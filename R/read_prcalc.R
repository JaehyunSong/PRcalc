#' Transformation from `.csv` to `prcalc`
#' @param x a `data.frame` or `tibble` object.
#' @param l1 a character (mandatory). A column name of region or state.
#' @param l2 a character (optional). A column name of party or district.
#' @param p a character (mandatory). A column name of population.
#' @param q a character (optional). A column name of magnitude. If `NULL`, magnitudes of all districts are replaced by `1`.
#' @param type a type of `l2`. If `"party"`, vector of `l2` represents parties. If `"district"`, vector of `l2` represents electoral district.
#' @param ... ignored
#'
#' @details
#' `.csv` file must include three columns---region(state) name, district name, and population (number of electorates). A column of magnitude is optional.
#'
#' @return
#' a `prcalc` object.
#'
#' @import readr
#' @import tibble
#' @import dplyr
#' @import tidyr
#'
#' @rdname read_prcalc
#'
#' @export
#'
#' @seealso
#' \code{\link{as_prcalc}}
#'
#' @examples
#' \dontrun{
#' obj <- read_prcalc("data/my_file.csv",
#'                    l1   = "region",
#'                    l2   = "district",
#'                    p    = "electorates",
#'                    q    = "magnitude",
#'                    type = "district")
#' obj
#' }
read_prcalc <- function(x,
                        l1,
                        l2   = NULL,
                        p,
                        q    = NULL,
                        type = c("district", "party"),
                        ...) {

  result <- NULL

  temp_df <- read.csv(x)

  reuslt <- as_prcalc(temp_df,
                      l1 = l1, l2 = l2,
                      p = p, q = q,
                      type = type)

  result
}
