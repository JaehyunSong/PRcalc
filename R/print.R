#' Printing a `prcalc` object.
#'
#' @method print prcalc
#'
#' @param x a `prcalc` object.
#' @param prop If `TRUE`, voteshare and seatshare are displayed. Default is `FALSE`.
#' @param show_total If `TRUE`, total vote (share) and seat (share) are displayed on the last column. Default is `TRUE`.
#' @param use_gt Use `gt` package? Default is `FALSE`.
#' @param digits the number of decimal places. Default is 3.
#' @param ... ignored.
#'
#' @import dplyr
#' @import gt
#'
#' @seealso
#' \code{\link{summary.prcalc}}
#'
#' @export
#'
#' @examples
#' data(jp_upper_2019)
#' jp2019 <- prcalc(jp_upper_2019, m = 50, method = "dt")
#'
#' print(jp2019)
#'

print.prcalc <- function(x,
                         prop       = FALSE,
                         show_total = TRUE,
                         use_gt     = FALSE,
                         digits     = 3,
                         ...) {

  Type <- NULL

  result_raw  <- x$raw
  result_dist <- x$dist

  result_raw  <- result_raw |> mutate(across(1, ~as.character(.x)))
  result_dist <- result_dist |> mutate(across(1, ~as.character(.x)))

  if (show_total & ncol(result_raw) > 2) {
    result_raw  <- result_raw |> mutate(Total = rowSums(result_raw[, -1]))
    result_dist <- result_dist |> mutate(Total = rowSums(result_dist[, -1]))
  }

  if (prop) {
    result_raw  <- result_raw |> mutate(across(-1, ~(.x / sum(.x))))
    result_dist <- result_dist |> mutate(across(-1, ~(.x / sum(.x))))
  }

  if (use_gt) {

    result <- list("Raw"          = result_raw,
                   "Distribution" = result_dist) |>
      bind_rows(.id = "Type")

    result_tbl <- result |>
      group_by(Type) |>
      gt() |>
      tab_footnote(paste("Allocation method:", x$method)) |>
      tab_footnote(paste("Extra parameter:", x$extra)) |>
      tab_footnote(paste("Threshold:", x$threshold))

    if (prop) {
       result_tbl |>
        fmt_number(columns = 2:ncol(result), decimals = digits)
    } else{
      result_tbl
    }
  } else {
    cat("Raw:\n")
    print(result_raw, digits = {if (prop) {digits}})
    cat("\n")
    cat("Result:\n")
    print(result_dist, digits = {if (prop) {digits}})
    cat("\nParameters:\n")
    cat("  Allocation method:", x$method, "\n")
    cat("  Extra parameter:", x$extra, "\n")
    cat("  Threshold:", x$threshold, "\n")
    cat("\nMagnitude: ")
    if (length(x$m) == 1) {
      cat(x$m)
    } else{
      cat("\n")
      print(x$m)
    }
  }

}

#' Printing a `prcalc_compare` object.
#'
#' @method print prcalc_compare
#'
#' @param x a `prcalc_compare` object.
#' @param subset a
#' @param prop a
#' @param use_gt Use `gt` packages? Default is `FALSE`.
#' @param digits the number of decimal places. Default is 3.
#' @param ... ignored.
#'
#' @import dplyr
#' @import tibble
#' @import gt
#'
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
#' list("t = 0%"   = pr_obj1,
#'      "t = 2.5%" = pr_obj2,
#'      "t = 5%"   = pr_obj3) |>
#'   compare() |>
#'   print()
#'
#' list("t = 0%"   = pr_obj1,
#'      "t = 2.5%" = pr_obj2,
#'      "t = 5%"   = pr_obj3) |>
#'   compare() |>
#'   print(subset = c("自民", "公明", "立憲", "共産", "維新"))
#'

print.prcalc_compare <- function (x,
                                  subset = NULL,
                                  prop   = FALSE,
                                  use_gt = FALSE,
                                  digits = 3,
                                  ...) {
  result <- as_tibble(x)

  if (prop) {
    result <- result |> mutate(across(-1, ~(.x / sum(.x))))
  }

  if (!is.null(subset)) {
    result <- result |>
      filter(if_any(1, \(x) x %in% subset))
  }

  if (use_gt) {
    if (prop) {
      result |>
        gt() |>
        fmt_number(decimals = digits)
    } else {
      result |>
        gt()
    }
  } else{
    print(as.data.frame(result), digits = digits)
  }

}

#' Printing a `prcalc_index` object.
#'
#' @method print prcalc_index
#'
#' @param x a `prcalc_index` object.
#' @param subset a
#' @param hide_id a
#' @param use_gt a
#' @param digits the number of decimal places. Default is 3.
#' @param ... ignored.
#'
#' @import dplyr
#' @import gt
#'
#' @export
#'
#' @examples
#' data(jp_upper_2019)
#'
#' pr_obj <- prcalc(jp_upper_2019, m = 50, method = "dt")
#'
#' index(pr_obj)
#'
#' index(pr_obj) |>
#'   print(subset = c("lh", "gallagher", "rae", "dhondt", "ad"))

print.prcalc_index <- function (x,
                                subset  = NULL,
                                hide_id = FALSE,
                                use_gt  = FALSE,
                                digits  = 3,
                                ...) {

  ID <- Value <- NULL

  result <- enframe(x$values, name = "ID", value = "Value") |>
    mutate(Index = x$names, .after = ID) |>
    data.frame()

  if (!is.null(subset)) {
    result <- result |>
      filter(if_any(1, \(x) x %in% subset))
  }

  if (hide_id) result <- select(result, -ID)

  if (use_gt) {
    result |>
      gt() |>
      fmt_number(columns = Value, decimals = digits)
  } else{
    print(result, digits = digits)
  }

}

#' Printing a `prcalc_index_compare` object.
#'
#' @method print prcalc_index_compare
#'
#' @param x a `prcalc_index_compare` object.
#' @param subset a
#' @param hide_id a
#' @param use_gt a
#' @param digits the number of decimal places. Default is 3.
#' @param ... ignored.
#'
#' @import dplyr
#' @import tibble
#' @import gt
#'
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
#'   compare() |>
#'   print(subset  = c("lh", "gallagher", "rae", "dhondt", "ad"),
#'         hide_id = TRUE)
#'

print.prcalc_index_compare <- function (x,
                                        subset  = NULL,
                                        hide_id = FALSE,
                                        use_gt  = FALSE,
                                        digits  = 3,
                                        ...) {

  ID <- NULL

  result <- as_tibble(x)

  if (!is.null(subset)) {
    result <- result |>
      filter(ID %in% subset)
  }

  if (hide_id) result <- select(result, -ID)

  if (use_gt) {
    result |>
      gt() |>
      fmt_number(decimals = digits)
  } else{
    print(as.data.frame(result), digits = digits)
  }

}
