# Data

- `raw/source/wine-quality.zip` is the supplied immutable archive.
- `raw/wine_quality/winequality-red.csv` is the assigned Part 1 dataset.
- `raw/wine_quality/winequality-white.csv` and `winequality.names` are retained exactly as supplied for provenance; the white-wine data are not the assigned Part 1 dataset.
- `raw/student_performance/StudentsPerformance.csv` is the immutable public
  Student Performance source used for the Part 2 observational factorial
  analysis. Its SHA-256 is
  `ADE5869DBA8B2D3E2B96379359FB2F61CB0308E8394D9B1BA37E174CFE3BEE69`.
- `processed/` contains only reproducible derived files and is ignored except for its placeholder.

The Wine Quality CSV files use semicolons as delimiters and periods as decimal
marks. In base R, use `read.csv(..., sep = ";", dec = ".")`.
