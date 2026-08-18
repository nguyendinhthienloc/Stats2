# Part 1 integration checklist

- [ ] `R/00_run_all.R` succeeds from a clean output directory.
- [ ] Archive/data checksum and row counts match the report.
- [ ] Only red wine is analyzed.
- [ ] Exact duplicates are removed before the split.
- [ ] Holdout record IDs never occur in training.
- [ ] No file outside `R/04_holdout.R` contains or uses `y_test`.
- [ ] Every preprocessing quantity is learned from training data; CV refits it
      inside folds.
- [ ] Mean and OLS baselines plus Ridge, Lasso, and Elastic Net are reported.
- [ ] Regularized models share folds and lambda values.
- [ ] `output/model_lock.csv` predates holdout completion in pipeline order.
- [ ] RMSE, MAE, and R-squared use identical holdout rows for every model.
- [ ] Each important figure/table is interpreted in the report.
- [ ] Main report is at most 20 pages excluding appendix.
- [ ] Presentation is paced for approximately 10 minutes.
- [ ] Citations include the dataset paper and regularization methods.
- [ ] The actual members confirm the contribution statement.

