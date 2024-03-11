library(tidyverse)
library(PRcalc)
# https://www.sciencedirect.com/science/article/pii/S0261379421000226?via%3Dihub
# https://www.sciencedirect.com/science/article/pii/S0165489618300155?via%3Dihub
# NZ (1949)
# D0: 0.0139881640653595
# Special: 0.00468607442617597
# Reapportionment: 3.76154967369974E-06
# Redistricting: 0.00929832808950988
# NZ (2011)
# D0: 0.00174951717785439
# Special: 0.00124797566628941
# Reapportionment: 2.04128780587274E-06
# Redistricting: 0.000499500223759176

nz_raw <- read_csv("altdoc/data/nz_sample.csv")

nz <- nz_raw |>
  filter(yr == 1949) |>
  select(sub, cst_n, pev1, mag) |>
  as_prcalc(region = "sub",
            district = "cst_n",
            population = "pev1",
            magnitude = "mag")

nz

decompose3(nz, special = "Maori")

special_name <- "Maori"

total_v <- sum(colSums(nz$raw[, -1]))
total_s <- sum(colSums(nz$dist[, -1]))

special_v <- sum(colSums(nz$raw[, -1])[special_name])
special_s <- sum(colSums(nz$dist[, -1])[special_name])

general_v <- total_v - sum(special_v)
general_s <- total_s - sum(special_s)

special_vec1 <- c(special_v, general_v)
special_vec2 <- c(special_s, general_s)

special_v_prop <- special_vec1 / sum(special_vec1)
special_s_prop <- special_vec2 / sum(special_vec2)

special <- sum(special_v_prop * log(special_v_prop / special_s_prop))

index(nz, alpha = 2, as_disprop = FALSE)

decompose3(nz, special = "Maori", alpha = 0, as_disprop = FALSE)

nz







temp_rd_vec <- rep(NA, length(x$m))

for (i in c("s", "g")) {
  temp_v <- v_prop[grepl(i, names(v_prop))]
  temp_s <- s_prop[grepl(i, names(s_prop))]

  temp1 <- c()

  for (j in 1:length(temp_v)) {
    v_hj <- temp_v / sum(temp_v)

    temp2 <- c()
    for (k in grep(i, names(v_prop))) {
      #print(names(v_prop)[k])
      v_hji <- v[, k]
      s_hji <- s[, k]

      s_hji <- s_hji[v_hji > 0]
      v_hji <- v_hji[v_hji > 0]

      s_hji <- s_hji / sum(s_hji)
      v_hji <- v_hji / sum(v_hji)

      temp2[k] <- sum(v_hji * log(v_hji / s_hji))
      cat(i, "/", j, "/", k, ":", temp2, "\n")
    }
    temp1[j] <- sum(temp2)
    #print(temp1)
  }

  temp_rd_vec[i] <- sum(v_hj * temp2)

}
