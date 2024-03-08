#' @param x a `prcalc` object.
#' @param ... ignored
#'
#' @rdname decompose
#'
#' @export
#'
decompose <- function(x, ...) {
  UseMethod("decompose")
}

#' Decompsition
#'
#' @param x a `prcalc` object.
#' @param alpha Default is `2`.
#' @param ... ignored
#'
#' @rdname decompose
#'
#' @import dplyr
#'
#' @return
#' a `prcalc_decomposition` object.
#' @export
#'
#' @references
#' \itemize{
#' \item{Yuta, Kamahara. "The Desired Political Entropy as the Measure of Unequal Representation: Disproportionality and Malapportionment". Working paper.}
#' }
#'
#' @examples
#' data(jp_lower_2021)
#'
#' obj <- prcalc(jp_lower_2021,
#'               m = c(8, 14, 20, 21, 17, 11, 21, 30, 11, 6, 21),
#'               method = "hare")
#'
#' decompose(obj)

decompose.prcalc <- function(x,
                             alpha = 2,
                             ...) {

  if (!inherits(x, "prcalc")) stop("Error!")
  if (length(x$m) < 2) stop("Error!")

  ra <- rd <- NULL

  v_j <- colSums(x$raw[, -1])
  s_j <- x$m

  v_j <- v_j / sum(v_j)
  s_j <- s_j / sum(s_j)

  raw_prop <- x$raw |>
    mutate(x$raw, across(-1, \(x) x / sum(x)))

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

