#' Largest Remainder Method
#'
#' @param x a data.frame or tibble with two columns. The first and second column represents names of parties and numbers of votes, respectively.
#' @param m a numeric value of district magnitude.
#' @param method a character string giving a method for computing seat allocation. See "Allocation methods" section.
#' @param extra a numeric vector of length `m`. If `method` is `"custom"`, this parameter is mandatory. Otherwise, it is ignored.
#'
#' @section Allocation methods:
#' * Highest average method
#'    * `"d'hondt"` (`"dt"`) or `"jefferson"`: D'hondt / Jefferson method
#'    * `"adams"` or `"cambridge"`: Adams / Cambridge method
#'    * `"sainte-lague"` (`"sl"`) or `"webster"`: Sainte-Laguë / Webster method
#'    * `"modified sainte-lague"` (`"msl"`): Modified Sainte-Laguë method
#'    * `"danish"`: Danish method
#'    * `"imperiali"`: Imperiali method
#'    * `"hungtington-hill"` (`"hh"`): Huntington-Hill method
#'    * `"dean"`: Dean method
#'    * `"custom"`: Custom divisor. `extra` is madatory.
#' * Largest reminder method
#'    * `"hare-niemeyer"` (`"hn"` or `"hare"`): Hare-Niemeyer quota
#'    * `"droop"`: Droop quota
#'    * `"hagenbach-bischoff"` (`"hb"`): Hagenbach-Bischoff quota
#'    * `"imperiali quota"` (`"iq"`): Imperiali quota
#'
#' @import dplyr
#' @import tidyr
#' @import purrr
#'
#' @return
#' A tibble object with two columns.
#' @export
#'
#' @examples
#' sample_data <- data.frame(Party = c("Party A", "Party B", "Party C", "Party D"),
#'                           Votes = c(53000, 25000, 16600, 5400))
#'
#' sample_data
#'
#' # Magnitude = 10, Hare-Niemeyer quota
#' allocation(x = sample_data, m = 10, method = "hare")
#'
#' # Magnitude = 10, D'hondt method
#' allocation(x = sample_data, m = 10, method = "dt")
#'
#' # Custom divisor: 1.4, 3, 5, 7, ... (identical to Modified Sainte-Laguë method)
#' allocation(x = sample_data, m = 10, method = "custom",
#'            extra = c(1.4, seq(3, 19, by = 2)))

allocation <- function(x, m, method, extra = NULL) {

  votes <- temp <- party <- remainder <- NULL

  # Validator
  if (!(is.data.frame(x) & ncol(x) == 2)) {
    stop("x must be a two-column data.frame or tibble.")
  }

  if (!(is.numeric(m) & length(m) == 1 & as.integer(m) == m & m > 0)) {
    stop("m must be a positive integer of length 1.")
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
                      "custom",
                      "hn", "hare", "hare-niemeyer",
                      "droop",
                      "hb", "hagenbach-bischoff",
                      "iq", "imperiali quota"))) {
    stop("Inappropriate method.")
  }

  if (method == "custom")  {
    if (length(extra) != m) {
      stop('If method is "custom", a numeric type vector of length m must be specified in extra.')
    }
  }

  names(x) <- c("party", "votes")


  # Highest average method
  if (method %in% c("dt", "d'hondt", "jefferson",
                    "adams", "cambridge",
                    "sl", "sainte-lague", "webster",
                    "msl", "modified sainte-lague",
                    "hh", "hungtington-hill",
                    "dean",
                    "custom")) {

    m2 <- ceiling(m * max(x[, 2] / sum(x[, 2])))
    k  <- 0:(m2 - 1)

    switch(method,
           # Jefferson (D'Hondt) method
           "dt"        = divisor <- k + 1,
           "d'hondt"   = divisor <- k + 1,
           "jefferson" = divisor <- k + 1,
           # Adams' (Cambridge) method
           "adams"     = divisor <- k,
           "cambridge" = divisor <- k,
           # Webster (Sainte-Laguë) method
           "sl"           = divisor <- k + 0.5,
           "sainte-lague" = divisor <- k + 0.5,
           "webster"      = divisor <- k + 0.5,
           # Modified Sainte-Laguë method
           "msl" = {
             divisor <- k + 0.5
             divisor[1] <- 0.7
           },
           "modified sainte-lague" = {
             divisor <- k + 0.5
             divisor[1] <- 0.7
           },
           # Danish method
           "danish"          = divisor <- k + 1/3,
           # Imperiali method
           "imperiali"       = divisor <- k + 2,
           # Hill's (Huntington–Hill) method
           "hh"              = divisor <- sqrt(k * (k + 1)),
           "huntington-hill" = divisor <- sqrt(k * (k + 1)),
           # Dean method
           "dean"        = divisor <- 1 / (((1 / k) + (1 / (k + 1))) / 2),
           # Custom divisorinator
           "custom"      = {
             divisor <- extra
           }
    )

    result <- x |>
      mutate(temp = map(votes, \(x) x / divisor)) |>
      unnest(temp) |>
      arrange(desc(temp)) |>
      slice(1:m) |>
      count(party, name = "votes")
  }

  # Largest remainder method
  if (method %in% c("hn", "hare", "hare-niemeyer",
                    "droop",
                    "hb", "hagenbach-bischoff",
                    "iq", "imperiali quota")) {
    switch(method,
           # Hare-Niemeyer quota
           "hn"            = quota <- sum(x[, 2]) / m,
           "hare"          = quota <- sum(x[, 2]) / m,
           "hare-niemeyer" = quota <- sum(x[, 2]) / m,
           # Droop quota
           "droop" = quota <- floor(1 + (sum(x[, 2]) / (1 + m))),
           # Hagenbach-Bischoff quota
           "hb"                 = quota <- round(sum(x[, 2]) / (1 + m)),
           "hagenbach-bischoff" = quota <- round(sum(x[, 2]) / (1 + m)),
           # Imperiali quota
           "iq"              = quota <- sum(x[, 2]) / (2 + m),
           "imperiali quota" = quota <- sum(x[, 2]) / (2 + m),
    )

    result <- x |>
      mutate(votes = votes / quota) |>
      mutate(remainder = votes - floor(votes),
             votes     = floor(votes),
             rank      = nrow(x) - rank(remainder) + 1,
             votes     = if_else(rank <= (m - sum(votes)), votes + 1, votes)) |>
      select(party, votes)
  }


  return(result)
}
