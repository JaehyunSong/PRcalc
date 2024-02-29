#' Visualization of a `prcalc` object.
#'
#' @method plot prcalc
#'
#' @param x a `prcalc` object.
#' @param type a plot of votes (`"raw"`), allocation (`"dist"`), or both (`"both"`). Default is `"both"`.
#' @param prop Output at a percentage. If `type` is `"both"`, it is ignored. Default is `TRUE`.
#' @param show_total If `TRUE`, a facet names "Total" is diplayed. Default is `TRUE`.
#' @param by Facets by blocks (`"block"`) or parties (`"party"`). Default is `"block"`.
#' @param subset_b a character vector of block names.
#' @param subset_p a character vector of party names.
#' @param free_y If `FALSE`, y-axes are fixed over all facets. Default is `TRUE`.
#' @param font_size a font size.
#' @param angle an angle of x-ticks label (0 to 90). Defualt is 0.
#' @param facet_col a number of columns of facets.
#' @param legend_pos a position of legend. Default is `"bottom"`
#' @param ... Ignored
#'
#' @import dplyr
#' @import tidyr
#' @import ggplot2
#' @import forcats
#'
#' @return
#' A `ggplot` object.
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
#' plot(pr_obj2, angle = 90)
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
                         angle      = 0,
                         facet_col  = 4,
                         legend_pos = "bottom",
                         ...) {

  block <- party <- values <- NULL

  raw_df  <- as_tibble(x$raw)
  dist_df <- as_tibble(x$dist)

  if (show_total & ncol(raw_df) > 2) {
    raw_df  <- raw_df |> mutate(Total = rowSums(raw_df[, -1]))
    dist_df <- dist_df |> mutate(Total = rowSums(dist_df[, -1]))
  }

  if (!(angle >= 0 & angle <= 90)) {
    stop("angle must be in 0 and 90.")
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
      labs(x = "Parties", y = "Distribution") +
      theme_bw(base_size = font_size)
  } else {
    result <- result +
      geom_col(aes(fill = type), position = position_dodge2()) +
      labs(x = "Parties", y = "Distribution", fill = "") +
      theme_bw(base_size = font_size) +
      theme(legend.position = legend_pos)
  }

  if (angle > 0) {
    result <- result +
      scale_x_discrete(guide = guide_axis(angle = angle))
  }

  result

}

#' Visualization of a `prcalc_compare` object.
#'
#' @method plot prcalc_compare
#'
#' @param x a `prcalc_compare` object.
#' @param bar_width Default is `0.75`.
#' @param facet Separate facets by parties? Default is `FALSE`.
#' @param free_y Default is `TRUE`.
#' @param font_size a font size. Default is `12`.
#' @param angle an angle of x-ticks label (`0` to `90`). Defualt is `0`.
#' @param facet_col a number of columns of facets. Default is `4`.
#' @param legend_pos a position of legend. Default is `"bottom"`
#' @param ... Ignored
#'
#' @import dplyr
#' @import tidyr
#' @import ggplot2
#' @import forcats
#'
#' @return
#' A `ggplot` object.
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
                                 angle      = 0,
                                 facet_col  = 4,
                                 legend_pos = "bottom",
                                 ...) {

  Party <- Model <- Value <- NULL

  if (!(angle >= 0 & angle <= 90)) {
    stop("angle must be in 0 and 90.")
  }

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
    labs(x = "Parties", y = "Distribution") +
    theme_bw(base_size = font_size) +
    theme(legend.position = legend_pos)

  if (angle > 0) {
    result <- result +
      scale_x_discrete(guide = guide_axis(angle = angle))
  }

  return(result)
}

#' Visualization of a `prcalc_index` object.
#'
#' @method plot prcalc_index
#'
#' @param x a `prcalc_index` object.
#' @param index a character vector. A subset of indices.
#' @param style Plot style. Lollipop (`"lollipop`) or bar plot (`"bar"`). Default is `"bar"`.
#' @param bar_width Default is `0.75`.
#' @param point_size Default is `5`.
#' @param font_size a font size. Default is `12`.
#' @param ... Ignored
#'
#' @import dplyr
#' @import tidyr
#' @import ggplot2
#' @import forcats
#'
#' @return
#' A `ggplot` object.
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
                               ...) {

  ID <- Index <- Value <- NULL

  data <- enframe(x, name = "ID", value = "Value") |>
    mutate(Index = attr(x, "labels"), .after = ID)

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
    labs(x = "Indices", y = "Values") +
    scale_y_discrete(limits = rev) +
    theme_bw(base_size = font_size)

  result
}

