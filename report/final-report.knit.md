---
title: "STAT452 Final Project: Wine Quality and Experimental Design"
author:
  - "Tr\u1EA7n L\u00EA Anh Tu\u1EA5n (24125107)"
  - "Nguy\u1EC5n B\u1EA3o Minh Tri\u1EBFt (24125047)"
  - "Nguy\u1EC5n \u0110\u00ECnh Thi\u00EAn L\u1ED9c (24125093)"
  - "Nguy\u1EC5n H\u1ED3ng T\u1EA5n T\u00E0i (24125078)"
  - "L\u00EA Minh Thu\u1EADn (24125105)"
date: "Academic Year 2025--2026"
bibliography:
  - references.bib
  - ../finals/part1/report/references.bib
link-citations: true
output:
  pdf_document:
    latex_engine: xelatex
    number_sections: true
    toc: true
    toc_depth: 2
    fig_caption: true
    keep_tex: true
    includes:
      in_header: ../finals/part1/report/header.tex
fontsize: 10pt
geometry: margin=0.78in
---

\begin{abstract}
This report currently completes Part 1 of the Group 8 final project. We predict
red Vinho Verde quality from 11 physicochemical measurements with a locked,
leakage-controlled comparison of OLS, Ridge, Lasso, and Elastic Net. Part 2,
the separate experimental-design extension, remains explicitly pending.
\end{abstract}



# Part 1: Wine Quality (Red)


<!-- Section 1 owner: P1 — Nguyễn Đình Thiên Lộc -->

# Exploratory Data Analysis

## Dataset, variables, and prediction question

The UCI Wine Quality data describe red Portuguese Vinho Verde samples using 11
continuous physicochemical measurements and a sensory score supplied as the
median of at least three expert ratings [@Cortez2009; @UCIWine]. The response is
`quality`; the predictors cover acidity, sugar, chlorides, sulfur dioxide,
density, pH, sulphates, and alcohol. All predictors are numeric, and the detailed
data dictionary appears in Appendix A.

We model quality numerically because regression preserves its ordering and
avoids an arbitrary good/poor threshold. This assumes that a one-point change
has roughly comparable meaning across the observed 3--8 range. Gaussian
regression can produce fractional expected scores, so the interpretation is
prediction of expected expert score rather than exact ordinal classification.

After the integrity checks in Section 2, the unique records were divided by a
fixed quality-stratified 80/20 split. Every plot below uses only the
1088 training observations; the
271 holdout outcomes were not inspected.

## Response and predictor distributions

\includefigure{../output/figures/fig_p2_quality_distribution.pdf}{Training-set distribution of the sensory response. Scores 5 and 6 dominate, while the extremes contain few observations.}{fig:p2-quality}

The response is concentrated at 5 and 6. A mean-like prediction is therefore a
strong baseline, and error estimates for rare scores 3, 4, and 8 will be less
precise. This imbalance also foreshadows regression toward the center.

\includefigure{../output/figures/fig_p2_predictor_distributions.pdf}{Training-set predictor distributions before transformation. Several chemistry measures are strongly right-skewed.}{fig:p2-distributions}

Residual sugar, chlorides, sulfur-dioxide measures, and sulphates have long
right tails. These distributions motivate the transformations documented in
Section 2; EDA itself is shown on the original measurement scale.

## Pairwise relationships and correlation structure

\includefigure{../output/figures/fig_p2_correlation_heatmap.pdf}{Training-set Pearson correlations. Blocks among acidity, density, pH, and sulfur-dioxide measures motivate coefficient stabilization.}{fig:p2-correlation}

The strongest marginal response signals are
alcohol ($r=0.47$); volatile acidity ($r=-0.37$); sulphates ($r=0.23$); citric acid ($r=0.22$).
The heatmap also shows correlated predictor blocks, especially among acidity,
density, pH, and the two sulfur-dioxide measurements. That structure makes OLS
coefficients potentially unstable and directly motivates Ridge, Lasso, and
Elastic Net.

