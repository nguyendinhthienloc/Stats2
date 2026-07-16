###############################################################################
# File:        install_requirements.R
# Description: Install packages listed in requirements.txt.
###############################################################################

script_arg <- grep("^--file=", commandArgs(), value = TRUE)
script_file <- if (length(script_arg) > 0) sub("^--file=", "", script_arg[1]) else "R_models/install_requirements.R"
project_root <- normalizePath(file.path(dirname(script_file), ".."),
                              winslash = "/", mustWork = TRUE)
setwd(project_root)

project_library <- file.path(project_root, ".Rlib")
dir.create(project_library, recursive = TRUE, showWarnings = FALSE)
.libPaths(c(project_library, .libPaths()))

log_install <- function(...) {
  cat(sprintf(">>> [%s] INSTALL %s\n", format(Sys.time(), "%H:%M:%S"),
              paste0(..., collapse = "")))
}

requirements_file <- file.path(project_root, "requirements.txt")

if (!file.exists(requirements_file)) {
  stop("Dependency file not found: ", requirements_file, call. = FALSE)
}

required_packages <- readLines(requirements_file, warn = FALSE)
required_packages <- trimws(sub("#.*$", "", required_packages))
required_packages <- required_packages[nzchar(required_packages)]

package_ok <- vapply(required_packages, function(package) {
  tryCatch({
    suppressWarnings(loadNamespace(package))
    TRUE
  }, error = function(e) FALSE)
}, logical(1))
packages_to_install <- required_packages[!package_ok]

if (length(packages_to_install) == 0) {
  log_install("All required packages load successfully from ", project_library)
} else {
  log_install("Repairing/installing: ", paste(packages_to_install, collapse = ", "))

  glmnet_legacy <- .Platform$OS.type == "windows" &&
    "glmnet" %in% packages_to_install && getRversion() < "4.5.3"
  if (glmnet_legacy) {
    install.packages(
      "https://www.icesi.edu.co/CRAN/bin/windows/contrib/4.5/glmnet_4.1-10.zip",
      repos = NULL,
      type = "win.binary",
      lib = project_library
    )
    packages_to_install <- setdiff(packages_to_install, "glmnet")
  }

  if (length(packages_to_install) > 0) {
    install.packages(
      packages_to_install,
      repos = "https://cloud.r-project.org/",
      dependencies = c("Depends", "Imports", "LinkingTo"),
      lib = project_library
    )
  }
}
