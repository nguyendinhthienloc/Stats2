script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_file <- normalizePath(sub("^--file=", "", script_arg[[1L]]),
                             winslash = "/", mustWork = TRUE)
project_root <- normalizePath(file.path(dirname(script_file), ".."),
                              winslash = "/", mustWork = TRUE)

activate_file <- file.path(project_root, "renv", "activate.R")
lockfile <- file.path(project_root, "renv.lock")

if (!file.exists(activate_file) || !file.exists(lockfile)) {
  stop("Tracked renv bootstrap files are missing. Expected renv/activate.R and renv.lock.",
       call. = FALSE)
}

cat(">>> Bootstrapping the renv version recorded in renv.lock\n")
Sys.setenv(RENV_PROJECT = project_root)
source(activate_file)

cat(">>> Restoring the project library transactionally\n")
renv::restore(
  project = project_root,
  lockfile = lockfile,
  strict = TRUE,
  prompt = FALSE
)

status <- renv::status(
  project = project_root,
  lockfile = lockfile,
  sources = FALSE,
  cache = FALSE
)
if (!isTRUE(status$synchronized)) {
  stop("renv restore completed, but the project library and lockfile differ.",
       call. = FALSE)
}

cat(">>> renv restore verified successfully\n")