\includefigure{../output/figures/fig_p2_pairwise_quality.pdf}{The four strongest marginal predictor--quality relationships in training. Jitter reveals the discrete response; lines are descriptive OLS trends.}{fig:p2-pairwise}

Alcohol is positively associated with quality and volatile acidity negatively
associated, but every score overlaps substantially on every predictor. No
single physicochemical measurement is sufficient. These are predictive
associations, not causal effects, because grape variety, brand, vintage, price,
and production conditions are absent.


<!-- Section 2 owner: P2 — Trần Lê Anh Tuấn -->

# Data Cleaning

## Missingness, duplicates, and the locked split

The raw archive contains 1599 rows, 11 numeric
predictors, no missing cells, and no non-finite values. It also contains
240 exact duplicate records. Because the
archive provides no sample identifier, an exact repeat could be either a copied
row or a genuinely repeated batch. We conservatively keep the first copy and
remove the rest **before** splitting, preventing identical profiles and labels
from appearing in both training and holdout data. The limitation is that this
choice may underweight genuinely repeated batches.

\tightinputtable{../output/tables/tab_p1_data_audit.tex}

The fixed seed 4520803 produces a
quality-stratified 80/20 partition after deduplication. Seed
4520804 then assigns five stratified folds inside
training. The shared fold IDs are reused by every model.

\tightinputtable{../output/tables/tab_p1_split_summary.tex}

## Outliers and transformations

Tukey's 1.5-IQR rule flags 277 training
rows (25.5%).
Deleting all of them would discard a large and scientifically plausible part of
the target population; the dataset metadata also warns that rare wines are
expected. We therefore retain every row, winsorize each predictor at its
training 1st and 99th percentiles to limit leverage, and never clip the response.

\includefigure{../output/figures/fig_p2_outlier_audit.pdf}{Training observations flagged by the univariate Tukey-IQR rule. Flags are diagnosed and retained rather than deleted wholesale.}{fig:p2-outliers}

The training skewness rule selects
residual sugar, chlorides, free sulfur dioxide, total sulfur dioxide, sulphates
for `log1p` transformation. Median imputation is defined as a reproducibility
safeguard but is a no-op for this dataset. After winsorization and optional
`log1p`, all predictors are centered and scaled so penalty magnitudes are
comparable.

## Leakage control

All medians, winsorization limits, transformation choices, means, and standard
deviations are learned without holdout outcomes. During cross-validation, those
quantities are refit inside each analysis fold and applied to its validation
fold. The final recipe is fit once to all training predictors and then applied
unchanged to the predictor-only holdout file. This design prevents preprocessing
information from leaking backward into feature selection or tuning.


<!-- Owner: P3 — Lê Minh Thuận -->

# Feature Selection

## Screening without deleting correlated information

We use three training-only views of relevance: marginal correlations, variance
inflation factors (VIFs), and an AIC stepwise sensitivity analysis. The largest
VIF is 7.90 for
fixed acidity. This is material multicollinearity but
not evidence that the feature is useless: deleting one correlated chemistry
measure can make the retained coefficient depend arbitrarily on that choice.
Therefore all predictors enter Ridge, while sparse selection is delegated to
Lasso's embedded penalty.

\includefigure{../output/figures/fig_p3_feature_screening.pdf}{VIFs and full-OLS coefficients after the training-derived transformations. Coefficients are comparable because predictors are standardized.}{fig:p3-screening}

The AIC sensitivity model retains
7 of 11 predictors:
alcohol, volatile acidity, sulphates, chlorides, ph, total sulfur dioxide, free sulfur dioxide.
We do not promote this data-dependent subset directly to the holdout comparison;
it is a diagnostic against which to compare Lasso.

## Mean and OLS baselines

\tightinputtable{../output/tables/tab_p3_baseline_performance.tex}

The mean-only model establishes the no-chemistry benchmark. OLS lowers
cross-validated error, but correlated predictors allow coefficient variance.
Regularization deliberately accepts some training bias to reduce that variance.

## Embedded Lasso selection

