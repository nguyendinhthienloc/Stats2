###############################################################################
# Compatibility setup for the Part 1 presentation source.
# The canonical configuration, data, and outputs all live at project root.
###############################################################################

frame_sources <- vapply(sys.frames(), function(frame) {
  value <- frame$ofile
  if (is.null(value) || !length(value)) NA_character_ else as.character(value[[1L]])
}, character(1L))
setup_frames <- frame_sources[
  !is.na(frame_sources) &
    basename(frame_sources) == "setup.R" &
    basename(dirname(frame_sources)) == "part1"
]
setup_candidates <- unique(c(
  setup_frames,
  file.path(getwd(), "setup.R"),
  file.path(getwd(), "..", "setup.R"),
  file.path(getwd(), "finals", "part1", "setup.R")
))
setup_candidates <- setup_candidates[file.exists(setup_candidates)]
if (!length(setup_candidates)) {
  stop("Cannot locate finals/part1/setup.R", call. = FALSE)
}

SETUP_FILE <- normalizePath(setup_candidates[[1L]], winslash = "/",
                            mustWork = TRUE)
PART1_ROOT <- normalizePath(dirname(SETUP_FILE), winslash = "/",
                           mustWork = TRUE)
ROOT_SETUP <- normalizePath(
  file.path(PART1_ROOT, "..", "..", "R", "setup.R"),
  winslash = "/", mustWork = TRUE
)
source(ROOT_SETUP)
source(file.path(PROJECT_ROOT, "R", "part1_helpers.R"))

REPORT_DIR <- file.path(PART1_ROOT, "report")
PRESENTATION_DIR <- file.path(PART1_ROOT, "presentation")

log_info(
  "Part 1 compatibility setup loaded | canonical root=", PROJECT_ROOT
)
