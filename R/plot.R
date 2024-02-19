#' Visualization of a \code{prcalc} object.
#'
#' @method plot prcalc
#'
#' @param x a `prcalc` object.
#' @param type a plot of votes (`"raw"`), allocation (`"dist"`), or both (`"both"`). Default is `"both"`.
#' @param prop 割合で表示。If `type` is `"both"`, it is ignored. Default is `TRUE`.
#' @param show_total 合計を表示。Default is `TRUE`.
#' @param by Facet分割の単位（`"block"` or `"party"`）。Default is `"block"`
#' @param subset_b 一部のブロックのみ出力
#' @param subset_p 一部の政党のみ出力
#' @param free_y If `FALSE`, y-axes are fixed over all facets. Default is `TRUE`.
#' @param font_size a font size.
#' @param facet_col a number of columns of facets.
#' @param xlab a label of x-axis.
#' @param ylab a label of y-axis.
#' @param title a title of plot.
#' @param caption a caption of plot.
#' @param legend_pos a position of legend. Default is `"bottom"`
#' @param ... Ignored
#'
#' @import dplyr
#' @import tidyr
#' @import ggplot2
#' @import forcats
#'
#' @return
#' A \code{ggplot} object.
#' @export
#'
#' @examples
#' data(jp_upper_2019)
#' data(jp_lower_2021)
#'
#' pr_obj1 <- prcalc(jp_upper_2019, m = 50, method = "dt")
#' plot(pr_obj1)
#'
#' pr_obj2 <- prcalc(jp_lower_2021,
#'                   m = c(8, 14, 20, 21, 17, 11, 21, 30, 11, 6, 21),
#'                   method = "hare")
#' plot(pr_obj2, subset_p = c("自民", "公明", "立憲", "維新", "国民"))
#' plot(pr_obj2, subset_b = c("Tokyo", "Kinki"), facet_col = 1)
#' plot(pr_obj2, by = "party",
#'      subset_p = c("自民", "公明", "立憲", "維新"),
#'      subset_b = c("Hokkaido", "Tohoku", "Tokyo", "Kinki"))
#'

plot.prcalc <- function (x,
                         type       = "both",
                         prop       = TRUE,
                         show_total = TRUE,
                         by         = "block",
                         subset_b   = NULL,
                         subset_p   = NULL,
                         free_y     = FALSE,
                         font_size  = 12,
                         facet_col  = 4,
                         legend_pos = "bottom",
                         xlab       = "Parties",
                         ylab       = "Distribution",
                         title      = NULL,
                         caption    = NULL,
                         ...) {

  block <- party <- values <- NULL

  raw_df  <- as_tibble(x$raw)
  dist_df <- as_tibble(x$dist)

  if (show_total & ncol(raw_df) > 2) {
    raw_df  <- raw_df |> mutate(Total = rowSums(raw_df[, -1]))
    dist_df <- dist_df |> mutate(Total = rowSums(dist_df[, -1]))
  }

  if (type == "both") {
    raw_df  <- raw_df |> mutate(across(-1, ~(.x / sum(.x))))
    dist_df <- dist_df |> mutate(across(-1, ~(.x / sum(.x))))

    raw_df <- raw_df |>
      pivot_longer(cols      = -1,
                   names_to  = "block",
                   values_to = "values")

    dist_df <- dist_df |>
      pivot_longer(cols      = -1,
                   names_to  = "block",
                   values_to = "values")

    temp_df <- bind_rows(list("Raw" = raw_df, "Dist" = dist_df),
                         .id = "Type")

    names(temp_df) <- c("type", "party", "block", "values")

  } else if (type == "raw") {

    if (prop) raw_df <- raw_df |> mutate(across(-1, ~(.x / sum(.x))))

    raw_df <- raw_df |>
      pivot_longer(cols      = -1,
                   names_to  = "block",
                   values_to = "values")

    temp_df <- raw_df

    names(temp_df) <- c("party", "block", "values")

  } else if (type == "dist") {

    if (prop) dist_df  <- dist_df |> mutate(across(-1, ~(.x / sum(.x))))

    dist_df <- dist_df |>
      pivot_longer(cols      = -1,
                   names_to  = "block",
                   values_to = "values")

    temp_df <- dist_df

    names(temp_df) <- c("party", "block", "values")

  }

  if (!is.null(subset_b)) temp_df <- filter(temp_df, block %in% subset_b)
  if (!is.null(subset_p)) temp_df <- filter(temp_df, party %in% subset_p)

  temp_df <- temp_df |>
    mutate(type  = fct_inorder(type),
           party = fct_inorder(party),
           block = fct_inorder(block))

  if (ncol(x$raw) == 2) {
    result <- temp_df |>
      ggplot(aes(x = party, y = values))
  } else {
    if (by == "block") {
      result <- temp_df |>
        ggplot(aes(x = party, y = values)) +
        facet_wrap(~block,
                   scales = if_else(free_y, "free_y", "fixed"),
                   ncol   = facet_col)
    } else if (by == "party") {
      result <- temp_df |>
        ggplot(aes(x = block, y = values)) +
        facet_wrap(~party,
                   scales = if_else(free_y, "free_y", "fixed"),
                   ncol   = facet_col)
    }
  }

  if (type %in% c("raw", "dist")) {
    result <- result +
      geom_col() +
      labs(x = xlab, y = ylab, title = title, caption = caption) +
      theme_bw(base_size = font_size)
  } else {
    result <- result +
      geom_col(aes(fill = type), position = position_dodge2()) +
      labs(x = xlab, y = ylab, title = title, caption = caption, fill = "") +
      theme_bw(base_size = font_size) +
      theme(legend.position = legend_pos)
  }

  result

}