At the one-standard-error penalty, Lasso retains
7 predictors:
alcohol, volatile acidity, sulphates, chlorides, ph, total sulfur dioxide, fixed acidity.
This is the required principled feature-selection result. The one-SE rule is
used for interpretation because it favors a stable sparse description; the
minimum-CV penalty remains the predeclared predictive fit.

\tightinputtable{../output/tables/tab_p4_lasso_selection.tex}

<!-- Owner: P4 — Nguyễn Bảo Minh Triết -->

# Modelling with Regularization

For standardized transformed predictors, all regularized candidates minimize

\[
\frac{1}{2n}\lVert \mathbf y-\beta_0-\mathbf X\boldsymbol\beta\rVert_2^2
+\lambda\left\{\alpha\lVert\boldsymbol\beta\rVert_1
+\frac{1-\alpha}{2}\lVert\boldsymbol\beta\rVert_2^2\right\}.
\]

Ridge uses $\alpha=0$ [@Hoerl1970], Lasso $\alpha=1$ [@Tibshirani1996],
and Elastic Net searches $\alpha\in\{0.25,0.50,0.75\}$ [@Zou2005]. For each
alpha, 120 decreasing $\lambda$ values from 100 to $10^{-4}$ use identical
folds. Coordinate-descent fits are produced with `glmnet` [@Friedman2010].

## Cross-validation and shrinkage

\includefigure{../output/figures/fig_p4_cv_curves.pdf}{Five-fold training CV curves with fold-specific preprocessing. Dashed lines minimize CV error; dotted lines apply the one-standard-error rule.}{fig:p4-cv}

Elastic Net selected $\alpha=0.75$. The
minimum-error and one-SE penalties, CV errors, and effective model sizes are
reported below. Ridge keeps all coefficients but continuously shrinks them;
Lasso and Elastic Net can set coefficients exactly to zero.

\tightinputtable{../output/tables/tab_p4_regularized_display.tex}

\includefigure{../output/figures/fig_p4_coefficient_paths.pdf}{Coefficient paths as regularization changes. The vertical line in each panel is the minimum-CV penalty used for prediction.}{fig:p4-paths}

As $\lambda$ grows, paths move toward zero. Lasso reaches exact zeros earliest;
Ridge shares weight among correlated measurements; Elastic Net interpolates.
This is the expected bias--variance mechanism rather than merely a software
choice.

## Pre-holdout decision

Before reconstructing any holdout outcome, we locked
**Lasso**, whose five-fold CV RMSE was
0.6712. This written lock prevents
choosing a preferred model after seeing test performance. All predeclared models
are nevertheless evaluated to make the comparison transparent.

<!-- Owner: P5 — Nguyễn Hồng Tấn Tài -->

# Evaluation

## Fair model comparison

\tightinputtable{../output/tables/tab_p5_holdout_display.tex}

On the same 271 rows, the pre-locked
Lasso obtained RMSE 0.614, MAE
0.482, and $R^2$ 0.439.
The observed lowest holdout RMSE belongs to **OLS**
(0.613). We retain the CV lock as the confirmatory
choice even if this ranking differs: selecting by the holdout would make its
error optimistic. The bootstrap intervals are wide enough that small ranking
differences should not be overinterpreted.

\includefigure{../output/figures/fig_p5_actual_vs_predicted.pdf}{Held-out predictions from the four fitted regression models. The diagonal denotes perfect prediction.}{fig:p5-predictions}

Predictions shrink toward the common scores 5--6, which lowers average error but
systematically misses rare extremes. This pattern follows from response
imbalance and squared-error fitting, not simply from regularization.

## Diagnostics and bias--variance trade-off

\includefigure{../output/figures/fig_p5_locked_residual_diagnostics.pdf}{Residual checks for the pre-locked model on the untouched holdout set. These diagnostics describe generalization and were not used to retune the model.}{fig:p5-residuals}

OLS has the least shrinkage and therefore the lowest regularization bias but the
greatest sensitivity to correlated predictors. Ridge reduces coefficient
variance without selection; Lasso trades additional bias for sparsity; Elastic
Net stabilizes groups of correlated features while retaining some selection.
The relevant empirical comparison is the gap among training, CV, and holdout
RMSE in Table \ref{tab:p5-holdout-display}. The regularized candidates have
similar held-out accuracy, so stability and interpretability matter more than a
small decimal-place difference.

