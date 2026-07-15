###############################################################################
# File:        install_requirements.R
# Description: Install packages listed in requirements.txt.
###############################################################################

requirements_file <- "requirements.txt"

if (!file.exists(requirements_file)) {
  stop("[install_requirements] File not found: ", requirements_file,
       "\n  Run this script from the project root directory.")
}

required_packages <- readLines(requirements_file, warn = FALSE)
required_packages <- trimws(sub("#.*$", "", required_packages))
required_packages <- required_packages[nzchar(required_packages)]

installed <- rownames(installed.packages())
missing_packages <- setdiff(required_packages, installed)

if (length(missing_packages) == 0) {
  cat("[install_requirements] All required packages are already installed.\n")
} else {
  cat("[install_requirements] Installing:",
      paste(missing_packages, collapse = ", "), "\n")
  install.packages(missing_packages, repos = "https://cloud.r-project.org/")
}
