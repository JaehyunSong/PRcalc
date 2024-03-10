#' Transformation from `.csv` or `data.frame` to `prcalc_df`
#' @param x a data.frame or path of `.csv` file.
#' @param region a character. A column name of region or state.
#' @param district a character. A column name of district.
#' @param population a character. A column name of population.
#' @param ... ignored
#'
#'#' @details
#' `.csv` file must include three columns---region(state) name, district name, and population (number of electorates).
#'
#' @return
#' a `prcalc_df` object.
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
#' @examples
#' \dontrun{
#' library(PRcalc)
#'
#' my_df <- read_prcalc("data/my_file.csv")
#' my_df
#' }
read_prcalc <- function(x,
                        region     = NULL,
                        district   = NULL,
                        population = NULL,
                        ...) {

  Population <- Region <- District <- NULL

  if (!is.data.frame(x)) {
    temp_df <- read_csv(x)
  } else {
    temp_df <- as_tibble(x)
  }

  temp_df <- temp_df |>
    select("Region"     = region,
           "District"   = district,
           "Population" = population)

  result <- temp_df |>
    group_by(Region) |>
    mutate(District = 1:n()) |>
    ungroup() |>
    pivot_wider(names_from  = Region,
                values_from = Population)

  structure(result, class = c("prcalc_df", class(result)))
}
