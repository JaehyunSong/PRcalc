#' @rdname as_prcalc
#'
#' @export
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
