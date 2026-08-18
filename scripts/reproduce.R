script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_file <- normalizePath(sub("^--file=", "", script_arg[[1L]]),
                             winslash = "/", mustWork = TRUE)
project_root <- normalizePath(file.path(dirname(script_file), ".."),
                              winslash = "/", mustWork = TRUE)
arguments <- commandArgs(trailingOnly = TRUE)
render_report <- "--report" %in% arguments
unknown <- setdiff(arguments, "--report")

if (length(unknown)) {
  stop("Unknown argument(s): ", paste(unknown, collapse = ", "), call. = FALSE)
}

cat(">>> Restoring the locked R environment\n")
sys.source(file.path(project_root, "scripts", "restore.R"), envir = new.env())

cat(">>> Running repository and data checks\n")
sys.source(file.path(project_root, "scripts", "ci_check.R"), envir = new.env())

cat(">>> Running the ordered analysis pipeline\n")
sys.source(file.path(project_root, "analysis", "00_run_all.R"),
           envir = new.env())

if (render_report) {
  if (!requireNamespace("rmarkdown", quietly = TRUE)) {
    stop("Package 'rmarkdown' was not restored correctly.", call. = FALSE)
  }
  if (!rmarkdown::pandoc_available(version = "2.0")) {
    stop("Pandoc 2.0 or newer is required to render the report. See README.md.",
         call. = FALSE)
  }
  miktex_commands <- Sys.which(c("miktex", "initexmf"))
  if (!any(nzchar(miktex_commands))) {
    stop("MiKTeX is required to render the report. See README.md.",
         call. = FALSE)
  }
  if (!nzchar(Sys.which("xelatex"))) {
    stop("MiKTeX's XeLaTeX executable is not on PATH. See README.md.",
         call. = FALSE)
  }

  cat(">>> Rendering report/final-report.pdf\n")
  rmarkdown::render(
    file.path(project_root, "report", "final-report.Rmd"),
    output_file = "final-report.pdf",
    quiet = FALSE,
    envir = new.env(parent = globalenv())
  )
}

cat(">>> Reproduction workflow completed successfully\n")
