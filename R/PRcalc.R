#' Proportional Representation Calculator
#'
#' @param x a `data.frame` or `tibble` object.
#' @param m a numeric vector of district magnitude.
#' @param method a character string giving a method for computing seat allocation. See "Allocation methods" section.
#' @param extra a numeric vector of length `m`. If `method` is `"custom divisor"` (`"cd"`) or `"custom quota"` (`"cq"`), this parameter is mandatory. See "About custom methods" section.
#' @param threshold a threshold. It must be equal or larger than 0 (0%) and smaller than 0.1 (10%). a default is 0.
#'
#' @section Allocation methods:
#' aaa
#'
#' @section About custom methods:
#' Custom methods (`"custom divisor"` and `"custom quota"`) require `extra` parameter. In the case of `"custom divisor"` (`"cd"`), a numeric vector of the same length as the magnitude (`m`) must be specified. If the magnitude (`m`) is a vector of length 2 or longer, the `extra` must have a length equal to `max(m)`. For example, if `m = c(5, 7, 4)`, then the length of the extra must be 7.
#'
#' In the case of `"custom quota"`, `extra` must be a vector of the same length as `m`. For example, if `m = c(5, 7, 4)`, `extra` must also be a numeric vector of length 3. If length of `extra` is 1, the same quota is applied to all blocks.
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
#' japan_2021

prcalc <- function (x,
                    m,
                    method,
                    extra = NULL,
                    threshold = 0) {

  votes <- NULL

  # Validator
  if (!(is.numeric(threshold) & threshold >= 0 & threshold <= 0.1)) {
    stop("threshold must be a numeric vector of length 1 that is greater than or equal to 0 and less than or equal to 0.1.")
  }

  if (is.character(method) & length(method) == 1) {
    method <- tolower(method)
  } else {
    stop("method must be a vector of type character of length 1.")
  }

  if (!(method %in% c("dt", "d'hondt", "jefferson",
                      "adams", "cambridge",
                      "sl", "sainte-lague", "webster",
                      "msl", "modified sainte-lague",
                      "danish",
                      "imperiali",
                      "hh", "hungtington-hill",
                      "dean",
                      "ad",
                      "custom divisor", "cd",
                      "hn", "hare", "hare-niemeyer",
                      "droop",
                      "hb", "hagenbach-bischoff",
                      "iq", "imperiali quota",
                      "custom quota", "cq"))) {
    stop("Inappropriate method.")
  }

  if (method %in% c("custom divisor", "cd"))  {
    if (length(extra) < m) {
      stop('If method is "custom divisor" or "cd", extra must be specified. extra must be a numeric vector of length of max(m) or longer.')
    }
  }

  if (method %in% c("custom quota", "cq")) {
    if (!(length(extra) == length(m) | length(extra) == 1)) {
      stop('"extra" must be a vector of the same length as length(m) or 1.')
    }
  }

  result   <- list()
  df_names <- names(x)

  result_df        <- as_tibble(x[, 1])
  names(result_df) <- "party"

  for (i in 2:ncol(x)) {
    temp <- x |>
      select(party = 1, votes = all_of(i)) |>
      mutate(votes = if_else((votes / sum(votes)) < threshold, 0, votes))

    if (method %in% c("custom quota", "cq")) {
      temp2 <- allocation(temp, m[i - 1], method, extra[i-1])
    } else {
      temp2 <- allocation(temp, m[i - 1], method, extra)
    }

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
         # Custom divisor
         "custom divisor"     = method_return <- "Custom divisor",
         "cd"                 = method_return <- "Custom divisor",
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
         "imperiali quota"    = method_return <- "Imperiali quota",
         # Custom quota
         "cq"                 = method_return <- "Custom quota",
         "custom quota"       = method_return <- "Custom quota"
  )

  if (!(method %in% c("custom divisor", "cd", "custom quota", "cq"))) extra <- NULL

  result <- list(raw       = as.data.frame(x),
                 dist      = as.data.frame(result_df),
                 m         = magnitude,
                 method    = method_return,
                 extra     = extra,
                 threshold = threshold)

  structure(result, class = "prcalc")
}
