# Part 2: Student Performance factorial analysis

This directory contains the five owned Part 2 source and report sections. It
fits the canonical root wireframe; it is not a standalone data/output tree.

- Immutable input: `data/raw/student_performance/StudentsPerformance.csv`
- Canonical stage: `analysis/05_part2_experimental_design.R`
- Five analysis modules: `finals/part2/R/01_*.R` through `05_*.R`
- Five report modules: `finals/part2/report/sections/01_*.Rmd` through `05_*.Rmd`
- Generated data: `data/processed/`
- Generated figures, tables, and models: `output/`
- Ownership and balancing plan: `collaboration/WORK_SPLIT.md`

The pre-specified model is an observational two-factor ANOVA:

```r
math_score ~ test_preparation * lunch
```

The analysis uses all 1,000 rows. It does not sample, impute, or treat lunch or
test preparation as randomized interventions.

## Run in RStudio

Open `Stats2.Rproj`, restore dependencies once, and run the only supported full
pipeline:

```r
renv::restore()
source("analysis/00_run_all.R")
```

While developing Part 2 after restoration, Stage 5 can be rerun directly from
the project root:

```r
source("analysis/05_part2_experimental_design.R")
```

Render the combined report only after the analysis succeeds:

```r
rmarkdown::render("report/final-report.Rmd")
```

Do not run the five modules out of order or hand-edit generated outputs.