#' Visualization of a `prcalc_index_compare` object.
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
#' @param legend_pos a position of legend. Default is `"bottom"`
#' @param ... Ignored
#'
#' @import dplyr
#' @import tidyr
#' @import ggplot2
#' @import forcats
#'
#' @return
#' A `ggplot` object.
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
         y = if_else(facet, "Models", "Indices")) +
    theme_bw(base_size = font_size) +
    theme(legend.position = legend_pos)

  result
}

#' Visualization of a `prcalc_decomposition_compare` object.
#'
#' @method plot prcalc_decomposition_compare
#'
#' @param x a `prcalc_decomposition_compare` object.
#' @param facet Default is `FALSE`.
#' @param bar_width Default is `0.75`.
#' @param value_type `"label"`, `"text"`, or `"none"`. Default is `"label"`.
#' @param value_size Default is `3`.
#' @param font_size a font size. Default is `12`.
#' @param digits Default is `3`.
#' @param ... Ignored
#'
#' @import dplyr
#' @import tidyr
#' @import ggplot2
#'
#' @return
#' A `ggplot` object.
#' @export
#'
#' @examples
#' data(jp_lower_2019)
#'
#' obj1 <- prcalc(jp_lower_2021[1:9, ],
#'                m = c(8, 13, 19, 22, 17, 11, 21, 28, 11, 6, 20),
#'                method = "dt")
#'
#' obj2 <- prcalc(jp_lower_2021[1:9, ],
#'                m = c(8, 13, 19, 22, 17, 11, 21, 28, 11, 6, 20),
#'                method = "hare")
#'
#' obj3 <- prcalc(jp_lower_2021[1:9, ],
#'                m = c(8, 13, 19, 22, 17, 11, 21, 28, 11, 6, 20),
#'                method = "msl")
#'
#' obj4 <- prcalc(jp_lower_2021[1:9, ],
#'                m = c(8, 13, 19, 23, 19, 11, 20, 29, 10, 5, 19),
#'                method = "dt")
#'
#' obj5 <- prcalc(jp_lower_2021[1:9, ],
#'                m = c(8, 13, 19, 23, 19, 11, 20, 29, 10, 5, 19),
#'                method = "msl")
#'
#' compare(list("D'Hondt"     = decompose(obj1),
#'              "Hare"        = decompose(obj2),
#'              "Modified-SL" = decompose(obj3))) |>
#'   plot(digits = 5)
#'
#' compare(list("Model 1" = decompose(obj1),
#'              "Model 2" = decompose(obj4),
#'              "Model 3" = decompose(obj5))) |>
#'   plot(facet = TRUE, value_type = "text")


plot.prcalc_decomposition_compare <- function (x,
                                               facet      = FALSE,
                                               bar_width  = 0.75,
                                               value_type = "label",
                                               value_size = 3,
                                               font_size  = 12,
                                               digits     = 3,
                                               ...) {

  Type <- Model <- Value <- label_y <- NULL

  d_s <- paste0("%.", digits, "f")

  data <- x |>
    pivot_longer(cols      = -Type,
                 names_to  = "Model",
                 values_to = "Value")

  if (!facet) {

    data <- data |>
      filter(Type != "Alpha-divergence") |>
      group_by(Model) |>
      mutate(alpha   = sum(Value),
             label_y = if_else(Type == "Redistricting",
                               Value / 2, alpha),
             Model   = paste0(Model, "\n(", sprintf(d_s, alpha), ")"))

    result <- data |>
      ggplot(aes(x = Model)) +
      geom_col(aes(y = Value, fill = Type), width = bar_width)

    if (value_type == "label") {
      result <- result +
        geom_label(aes(y = label_y, label = sprintf(d_s, Value)),
                   size = value_size, vjust = -0.25) +
        coord_cartesian(ylim = c(0, max(data$alpha) * 1.1))
    } else if (value_type == "text") {
      result <- result +
        geom_text(aes(y = label_y, label = sprintf(d_s, Value)),
                  size = value_size, vjust = -0.25) +
        coord_cartesian(ylim = c(0, max(data$alpha) * 1.1))
    }
  } else if (facet) {

    result <- data |>
      ggplot(aes(x = Model)) +
      geom_col(aes(y = Value), width = bar_width) +
      facet_wrap(~Type, nrow = 1, scales = "free_y")

    if (value_type == "label") {
      result <- result +
        geom_label(aes(y = Value, label = sprintf(d_s, Value)),
                   size = value_size)
    } else if (value_type == "text") {
      result <- result +
        geom_text(aes(y = 0, label = sprintf(d_s, Value)),
                  size = value_size, vjust = -0.25, color = "white")
    }
  }


  result <- result +
    labs(x = "Model", y = "Values", fill = "") +
    theme_bw(base_size = font_size) +
    theme(legend.position = "bottom")

  result
}
