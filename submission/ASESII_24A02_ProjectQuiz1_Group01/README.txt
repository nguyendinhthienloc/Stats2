========================================================================
ASESII 24A02 Project-Based Quiz 1 — Group 01 Replication Guide
========================================================================

This folder contains the self-contained R Markdown report and bibliographical
references for Group 01.

------------------------------------------------------------------------
Files Included
------------------------------------------------------------------------
1. Group01_ProjectQuiz1.Rmd : Self-contained R Markdown report containing
                              both analysis code and report text.
2. references.bib           : BibTeX file containing all citations.
3. Group01-ProjectQuiz1.pdf : Final compiled report PDF.
4. README.txt               : This instruction file.

------------------------------------------------------------------------
Reproduction Instructions
------------------------------------------------------------------------

To reproduce and render the report from a clean R session:

1. Ensure the following R packages are installed:
   - glmnet
   - knitr
   - rmarkdown (required to render Rmd)

2. Ensure a working LaTeX installation (e.g., MiKTeX or TeX Live) with 
   XeLaTeX is installed on your system.

3. Place the dataset `fat.csv` in a folder named `data/` in either the
   same directory as the Rmd file or one directory up (e.g., `./data/fat.csv`
   or `../data/fat.csv`).

4. Run the following command in your terminal/console from this directory
   to render the RMarkdown document to PDF:

   Rscript -e "rmarkdown::render('Group01_ProjectQuiz1.Rmd', output_file='Group01-ProjectQuiz1.pdf', output_format='pdf_document')"

   Or open `Group01_ProjectQuiz1.Rmd` in RStudio and click the "Knit" button.