#' Visualization of a \code{prcalc_compare} object.
#'
#' @method plot prcalc_compare
#'
#' @param x a `prcalc_compare` object.
#' @param bar_width Default is `0.75`.
#' @param facet 政党ごとにfacet分割. Default is `FALSE`.
#' @param free_y Default is `TRUE`.
#' @param font_size a font size.
#' @param facet_col a number of columns of facets.
#' @param title a title of plot.
#' @param caption a caption of plot.
#' @param legend_pos a position of legend. Default is `"bottom"`
#' @param ... Ignored
#'
#' @import dplyr
#' @import tidyr
#' @import ggplot2
#' @import forcats
#'
#' @return
#' A \code{ggplot} object.
#' @export
#'
#' @examples
#' data(jp_upper_2019)
#'
#' pr_obj1 <- prcalc(jp_upper_2019, m = 50, method = "dt")
#' pr_obj2 <- prcalc(jp_upper_2019, m = 50, method = "dt", threshold = 0.025)
#' pr_obj3 <- prcalc(jp_upper_2019, m = 50, method = "dt", threshold = 0.05)
#'
#' list("t = 0%"   = pr_obj1,
#'      "t = 2.5%" = pr_obj2,
#'      "t = 5%"   = pr_obj3) |>
#'   compare() |>
#'   plot()

plot.prcalc_compare <- function (x,
                                 bar_width  = 0.75,
                                 facet      = FALSE,
                                 free_y     = TRUE,
                                 font_size  = 12,
                                 facet_col  = 4,
                                 title      = NULL,
                                 caption    = NULL,
                                 legend_pos = "bottom",
                                 ...) {

  Party <- Model <- Value <- NULL

  data <- as_tibble(x)

  data <- data |>
    pivot_longer(cols      = -1,
                 names_to  = "Model",
                 values_to = "Value")

  names(data)[1] <- "Party"

  if (facet) {
    result <- data |>
      mutate(Party = fct_inorder(Party),
             Model = fct_inorder(Model)) |>
      ggplot(aes(x = Model, y = Value)) +
      facet_wrap(~Party,
                 scales = if_else(free_y, "free_y", "fixed"),
                 ncol = facet_col)
  } else {
    result <- data |>
      mutate(Party = fct_inorder(Party),
             Model = fct_inorder(Model)) |>
      ggplot(aes(x = Party, y = Value, fill = Model))
  }

  result <- result +
    geom_col(width = bar_width,
             position = position_dodge2()) +
    labs(x = "Parties", y = "Distribution",
         title = title, caption = caption) +
    theme_bw(base_size = font_size) +
    theme(legend.position = legend_pos)

  return(result)
}

#' Visualization of a \code{prcalc_index} object.
#'
#' @method plot prcalc_index
#'
#' @param x a `prcalc_index` object.
#' @param index a
#' @param style Plot style. Lollipop (`"lollipop`) or bar plot (`"bar"`). Default is `"bar"`.
#' @param bar_width Default is `0.75`.
#' @param point_size Default is `5`.
#' @param font_size a font size. Default is `12`.
#' @param title a title of plot.
#' @param caption a caption of plot.
#' @param ... Ignored
#'
#' @import dplyr
#' @import tidyr
#' @import ggplot2
#' @import forcats
#'
#' @return
#' A \code{ggplot} object.
#' @export
#'
#' @examples
#' data(jp_upper_2019)
#'
#' pr_obj <- prcalc(jp_upper_2019, m = 50, method = "dt")
#'
#' plot(index(pr_obj))
#'
#' plot(index(pr_obj), style = "lollipop",
#'      index = c("lh", "gallagher", "rae", "dhondt", "ad"))
#'

