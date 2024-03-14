#' Decomposition using a `prcalc` object with three-step.
#' @param x a `prcalc` object.
#' @param special a character. names of special district.
#' @param as_disprop If `TRUE`, `alpha` must be larger than `0`. Default is `FALSE`.
#' @param alpha Default is `0`.
#' @param ... ignored
#'
#' @return
#' a `prcalc_decomposition` object.
#'
#' @import dplyr
#'
#' @rdname decompose3
#'
#' @export
#'
#' @seealso
#' \code{\link{decompose}}, \code{\link{decompose2}}
#'
#' @references
#' \itemize{
#' \item{Yuta, Kamahara, Junichiro Wada, and Yuko Kasuya. 2021. "Malapportionment in space and time: Decompose it!" \emph{Electoral Studies}. 71: 102301.}
#' }
#'
decompose3 <- function(x, ...) {
  UseMethod("decompose3")
}

#' @rdname decompose3
#'
#' @export
#'
#' @seealso
#' \code{\link{decompose}}
#'
#' @examples
#' data(nz_district)
#'
#' nz_1949 <- nz_district |>
#'   dplyr::filter(year == 1949) |>
#'   as_prcalc(region     = "region",
#'             district   = "district",
#'             population = "electorates",
#'             magnitude  = "magnitude")
#'
#' decompose3(nz_1949, special = "Maori")

decompose3.prcalc <- function(x,
                              special    = NULL,
                              as_disprop = FALSE,
                              alpha      = 0,
                              ...) {

  if (!inherits(x, "prcalc")) stop("Error!")
  if (length(x$m) < 2) stop("Error!")

  special_names <- special

  v <- x$raw[, -1]
  s <- x$dist[, -1]

  temp_a <- 1 / (alpha * (alpha - 1))

  names(v)[names(v) %in% special] <- paste0("s_", 1:length(special))
  names(v)[!grepl("s", names(v))] <- paste0("g_", 1:(length(x$m) - length(special)))
  names(s)[names(s) %in% special] <- paste0("s_", 1:length(special))
  names(s)[!grepl("s", names(s))] <- paste0("g_", 1:(length(x$m) - length(special)))

  v_prop <- colSums(v) / sum(colSums(v))
  s_prop <- colSums(s) / sum(colSums(s))

  ##################
  ## Special term ##
  ##################
  total_v <- sum(colSums(v))
  total_s <- sum(colSums(s))

  special_v <- sum(colSums(v)[grepl("s", names(v))])
  special_s <- sum(colSums(s)[grepl("s", names(s))])

  general_v <- total_v - sum(special_v)
  general_s <- total_s - sum(special_s)

  special_vec1 <- c(special_v, general_v)
  special_vec2 <- c(special_s, general_s)

  special_v_prop <- special_vec1 / sum(special_vec1)
  special_s_prop <- special_vec2 / sum(special_vec2)

  if (alpha == 0) {
    special <- sum(special_v_prop * log(special_v_prop / special_s_prop))
  } else if (alpha == 1) {
    special <- sum(special_s_prop * log(special_s_prop / special_v_prop))
  } else {
    special <- sum(special_v_prop * temp_a * ((special_s_prop / special_v_prop)^alpha - 1))
  }


  ##########################
  ## Reapportionment term ##
  ##########################

  temp_ra_vec <- c("s" = NA, "g" = NA)

  for (i in c("s", "g")) {
    temp_v <- v_prop[grepl(i, names(v_prop))]
    temp_s <- s_prop[grepl(i, names(s_prop))]

    v_hj <- temp_v / sum(temp_v)
    s_hj <- temp_s / sum(temp_s)

    if (alpha == 0) {
      temp_ra_vec[i] <- sum(v_hj * log(v_hj / s_hj))
    } else if (alpha == 1) {
      temp_ra_vec[i] <- sum(s_hj * log(s_hj / v_hj))
    } else {
      v_h <- special_vec1 / sum(special_vec1)
      s_h <- special_vec2 / sum(special_vec2)
      temp_ra_vec[i] <- sum(s_h^alpha * v_h^(1 - alpha) *
                              sum(v_hj * temp_a * ((s_hj / v_hj)^alpha - 1)))
    }


  }

  ra <- sum(special_v_prop * temp_ra_vec)

  ########################
  ## Redistricting term ##
  ########################

  temp_rd_vec <- c("s" = NA, "g" = NA)

  for (i in c("s", "g")) {
    temp_v <- v_prop[grepl(i, names(v_prop))]
    temp_s <- s_prop[grepl(i, names(s_prop))]

    v_hj <- temp_v / sum(temp_v)
    s_hj <- temp_s / sum(temp_s)

    temp <- c()

    for (j in 1:length(temp_v)) {
      v_hji <- v[, names(temp_v)[j]]
      s_hji <- s[, names(temp_v)[j]]

      s_hji <- s_hji[v_hji > 0]
      v_hji <- v_hji[v_hji > 0]

      s_hji <- s_hji / sum(s_hji)
      v_hji <- v_hji / sum(v_hji)

      if (alpha == 0) {
        temp[j] <- sum(v_hji * log(v_hji / s_hji))
      } else if (alpha == 1) {
        temp[j] <- sum(s_hji * log(s_hji / v_hji))
      } else {
        v_h <- special_vec1 / sum(special_vec1)
        s_h <- special_vec2 / sum(special_vec2)
        temp_3_1 <- sum(v_hji * temp_a * ((s_hji / v_hji)^alpha - 1))
        temp_3_2 <- sum(s_hj^alpha * v_hj^(1 - alpha) * temp_3_1)
        temp[j]  <- sum(s_h^alpha * v_h^(1 - alpha) * temp_3_2)
      }
    }

    temp_rd_vec[i] <- sum(v_hj * temp)

  }

  rd <- sum(special_v_prop * temp_rd_vec)

  result <- c("d"       = special + ra + rd,
              "special" = special,
              "ra"      = ra,
              "rd"      = rd)
  attr(result, "labels") <- c("alpha-divergence",
                              "Special",
                              "Reapportionment",
                              "Redistricting")
  attr(result, "special") <- special_names
  attr(result, "alpha") <- alpha

  structure(result, class = c("prcalc_decomposition"))

}
