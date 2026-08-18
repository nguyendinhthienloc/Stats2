source("renv/activate.R")
# Use the restored project library without running renv's slow autoloader.
project <- normalizePath(getwd(), winslash = "/", mustWork = FALSE)
project_library_root <- file.path(project, "renv", "library")
project_libraries <- if (dir.exists(project_library_root)) {
  list.dirs(project_library_root, recursive = TRUE, full.names = TRUE)
} else {
  character(0)
}

project_library <- project_libraries[
  file.exists(file.path(project_libraries, "renv", "DESCRIPTION"))
]

if (length(project_library) > 0) {
  project_library <- project_library[[length(project_library)]]
  # Keep the project isolated from user-level packages. Base and recommended
  # packages remain available from R's system library.
  .libPaths(c(project_library, .Library))
}

Sys.setenv(RENV_PROJECT = project)
