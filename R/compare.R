#' @param x a list.
#' @param ... Ignored
#'
#' @rdname compare
#'
#' @export
#'
compare <- function(x, ...) {
  UseMethod("compare", x)
}

#' Comparison multiple `prcalc`, `prcalc_index`, or `prcalc_decomposition` objects.
#'
#' @param x a list. All elements in the list must be `prcalc`, `prcalc_index`, or `prcalc_decomposition` objects.
#' @param prop Default is `FALSE`.
#' @param ... Ignored
#'
#' @rdname compare
#'
#' @import dplyr
#'
#' @return
#' A `prcalc_compare`, `prcalc_index_compare`, or `prcalc_decomposition_compare` object
#' @export
#'
#' @examples
#' data(jp_upper_2019)
#'
#' pr_obj1 <- prcalc(jp_upper_2019, m = 50, method = "dt")
#' pr_obj2 <- prcalc(jp_upper_2019, m = 50, method = "dt", threshold = 0.025)
#' pr_obj3 <- prcalc(jp_upper_2019, m = 50, method = "dt", threshold = 0.05)
#'
#' compare(list("t = 0%" = pr_obj1, "t = 2.5%" = pr_obj2, "t = 5%" = pr_obj3))
#'
#' list("t = 0%"   = index(pr_obj1),
#'      "t = 2.5%" = index(pr_obj2),
#'      "t = 5%"   = index(pr_obj3)) |>
#'   compare()

compare.list <- function (x,
                          prop = FALSE,
                          ...) {

  if (is.null(names(x))) {
    m_names <- paste0("Model", 1:length(x))
  } else {
    m_names <- names(x)
  }

  if (is.list(x) &
      length (x) >= 2 &
      all(unlist(lapply(x, class)) == "prcalc")) {

    for (i in 1:length(x)) {
      if (!all(x[[1]]$raw[, 1] == x[[i]]$raw[, 1])) {
        stop("Error")
      }
    }

    result <- as_tibble(x[[1]]$dist)[, 1]

    for (i in 1:length(x)) {
      result[, m_names[i]] <- rowSums(as_tibble(x[[i]]$dist)[, -1])
    }

    if (prop) {
      result <- result |>
        mutate(across(-1, ~(.x / sum(.x))))
    }

    structure(result, class = c("prcalc_compare", "data.frame"))

  } else if (is.list(x) &
             length (x) >= 2 &
             all(unlist(lapply(x, class)) == "prcalc_index")) {

    result <- tibble(ID    = names(x[[1]]),
                     Index = attr(x[[1]], "labels"))

    for (i in 1:length(x)) {
      result[, m_names[i]] <- x[[i]]
    }

    structure(result, class = c("prcalc_index_compare", "data.frame"))

  } else if (is.list(x) &
             length (x) >= 2 &
             all(unlist(lapply(x, class)) == "prcalc_decomposition")) {

    if (length(x[[1]]) == 3) {
      result <- tibble(Type = c("Alpha-divergence",
                                "Reapportionment",
                                "Redistricting"))
    } else if (length(x[[1]]) == 4) {
      result <- tibble(Type = c("Alpha-divergence",
                                "Special",
                                "Reapportionment",
                                "Redistricting"))
    }

    for (i in 1:length(x)) {
      result[, m_names[i]] <- as.numeric(x[[i]])
    }

    structure(result, class = c("prcalc_decomposition_compare", "data.frame"))

  } else {
    stop("Error")
  }

}
