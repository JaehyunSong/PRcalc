#' @param x a `prcalc` object.
#' @param ... ignored
#'
#' @rdname index
#'
#' @export
#'
index <- function(x, ...) {
  UseMethod("index")
}

#' Calculate the disproportionality indices.
#'
#' @param x a `prcalc` object.
#' @param k a parameter for Generalized Gallagher index. Default is `2`.
#' @param eta a parameter for Atkinson index. Default is `2`.
#' @param alpha a parameter for alpha-divergence. Default is `2`.
#' @param omit_zero If `TRUE`, parties with 0 votes and 0 seats are ignored. Default is `TRUE`.
#' @param ... ignored
#'
#' @rdname index
#'
#' @import tibble
#'
#' @return
#' a `prcalc_index` object.
#' @export
#'
#' @references
#' \itemize{
#' \item{Laakso, Markku and Rein Taagepera. 1979. ""Effective" Number of Parties: A Measure with Application to West Europe". Comparative Political Studies. 12 (1): 3–27.}
#' \item{Gallagher, Michael. 1991. "Proportionality, Disproportionality and Electoral Systems". Electoral Studies. 10: 33–51.}
#' }
#'
#' @examples
#' data(jp_upper_2019)
#'
#' obj <- prcalc(jp_upper_2019, m = 50, method = "dt")
#'
#' obj_index <- index(obj)
#' obj_index
#'
#' obj_index["gallagher"] # Extract Gallagher index

