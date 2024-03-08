#' Decomposition using a `prcalc` or `list` object.
#' @param x a `prcalc` or `list` object.
#' @param as_disprop If `TRUE`, `alpha` must be larger than `0`. Default is `TRUE`.
#' @param alpha Default is `2` and it must be larger than `0`.
#' @param ... ignored
#'
#' @details
#' If using a `list` object, the first element must be `data.frame` (or `tibble`) of votes and the second element must be `data.frame` (or `tibble`) of seats. See example for details.
#'
#' @return
#' a `prcalc_decomposition` object.
#'
#' @import dplyr
#'
#' @rdname decompose
#'
#' @export
#'
#' @references
#' \itemize{
#' \item{Yuta, Kamahara. "The Desired Political Entropy as the Measure of Unequal Representation: Disproportionality and Malapportionment". Working paper.}
#' }
#'
decompose <- function(x, ...) {
  UseMethod("decompose")
}

#' @rdname decompose
#'
#' @export
#'
#' @examples
#' # Using a prcalc object
#' data(jp_lower_2021)
#'
#' obj <- prcalc(jp_lower_2021,
#'               m = c(8, 14, 20, 21, 17, 11, 21, 30, 11, 6, 21),
#'               method = "hare")
#'
#' decompose(obj)

decompose.prcalc <- function(x,
                             as_disprop = TRUE,
                             alpha = 2,
                             ...) {

  if (!inherits(x, "prcalc")) stop("Error!")
  if (length(x$m) < 2) stop("Error!")

  if (as_disprop) {
    if (alpha <= 0) stop("alpha must be larger than 0.")
  }

  ra <- rd <- NULL

  v_j <- colSums(x$raw[, -1])
  s_j <- x$m

  v_j <- v_j / sum(v_j)
  s_j <- s_j / sum(s_j)

  raw_prop <- x$raw |>
    mutate(across(-1, \(x) x / sum(x)))

  dist_prop <- x$dist |>
    mutate(across(-1, \(x) x / sum(x)))

  if (alpha == 0) {
    ra <- sum(v_j * log(v_j / s_j))

    for (i in 2:ncol(raw_prop)) {
      v_ij <- raw_prop[, i]
      s_ij <- dist_prop[, i]

      v_s <- log(v_ij / s_ij)

      v_s[is.nan(v_s) | is.infinite(v_s)] <- 0

      #temp <- v_j[i-1] * sum(v_ij * log(v_ij / s_ij))
      temp <- v_j[i-1] * sum(v_ij * v_s)

      rd[i - 1] <- temp
    }

  } else if (alpha == 1) {
    ra <- sum(s_j * log(s_j / v_j))

    for (i in 2:ncol(raw_prop)) {
      v_ij <- raw_prop[, i]
      s_ij <- dist_prop[, i]

      zero_ind <- (v_ij == 0) & (s_ij == 0)

      v_ij <- v_ij[!zero_ind]
      s_ij <- s_ij[!zero_ind]

      s_v <- log(s_ij / v_ij)

      #s_v[is.nan(s_v) | is.infinite(s_v)] <- 0
      s_v[s_ij == 0] <- 0

      #temp <- s_j[i-1] * sum(s_ij * log(s_ij / v_ij))
      temp <- s_j[i-1] * sum(s_ij * s_v)

      rd[i - 1] <- temp
    }
  } else {
    temp_a <- 1 / (alpha * (alpha - 1))
    ra <- sum(v_j * ((s_j / v_j)^alpha - 1)) * temp_a

    rd <- NULL

    for (i in 2:ncol(raw_prop)) {
      v_ij <- raw_prop[, i]
      s_ij <- dist_prop[, i]

      zero_ind <- (v_ij == 0) & (s_ij == 0)

      v_ij <- v_ij[!zero_ind]
      s_ij <- s_ij[!zero_ind]

      s_v <- s_ij / v_ij

      s_v_a <- s_v^alpha
      #s_v_a[is.infinite(s_v_a)] <- 0

      temp <- s_j[i-1]^alpha * v_j[i-1]^(1 - alpha) * sum(temp_a * v_ij * (s_v_a - 1))

      rd[i - 1] <- temp
    }

  }

  rd <- sum(rd)

  result <- c("d" = ra + rd, "ra" = ra, "rd" = rd)
  attr(result, "labels") <- c("alpha-divergence",
                              "Reapportionment",
                              "Redistricting")
  attr(result, "alpha") <- alpha

  structure(result, class = c("prcalc_decomposition"))

  }

