###############################################################################
# Part 2 / Section 2: descriptive statistics and required visualizations.
###############################################################################

source(file.path("R", "setup.R"))
source(file.path(PROJECT_ROOT, "finals", "part2", "R", "part2_helpers.R"))

log_step("Part 2 / Section 2: descriptive statistics and factorial plots")
student <- load_part2_data()

summarize_scores <- function(index) {
  values <- student$math_score[index]
  c(
    N = length(values), Mean = mean(values), Median = stats::median(values),
    SD = stats::sd(values), Variance = stats::var(values),
    Q1 = unname(stats::quantile(values, 0.25)),
    Q3 = unname(stats::quantile(values, 0.75)),
    Minimum = min(values), Maximum = max(values)
  )
}
groups <- split(seq_len(nrow(student)), student$design_cell)
descriptive <- as.data.frame(do.call(rbind, lapply(groups, summarize_scores)))
descriptive <- cbind(
  Design_cell = names(groups), descriptive, row.names = NULL,
  stringsAsFactors = FALSE
)
save_part2_table(
  descriptive, "tab_part2_descriptive_statistics",
  "Math-score summaries for the four factorial cells.",
  "tab:part2-descriptive", digits = 2L
)
descriptive_display <- descriptive[
  , c("Design_cell", "N", "Mean", "Median", "SD", "Minimum", "Maximum")
]
names(descriptive_display) <- c("Cell", "n", "Mean", "Median", "SD", "Min", "Max")
save_part2_table(
  descriptive_display, "tab_part2_descriptive_display",
  "Math-score summaries for the four factorial cells.",
  "tab:part2-descriptive-display", digits = 2L
)

cell_palette <- c("#4477AA", "#66CCEE", "#CC6677", "#AA3377")
open_part2_pdf("fig_part2_histograms.pdf", width = 8, height = 6.5)
graphics::par(mfrow = c(2, 2), mar = c(3.5, 3.8, 2.5, 0.8))
for (i in seq_along(groups)) {
  graphics::hist(
    student$math_score[groups[[i]]], breaks = seq(-2.5, 102.5, by = 5),
    col = cell_palette[[i]], border = "white", xlim = c(0, 100),
    main = names(groups)[[i]], xlab = "Math score", ylab = "Frequency"
  )
}
grDevices::dev.off()

open_part2_pdf("fig_part2_boxplots.pdf", width = 7.4, height = 5)
graphics::boxplot(
  math_score ~ design_cell, data = student, col = cell_palette,
  outline = TRUE, ylab = "Math score", xlab = "Lunch | test preparation",
  main = "Math scores across the four observed groups",
  names = c("Free | none", "Standard | none",
            "Free | completed", "Standard | completed")
)
graphics::stripchart(
  math_score ~ design_cell, data = student, vertical = TRUE,
  method = "jitter", jitter = 0.18, pch = 16, cex = 0.25,
  col = grDevices::adjustcolor("#17212B", alpha.f = 0.22), add = TRUE
)
grDevices::dev.off()

cell_means <- with(
  student,
  tapply(math_score, list(lunch, test_preparation), mean)
)
cell_se <- with(
  student,
  tapply(math_score, list(lunch, test_preparation),
         function(x) stats::sd(x) / sqrt(length(x)))
)
open_part2_pdf("fig_part2_interaction.pdf", width = 6.8, height = 5)
graphics::matplot(
  x = seq_len(nrow(cell_means)), y = cell_means, type = "b", pch = c(16, 17),
  lty = 1, lwd = 2, col = c("#4477AA", "#CC6677"), xaxt = "n",
  xlab = "Lunch group", ylab = "Mean math score", ylim = c(52, 77),
  main = "Observed preparation-by-lunch interaction"
)
graphics::axis(1, at = 1:2, labels = c("Free/reduced", "Standard"))
for (j in seq_len(ncol(cell_means))) {
  graphics::arrows(
    1:2, cell_means[, j] - 1.96 * cell_se[, j],
    1:2, cell_means[, j] + 1.96 * cell_se[, j],
    angle = 90, code = 3, length = 0.05,
    col = c("#4477AA", "#CC6677")[[j]]
  )
}
graphics::legend(
  "topleft", legend = c("None", "Completed"), pch = c(16, 17), lty = 1,
  lwd = 2, col = c("#4477AA", "#CC6677"), bty = "n",
  title = "Test preparation"
)
grDevices::dev.off()

open_part2_pdf("fig_part2_factorial_patterns.pdf", width = 9, height = 4.5)
graphics::par(mfrow = c(1, 2), mar = c(4.3, 4.2, 2.7, 0.8))
graphics::boxplot(
  math_score ~ design_cell, data = student, col = cell_palette,
  outline = TRUE, ylab = "Math score", xlab = "Lunch | preparation",
  main = "Observed score distributions",
  names = c("Free\nnone", "Standard\nnone",
            "Free\ncompleted", "Standard\ncompleted")
)
graphics::matplot(
  x = seq_len(nrow(cell_means)), y = cell_means, type = "b", pch = c(16, 17),
  lty = 1, lwd = 2, col = c("#4477AA", "#CC6677"), xaxt = "n",
  xlab = "Lunch group", ylab = "Mean math score", ylim = c(52, 77),
  main = "Factor interaction"
)
graphics::axis(1, at = 1:2, labels = c("Free/reduced", "Standard"))
graphics::legend(
  "topleft", legend = c("None", "Completed"), pch = c(16, 17), lty = 1,
  lwd = 2, col = c("#4477AA", "#CC6677"), bty = "n", cex = 0.85
)
grDevices::dev.off()

log_step("Part 2 Section 2 complete: summaries and four PDF figures saved")
