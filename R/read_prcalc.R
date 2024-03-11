#' Transformation from `.csv` to `prcalc`
#' @param x a character. a path of `.csv` file.
#' @param region a character (mandatory). A column name of region or state.
#' @param district a character (mandatory). A column name of district.
#' @param population a character (mandatory). A column name of population.
#' @param magnitude a character (optional). A column name of magnitude. If `NULL`, magnitudes of all districts are replaced by `1`.
#' @param distinct_name If `TRUE`, all district names are distinct. Default is `FALSE`.
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
#' obj <- read_prcalc("data/my_file.csv")
#'                    region     = "region",
#'                    district   = "district",
#'                    population = "electorates",
#'                    magnitude  = "magnitude")
#' obj
#' }
read_prcalc <- function(x,
                        region        = NULL,
                        district      = NULL,
                        population    = NULL,
                        magnitude     = NULL,
                        distinct_name = FALSE,
                        ...) {

  Population <- Region <- District <- Magnitude <- NULL

  temp_df <- read.csv(x)

  if (is.null(magnitude)) {
    temp_df1 <- temp_df |>
      select("Region"     = region,
             "District"   = district,
             "Population" = population)

    temp_df2 <- temp_df |>
      select("Region"     = region,
             "District"   = district) |>
      mutate(Magnitude    = 1)
  } else {
    temp_df1 <- temp_df |>
      select("Region"     = region,
             "District"   = district,
             "Population" = population)

    temp_df2 <- temp_df |>
      select("Region"     = region,
             "District"   = district,
             "Magnitude"  = magnitude)
  }

  if (!distinct_name) {
    v_df <- temp_df1 |>
      group_by(Region) |>
      mutate(District = 1:n()) |>
      ungroup() |>
      pivot_wider(names_from  = Region,
                  values_from = Population) |>
      mutate(across(-1, \(x) if_else(is.na(x), 0, x)))

    s_df <- temp_df2 |>
      group_by(Region) |>
      mutate(District = 1:n()) |>
      ungroup() |>
      pivot_wider(names_from  = Region,
                  values_from = Magnitude) |>
      mutate(across(-1, \(x) if_else(is.na(x), 0, x)))
  } else {
    v_df <- temp_df1 |>
      group_by(Region) |>
      ungroup() |>
      pivot_wider(names_from  = Region,
                  values_from = Population) |>
      mutate(across(-1, \(x) if_else(is.na(x), 0, x)))

    s_df <- temp_df2 |>
      group_by(Region) |>
      ungroup() |>
      pivot_wider(names_from  = Region,
                  values_from = Magnitude) |>
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
