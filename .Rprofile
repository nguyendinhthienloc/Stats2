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
  .libPaths(c(project_library, .libPaths()))
}

Sys.setenv(RENV_PROJECT = project)
