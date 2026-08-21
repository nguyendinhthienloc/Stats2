###############################################################################
# Shared helpers for Part 2. Generated artifacts remain in root data/output.
###############################################################################

setup_candidates <- c(
  file.path("R", "setup.R"),
  file.path("..", "..", "..", "R", "setup.R")
)
setup_file <- setup_candidates[file.exists(setup_candidates)][1L]
if (is.na(setup_file)) {
  stop("Could not locate the project R/setup.R file.", call. = FALSE)
}
source(setup_file)

if (!requireNamespace("knitr", quietly = TRUE)) {
  stop("Package 'knitr' is required. Run renv::restore().", call. = FALSE)
}

PART2_ROOT <- file.path(PROJECT_ROOT, "finals", "part2")
PART2_MODEL_FILE <- file.path(paths$models, "part2_anova.RData")
PART2_SUMMARY_FILE <- file.path(PROJECT_ROOT, "output", "part2_summary.RData")
PART2_DATA_FILE <- file.path(paths$processed, "student_performance_clean.csv")
PART2_ALPHA <- 0.05

part2_abort <- function(...) stop(paste0(..., collapse = ""), call. = FALSE)

part2_require_file <- function(path, instruction = NULL) {
  if (!file.exists(path)) {
    message <- paste0("Required Part 2 file is missing: ", path)
    if (!is.null(instruction)) message <- paste(message, instruction)
    part2_abort(message)
  }
  invisible(path)
}

save_part2_table <- function(data, stem, caption, label, digits = 3L) {
  ensure_dirs()
  utils::write.csv(
    data, file.path(paths$tables, paste0(stem, ".csv")),
    row.names = FALSE, na = ""
  )
  tex_path <- save_table_tex(
    data, paste0(stem, ".tex"), caption = caption, label = label,
    digits = digits
  )
  table_tex <- readLines(tex_path, warn = FALSE)
  table_tex <- sub(
    "\\begin{table}", "\\begin{table}[H]", table_tex, fixed = TRUE
  )
  writeLines(table_tex, tex_path, useBytes = TRUE)
  invisible(tex_path)
}

open_part2_pdf <- function(filename, width = 7, height = 5) {
  ensure_dirs()
  grDevices::pdf(
    file.path(paths$figures, filename), width = width, height = height,
    family = "serif", useDingbats = FALSE
  )
  graphics::par(
    mar = c(4.3, 4.4, 2.8, 1.0), mgp = c(2.5, 0.8, 0),
    tcl = -0.25, las = 1, bty = "l", col.axis = "#25313C",
    col.lab = "#25313C", col.main = "#17212B"
  )
}

load_part2_data <- function() {
  part2_require_file(
    PART2_DATA_FILE,
    "Run analysis/05_part2_experimental_design.R from the project root."
  )
  data <- utils::read.csv(PART2_DATA_FILE, stringsAsFactors = FALSE)
  data$lunch <- factor(data$lunch, levels = c("free/reduced", "standard"))
  data$test_preparation <- factor(
    data$test_preparation, levels = c("none", "completed")
  )
  data$design_cell <- interaction(
    data$lunch, data$test_preparation, sep = " | ", drop = TRUE
  )
  data
}

part2_cell_grid <- function() {
  expand.grid(
    lunch = factor(c("free/reduced", "standard"),
                   levels = c("free/reduced", "standard")),
    test_preparation = factor(c("none", "completed"),
                              levels = c("none", "completed")),
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )[, c("lunch", "test_preparation")]
}

part2_model_matrix <- function(model, newdata = part2_cell_grid()) {
  stats::model.matrix(
    stats::delete.response(stats::terms(model)), data = newdata,
    contrasts.arg = model$contrasts
  )
}

linear_contrast <- function(model, contrast, covariance = stats::vcov(model),
                            level = 0.95) {
  contrast <- as.numeric(contrast)
  estimate <- as.numeric(contrast %*% stats::coef(model))
  standard_error <- sqrt(as.numeric(contrast %*% covariance %*% contrast))
  degrees_freedom <- stats::df.residual(model)
  statistic <- estimate / standard_error
  probability <- 2 * stats::pt(abs(statistic), df = degrees_freedom,
                               lower.tail = FALSE)
  critical <- stats::qt((1 + level) / 2, df = degrees_freedom)
  c(
    Estimate = estimate,
    SE = standard_error,
    Df = degrees_freedom,
    t = statistic,
    P_value = probability,
    CI_low = estimate - critical * standard_error,
    CI_high = estimate + critical * standard_error
  )
}

part2_effect_contrasts <- function(model) {
  matrix_by_cell <- part2_model_matrix(model)
  list(
    `Preparation: completed - none` =
      0.5 * ((matrix_by_cell[3L, ] - matrix_by_cell[1L, ]) +
             (matrix_by_cell[4L, ] - matrix_by_cell[2L, ])),
    `Lunch: standard - free/reduced` =
      0.5 * ((matrix_by_cell[2L, ] - matrix_by_cell[1L, ]) +
             (matrix_by_cell[4L, ] - matrix_by_cell[3L, ])),
    `Interaction: difference in preparation effects` =
      (matrix_by_cell[4L, ] - matrix_by_cell[2L, ]) -
      (matrix_by_cell[3L, ] - matrix_by_cell[1L, ])
  )
}

hc3_vcov <- function(model) {
  design <- stats::model.matrix(model)
  leverage <- stats::hatvalues(model)
  adjusted_squared <- (stats::residuals(model) / (1 - leverage))^2
  bread <- solve(crossprod(design))
  meat <- crossprod(design, design * adjusted_squared)
  bread %*% meat %*% bread
}

format_part2_p <- function(x) {
  ifelse(x < 0.001, "<0.001", formatC(x, digits = 3L, format = "f"))
}

ensure_dirs()
