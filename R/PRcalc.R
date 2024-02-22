#' Proportional Representation Calculator
#'
#' @param x a \code{data.frame} or \code{tibble} object.
#' @param m a \code{numeric} vector of magnitude.
#' @param method a character string giving a method for computing seat allocation. See "Allocation methods" section.
#' @param extra a numeric vector of length `m`. If `method` is `"custom"`, this parameter is mandatory. Otherwise, it is ignored.
#' @param threshold a threshold. It must be equal or larger than 0 (0%) and smaller than 0.1 (10%). a default is 0.
#'
#' @import tibble
#' @import dplyr
#'
#' @return
#' a \code{prcalc} object
#'
#' @seealso
#' \code{\link{print.prcalc}}, \code{\link{summary.prcalc}}, \code{\link{plot.prcalc}}
#'
#' @export
#'
#' @examples
#' data(jp_upper_2019)
#' data(jp_lower_2021)
#' prcalc(jp_upper_2019, m = 50, method = "dt")
#'
#' japan_2021 <- prcalc(jp_lower_2021,
#'                      m = c(8, 14, 20, 21, 17, 11, 21, 30, 11, 6, 21),
#'                      method = "hare")
#'

prcalc <- function (x,
                    m,
                    method,
                    extra = NULL,
                    threshold = 0) {

  votes <- NULL

  if (!(is.numeric(threshold) & threshold >= 0 & threshold <= 0.1)) {
    stop("threshold must be a numeric vector of length 1 that is greater than or equal to 0 and less than or equal to 0.1.")
  }

  result   <- list()
  df_names <- names(x)

  result_df        <- as_tibble(x[, 1])
  names(result_df) <- "party"

  for (i in 2:ncol(x)) {
    temp <- x |>
      select(party = 1, votes = all_of(i)) |>
      mutate(votes = if_else((votes / sum(votes)) < threshold, 0, votes))

    temp2 <- allocation(temp, m[i - 1], method, extra)

    result_df <- result_df |>
      left_join(temp2, by = "party")
  }

  result_df <- result_df |>
    mutate(across(all_of(2:ncol(x)),
                  ~if_else(is.na(.x), 0, .x)))

  names(result_df) <- df_names

  if (length(m) > 1) {
    magnitude <- m
    names(magnitude) <- df_names[-1]
  } else {
    magnitude <- m
  }


  switch(method,
         # Jefferson (D'Hondt) method
         "dt"        = method_return <- "D\'Hondt (Jefferson) method",
         "d'hondt"   = method_return <- "D\'Hondt (Jefferson) method",
         "jefferson" = method_return <- "D\'Hondt (Jefferson) method",
         # Adams' (Cambridge) method
         "adams"     = method_return <- "Adams\' (Cambridge) method",
         "cambridge" = method_return <- "Adams\' (Cambridge) method",
         # Webster (Sainte-Lague) method
         "sl"           = method_return <- "Sainte-Lagu\u00eb (Webster) method",
         "sainte-lague" = method_return <- "Sainte-Lagu\u00eb (Webster) method",
         "webster"      = method_return <- "Sainte-Lagu\u00eb (Webster) method",
         # Modified Sainte-Lague method
         "msl"                   = method_return <- "Modified Sainte-Lagu\u00eb method",
         "modified sainte-lague" = method_return <- "Modified Sainte-Lagu\u00eb method",
         # Danish method
         "danish"             = method_return <- "Danish",
         # Imperiali method
         "imperiali"          = method_return <- "Imperiali method",
         # Hill's (Huntington–Hill) method
         "hh"                 = method_return <- "Hill\'s (Huntington-Hill) method",
         "huntington-hill"    = method_return <- "Hill\'s (Huntington-Hill) method",
         # Dean method
         "dean"               = method_return <- "Dean method",
         # alpha-divergence
         "ad"                 = method_return <- "alpha-divergence",
         # Custom
         "custom"             = method_return <- "Custom",
         # Hare-Niemeyer quota
         "hn"                 = method_return <- "Hare-Niemeyer quota",
         "hare"               = method_return <- "Hare-Niemeyer quota",
         "hare-niemeyer"      = method_return <- "Hare-Niemeyer quota",
         # Droop quota
         "droop"              = method_return <- "Droop quota",
         # Hagenbach-Bischoff quota
         "hb"                 = method_return <- "Hagenbach-Bischoff quota",
         "hagenbach-bischoff" = method_return <- "Hagenbach-Bischoff quota",
         # Imperiali quota
         "iq"                 = method_return <- "Imperiali quota",
         "imperiali quota"    = method_return <- "Imperiali quota"
  )

  if (method != "custom") extra <- NULL

  result <- list(raw       = as.data.frame(x),
                 dist      = as.data.frame(result_df),
                 m         = magnitude,
                 method    = method_return,
                 extra     = extra,
                 threshold = threshold)

  structure(result, class = "prcalc")
}
