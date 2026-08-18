script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_file <- if (length(script_arg)) sub("^--file=", "", script_arg[[1L]]) else "analysis/01_eda_cleaning.R"
source(file.path(dirname(normalizePath(script_file, winslash = "/", mustWork = TRUE)),
                 "..", "R", "setup.R"))

ensure_dirs()
wine_red <- read_wine_red()
stopifnot(nrow(wine_red) == 1599L, ncol(wine_red) == 12L)
log_step("Loaded Wine Quality (Red): ", nrow(wine_red), " rows x ",
         ncol(wine_red), " columns")

# TODO: implement the reviewed EDA, cleaning, split, and preprocessing workflow.
