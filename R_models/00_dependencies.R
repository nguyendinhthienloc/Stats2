###############################################################################
# File:        00_dependencies.R
# Description: Dependency declaration for project tooling.
#
# This file is not part of the analysis pipeline. It exists so renv records
# packages that are needed by editor tooling, especially the VSCode-R session
# watcher, even when the analysis scripts do not call those packages directly.
###############################################################################

jsonlite::toJSON(list(vscode_r = TRUE), auto_unbox = TRUE)
rlang::is_installed("rlang")