plot.prcalc_index <- function (x,
                               index      = NULL,
                               style      = "bar",
                               bar_width  = 0.75,
                               point_size = 5,
                               font_size  = 12,
                               title      = NULL,
                               caption    = NULL,
                               ...) {

  ID <- Index <- Value <- NULL

  data <- enframe(x$values, name = "ID", value = "Value") |>
    mutate(Index = x$names, .after = ID)

  if (!is.null(index)) {
    data <- data |> filter(ID %in% index)
  }

  if (nrow(data) < 1) {
    stop("Error")
  }

  result <- data |>
    mutate(Index = fct_inorder(Index)) |>
    ggplot(aes(x = Value, y = Index))

  if (style == "bar") {
    result <- result +
      geom_col(width = bar_width)
  } else if (style == "lollipop") {
    result <- result +
      geom_segment(aes(x = 0, xend = Value,
                       y = Index, yend = Index)) +
      geom_point(shape = 21, size = point_size,
                 color = "white", fill = "black")
  }

  result <- result +
    labs(x = "Indices", y = "Values", title = title, caption = caption) +
    scale_y_discrete(limits = rev) +
    theme_bw(base_size = font_size)

  result
}

#' Visualization of a \code{prcalc_index_compare} object.
#'
#' @method plot prcalc_index_compare
#'
#' @param x a `prcalc_index_compare` object.
#' @param index a
#' @param style Plot style. Lollipop (`"lollipop`) or bar plot (`"bar"`). Default is `"bar"`.
#' @param bar_width Default is `0.75`.
#' @param point_size Default is `5`.
#' @param facet 政党ごとにfacet分割. Default is `FALSE`.
#' @param free_x Default is `TRUE`.
#' @param font_size a font size. Default is `12`.
#' @param facet_col a number of columns of facets. Default is `4`.
#' @param title a title of plot.
#' @param caption a caption of plot.
#' @param legend_pos a position of legend. Default is `"bottom"`
#' @param ... Ignored
#'
#' @import dplyr
#' @import tidyr
#' @import ggplot2
#' @import forcats
#'
#' @return
#' A \code{ggplot} object.
#' @export
#'
#' @examples
#' data(jp_upper_2019)
#'
#' pr_obj1 <- prcalc(jp_upper_2019, m = 50, method = "dt")
#' pr_obj2 <- prcalc(jp_upper_2019, m = 50, method = "dt", threshold = 0.025)
#' pr_obj3 <- prcalc(jp_upper_2019, m = 50, method = "dt", threshold = 0.05)
#'
#' list("t = 0%"   = index(pr_obj1),
#'      "t = 2.5%" = index(pr_obj2),
#'      "t = 5%"   = index(pr_obj3)) |>
#'   compare() |>
#'   plot()
#'
#' list("t = 0%"   = index(pr_obj1),
#'      "t = 2.5%" = index(pr_obj2),
#'      "t = 5%"   = index(pr_obj3)) |>
#'   compare() |>
#'   plot(index = c("lh", "gallagher", "rae", "dhondt", "ad"))

plot.prcalc_index_compare <- function (x,
                                       index      = NULL,
                                       style      = "bar",
                                       bar_width  = 0.75,
                                       point_size = 5,
                                       facet      = FALSE,
                                       free_x     = TRUE,
                                       font_size  = 12,
                                       facet_col  = 4,
                                       title      = NULL,
                                       caption    = NULL,
                                       legend_pos = "bottom",
                                       ...) {

  ID <- Index <- Model <- Value <- NULL

  data <- x |>
    pivot_longer(cols      = -c("ID", "Index"),
                 names_to  = "Model",
                 values_to = "Value")

  if (!is.null(index)) {
    data <- data |> filter(ID %in% index)
  }

  if (nrow(data) < 1) {
    stop("Error")
  }

  if (facet) {
    result <- data |>
      mutate(Index = fct_inorder(Index),
             Model = fct_rev(fct_inorder(Model))) |>
      ggplot(aes(x = Value, y = Model)) +
      facet_wrap(~Index,
                 scales = if_else(free_x, "free_x", "fixed"),
                 ncol = facet_col)
  } else {
    result <- data |>
      mutate(Index = fct_rev(fct_inorder(Index)),
             Model = fct_rev(fct_inorder(Model))) |>
      ggplot(aes(x = Value, y = Index, fill = Model)) +
      guides(fill = guide_legend(reverse = TRUE))
  }

  if (style == "bar") {
    result <- result +
      geom_col(width = bar_width,
               position = position_dodge2())
  } else if (style == "lollipop") {
    if (facet) {
      result <- result +
        geom_segment(aes(x = 0, xend = Value,
                         y = Model, yend = Model)) +
        geom_point(shape = 21, size = point_size,
                   color = "white", fill = "black")
    } else {
      result <- result +
        geom_segment(aes(x = 0, xend = Value,
                         y = Index, yend = Index)) +
        geom_point(shape = 21, size = point_size,
                   color = "white") +
        scale_y_discrete(limits = rev)
    }

  }

  result <- result +
    labs(x = "Values",
         y = if_else(facet, "Models", "Indices"),
         title = title, caption = caption) +
    theme_bw(base_size = font_size) +
    theme(legend.position = legend_pos)

  result
}
