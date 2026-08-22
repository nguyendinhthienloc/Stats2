frame_sources <- vapply(sys.frames(), function(frame) {
  value <- frame$ofile
  if (is.null(value) || !length(value)) NA_character_ else as.character(value[[1L]])
}, character(1L))
script_frames <- frame_sources[
  !is.na(frame_sources) &
    basename(frame_sources) == "ci_check.R" &
    basename(dirname(frame_sources)) == "scripts"
]
script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_file <- if (length(script_frames)) {
  tail(script_frames, 1L)
} else if (length(script_arg)) {
  sub("^--file=", "", script_arg[[1L]])
} else {
  file.path("scripts", "ci_check.R")
}
if (!file.exists(script_file) && file.exists(basename(script_file))) {
  script_file <- basename(script_file)
}
script_file <- normalizePath(script_file, winslash = "/", mustWork = TRUE)
source(file.path(dirname(script_file), "..", "R", "setup.R"))

log_step("Checking required repository structure")
required_paths <- c(
  "TODO.md",
  "README.md",
  "DESCRIPTION",
  "renv.lock",
  "renv/activate.R",
  "scripts/restore.R",
  "scripts/reproduce.R",
  "scripts/validate_outputs.R",
  "R/part1_helpers.R",
  "analysis/00_run_all.R",
  "analysis/04_holdout_evaluation.R",
  "analysis/05_part2_experimental_design.R",
  "report/final-report.Rmd",
  ".github/workflows/ci.yml",
  "data/raw/source/wine-quality.zip",
  "data/raw/wine_quality/winequality-red.csv",
  "data/raw/student_performance/StudentsPerformance.csv",
  "finals/part2/R/01_data_audit_design.R",
  "finals/part2/R/05_interpretation_integration.R",
  "finals/part2/collaboration/WORK_SPLIT.md"
)
missing_paths <- required_paths[!file.exists(file.path(PROJECT_ROOT, required_paths))]
if (length(missing_paths)) {
  stop("Missing required paths: ", paste(missing_paths, collapse = ", "),
       call. = FALSE)
}

duplicate_snapshot_paths <- file.path(
  PROJECT_ROOT, "finals", "part1", c("data", "output")
)
if (any(dir.exists(duplicate_snapshot_paths))) {
  stop(
    "Noncanonical duplicate tree(s) found: ",
    paste(duplicate_snapshot_paths[dir.exists(duplicate_snapshot_paths)],
          collapse = ", "),
    call. = FALSE
  )
}

log_step("Checking renv lockfile synchronization")
if (!requireNamespace("renv", quietly = TRUE)) {
  stop("renv is unavailable. Run: Rscript --vanilla scripts/restore.R",
       call. = FALSE)
}
lockfile_path <- file.path(PROJECT_ROOT, "renv.lock")
lock <- renv::lockfile_read(lockfile_path)
current_r <- paste(R.version$major, R.version$minor, sep = ".")
if (!identical(lock$R$Version, current_r)) {
  stop("R version mismatch: renv.lock records ", lock$R$Version,
       ", but this session uses ", current_r, ".", call. = FALSE)
}

description <- read.dcf(file.path(PROJECT_ROOT, "DESCRIPTION"))
imports <- trimws(unlist(strsplit(description[[1L, "Imports"]], ",")))
imports <- sub("[[:space:]]*\\(.*$", "", imports)
missing_from_lock <- setdiff(c("renv", imports), names(lock$Packages))
if (length(missing_from_lock)) {
  stop("DESCRIPTION dependencies missing from renv.lock: ",
       paste(missing_from_lock, collapse = ", "), call. = FALSE)
}

renv_status <- renv::status(project = PROJECT_ROOT, lockfile = lockfile_path,
                            sources = FALSE, cache = FALSE)
if (!isTRUE(renv_status$synchronized)) {
  stop("The project library, dependency declarations, and renv.lock are not synchronized.",
       call. = FALSE)
}

log_step("Validating the supplied red-wine dataset")
wine <- read_wine_red()
expected_columns <- c(
  "fixed acidity", "volatile acidity", "citric acid", "residual sugar",
  "chlorides", "free sulfur dioxide", "total sulfur dioxide", "density",
  "pH", "sulphates", "alcohol", "quality"
)
stopifnot(
  nrow(wine) == 1599L,
  ncol(wine) == 12L,
  identical(names(wine), expected_columns),
  all(vapply(wine, is.numeric, logical(1))),
  !anyNA(wine),
  all(wine$quality >= 0 & wine$quality <= 10)
)

log_step("Validating the Part 2 Student Performance dataset")
student <- utils::read.csv(paths$raw_student, check.names = FALSE)
expected_student_columns <- c(
  "gender", "race/ethnicity", "parental level of education", "lunch",
  "test preparation course", "math score", "reading score", "writing score"
)
student_scores <- student[c("math score", "reading score", "writing score")]
stopifnot(
  nrow(student) == 1000L,
  ncol(student) == 8L,
  identical(names(student), expected_student_columns),
  !anyNA(student),
  all(student_scores >= 0),
  all(student_scores <= 100),
  setequal(unique(student$lunch), c("free/reduced", "standard")),
  setequal(unique(student$`test preparation course`), c("none", "completed"))
)
student_raw <- readBin(paths$raw_student, what = "raw",
                       n = file.size(paths$raw_student))
student_text <- rawToChar(student_raw)
student_text <- gsub("\\r\\n?", "\\n", student_text, perl = TRUE)
student_normalized <- tempfile(fileext = ".csv")
on.exit(unlink(student_normalized), add = TRUE)
writeBin(charToRaw(student_text), student_normalized)
student_md5 <- tolower(unname(tools::md5sum(student_normalized)))
if (!identical(student_md5, "ec06a4da16a0122c33133593ef1cef1a")) {
  stop("The immutable Student Performance source checksum changed.",
       call. = FALSE)
}

log_step("Parsing active R source files")
r_files <- c(
  list.files(file.path(PROJECT_ROOT, "R"), pattern = "[.]R$",
             recursive = TRUE, full.names = TRUE),
  list.files(file.path(PROJECT_ROOT, "analysis"), pattern = "[.]R$",
             recursive = TRUE, full.names = TRUE),
  list.files(file.path(PROJECT_ROOT, "finals", "part1", "R"),
             pattern = "[.]R$", recursive = TRUE, full.names = TRUE),
  list.files(file.path(PROJECT_ROOT, "finals", "part2", "R"),
             pattern = "[.]R$", recursive = TRUE, full.names = TRUE),
  list.files(file.path(PROJECT_ROOT, "scripts"), pattern = "[.]R$",
             recursive = TRUE, full.names = TRUE)
)
invisible(lapply(r_files, parse, keep.source = TRUE))

log_step("Checking active files for machine-specific project paths")
text_files <- c(r_files,
                file.path(PROJECT_ROOT, c("README.md", "TODO.md")))
hardcoded <- vapply(text_files, function(path) {
  any(grepl("[A-Za-z]:[/\\\\]Stats2", readLines(path, warn = FALSE),
            ignore.case = TRUE))
}, logical(1))
if (any(hardcoded)) {
  stop("Machine-specific project path found in: ",
       paste(text_files[hardcoded], collapse = ", "), call. = FALSE)
}

log_step("All repository checks passed")