index.prcalc <- function(x,
                         k         = 2,
                         eta       = 2,
                         alpha     = 2,
                         omit_zero = TRUE,
                         ...) {

  ID <- Value <- NULL

  # v: voteshare (v[1] > v[2] > ...)
  # s: seatshare (s[1] > s[2] > ...)
  # p: number of parties
  v     <- rowSums(as_tibble(x$raw)[, -1])
  s     <- rowSums(as_tibble(x$dist)[, -1])

  if (omit_zero) {
    v        <- v / sum(v)
    s        <- s / sum(s)
    zero_ind <- (v == 0) & (s == 0)
    v        <- v[!zero_ind]
    s        <- s[!zero_ind]
  } else {
    v     <- v / sum(v)
    s     <- s / sum(s)
  }

  ord_i <- order(v, decreasing = TRUE)
  v     <- v[ord_i]
  s     <- s[ord_i]
  p     <- length(v)

  # D'Hondt
  dhondt <- max(s / v)
  # Monroe
  monroe <- sqrt(sum((s - v)^2) / (1 + sum(v^2)))
  # Maximum absolute deviation
  maxdev <- max(abs(s - v))
  # Rae index
  rae <- (1 / p) * sum(abs(s - v))
  # Loosemore–Hanby index
  lh <- (1 / 2) * sum(abs(s - v))
  # Grofman
  grofman <- (1 / (1 / sum(v^2))) * sum(abs(s - v))
  # Lijphart
  lijphart <- (abs(s[1] - v[1]) + abs(s[2] - v[2])) / 2
  # Gallagher index
  gallagher <- (sum((s - v)^2) * (1 / 2))^(1 / 2)
  # Generalized Gallagher
  g_gallagher <- (sum((s - v)^k) * (1 / k))^(1 / k)
  # Gatev
  gatev <- sqrt(sum((s - v)^2) / sum((s^2 + v^2)))
  # Ryabtsev
  ryabtsev <- sqrt(sum((s - v)^2) / sum((s + v)^2))
  # Szalai
  szalai <- sqrt((1 / p) * sum(((s - v) / (s + v))^2))
  # Weighted Szalai
  w_szalai <- sqrt((1 / 2) * sum((s - v)^2 / (s + v)))
  # Aleskerov & Platonov
  ap <- sum(I((s / v) > 1) * (s / v)) / sum(I((s / v) > 1))
  # Gini
  {
    gini_mod <- c(0, cumsum(v[order(s/v)]))
    gini_obs <- c(0, cumsum(s[order(s/v)]))
    gini <- 2 * (sum(gini_mod) - sum(gini_obs)) / p
  }
  # Atkinson
  atkinson <- 1 - (sum(v * (s / v)^(1 - eta)))^(1 / (1 - eta))
  # Generalized Entropy (Wada 2012)
  #if (alpha == 0) {
  #  entropy <- sum(v * log((sum(s) / sum(v)) / (s / v)))
  #} else if (alpha == 1) {
  #  entropy <- sum(v * (s / v) * log(s / v))
  #} else {
  #  entropy <- sum(v * (1 / (alpha^2 - alpha)) * ((s / v)^alpha - 1))
  #}
  # Sainte-Laguë index
  sl <- sum((s - v)^2 / (v))
  # Cox & Shugart
  cs <- sum((s - mean(s)) * (v - mean(v))) / sum((v - mean(v))^2)
  # Farina
  farina <- acos(sum(s * v) / sqrt(sum(s^2) * sum(v^2))) * (10 / 9)
  # Ortona
  ortona <- sum(abs(s - v)) / sum(abs(I(s == max(s)) - v))
  # Fragnelli
  # fragnelli <- 0
  # Gambarelli & Biella
  # gb <- 0
  # Cosine Dissimilarity
  cd <- 1 - (sum(s * v) / (sqrt(sum(s^2)) * sqrt(sum(v^2))))
  # Lebeda’s RR / Mixture D’Hondt
  rr <- 1 - (1 / (max(s / v)))
  # Lebeda’s ARR
  arr <- (1 / p) * (1 / (max(s / v)))
  # Lebeda’s SRR
  srr <- sqrt(sum((v - (s / max(s / v)))^2))
  # Lebeda’s WDRR
  wdrr <- (1 / 3) * ((sum(abs(v - s))) + (1 - (1 / max(s / v))))
  # Kullback-Leibler Surprise
  kl <- sum(s * log(s / v))
  # Likelihood Ratio Statistic
  lr <- 2 * sum(v * log(v / s))
  # Chi Squared
  chisq <- sum((v[s > 0] - s[s > 0])^2 / s[s > 0])
  # Hellinger Distance
  hellinger <- (1 / sqrt(2)) * sqrt(sum((sqrt(s) - sqrt(v))^2))
  # alpha-divergence
  if (alpha == 0) {
    # s = 0の場合、log(v / s)は Inf
    # s = v = 0なら NaN
    ad_vs <- log(v / s)
    ad_vs[is.nan(ad_vs)] <- 0
    ad <- sum(v * ad_vs)
  } else if (alpha == 1) {
    # s = 0の場合、log(s / v)は -Inf
    # s = v = 0なら NaN
    ad_sv <- log(s / v)
    ad_sv[s == 0] <- 0
    ad <- sum(s * ad_sv)
  } else {
    # alpha < 0、かつ s = 0の場合、Inf
    # s = v = 0なら NaN
    ad_sva <- (s / v)^alpha
    ad_sva[is.infinite(ad_sva) | is.nan(ad_sva)] <- 0
    ad <- sum(v * (1 / (alpha * (alpha - 1))) * (ad_sva - 1))
  }

  index_vec <- c(
    "dhondt"      = dhondt,
    "monroe"      = monroe,
    "maxdev"      = maxdev,
    "rae"         = rae,
    "lh"          = lh,
    "grofman"     = grofman,
    "lijphart"    = lijphart,
    "gallagher"   = gallagher,
    "g_gallagher" = g_gallagher,
    "gatev"       = gatev,
    "ryabtsev"    = ryabtsev,
    "szalai"      = szalai,
    "w_szalai"    = w_szalai,
    "ap"          = ap,
    "gini"        = gini,
    "atkinson"    = atkinson,
    #"entropy"     = entropy,
    "sl"          = sl,
    "cs"          = cs,
    "farina"      = farina,
    "ortona"      = ortona,
    #"fragnelli"   = fragnelli,
    #"gb"          = gb,
    "cd"          = cd,
    "rr"          = rr,
    "arr"         = arr,
    "srr"         = srr,
    "wdrr"        = wdrr,
    "kl"          = kl,
    "lr"          = lr,
    "chisq"       = chisq,
    "hellinger"   = hellinger,
    "ad"          = ad
  )

  result <- index_vec
  attr(result, "labels") <- c("D\u2019Hondt",
                              "Monroe",
                              "Maximum Absolute Deviation",
                              "Rae",
                              "Loosemore & Hanby",
                              "Grofman",
                              "Lijphart",
                              "Gallagher",
                              "Generalized Gallagher",
                              "Gatev",
                              "Ryabtsev",
                              "Szalai",
                              "Weighted Szalai",
                              "Aleskerov & Platonov",
                              "Gini",
                              "Atkinson",
                              #"Generalized Entropy",
                              "Sainte-Lagu\u00eb",
                              "Cox & Shugart",
                              "Farina",
                              "Ortona",
                              #"Fragnelli",
                              #"Gambarelli & Biella",
                              "Cosine Dissimilarity",
                              "Lebeda\u2019s RR (Mixture D\u2019Hondt)",
                              "Lebeda\u2019s ARR",
                              "Lebeda\u2019s SRR",
                              "Lebeda\u2019s WDRR",
                              "Kullback-Leibler Surprise",
                              "Likelihood Ratio Statistic",
                              "Chi Squared",
                              "Hellinger Distance",
                              "alpha-Divergence")

  structure(result, class = c("prcalc_index"))
}
