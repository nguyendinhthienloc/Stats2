# Part 2 five-person work split

Dataset discovery is excluded from this allocation. The plan starts after the
Student Performance file has been selected and placed in the immutable raw-data
directory. Ownership coordinates implementation, interpretation, and review;
it is not evidence of work completed and must be replaced by an honest final
contribution statement.

## Compensating workload allocation

The planning units below are relative coordination weights, not marks or hours.
Part 2 scope is deliberately inverse-weighted against the approximate Part 1
burden so that every member has a target total of 6.5 units.

| Member | Part 1 responsibility and planning units | Part 2 owned section | Part 2 units | Combined target |
|---|---:|---|---:|---:|
| Nguyen Dinh Thien Loc (`24125093`) | EDA plus project framework (4.0) | 1. Data audit, design justification, questions, hypotheses | 2.5 | 6.5 |
| Tran Le Anh Tuan (`24125107`) | Cleaning and preprocessing (3.0) | 2. Descriptive statistics and required visualizations | 3.5 | 6.5 |
| Le Minh Thuan (`24125105`) | Feature selection (3.5) | 3. Effect-coded factorial ANOVA and effect sizes | 3.0 | 6.5 |
| Nguyen Hong Tan Tai (`24125078`) | Held-out evaluation (3.5) | 4. Assumptions, diagnostics, Holm follow-up, HC3 sensitivity | 3.0 | 6.5 |
| Nguyen Bao Minh Triet (`24125047`) | Regularized modelling plus Part 1 integration (5.0) | 5. Concise practical conclusion, limitations, report integration | 1.5 | 6.5 |

The estimates make the compensation explicit. The final contribution statement
must describe actual work and may differ if the team redistributes tasks.

## Section contracts

### 1. Data audit and design

- Validate the 1,000-by-8 raw-file contract and immutable-source checksum.
- Preserve all valid rows and explain why no sampling is used.
- Lock mathematics score, test preparation, lunch, and the three hypotheses.
- Document observational provenance, sensitive-variable handling, and the
  no-causal-claims boundary.
- Handoff: processed data, audit, dictionary, hypotheses, and metadata.

### 2. Descriptive analysis

- Produce cell counts, means, medians, variance, standard deviations, quartiles,
  minima, and maxima.
- Produce the required histograms, boxplots, and interaction plot as PDFs.
- Identify imbalance and visual patterns without making significance claims.
- Handoff: report-ready descriptive tables and figures.

### 3. Factorial ANOVA

- Fit the full preparation-by-lunch model with sum-to-zero contrasts.
- Report marginal effects, interaction, confidence intervals, F tests, and
  partial eta-squared.
- Explain why effect-coded partial tests are used for unequal cell sizes.
- Handoff: saved model, ANOVA table, cell means, and effect estimates.

### 4. Diagnostics and follow-up

- Check residual shape, variance homogeneity, influence, and the limits of the
  independence assumption.
- Run Brown--Forsythe and graphical diagnostics.
- Report Holm-adjusted simple contrasts and explain why Tukey is redundant for
  a two-level factor.
- Run HC3 sensitivity and compare decisions.
- Handoff: diagnostics model object, tables, and diagnostic figure.

### 5. Interpretation and integration

- Separate statistical significance from score-point and partial-eta-squared
  practical significance.
- State non-causal conclusions, limitations, and an improved future design.
- Assemble the report-ready Part 2 summary and verify the root report wiring.
- Handoff: key-findings and limitations tables plus `part2_summary.RData`.

## Cross-review ring

| Owned section | Required second reviewer |
|---|---|
| 1 | Tran Le Anh Tuan |
| 2 | Le Minh Thuan |
| 3 | Nguyen Hong Tan Tai |
| 4 | Nguyen Bao Minh Triet |
| 5 | Nguyen Dinh Thien Loc |

Every reviewer checks code, generated artifacts, and the corresponding report
prose before sign-off. Run the complete canonical pipeline after all handoffs.

