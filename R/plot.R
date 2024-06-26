#' Visualization of a `prcalc` object.
#'
#' @method plot prcalc
#'
#' @param x a `prcalc` object.
#' @param type a plot of votes (`"raw"`), allocation (`"dist"`), or both (`"both"`). Default is `"both"`.
#' @param prop Output at a percentage. If `type` is `"both"`, it is ignored. Default is `TRUE`.
#' @param show_total If `TRUE`, a facet names "Total" is diplayed. Default is `TRUE`.
#' @param by Facets by level 1 (`"l1"`) or level 2 (`"l2"`). Default is `"l1"`.
#' @param subset_l1 a character vector. a subset of level 1.
#' @param subset_l2 a character vector. a subset of level 2.
#' @param free_y If `FALSE`, y-axes are fixed over all facets. Default is `TRUE`.
#' @param font_size a font size.
#' @param angle an angle of x-ticks label (`0` to `90`). Defualt is `0`.
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
#' plot(pr_obj2, subset_l2 = c("自民", "公明", "立憲", "維新", "国民"))
#' plot(pr_obj2, subset_l1 = c("Tokyo", "Kinki"), facet_col = 1)
#' plot(pr_obj2, by = "l2",
#'      subset_l2 = c("自民", "公明", "立憲", "維新"),
#'      subset_l1 = c("Hokkaido", "Tohoku", "Tokyo", "Kinki"))
#'

