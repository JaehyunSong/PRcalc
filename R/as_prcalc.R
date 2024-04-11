#' Transformation from `.csv` or `data.frame` (`tibble`) to `prcalc` object.
#' @param x a path of `.csv` file (`read_prcalc()`), or name of `data.frame` or `tibble` object (`as_prcalc()`).
#' @param l1 a character. \emph{Mandatory.} A column name of level 1 (region or state).
#' @param l2 a character. \emph{Optional.} A column name of level 2 (party or district).
#' @param p a character. \emph{Mandatory.} A column name of population or number of electorates.
#' @param q a character. \emph{Optional.} A column name of magnitude or number of allocated seats. If `NULL`, replaced by `1`.
#' @param type a type of `l2`. \emph{Mandatory.} If `"span"`, vector of `l2` represents parties. If `"nested"`, vector of `l2` represents electoral district. Default is `"nested"`.
#' @param ... ignored
#'
#' @details
#' At least two columns of `x` are required---`l1` and `p`.
#'
#' @return
#' a `prcalc` object.
#'
#' @import utils
#' @import tibble
#' @import dplyr
#' @import tidyr
#' @import tidyselect
#'
#' @rdname as_prcalc
#'
#' @export
#'
#' @examples
#' data("jp_lower_2021_result")
#'
#' as_prcalc(jp_lower_2021_result,
#'           l1   = "Pref",
#'           l2   = "Party",
#'           p    = "Votes",
#'           q    = "Seats",
#'           type = "span")
#'
#' data("br_district_2010")
#' # Brazil has single block PR system, l2 can be omitted.
#' # If type = "party", raw names of districts are preserved.
#' br_district_2010 |>
#'   as_prcalc(l1   = "district",
#'             p    = "population",
#'             q    = "magnitude",
#'             type = "span")
#'
#' data("au_district_2010")
#' # Because all of magnitude are 1 and type of l2 is district,
#' # you can omit q and type arguments.
#' as_prcalc(au_district_2010,
#'           l1   = "region",
#'           l2   = "district",
#'           p    = "electorates")
#' # You can import .csv format and transform into prcalc object directly.
#' \dontrun{
#' read_prcalc("data/my_file.csv",
#'             l1   = "region",
#'             l2   = "district",
#'             p    = "electorates",
#'             q    = "magnitude",
#'             type = "nested")
#' }

as_prcalc <- function(x,
                      l1,
                      l2   = NULL,
                      p,
                      q    = NULL,
                      type = c("nested", "span"),
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

  if (type == "nested") {
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
