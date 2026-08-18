# Five-workstream collaboration plan

The split below mirrors a five-person team while keeping every handoff explicit
and reproducible. File ownership is a coordination boundary, not proof that a
particular person completed the work; the group should confirm the final
authorship statement before submission.

| Workstream | Proposed owner | Primary files | Required handoff | Cross-review |
|---|---|---|---|---|
| P1 Exploratory Data Analysis | Nguyễn Đình Thiên Lộc (`24125093`) | `R/01_p1_data_prep.R`, `report/sections/01_exploratory_data_analysis.Rmd` | Validated variables, locked training population, distributions, pairwise relationships, and correlation findings | P2 verifies that EDA-driven cleaning choices use training data only |
| P2 Data Cleaning | Trần Lê Anh Tuấn (`24125107`) | `R/02_p2_eda_cleaning.R`, `report/sections/02_data_cleaning.Rmd` | Missing/duplicate/outlier decisions, preprocessing recipe, transformed matrices | P3 checks transformations and VIF inputs |
| P3 Feature Selection | Lê Minh Thuận (`24125105`) | `R/03_p3_feature_selection.R`, report section 3 | VIF/correlation screen, stepwise sensitivity check, Lasso interpretation, and baselines | P4 checks common folds and metric definitions |
| P4 Modelling with Regularization | Nguyễn Bảo Minh Triết (`24125047`) | `R/04_p4_regularized_models.R`, report section 4 | Fold-clean Ridge/Lasso/Elastic Net CV, coefficient paths, and pre-holdout model lock | P3 checks selected features; P5 checks lock order |
| P5 Evaluation | Nguyễn Hồng Tấn Tài (`24125078`) | `R/04_holdout.R`, report section 5 | RMSE/MAE/R2 comparison, diagnostics, bias--variance discussion, and reproducibility record | P1 verifies record-ID reconstruction; all review conclusions |

## Handoff sequence

```text
P1 validated training-only EDA
  -> P2 cleaning decisions and train-only recipe
    -> P3 baseline and screening
      -> P4 common-fold regularization + model lock
        -> P5 one-time holdout evaluation and integration
```

## Integration rules

1. Generated files are never hand-edited; change the owning R source and rerun.
2. All tables have both `.csv` and `.tex` forms; all figures are PDFs.
3. The same training folds are reused for all candidate models.
4. P1–P4 must not reconstruct or inspect holdout outcomes.
5. P5 reports every predeclared model, even if the locked model is not the
   observed holdout winner.
6. A second member reviews each workstream before the authorship statement is
   finalized.
