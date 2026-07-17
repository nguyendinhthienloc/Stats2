###############################################################################
# File:        00_restore.R
# Description: Bootstrap renv and restore the project-local package library.
#
# Run this file with --vanilla so a missing or broken project library cannot
# interfere with the restore process:
#   Rscript --vanilla R_models/00_restore.R
###############################################################################

cat(">>> Locating project root\n")

script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(script_arg) != 1L) {
  stop("Run this script with: Rscript --vanilla R_models/00_restore.R",
       call. = FALSE)
}

script_file <- normalizePath(sub("^--file=", "", script_arg),
                             winslash = "/", mustWork = TRUE)
project_root <- normalizePath(file.path(dirname(script_file), ".."),
                              winslash = "/", mustWork = TRUE)
setwd(project_root)

lockfile <- file.path(project_root, "renv.lock")
if (!file.exists(lockfile)) {
  stop("renv.lock was not found at: ", lockfile, call. = FALSE)
}

# --vanilla bypasses project startup files, but it normally retains R's user
# package library. Create that directory explicitly so installing the small
# renv bootstrap package never requires access to R's system directory.
user_library <- Sys.getenv("R_LIBS_USER")
if (!nzchar(user_library)) {
  user_library <- file.path(path.expand("~"), "R", "library")
}
user_library <- normalizePath(user_library, winslash = "/", mustWork = FALSE)
dir.create(user_library, recursive = TRUE, showWarnings = FALSE)
.libPaths(c(user_library, .libPaths()))

if (!requireNamespace("renv", quietly = TRUE)) {
  cat(">>> Installing the renv bootstrap package\n")
  install.packages(
    "renv",
    repos = "https://cloud.r-project.org",
    lib = user_library
  )
}

project_library <- renv::paths$library(project = project_root)
dir.create(project_library, recursive = TRUE, showWarnings = FALSE)

# Seed the project library with the bootstrap copy of renv. Without this step,
# restore() may download the same renv version a second time before it can
# process the rest of the lockfile.
project_renv <- file.path(project_library, "renv")
if (!dir.exists(project_renv)) {
  bootstrap_renv <- find.package("renv")
  copied <- file.copy(bootstrap_renv, project_library, recursive = TRUE)
  if (!isTRUE(copied)) {
    stop("Could not copy renv into the project library: ", project_library,
         call. = FALSE)
  }
}

cat(">>> Restoring locked packages to: ", project_library, "\n", sep = "")
renv::restore(
  project = project_root,
  library = project_library,
  lockfile = lockfile,
  prompt = FALSE
)

cat(">>> Project package library is ready\n")
