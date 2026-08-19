frame_sources <- vapply(sys.frames(), function(frame) {
  value <- frame$ofile
  if (is.null(value) || !length(value)) NA_character_ else as.character(value[[1L]])
}, character(1L))
script_frames <- frame_sources[
  !is.na(frame_sources) &
    basename(frame_sources) == "restore.R" &
    basename(dirname(frame_sources)) == "scripts"
]
script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_file <- if (length(script_frames)) {
  tail(script_frames, 1L)
} else if (length(script_arg)) {
  sub("^--file=", "", script_arg[[1L]])
} else {
  file.path("scripts", "restore.R")
}
if (!file.exists(script_file) && file.exists(basename(script_file))) {
  script_file <- basename(script_file)
}
script_file <- normalizePath(script_file, winslash = "/", mustWork = TRUE)
project_root <- normalizePath(file.path(dirname(script_file), ".."),
                              winslash = "/", mustWork = TRUE)

activate_file <- file.path(project_root, "renv", "activate.R")
lockfile <- file.path(project_root, "renv.lock")

if (!file.exists(activate_file) || !file.exists(lockfile)) {
  stop("Tracked renv bootstrap files are missing. Expected renv/activate.R and renv.lock.",
       call. = FALSE)
}

lock_lines <- readLines(lockfile, warn = FALSE)
r_block <- grep('^[[:space:]]*"R"[[:space:]]*:[[:space:]]*\\{',
                lock_lines)
version_lines <- grep('^[[:space:]]*"Version"[[:space:]]*:',
                      lock_lines, value = TRUE)
if (!length(r_block) || !length(version_lines)) {
  stop("Could not read the required R version from renv.lock.", call. = FALSE)
}
required_r <- sub('.*"Version"[[:space:]]*:[[:space:]]*"([^"]+)".*',
                  '\\1', version_lines[[1L]])
current_r <- paste(R.version$major, R.version$minor, sep = ".")
if (!identical(required_r, current_r)) {
  stop(
    "R version mismatch: renv.lock requires ", required_r,
    ", but this session uses ", current_r,
    ". Select the required R version before restoring.",
    call. = FALSE
  )
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
