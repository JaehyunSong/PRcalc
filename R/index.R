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

#' 各種指標の計算
#'
#' @param x a `prcalc` object.
#' @param k a parameter for Generalized Gallagher index. Default is `2`.
#' @param eta a parameter for Atkinson index. Default is `2`.
#' @param alpha a parameter for Generalized Entropy and alpha-divergence. Default is `2`.
#' @param ... ignored
#'
#' @rdname index
#'
#' @import tibble
#'
#' @return
#' a \code{prcalc_index} object.
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
#' pr_obj <- prcalc(jp_upper_2019, m = 50, method = "dt")
#'
#' obj_index <- index(pr_obj)
#' obj_index
#'
#' obj_index$values["gallagher"] # Extract Gallagher index

index.prcalc <- function(x,
                         k     = 2,
                         eta   = 2,
                         alpha = 2,
                         ...) {

  ID <- Value <- NULL

  v <- rowSums(as_tibble(x$raw)[, -1])
  v <- v / sum(v)
  s <- rowSums(as_tibble(x$dist)[, -1])
  s <- s / sum(s)
  v <- v[order(s, decreasing = TRUE)]
  s <- s[order(s, decreasing = TRUE)]
  p <- length(raw)

  # v: voteshare (v[1] > v[2] > ...)
  # s: seatshare (s[1] > s[2] > ...)
  # p: number of parties

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
  grofman <- (1 / (1 / sum(s^2))) * sum(abs(s - v))
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
  gini <- 0
  # Atkinson
  atkinson <- 1 - (sum(v * (s / v)^(1 - eta)))^(1 / (1 - eta))
  # Generalized Entropy
  entropy <- (1 / (alpha^2 - alpha)) * (sum(v * (s / v)^alpha) - 1)
  # Sainte-Laguë index
  sl <- sum((s - v)^2 / (v))
  # Cox & Shugart
  cs <- sum((s - mean(s)) * (v - mean(v))) / sum((v - mean(v))^2)
  # Farina
  farina <- acos(sum(s * v) / sqrt(sum(s^2) * sum(v^2))) * (10 / 9)
  # Ortona
  ortona <- sum(abs(s - v)) / sum(abs(I(s == max(s)) - v))
  # Fragnelli
  fragnelli <- 0
  # Gambarelli & Biella
  gb <- 0
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
  kl <- sum(s[s > 0] * log(s[s > 0] / v[s > 0]))
  # Likelihood Ratio Statistic
  lr <- 2 * sum(v[s > 0] * log(v[s > 0] / s[s > 0]))
  # Chi Squared
  chisq <- sum((v[s > 0] - s[s > 0])^2 / s[s > 0])
  # Hellinger Distance
  hellinger <- (1 / sqrt(2)) * sqrt(sum((sqrt(s) - sqrt(v))^2))
  # alpha-divergence
  if (alpha == 0) {
    ad <- sum(v[s > 0] * log(v[s > 0] / s[s > 0]))
  } else if (alpha == 1) {
    ad <- sum(s[s > 0] * log(s[s > 0] / v[s > 0]))
  } else {
    ad <- sum(v[s > 0] * (1 / (alpha * (alpha - 1))) * ((s[s > 0] / v[s > 0])^alpha - 1))
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
    "entropy"     = entropy,
    "sl"          = sl,
    "cs"          = cs,
    "farina"      = farina,
    "ortona"      = ortona,
    "fragnelli"   = fragnelli,
    "gb"          = gb,
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

  result <- list(values = index_vec,
                 names  = c("D\u2019Hondt",
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
                            "Generalized Entropy",
                            "Sainte-Lagu\u00eb",
                            "Cox & Shugart",
                            "Farina",
                            "Ortona",
                            "Fragnelli",
                            "Gambarelli & Biella",
                            "Cosine Dissimilarity",
                            "Lebeda\u2019s RR (Mixture D\u2019Hondt)",
                            "Lebeda\u2019s ARR",
                            "Lebeda\u2019s SRR",
                            "Lebeda\u2019s WDRR",
                            "Kullback-Leibler Surprise",
                            "Likelihood Ratio Statistic",
                            "Chi Squared",
                            "Hellinger Distance",
                            "alpha-Divergence"))

  structure(result, class = c("prcalc_index"))
}