## Limitations

1. Quality is ordinal and discrete; Gaussian regression treats adjacent scores
   as equally spaced and permits fractional predictions.
2. Rare scores 3, 4, and 8 yield imprecise tail performance, while the bootstrap
   quantifies only sampling variation in this holdout.
3. Exact deduplication prevents leakage but may remove genuinely repeated
   batches because the archive has no sample identifier.
4. Physicochemical measurements omit brand, vintage, grape variety, price, and
   production process; predictive associations are not causal effects.
5. Winsorization limits leverage and log transforms reduce skew, but alternative
   robust losses or ordinal models could change tail behavior.

## Conclusion

The full workflow meets the Part 1 objective: documented EDA and cleaning,
principled selection, a baseline plus three regularized models, shared-fold CV,
coefficient-path interpretation, and a single locked holdout evaluation.
Lasso is the confirmatory recommendation for expected-score
prediction under this design. Alcohol and volatile acidity provide the strongest
marginal signals, but correlated chemistry measurements and irreducible sensory
variation limit accuracy. A future extension should compare ordinal regression
or robust nonlinear models under the same locked resampling protocol.

\clearpage

# Part 2: Experimental-design extension

TODO: Select and justify the separate dataset; state hypotheses; complete the
two-factor ANOVA or \(2^k\) factorial analysis; check assumptions; report
interactions and post-hoc comparisons where justified; and interpret practical
significance and limitations.

# Contributions

TODO: Replace the workstream ownership plan with a statement of the work each
member actually completed and reviewed.


<!-- Integration appendix; generated artifacts are owned by P1–P5 -->

\clearpage
\appendix

# Detailed data documentation

\tightinputtable{../output/tables/tab_p1_data_dictionary.tex}

\begingroup\scriptsize\setlength{\tabcolsep}{2.5pt}
\input{../output/tables/tab_p2_descriptive_statistics.tex}
\endgroup

# Cleaning and outlier audit

\tightinputtable{../output/tables/tab_p2_outlier_audit.tex}

\begingroup\scriptsize\setlength{\tabcolsep}{2.5pt}
\input{../output/tables/tab_p2_transformation_plan.tex}
\endgroup

\includefigure{../output/figures/fig_p2_outlier_audit.pdf}{Training observations flagged by the univariate Tukey-IQR rule. Flags are diagnosed rather than deleted wholesale.}{fig:appendix-outliers}

# Supplementary selection and model tables

\begingroup\scriptsize\setlength{\tabcolsep}{2.5pt}
\input{../output/tables/tab_p3_feature_screening.tex}
\endgroup

\begingroup\scriptsize\setlength{\tabcolsep}{2.5pt}
\input{../output/tables/tab_p4_coefficient_comparison.tex}
\endgroup

\tightinputtable{../output/tables/tab_p4_enet_alpha_search.tex}

\tightinputtable{../output/tables/tab_p5_error_by_quality.tex}

# Reproducibility and collaboration

The canonical analysis is rebuilt from RStudio with
`source("analysis/00_run_all.R")`, or from a terminal with
`Rscript --vanilla analysis/00_run_all.R`. The five workstreams execute in
dependency order, every random operation uses a recorded seed, and
`output/artifact_manifest.csv` stores file sizes and MD5 checksums. Row-level
holdout outcomes are not serialized. Software versions for the verified run
are listed below; full `sessionInfo()` is in `output/logs/session_info.txt`.
The analysis and dynamic report use R, `knitr`, and `rmarkdown`
[@RCore2026; @XieKnitr2025; @AllaireRmarkdown2026].

\tightinputtable{../output/tables/tab_reproducibility_versions.tex}

The workstream allocation and review interfaces are documented in the
repository's collaboration work-split file. These organizational labels must be checked
against the members' actual contributions before final submission.

\newpage

# References {-}
