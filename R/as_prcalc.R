#' Transformation from `data.frame` to `prcalc`
#' @param x a `data.frame` or `tibble` object.
#' @param l1 a character (mandatory). A column name of region or state.
#' @param l2 a character (optional). A column name of party or district.
#' @param p a character (mandatory). A column name of population.
#' @param q a character (optional). A column name of magnitude. If `NULL`, magnitudes of all districts are replaced by `1`.
#' @param type a type of `l2`. If `"party"`, vector of `l2` represents parties. If `"district"`, vector of `l2` represents electoral district.
#' @param ... ignored
#'
#' @details
#' an object `x` must include three columns---region(state) name, district name, and population (number of electorates). A column of magnitude is optional.
#'
#' @return
#' a `prcalc` object.
#'
#' @import utils
#' @import tibble
#' @import dplyr
#' @import tidyr
#'
#' @rdname as_prcalc
#'
#' @export
#'
#' @seealso
#' \code{\link{read_prcalc}}
#'
#' @examples
#' data(au_district_2010)
#'
#' obj <- as_prcalc(au_district_2010,
#'                  l1   = "region",
#'                  l2   = "district",
#'                  p    = "electorates",
#'                  q    = "magnitude",
#'                  type = "district")
#' obj
as_prcalc <- function(x,
                      l1,
                      l2   = NULL,
                      p,
                      q    = NULL,
                      type = c("district", "party"),
                      ...) {

  Level1 <- Level2 <- NULL

  type <- match.arg(type)

  temp_df <- as.data.frame(x)

  if (is.null(q)) {

    if (is.null(l2)) {
      temp_df1 <- temp_df |>
        select("Level2" = all_of(l1),
               all_of(p)) |>
        mutate("Level1" = "National",
               .before  = Level2)

      temp_df2 <- temp_df |>
        select("Level2" = all_of(l1)) |>
        mutate("Level1" = "National",
               .before  = Level2) |>
        mutate(q = 1)
    } else {
      temp_df1 <- temp_df |>
        select("Level1" = all_of(l1),
               "Level2" = all_of(l2),
               all_of(p))

      temp_df2 <- temp_df |>
        select("Level1" = all_of(l1),
               "Level2" = all_of(l2)) |>
        mutate(q = 1)
    }

  } else {

    if (is.null(l2)) {
      temp_df1 <- temp_df |>
        select("Level2" = all_of(l1),
               all_of(p)) |>
        mutate("Level1" = "National",
               .before  = Level2)

        temp_df2 <- temp_df |>
          select("Level2" = all_of(l1),
                 all_of(q)) |>
          mutate("Level1" = "National",
                 .before  = Level2)
    } else {
      temp_df1 <- temp_df |>
        select("Level1" = all_of(l1),
               "Level2" = all_of(l2),
               all_of(p))

      temp_df2 <- temp_df |>
        select("Level1" = all_of(l1),
               "Level2" = all_of(l2),
               all_of(q))
    }

  }

  if (type == "district") {
    v_df <- temp_df1 |>
      group_by(Level1) |>
      mutate(Level2 = 1:n()) |>
      ungroup() |>
      pivot_wider(names_from  = Level1,
                  values_from = p) |>
      mutate(across(-1, \(x) if_else(is.na(x), 0, x)))

    s_df <- temp_df2 |>
      group_by(Level1) |>
      mutate(Level2 = 1:n()) |>
      ungroup() |>
      pivot_wider(names_from  = Level1,
                  values_from = q) |>
      mutate(across(-1, \(x) if_else(is.na(x), 0, x)))
  } else {
    v_df <- temp_df1 |>
      group_by(Level1) |>
      ungroup() |>
      pivot_wider(names_from  = Level1,
                  values_from = p) |>
      mutate(across(-1, \(x) if_else(is.na(x), 0, x)))

    s_df <- temp_df2 |>
      group_by(Level1) |>
      ungroup() |>
      pivot_wider(names_from  = Level1,
                  values_from = q) |>
      mutate(across(-1, \(x) if_else(is.na(x), 0, x)))
  }

  m <- colSums(s_df[, -1], na.rm = TRUE)

  result <- list(raw       = as.data.frame(v_df),
                 dist      = as.data.frame(s_df),
                 m         = m,
                 method    = NULL,
                 extra     = NULL,
                 threshold = NULL)

  structure(result, class = "prcalc")
}
