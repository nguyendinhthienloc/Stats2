###############################################################################
# Shared configuration for the STAT452 Group 8 final project.
###############################################################################

frame_sources <- vapply(sys.frames(), function(frame) {
  value <- frame$ofile
  if (is.null(value) || !length(value)) NA_character_ else as.character(value[[1L]])
}, character(1L))
setup_frames <- frame_sources[
  !is.na(frame_sources) & grepl("(^|[/\\\\])R[/\\\\]setup[.]R$", frame_sources,
                                ignore.case = TRUE)
]
setup_source <- if (length(setup_frames)) tail(setup_frames, 1L) else NULL
if (is.null(setup_source) || !nzchar(setup_source)) {
  setup_candidates <- c("R/setup.R", "../R/setup.R", "setup.R")
  existing_setup <- setup_candidates[file.exists(setup_candidates)]
  if (!length(existing_setup)) {
    stop("Could not locate R/setup.R from the current working directory.",
         call. = FALSE)
  }
  setup_source <- existing_setup[[1L]]
}

SETUP_FILE <- normalizePath(setup_source, winslash = "/", mustWork = TRUE)
PROJECT_ROOT <- normalizePath(file.path(dirname(SETUP_FILE), ".."),
                              winslash = "/", mustWork = TRUE)


# A canonical reproduction run activates renv before sourcing this file. The
# fallback below only supports direct `Rscript --vanilla analysis/...` calls.
if (!nzchar(Sys.getenv("RENV_PROJECT", unset = ""))) {
  project_library_root <- file.path(PROJECT_ROOT, "renv", "library")
  if (dir.exists(project_library_root)) {
    project_libraries <- list.dirs(project_library_root, recursive = TRUE,
                                   full.names = TRUE)
    project_library <- project_libraries[
      file.exists(file.path(project_libraries, "renv", "DESCRIPTION"))
    ]
    if (length(project_library) > 0L) {
      .libPaths(c(project_library[[length(project_library)]], .libPaths()))
    }
  }
}

GROUP_NUMBER <- 8L
PROJECT_NUMBER <- 3L
PROJECT_SEED <- 4520803L

paths <- list(
  raw_red = file.path(PROJECT_ROOT, "data", "raw", "wine_quality",
                      "winequality-red.csv"),
  raw_white = file.path(PROJECT_ROOT, "data", "raw", "wine_quality",
                        "winequality-white.csv"),
  processed = file.path(PROJECT_ROOT, "data", "processed"),
  figures = file.path(PROJECT_ROOT, "output", "figures"),
  tables = file.path(PROJECT_ROOT, "output", "tables"),
  models = file.path(PROJECT_ROOT, "output", "models"),
  logs = file.path(PROJECT_ROOT, "output", "logs")
)

config <- list(
  task_type = "regression",
  response = "quality",
  test_fraction = 0.20,
  cv_folds = 5L
)

seeds <- list(
  split = PROJECT_SEED,
  folds = PROJECT_SEED + 1L,
  bootstrap = PROJECT_SEED + 2L
)

log_step <- function(...) {
  cat(">>> ", paste0(..., collapse = ""), "\n", sep = "")
}

ensure_dirs <- function() {
  invisible(lapply(paths[c("processed", "figures", "tables", "models", "logs")],
                   dir.create, recursive = TRUE, showWarnings = FALSE))
}

read_wine_red <- function() {
  if (!file.exists(paths$raw_red)) {
    stop("Raw red-wine data not found: ", paths$raw_red, call. = FALSE)
  }
  read.csv(paths$raw_red, sep = ";", dec = ".", check.names = FALSE)
}

save_table_tex <- function(data, filename, caption = NULL, label = NULL,
                           digits = 3L) {
  if (!requireNamespace("knitr", quietly = TRUE)) {
    stop("Package 'knitr' is required to save LaTeX tables.", call. = FALSE)
  }
  ensure_dirs()
  destination <- file.path(paths$tables, filename)
  table_tex <- knitr::kable(data, format = "latex", booktabs = TRUE,
                            digits = digits, caption = caption, label = label,
                            row.names = FALSE)
  writeLines(as.character(table_tex), destination, useBytes = TRUE)
  invisible(destination)
}

set.seed(PROJECT_SEED)
