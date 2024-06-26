#' Decomposition using a `prcalc` object with three-step.
#' @param x a `prcalc` object.
#' @param special a character. names of special district.
#' @param alpha Default is `2`.
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
#'   subset(year == 1949) |>
#'   as_prcalc(l1   = "region",
#'             l2   = "district",
#'             p    = "electorates",
#'             q    = "magnitude",
#'             type = "nested")
#'
#' decompose3(nz_1949, special = "Maori")

decompose3.prcalc <- function(x,
                              special    = NULL,
                              alpha      = 2,
                              ...) {

  if (!inherits(x, "prcalc")) stop('Error! "prcalc" class is required.')
  if (length(x$m) < 2) stop('Error! a "prcalc" object must have a two-dimensional structure, for example, state and party, state and district.')

  special_names <- special

  v <- x$raw[, -1]
  s <- x$dist[, -1]

  temp_a <- 1 / (alpha^2 - alpha)

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

  special_v_prop
  special_s_prop

  #cat("##################\n")
  #cat("## Special term ##\n")
  #cat("##################\n")

  if (alpha == 0) {
    special <- sum(special_v_prop * log(special_v_prop / special_s_prop))
  } else if (alpha == 1) {
    special <- sum(special_s_prop * log(special_s_prop / special_v_prop))
  } else {
    special <- sum(special_v_prop * temp_a * ((special_s_prop / special_v_prop)^alpha - 1))
    #cat("p_h:", special_v_prop, "\n")
    #cat("q_h:", special_s_prop, "\n")
    #cat("========================================\n")
  }


  ##########################
  ## Reapportionment term ##
  ##########################

  temp_ra_vec <- c("s" = NA, "g" = NA)

  #cat("##########################\n")
  #cat("## Reapportionment term ##\n")
  #cat("##########################\n")

  for (i in 1:2) {
    temp_v <- v_prop[grepl(c("s", "g")[i], names(v_prop))]
    temp_s <- s_prop[grepl(c("s", "g")[i], names(s_prop))]

    v_hj <- temp_v / sum(temp_v)
    s_hj <- temp_s / sum(temp_s)

    if (alpha == 0) {
      temp_ra_vec[i] <- sum(v_hj * log(v_hj / s_hj))
    } else if (alpha == 1) {
      temp_ra_vec[i] <- sum(s_hj * log(s_hj / v_hj))
    } else {
      v_h <- special_vec1 / sum(special_vec1)
      s_h <- special_vec2 / sum(special_vec2)

      temp_ra_vec[i] <- sum(s_h[i]^alpha * v_h[i]^(1 - alpha) *
                              sum(v_hj * temp_a * ((s_hj / v_hj)^alpha - 1)))
      #cat("Type:", c("s", "g")[i], "\n")
      #cat("q_h:", s_h[i], "\n")
      #cat("p_h:", v_h[i], "\n")
      #cat("q_hj:", s_hj, "\n")
      #cat("p_hj:", v_hj, "\n")
      #cat("========================================\n")
    }


  }

  if (alpha == 0) {
    ra <- sum(special_v_prop * temp_ra_vec)
  } else if (alpha == 1) {
    ra <- sum(special_s_prop * temp_ra_vec)
  } else {
    ra <- sum(temp_ra_vec)
  }

  ########################
  ## Redistricting term ##
  ########################

  temp_rd_vec <- c("s" = NA, "g" = NA)

  #cat("########################\n")
  #cat("## Redistricting term ##\n")
  #cat("########################\n")

  for (i in 1:2) {
    temp_v <- v_prop[grepl(c("s", "g")[i], names(v_prop))]
    temp_s <- s_prop[grepl(c("s", "g")[i], names(s_prop))]

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
        temp_3_2 <- sum(s_hj[j]^alpha * v_hj[j]^(1 - alpha) * temp_3_1)
        temp[j]  <- sum(s_h[i]^alpha  * v_h[i]^(1 - alpha)  * temp_3_2)
        #cat("Type:", c("s", "g")[i], "\n")
        #cat("District:", names(temp_v)[j], "\n")
        #cat("q_h:", s_h[i], "\n")
        #cat("p_h:", v_h[i], "\n")
        #cat("q_hj:", s_hj[j], "\n")
        #cat("p_hj:", v_hj[j], "\n")
        #cat("q_hji:", s_hji, "\n")
        #cat("p_hji:", v_hji, "\n")
        #cat("p_hji:", v_hji, "\n")
        #cat("========================================\n")
      }
    }

    if (alpha == 0) {
      temp_rd_vec[i] <- sum(v_hj * temp)
    } else if (alpha == 1) {
      temp_rd_vec[i] <- sum(s_hj * temp)
    } else {
      temp_rd_vec[i] <- sum(temp)
    }

  }

  if (alpha == 0) {
    rd <- sum(special_v_prop * temp_rd_vec)
  } else if (alpha == 1) {
    rd <- sum(special_s_prop * temp_rd_vec)
  } else {
    rd <- sum(temp_rd_vec)
  }

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
