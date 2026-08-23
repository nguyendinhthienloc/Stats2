###############################################################################
# Part 2 / Section 1: data audit, design justification, and hypotheses.
###############################################################################

source(file.path("R", "setup.R"))
source(file.path(PROJECT_ROOT, "finals", "part2", "R", "part2_helpers.R"))

log_step("Part 2 / Section 1: auditing data and locking the factorial question")
part2_require_file(paths$raw_student)

raw_student <- utils::read.csv(
  paths$raw_student, check.names = FALSE, stringsAsFactors = FALSE
)
expected_names <- c(
  "gender", "race/ethnicity", "parental level of education", "lunch",
  "test preparation course", "math score", "reading score", "writing score"
)
if (!identical(names(raw_student), expected_names)) {
  part2_abort("Unexpected Student Performance schema: ",
              paste(names(raw_student), collapse = ", "))
}
if (nrow(raw_student) != 1000L || ncol(raw_student) != 8L) {
  part2_abort("Expected 1,000 rows and 8 columns in Student Performance data.")
}

names(raw_student) <- c(
  "gender", "race_ethnicity", "parental_education", "lunch",
  "test_preparation", "math_score", "reading_score", "writing_score"
)
score_names <- c("math_score", "reading_score", "writing_score")
if (anyNA(raw_student) || any(!vapply(raw_student[score_names], is.numeric,
                                     logical(1)))) {
  part2_abort("Student Performance data contain missing or nonnumeric scores.")
}
if (any(raw_student[score_names] < 0 | raw_student[score_names] > 100)) {
  part2_abort("Student Performance scores must be within 0--100.")
}

expected_levels <- list(
  lunch = c("free/reduced", "standard"),
  test_preparation = c("completed", "none")
)
for (variable in names(expected_levels)) {
  if (!setequal(unique(raw_student[[variable]]), expected_levels[[variable]])) {
    part2_abort("Unexpected levels for ", variable, ".")
  }
}

student <- raw_student
student$student_id <- sprintf("SP%04d", seq_len(nrow(student)))
student <- student[, c("student_id", names(raw_student)), drop = FALSE]
student$lunch <- factor(student$lunch,
                        levels = c("free/reduced", "standard"))
student$test_preparation <- factor(
  student$test_preparation, levels = c("none", "completed")
)
student$design_cell <- interaction(
  student$lunch, student$test_preparation, sep = " | ", drop = TRUE
)

# Exact duplicate profiles are audited but not removed: without a source ID,
# identical profiles could represent distinct students. The supplied file has none.
duplicate_profiles <- sum(duplicated(raw_student))
utils::write.csv(student, PART2_DATA_FILE, row.names = FALSE)

audit <- data.frame(
  Check = c(
    "Rows", "Columns", "Missing values", "Exact duplicate profiles",
    "Math-score range", "Lunch levels", "Preparation levels", "Sampling"
  ),
  Result = c(
    nrow(student), ncol(raw_student), sum(is.na(raw_student)),
    duplicate_profiles,
    paste(range(student$math_score), collapse = "--"),
    nlevels(student$lunch), nlevels(student$test_preparation),
    "None; all 1,000 rows retained"
  ),
  stringsAsFactors = FALSE
)
save_part2_table(
  audit, "tab_part2_data_audit",
  "Student Performance data-integrity audit.",
  "tab:part2-data-audit", digits = 0L
)

dictionary <- data.frame(
  Variable = c("math_score", "test_preparation", "lunch"),
  Role = c("Continuous response", "Factor A", "Factor B"),
  Levels_or_range = c(
    paste(range(student$math_score), collapse = "--"),
    "none; completed", "free/reduced; standard"
  ),
  Analysis_use = c(
    "Primary bounded exam outcome",
    "Two-level observational exposure",
    "Two-level socioeconomic proxy"
  ),
  stringsAsFactors = FALSE
)
save_part2_table(
  dictionary, "tab_part2_variable_dictionary",
  "Variables in the pre-specified two-factor analysis.",
  "tab:part2-variable-dictionary", digits = 0L
)

hypotheses <- data.frame(
  Effect = c("Test preparation", "Lunch", "Interaction"),
  Null_hypothesis = c(
    "Average math scores are equal for completed and none",
    "Average math scores are equal for standard and free/reduced",
    "The preparation-score difference is the same in both lunch groups"
  ),
  Alternative = c(
    "The preparation marginal means differ",
    "The lunch marginal means differ",
    "The preparation-score difference depends on lunch group"
  ),
  stringsAsFactors = FALSE
)
save_part2_table(
  hypotheses, "tab_part2_hypotheses",
  "Pre-specified hypotheses for the two-factor model.",
  "tab:part2-hypotheses", digits = 0L
)

design_metadata <- list(
  source = "Kaggle: Students Performance in Exams (Timothy Adeyemi)",
  source_url = paste0(
    "https://www.kaggle.com/datasets/timothyadeyemi/",
    "students-performance-in-exams"
  ),
  source_md5 = unname(tools::md5sum(paths$raw_student)),
  response = "math_score",
  factors = c("test_preparation", "lunch"),
  design = "observational 2 x 2 factorial ANOVA",
  causal_claims_allowed = FALSE,
  alpha = PART2_ALPHA,
  rows_retained = nrow(student)
)
save(design_metadata, file = file.path(paths$processed,
                                       "part2_design_metadata.RData"))

log_step("Part 2 Section 1 complete: all 1,000 rows retained; no imputation")
