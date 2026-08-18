# STAT452 Final Project - Group 8

This repository is the active workspace for STAT452 Project 03, **Wine Quality (Red)**. The supplied data contain 1,599 red wines, 11 physicochemical predictors, and the `quality` response.

The project has two required parts:

1. A complete supervised-learning workflow for Wine Quality (Red): EDA, cleaning, feature selection, a baseline, at least two regularized models, and held-out evaluation.
2. A separate experimental-design study using two-factor ANOVA or a `2^k` factorial design with `k >= 2`.

The current planning assumption is regression on the quality score. This is recorded as a decision to confirm in [TODO.md](TODO.md).

## Group 8

| No. | Member | Student ID |
|---:|---|---:|
| 1 | Trần Lê Anh Tuấn | 24125107 |
| 2 | Nguyễn Bảo Minh Triết | 24125047 |
| 3 | Nguyễn Đình Thiên Lộc | 24125093 |
| 4 | Nguyễn Hồng Tấn Tài | 24125078 |
| 5 | Lê Minh Thuận | 24125105 |

## Repository map

| Path | Purpose |
|---|---|
| `analysis/` | Ordered, top-to-bottom R analysis scripts |
| `R/` | Shared configuration and reusable functions |
| `data/raw/` | Immutable supplied source data |
| `data/processed/` | Reproducible derived datasets |
| `output/` | Generated figures, tables, and model objects |
| `report/` | Reproducible final report source |
| `presentation/` | Presentation source and final deck |
| `scripts/` | Repository validation and automation helpers |
| `references/` | Course briefs, group assignment, notes, and labs |
| `legacy/midterm/` | Preserved Applied Statistics II midterm project |

## Quick start

Prerequisites are R 4.5.x, Pandoc, and XeLaTeX.

```text
make restore
make check
make analysis
make report
```

Without Make, run the corresponding commands from [Makefile](Makefile). The analysis uses the fixed project seed `4520803`. Raw data are never edited in place, and the held-out test target may only be used by `analysis/04_holdout_evaluation.R`.

## Automation

- Continuous integration validates the repository and data contract, runs the ordered analysis, renders the PDF report, and uploads it as a build artifact.
- Continuous delivery runs for tags matching `v*` and creates a GitHub release containing the PDF report and reproducible source bundle.
- Package versions are recorded in `renv.lock`; update it intentionally when dependencies change.

## Deliverables

- Written report: PDF, no more than 20 pages excluding appendices.
- Reproducible source: R Markdown and R scripts that run top-to-bottom without manual intervention.
- Presentation: 10 minutes.

See [TODO.md](TODO.md) for the complete requirement checklist and open decisions.