plot.prcalc <- function (x,
                         type       = "both",
                         prop       = TRUE,
                         show_total = TRUE,
                         by         = c("l1", "l2"),
                         subset_l1  = NULL,
                         subset_l2  = NULL,
                         free_y     = FALSE,
                         font_size  = 12,
                         angle      = 0,
                         facet_col  = 4,
                         legend_pos = "bottom",
                         ...) {

  block <- party <- values <- NULL

  by <- match.arg(by)

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
                   names_to  = "l1",
                   values_to = "values")

    dist_df <- dist_df |>
      pivot_longer(cols      = -1,
                   names_to  = "l1",
                   values_to = "values")

    temp_df <- bind_rows(list("Raw" = raw_df, "Dist" = dist_df),
                         .id = "Type")

    names(temp_df) <- c("type", "l2", "l1", "values")

  } else if (type == "raw") {

    if (prop) raw_df <- raw_df |> mutate(across(-1, ~(.x / sum(.x))))

    raw_df <- raw_df |>
      pivot_longer(cols      = -1,
                   names_to  = "l1",
                   values_to = "values")

    temp_df <- raw_df

    names(temp_df) <- c("l2", "l1", "values")

  } else if (type == "dist") {

    if (prop) dist_df  <- dist_df |> mutate(across(-1, ~(.x / sum(.x))))

    dist_df <- dist_df |>
      pivot_longer(cols      = -1,
                   names_to  = "l1",
                   values_to = "values")

    temp_df <- dist_df

    names(temp_df) <- c("l2", "l1", "values")

  }

  if (!is.null(subset_l1)) temp_df <- filter(temp_df, l1 %in% subset_l1)
  if (!is.null(subset_l2)) temp_df <- filter(temp_df, l2 %in% subset_l2)

  temp_df <- temp_df |>
    mutate(across(type:l1, \(x) as.character(x))) |>
    mutate(type  = fct_inorder(type),
           l2    = fct_inorder(l2),
           l1    = fct_inorder(l1))

  if (ncol(x$raw) == 2) {
    result <- temp_df |>
      ggplot(aes(x = l2, y = values))
  } else {
    if (by == "l1") {
      result <- temp_df |>
        ggplot(aes(x = l2, y = values)) +
        facet_wrap(~l1,
                   scales = if_else(free_y, "free_y", "fixed"),
                   ncol   = facet_col)
    } else if (by == "l2") {
      result <- temp_df |>
        ggplot(aes(x = l1, y = values)) +
        facet_wrap(~l2,
                   scales = if_else(free_y, "free_y", "fixed"),
                   ncol   = facet_col)
    }
  }

  if (type %in% c("raw", "dist")) {
    result <- result +
      geom_col() +
      labs(x = "Level 2", y = "Distribution") +
      theme_bw(base_size = font_size)
  } else {
    result <- result +
      geom_col(aes(fill = type), position = position_dodge2()) +
      labs(x = "Level 2", y = "Distribution", fill = "") +
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
#' @param subset_l2 a character vector. A subset of level 2.
#' @param bar_width Default is `0.75`.
#' @param facet Separate facets by level 2? Default is `FALSE`.
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
                                 subset_l2  = NULL,
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


  names(data)[1] <- "l2"

  if (!is.null(subset_l2)) {
    data <- data |>
      filter(l2 %in% subset_l2)
  }

  if (facet) {
    result <- data |>
      mutate(l2    = fct_inorder(as.character(l2)),
             Model = fct_inorder(Model)) |>
      ggplot(aes(x = Model, y = Value)) +
      facet_wrap(~l2,
                 scales = if_else(free_y, "free_y", "fixed"),
                 ncol = facet_col)
  } else {
    result <- data |>
      mutate(l2    = fct_inorder(as.character(l2)),
             Model = fct_inorder(Model)) |>
      ggplot(aes(x = l2, y = Value, fill = Model))
  }

  result <- result +
    geom_col(width = bar_width,
             position = position_dodge2()) +
    labs(x = "Level 2", y = "Distribution") +
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
#' @param index a character vector. A subset of indices. If `NULL`, all indices are displayed. Default is `NULL`.
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
#' @param index a character vector of disproportionality indices. If `NULL`, all indices are displayed.
#' @param style Plot style. Lollipop (`"lollipop`) or bar plot (`"bar"`). Default is `"bar"`.
#' @param bar_width Default is `0.75`.
#' @param point_size Default is `5`.
#' @param facet Separate facets by indices? Default is `FALSE`.
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
#' @param percentage If `TRUE`, the percentage of each element is displayed. If `facet = TRUE`, it is ignored.
#' @param facet Default is `FALSE`.
#' @param bar_width Default is `0.75`.
#' @param value_type `"all"`, `"total"`, or `"none"`. If `"total"`, only alpha-divergences are displayed. Default is `"all"`.
#' @param value_angle Angle of values. Default is `0`.
#' @param value_size Default is `3`. If `value_type == "none"`, it is ignored.
#' @param x_angle an angle of x-ticks label (`0` to `90`). Defualt is `0`.
#' @param font_size a font size. Default is `12`.
#' @param border_width width of border. Default is `0` (no border).
#' @param border_color color of border. Default is `"black"`.
#' @param digits Default is `3`.
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
#' data(jp_lower_2021)
#'
#' obj1 <- prcalc(jp_lower_2021,
#'                m = c(8, 13, 19, 22, 17, 11, 21, 28, 11, 6, 20),
#'                method = "dt")
#'
#' obj2 <- prcalc(jp_lower_2021,
#'                m = c(8, 13, 19, 22, 17, 11, 21, 28, 11, 6, 20),
#'                method = "hare")
#'
#' obj3 <- prcalc(jp_lower_2021,
#'                m = c(8, 13, 19, 22, 17, 11, 21, 28, 11, 6, 20),
#'                method = "msl")
#'
#' obj4 <- prcalc(jp_lower_2021,
#'                m = c(8, 13, 19, 23, 19, 11, 20, 29, 10, 5, 19),
#'                method = "dt")
#'
#' obj5 <- prcalc(jp_lower_2021,
#'                m = c(8, 13, 19, 23, 19, 11, 20, 29, 10, 5, 19),
#'                method = "msl")
#'
#' compare(list("D'Hondt"     = decompose(obj1),
#'              "Hare"        = decompose(obj2),
#'              "Modified-SL" = decompose(obj3))) |>
#'   plot()
#'
#' compare(list("Model 1" = decompose(obj1),
#'              "Model 2" = decompose(obj4),
#'              "Model 3" = decompose(obj5))) |>
#'   plot(facet = TRUE, value_type = "total", digits = 5)


plot.prcalc_decomposition_compare <- function (x,
                                               percentage   = FALSE,
                                               facet        = FALSE,
                                               bar_width    = 0.75,
                                               value_type   = "all",
                                               value_angle  = 0,
                                               value_size   = 3,
                                               x_angle      = 0,
                                               font_size    = 12,
                                               border_width = 0,
                                               border_color = "black",
                                               digits       = 3,
                                               ...) {

  if (!(x_angle >= 0 & x_angle <= 90)) stop("x_angle must be in 0 and 90.")

  Type <- Model <- Value <- label_y <- base <- NULL

  d_s <- paste0("%.", digits, "f")

  data <- x |>
    pivot_longer(cols      = -Type,
                 names_to  = "Model",
                 values_to = "Value")

  if (!facet) {

    if (percentage) {
      data <- data |>
        group_by(Model) |>
        mutate(alpha = sum(Value) / 2,
               Value = Value / sum(Value) * 200,
               Value = if_else(Type == "Alpha-divergence", Value / 2, Value)) |>
        ungroup()
    } else {
      data <- data |>
        group_by(Model) |>
        mutate(alpha = sum(Value) / 2) |>
        ungroup()
    }

    if (value_type == "all") {
      data <- data |>
        mutate(Model = paste0(Model, "\n(", sprintf(d_s, alpha), ")")) |>
        mutate(Model = fct_inorder(Model))
    }

    data <- data  |>
      mutate(Model = fct_inorder(Model)) |>
      filter(Type != "Alpha-divergence") |>
      group_by(Model) |>
      mutate(Type    = factor(Type, levels = c("Special",
                                               "Reapportionment",
                                               "Redistricting")),
             alpha   = sum(Value)) |>
      arrange(Model, desc(Type)) |>
      mutate(base = cumsum(Value),
             label_y = base - Value,
             label_y = label_y + (Value / 2))

    result <- data |>
      ggplot(aes(x = Model)) +
      geom_col(aes(y = Value, fill = Type),
               width     = bar_width,
               linewidth = border_width,
               color     = border_color)

    if (value_type == "all") {
      result <- result +
        geom_label(aes(y = label_y, label = sprintf(d_s, Value)),
                   size = value_size, angle = value_angle)
    } else if (value_type == "total") {
      result <- result +
        geom_label(aes(y = alpha, label = sprintf(d_s, alpha)),
                   size = value_size, angle = value_angle)
    }
  } else if (facet) {

    result <- data |>
      mutate(Type = factor(Type,
                           levels = c("Alpha-divergence", "Special",
                                      "Reapportionment", "Redistricting")),
             Model = fct_rev(fct_inorder(Model))) |>
      ggplot(aes(y = Model)) +
      geom_col(aes(x = Value), width = bar_width) +
      facet_wrap(Type~., ncol = 1, scales = "free_x")

    if (value_type != "none") {
      result <- result +
        geom_label(aes(x = 0, label = sprintf(d_s, Value)),
                   size = value_size, angle = value_angle, hjust = 0)
    }

  }

  result <- result +
    theme_bw(base_size = font_size) +
    theme(legend.position = "bottom")

  if (facet) {
    result <- result +
      labs(y = "Model", x = "Values", fill = "") +
      theme(panel.grid.major.y = element_blank())
  } else if (!facet) {
    result <- result +
      labs(x = "Model", y = "Values", fill = "") +
      theme(legend.position = "bottom")
  }

  if (x_angle > 0) {
    result <- result +
      scale_x_discrete(guide = guide_axis(angle = x_angle))
  }

  result
}
