# Data

- `raw/source/wine-quality.zip` is the supplied immutable archive.
- `raw/wine_quality/winequality-red.csv` is the assigned Part 1 dataset.
- `raw/wine_quality/winequality-white.csv` and `winequality.names` are retained exactly as supplied for provenance; the white-wine data are not the assigned Part 1 dataset.
- `processed/` contains only reproducible derived files and is ignored except for its placeholder.

The Wine Quality CSV files use semicolons as delimiters and periods as decimal
marks. In base R, use `read.csv(..., sep = ";", dec = ".")`.