#' @rdname decompose
#'
#' @export
#'
#' @examples
#' # Using a list object
#' votes <- data.frame(Party  = LETTERS[1:5],
#'                     Block1 = c(8600, 2940, 6729, 2072, 2153),
#'                     Block2 = c(16282, 4663, 9915, 2928, 2587),
#'                     Block3 = c(2172, 8239, 13911, 4441, 6175),
#'                     Block4 = c(25900, 8600, 16500, 5300, 8600))
#'
#' seats <- data.frame(Party  = LETTERS[1:5],
#'                     Block1 = c(3, 1, 2, 1, 1),
#'                     Block2 = c(6, 2, 3, 1, 1),
#'                     Block3 = c(7, 3, 5, 1, 2),
#'                     Block4 = c(7, 2, 5, 2, 3))
#'
#' decompose(list(votes, seats))
#'
decompose.list <- function(x,
                           as_disprop = TRUE,
                           alpha = 2,
                           ...) {

  if (!inherits(x, "list")) stop("Error!")
  if (ncol(x[[1]]) < 2) stop("Error!")

  if (as_disprop) {
    if (alpha <= 0) stop("alpha must be larger than 0.")
  }

  ra <- rd <- NULL

  v_j <- colSums(x[[1]][, -1])
  s_j <- colSums(x[[2]][, -1])

  v_j <- v_j / sum(v_j)
  s_j <- s_j / sum(s_j)

  raw_prop <- x[[1]] |>
    mutate(across(-1, \(x) x / sum(x))) |>
    as.data.frame()

  dist_prop <- x[[2]] |>
    mutate(across(-1, \(x) x / sum(x))) |>
    as.data.frame()

  if (alpha == 0) {
    ra <- sum(v_j * log(v_j / s_j))

    for (i in 2:ncol(raw_prop)) {
      v_ij <- raw_prop[, i]
      s_ij <- dist_prop[, i]

      v_s <- log(v_ij / s_ij)

      v_s[is.nan(v_s) | is.infinite(v_s)] <- 0

      #temp <- v_j[i-1] * sum(v_ij * log(v_ij / s_ij))
      temp <- v_j[i-1] * sum(v_ij * v_s)

      rd[i - 1] <- temp
    }

  } else if (alpha == 1) {
    ra <- sum(s_j * log(s_j / v_j))

    for (i in 2:ncol(raw_prop)) {
      v_ij <- raw_prop[, i]
      s_ij <- dist_prop[, i]

      zero_ind <- (v_ij == 0) & (s_ij == 0)

      v_ij <- v_ij[!zero_ind]
      s_ij <- s_ij[!zero_ind]

      s_v <- log(s_ij / v_ij)

      #s_v[is.nan(s_v) | is.infinite(s_v)] <- 0
      s_v[s_ij == 0] <- 0

      #temp <- s_j[i-1] * sum(s_ij * log(s_ij / v_ij))
      temp <- s_j[i-1] * sum(s_ij * s_v)

      rd[i - 1] <- temp
    }
  } else {
    temp_a <- 1 / (alpha * (alpha - 1))
    ra <- sum(v_j * ((s_j / v_j)^alpha - 1)) * temp_a

    rd <- NULL

    for (i in 2:ncol(raw_prop)) {
      v_ij <- raw_prop[, i]
      s_ij <- dist_prop[, i]

      zero_ind <- (v_ij == 0) & (s_ij == 0)

      v_ij <- v_ij[!zero_ind]
      s_ij <- s_ij[!zero_ind]

      s_v <- s_ij / v_ij

      s_v_a <- s_v^alpha
      #s_v_a[is.infinite(s_v_a)] <- 0

      temp <- s_j[i-1]^alpha * v_j[i-1]^(1 - alpha) * sum(temp_a * v_ij * (s_v_a - 1))

      rd[i - 1] <- temp
    }

  }

  rd <- sum(rd)

  result <- c("d" = ra + rd, "ra" = ra, "rd" = rd)
  attr(result, "labels") <- c("alpha-divergence",
                              "Reapportionment",
                              "Redistricting")
  attr(result, "alpha") <- alpha

  structure(result, class = c("prcalc_decomposition"))

}

